'use strict'

const customersController = require('dev-portal-common/customers-controller')
const rh   =  require('dev-portal-common/responsehandler')

exports.handler = async (req, res) => {
    if(typeof req.pathParameters == "string")
        req['pathParameters'] = JSON.parse(req.pathParameters)
        let userPoolId = process.env.UserPoolId
        let userId = req.pathParameters.userId
        let user = await customersController.getAccountDetails(userId)
        let newApi = null
        if (user == null)
        {
            return rh.callbackRespondWithSimpleMessage(404,'Account does not exists')
        }
        const data = await new Promise((resolve, reject) => {customersController.getApiKeyForCustomer(userId, reject, resolve) });

        let apiKeyVal = data.items[0].id
        // Remove previous allocations of userId
        let usagePlanId = await new Promise((resolve, reject) => {customersController.getUsagePlansForCustomer(userId, reject, resolve) });

        if(usagePlanId.items.hasOwnProperty("id")) {
            usagePlanId = usagePlanId.items[0].id
            await new Promise((resolve, reject) => {customersController.unsubscribe(userId, usagePlanId, reject, resolve)})
            await customersController.deletePreviousApiKey(apiKeyVal)
            newApi = await customersController.renewApiKey(userId, userPoolId, true)
            await new Promise((resolve, reject) => { customersController.subscribe(userId, usagePlanId, reject, resolve) })
        }
        else {
            
            console.log("in unsubscribed user call")
            await customersController.deletePreviousApiKey(apiKeyVal)
            newApi = await customersController.renewApiKey(userId, userPoolId, true)
        }
        let response_body = {
            "user_api_details" :{
                "id":newApi.id,
                "name":newApi.name,
                "enabled":newApi.enabled
            }
        }
        return rh.callbackRespondWithJsonBody(200,response_body)
        }

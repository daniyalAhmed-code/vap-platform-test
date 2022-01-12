'use strict'

const util = require('dev-portal-common/util')
const customersController = require('dev-portal-common/customers-controller')
const rh   =  require('dev-portal-common/responsehandler')

exports.handler = async (req, res) => {
    if(typeof req.body == "string")
        req['body'] = JSON.parse(req.body)
    
    let stage = req.body.stage

    const cognitoIdentityId = util.getCognitoIdentityId(req)
    const userId = util.getCognitoUserId(req)
    
    console.log(`PUT /subscriptions for Cognito ID: ${cognitoIdentityId}`)
    const usagePlanId = req.pathParameters.usageplanId

    let cognitoId = `${cognitoIdentityId}/${userId}/${stage}`

    const catalog = await util.catalog()
    const catalogUsagePlan = util.getUsagePlanFromCatalog(usagePlanId, catalog)
    // const apiGatewayUsagePlan = await apigateway.getUsagePlan({ usagePlanId }).promise()
    console.log(`catalogUsagePlan: ${JSON.stringify(catalogUsagePlan, null, 2)}`)

    // the usage plan doesn't exist
    if (!catalogUsagePlan) {
        return rh.callbackRespondWithError(404,'Invalid Usage Plan ID')
        
        // the usage plan exists, but 0 of its apis are visible
    } else if (!catalogUsagePlan.apis.length) {
        return rh.callbackRespondWithError(404,'Invalid Usage Plan ID')
        // allow subscription if (the usage plan exists, at least 1 of its apis are visible)
    } else {
        const data = await new Promise((resolve, reject) => {
        customersController.subscribe(cognitoId, usagePlanId, reject, resolve)
        })
        
        return rh.callbackRespondWithJsonBody(200,data)
    }
}


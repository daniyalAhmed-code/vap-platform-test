'use strict'

const util = require('dev-portal-common/util')
const customersController = require('dev-portal-common/customers-controller')
const rh   =  require('dev-portal-common/responsehandler')

exports.handler = async (req, res) => {
        if(typeof req.queryStringParameters == "string")
          req['queryStringParameters'] = JSON.parse(req.queryStringParameters)
        
        let stage = req.queryStringParameters.stage
        const cognitoIdentityId = util.getCognitoIdentityId(req)
        const UserId = util.getCognitoUserId(req)
        
        console.log(`GET /subscriptions for Cognito ID: ${cognitoIdentityId}`)
        let cognitoId = `${cognitoIdentityId}/${UserId}/${stage}`
        
        const data = await new Promise((resolve, reject) => {
          customersController.getUsagePlansForCustomer(cognitoId, reject, resolve)
        })
        return rh.callbackRespondWithJsonBody(200,data.items)
 
}

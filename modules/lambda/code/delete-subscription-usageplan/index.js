'use strict'

const util = require('dev-portal-common/util')
const customersController = require('dev-portal-common/customers-controller')
const rh   =  require('dev-portal-common/responsehandler')

exports.handler = async (req, res) => {
  if(typeof req.pathParameters == "string")
    req['pathParameters'] = JSON.parse(req.pathParameters)      
  const cognitoIdentityId = util.getCognitoIdentityId(req)
      console.log(`DELETE /subscriptions for Cognito ID: ${cognitoIdentityId}`)
      const usagePlanId = req.pathParameters.usageplanId
    
      const catalog = await util.catalog()
      const usagePlan = util.getUsagePlanFromCatalog(usagePlanId, catalog)
    
      if (!usagePlan || !usagePlan.apis.length) {
        return rh.callbackRespondWithSimpleMessage(404,'Invalid Usage Plan ID')

      } else {
        const data = await new Promise((resolve, reject) => {
          customersController.unsubscribe(cognitoIdentityId, usagePlanId, reject, resolve)
        })
        return rh.callbackRespondWithJsonBody(200,data)
        
      }
}


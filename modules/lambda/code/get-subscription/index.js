'use strict'

const util = require('dev-portal-common/util')
const customersController = require('dev-portal-common/customers-controller')
const rh   =  require('dev-portal-common/responsehandler')

exports.handler = async (req, res) => {

        const cognitoIdentityId = util.getCognitoIdentityId(req)
        console.log(`GET /subscriptions for Cognito ID: ${cognitoIdentityId}`)
      
        const data = await new Promise((resolve, reject) => {
          customersController.getUsagePlansForCustomer(cognitoIdentityId, reject, resolve)
        })
        return rh.callbackRespondWithJsonBody(200,data.items)
 
}

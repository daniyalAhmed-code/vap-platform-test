'use strict'

const customersController = require('dev-portal-common/customers-controller')
const { promisify2 } = require('dev-portal-common/promisify2')
const util = require('dev-portal-common/util')
// this returns the key we use in the CustomersTable. It's constructed from the issuer field and the username when we
// allow multiple identity providers, this will allow google's example@example.com to be distinguishable from
// Cognito's or Facebook's example@example.com
// function getCognitoKey (req) {
//   return req.apiGateway.event.requestContext.authorizer.claims.iss + ' ' + getCognitoUsername(req)
// }
const rh   =  require('dev-portal-common/responsehandler')

exports.handler = async (req, res) => {
  console.log(req)
  if(typeof req.body == "string")
        req['body'] = JSON.parse(req.body)
  
  const cognitoIdentityId = util.getCognitoIdentityId(req)
  const cognitoUserId = util.getCognitoUserId(req)
  console.log(`POST /signin for identity ID [${cognitoIdentityId}]`)
  
  try {
      await promisify2(customersController.ensureCustomerItem)(
          cognitoIdentityId,
          cognitoUserId,
          'NO_API_KEY'
        )
        await customersController.ensureApiKeyForCustomer({
          userId: cognitoUserId,
          identityId: cognitoIdentityId
        })
      return rh.callbackRespondSimpleMessage(200,"Success")

  }
  catch (error) {
      console.log(`error: ${error}`)
    return rh.callbackRespondWithError(200,error)
  }
}    

'use strict'

const customersController = require('dev-portal-common/customers-controller')
const util = require('dev-portal-common/util')
const rh   =  require('dev-portal-common/responsehandler')

exports.handler = async (req, res) => {
  console.log(req)
  if(typeof req.queryStringParameters == "string")
    req['queryStringParameters'] = JSON.parse(req.queryStringParameters)    
  
  const cognitoIdentityId = util.getCognitoIdentityId(req)
  console.log(`GET /apikey for Cognito ID: ${cognitoIdentityId}`)
        
        const data = await new Promise((resolve, reject) => {
            customersController.getApiKeyForCustomer(cognitoIdentityId, reject, resolve)
          })
          if (data.items.length === 0) {
          return  rh.callbackRespondWithError(404,'No API Key for customer')
          } else {
            const item = data.items[0]
            const key = {
              id: item.id,
              value: item.value
            }
          return  rh.callbackRespondWithJsonBody(200,key)
         }
        }

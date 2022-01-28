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
const AWS = require('aws-sdk')

const rh   =  require('dev-portal-common/responsehandler')
const common = require('dev-portal-common/common')
exports.handler = async (req, res) => {
  let apis = {}

  if(typeof req.body == "string")
        req['body'] = JSON.parse(req.body)

  const cognitoIdentityId = util.getCognitoIdentityId(req)
  const cognitoUserId = util.getCognitoUserId(req)
  
  console.log(`POST /signin for identity ID [${cognitoIdentityId}]`)

  let stages = null
  await customersController.ensureCustomerItem(cognitoIdentityId,cognitoUserId)
  
  let userdetails = await customersController.getAccountDetails(cognitoIdentityId)
  
  if (userdetails.hasOwnProperty('ApiKeyId') && userdetails.ApiKeyId.stage[0].id == undefined){
      console.log("in if")
    let user_stage= []
    stages =     userdetails.ApiKeyId.stage
    for (let stage of stages){
       let apiKey = await customersController.ensureApiKeyForCustomer({
           userId: cognitoUserId,
           identityId: cognitoIdentityId,
           stage : stage
         })
         let user_stage_details = {
            "id" : apiKey.id,
            "Name": (stage.hasOwnProperty('name')) ? stage.name : stage.Name,
           "ApiKeyDuration":(stage.hasOwnProperty('apiKeyDuration')) ? stage.apiKeyDuration : stage.ApiKeyDuration,
           "KeyRotaionEnabled":(stage.hasOwnProperty('apiKeyDuration')) ? stage.keyRotation : stage.KeyRotaionEnabled,
           "CallbackAuthType":(stage.hasOwnProperty('type')) ? stage.type : stage.CallbackAuthType,
           "CallBackUrl":(stage.hasOwnProperty('CallBackUrl')) ? stage.CallBackUrl : stage.callBackUrl,
           "CallBackAuthARN":stage.CallBackAuthARN
        }
        user_stage.push(user_stage_details)
   }
     apis = {"stage":user_stage}
       let updateuser = await customersController.updateCustomerApiKeyId(cognitoIdentityId,apis)
  }
    
else if (userdetails.ApiKeyId == undefined)
  {   console.log("in else if")    
      let user_stage= []
       stages = [common.stages.alpha,common.stages.beta,common.stages.production]
       userdetails.ApiKeyId = {}
	    userdetails.ApiKeyId.stage = []
       for (let stage of stages){
       let apiKey = await customersController.ensureApiKeyForCustomer({
         userId: cognitoUserId,
         identityId: cognitoIdentityId,
           stage : stage
       })
       
       let user_stage_details = {
	             "id" : apiKey.id,
	              "name": stage,
            "apiKeyDuration":90,
            "keyRotation":false,
            "type":"none",
	            "CallBackAuthARN":"none",
	            "CallBackUrl":"none"
       }
       user_stage.push(user_stage_details)
       apis= {"stage":user_stage}
        let updateuser = await customersController.updateCustomerApiKeyId(cognitoIdentityId,apis)
  } 
}
else
    {   console.log("in else")
        return rh.callbackRespondWithSimpleMessage(200,"Success")
    }

//   let updateuser = await customersController.updateCustomerApiKeyId(cognitoIdentityId,apis)

    
  return rh.callbackRespondWithSimpleMessage(200,"Success")
  
}    

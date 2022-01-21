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
const dynamoDb = new AWS.DynamoDB.DocumentClient()

const rh   =  require('dev-portal-common/responsehandler')
const common = require('dev-portal-common/common')
exports.handler = async (req, res) => {
  let stages = [common.stages.alpha,common.stages.beta,common.stages.production]

  if(typeof req.body == "string")
        req['body'] = JSON.parse(req.body)

  const cognitoIdentityId = util.getCognitoIdentityId(req)
  const cognitoUserId = util.getCognitoUserId(req)
  console.log(`POST /signin for identity ID [${cognitoIdentityId}]`)
  await customersController.ensureCustomerItem(cognitoIdentityId,cognitoUserId)

  let userdetails = await customersController.getAccountDetails(cognitoIdentityId)
  let user_stage= []
  userdetails.ApiKeyId = {}
  userdetails.ApiKeyId.stage = []
  for (let stage of stages){
    try {
        let apiKey = await customersController.ensureApiKeyForCustomer({
            userId: cognitoUserId,
            identityId: cognitoIdentityId,
            stage : stage
          })

        let user_stage_details = {
            "name" : stage,
            "id" : apiKey.id
        }
        user_stage.push(user_stage_details)
    }
    catch (error) {
        console.log(`error: ${error}`)
      return rh.callbackRespondWithError(200,error)
    }
  }

  let apis = {"stage":user_stage}
  let updateuser = await customersController.updateCustomerApiKeyId(cognitoIdentityId,apis)

    
  return rh.callbackRespondWithSimpleMessage(200,"Success")
  
}
//@ts-check
'use strict'

const util = require('dev-portal-common/util')
const customersController = require('dev-portal-common/customers-controller')
const rh   =  require('dev-portal-common/responsehandler')

exports.handler = async (req, res) => {
  if(typeof req.pathParameters == "string")
    req['pathParameters'] = JSON.parse(req.pathParameters)
  
  const cognitoIdentityId = util.getCognitoIdentityId(req)
  console.log(`GET /subscriptions/:usagePlanId/usage for Cognito ID: ${cognitoIdentityId}`)
  const usagePlanId = req.pathParameters.usagePlanId

  const catalog = await util.catalog()
  const usagePlan = util.getUsagePlanFromCatalog(usagePlanId, catalog)

  // could error here if customer is not subscribed to usage plan, or save an extra request by just showing 0 usage
  if (!usagePlan) {

    return rh.callbackRespondWithError(404,'Invalid Usage Plan ID')

    
  } else {
    const data = await new Promise((resolve, reject) => {
      customersController.getApiKeyForCustomer(cognitoIdentityId, reject, resolve)
    })
    const keyId = data.items[0].id

    const params = {
      endDate: req.queryStringParameters.end,
      startDate: req.queryStringParameters.start,
      usagePlanId,
      keyId,
      limit: 1000
    }

    const usageData = await new Promise((resolve, reject) => {
      util.apigateway.getUsage(params, (err, data) => {
        if (err) reject(err)
        else resolve(data)
      })
    })
    return rh.callbackRespondWithJsonBody(200,usageData)
  }
}

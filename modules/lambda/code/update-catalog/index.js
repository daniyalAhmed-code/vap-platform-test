'use strict'

const hash = require('object-hash')
const { getAllUsagePlans } = require('dev-portal-common/get-all-usage-plans')
const util = require('dev-portal-common/util')
const nodeUtil = require('util')

const inspect = o => JSON.stringify(o, null, 2)
const rh   =  require('dev-portal-common/responsehandler')

// Let's try to minimize how many calls we make here.
const MAX_REST_API_LIMIT = 500



exports.handler = async (req, res) => {
  if(typeof req.body == "string")
        req['body'] = JSON.parse(req.body)
  console.log(`POST /admin/catalog/visibility for Cognito ID: ${util.getCognitoIdentityId(req)}`)

  // for apigateway managed APIs, provide "apiId_stageName"
  // in the apiKey field
  if (req.body && req.body.apiKey) {
    // try {
    const [restApiId, stageName] = req.body.apiKey.split('_')
    const swagger = await util.apigateway.getExport({
      restApiId,
      stageName,
      exportType: 'swagger',
      parameters: {
        extensions: 'apigateway'
      }
    }).promise()

    console.log('swagger: ', swagger.body)
    console.log('subscribable: ', req.body.subscribable)

    let file
    if (req.body.subscribable === 'true' || req.body.subscribable === true) {
      file = `catalog/${restApiId}_${stageName}.json`
    } else if (req.body.subscribable === 'false' || req.body.subscribable === false) {
      file = `catalog/unsubscribable_${restApiId}_${stageName}.json`
    } else {
      return rh.callbackRespondWithSimpleMessage(400,`Invalid input. Request body must have the 'subscribable' key`)
    }

    await uploadFile(file, swagger.body)
    return rh.callbackRespondWithSimpleMessage(200,`Success`)
    // }

    // for generic swagger, just provide the swagger body
  } else if (req.body && req.body.swagger) {
    let swaggerObject
    try {
      swaggerObject = JSON.parse(req.body.swagger)
      if (!(swaggerObject.info && swaggerObject.info.title)) {
        return rh.callbackRespondWithSimpleMessage(200,`Invalid input. API specification file must have a title`)
      }
    } catch (error) {
      return rh.callbackRespondWithSimpleMessage(400,`Invalid input. ${error.message}`)

    }

    await uploadFile(`catalog/${hash(swaggerObject)}.json`, Buffer.from(req.body.swagger))
    return rh.callbackRespondWithSimpleMessage(200,`Success`)
  } else {
    return rh.callbackRespondWithSimpleMessage(400,`Invalid Input`)

  }
}
  async function catalogUpdate () {
    console.log('awaiting catalog update')
  
    // This will end up invoked twice, but I'd like to be able to track how long it takes to
    // update. Ideally, I would also prevent executing the lambda from the S3 side as well, but
    // that's not as easy as it sounds.
    await util.lambda.invoke({
      FunctionName: process.env.CatalogUpdaterFunctionArn,
      // this API would be more performant if we moved to 'Event' invocations, but then we couldn't signal to
      // admins when the catalog updater failed to update the catalog; they'd see a 200 and then no change in
      // behavior.
      InvocationType: 'RequestResponse',
      LogType: 'None'
    }).promise()
  }
  
  async function uploadFile (file, body) {
    console.log('upload bucket: ', process.env.StaticBucketName)
    console.log('upload key: ', file)
    console.log('upload body length: ', body.byteLength)
    await util.s3.upload({ Bucket: process.env.StaticBucketName, Key: file, Body: body }).promise()
    await catalogUpdate()
  }

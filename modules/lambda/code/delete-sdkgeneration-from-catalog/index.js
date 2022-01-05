'use strict'

const util = require('dev-portal-common/util')

const rh   =  require('dev-portal-common/responsehandler')

exports.idempotentSdkGenerationUpdate = async (parity, id, res) => {
  const sdkGeneration =
    JSON.parse((await util.s3.getObject({
      Bucket: process.env.StaticBucketName,
      Key: 'sdkGeneration.json'
    }).promise()).Body)

  if (sdkGeneration[id] !== parity) {
    sdkGeneration[id] = parity

    await util.s3.upload({
      Bucket: process.env.StaticBucketName,
      Key: 'sdkGeneration.json',
      Body: JSON.stringify(sdkGeneration)
    }).promise()

    // call catalogUpdater to build a fresh catalog.json that includes changes from sdkGeneration.json
    await util.lambda.invoke({
      FunctionName: process.env.CatalogUpdaterFunctionArn,
      // this API would be more performant if we moved to 'Event' invocations, but then we couldn't signal to
      // admins when the catalog updater failed to update the catalog; they'd see a 200 and then no change in
      // behavior.
      InvocationType: 'RequestResponse',
      LogType: 'None'
    }).promise()
    return rh.callbackRespondWithSimpleMessage(200,'Success')
  } else {
    return rh.callbackRespondWithSimpleMessage(200,'Success')

  }
}




exports.handler = async (req, res) => {
  if(typeof req.pathParameters == "string")
    req['pathParameters'] = JSON.parse(req.pathParameters)
  console.log(`DELETE /admin/catalog/${req.pathParameters.id}/sdkGeneration for Cognito ID: ${util.getCognitoIdentityId(req)}`)

  await exports.idempotentSdkGenerationUpdate(false, req.pathParameters.id, res)
  return rh.callbackRespondWithSimpleMessage(200,'Success')
  }


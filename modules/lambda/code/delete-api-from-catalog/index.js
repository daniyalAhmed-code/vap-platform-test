'use strict'

const util = require('dev-portal-common/util')
const rh   =  require('dev-portal-common/responsehandler')

// Let's try to minimize how many calls we make here.


exports.handler = async (req, res) => {
        console.log(`DELETE /admin/catalog/visibility for Cognito ID: ${util.getCognitoIdentityId(req)}`)
        if(typeof req.pathParameters == "string")
          req['pathParameters'] = JSON.parse(req.pathParameters)
        // for apigateway managed APIs, provide "apiId_stageName"
        // in the apiKey field
        console.log('delete request params:', req.pathParameters)
        if (req.pathParameters && req.pathParameters.id) {
          if (!req.pathParameters.id.includes('_')) {
            return rh.callbackRespondWithSimpleMessage(400,'Invalid input')
             }
      
          console.log('managed api')
      
          // We assume it's JSON - users shouldn't be modifying this directly. However, we can't assume
          // it's still unsubscribable as if the API is attached to a usage plan, that ends up out of
          // sync with our catalog. In this case, we just try to delete both, as it's easier and faster
          // than checking whether it *is* subscribable.
          await deleteFile(`catalog/unsubscribable_${req.pathParameters.id}.json`)
          await deleteFile(`catalog/${req.pathParameters.id}.json`)
          return rh.callbackRespondWithSimpleMessage(200,'Success')
          // for generic swagger, provide the hashed swagger body
          // in the id field
        } else if (req.pathParameters && req.pathParameters.genericId) {
          console.log('generic api')
          await deleteFile(`catalog/${req.pathParameters.genericId}.json`)
          return rh.callbackRespondWithSimpleMessage(200,'Success')
          
        } else {
          return rh.callbackRespondWithSimpleMessage(400,'Invalid input')

        }
      }


    
async function deleteFile (file) {
    console.log('remove bucket: ', process.env.StaticBucketName)
    console.log('remove key: ', file)
    await util.s3.deleteObject({ Bucket: process.env.StaticBucketName, Key: file }).promise()
    await catalogUpdate()
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

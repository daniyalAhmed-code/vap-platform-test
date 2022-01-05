'use strict'
//@ts-check
const util = require('dev-portal-common/util')
const rh   =  require('dev-portal-common/responsehandler')

exports.handler = async (req, res) => {
  if(typeof req.pathParameters == "string")
    req['pathParameters'] = JSON.parse(req.pathParameters)
  console.log(`DELETE /admin/catalog/visibility for Cognito ID: ${util.getCognitoIdentityId(req)}`)

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
 
'use strict'

const util = require('dev-portal-common/util')

const rh   =  require('dev-portal-common/responsehandler')


exports.handler = async (req, res) => {
    if(typeof req.pathParameters == "string")
        req['pathParameters'] = JSON.parse(req.pathParameters)
    console.log(`PUT /admin/catalog/${req.pathParameters.id}/sdkGeneration for Cognito ID: ${util.getCognitoIdentityId(req)}`)

    await exports.idempotentSdkGenerationUpdate(true, req.pathParameters.id, res)
    return rh.callbackRespondWithSimpleMessage(200,'Success')
  }

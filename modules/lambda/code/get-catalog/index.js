'use strict'
const rh   =  require('dev-portal-common/responsehandler')

const util = require('dev-portal-common/util')
exports.handler = async (req, res) => {

        console.log(`GET /catalog for Cognito ID: ${util.getCognitoIdentityId(req)}`)
        const catalog = await util.catalog()
        return rh.callbackRespondWithJsonBody(200,catalog)
     }

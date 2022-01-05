'use strict'

const customersController = require('dev-portal-common/customers-controller')
const rh   =  require('dev-portal-common/responsehandler')

exports.handler = async (req, res) => {

        console.log('GET /admin/accounts/:userId')
        let user = await customersController.getAccountDetails(req.requestContext.authorizer.cognitoIdentityId)
        if (user == null)
        {
            return rh.callbackRespondWithSimpleMessage(400,'Account does not exists')

        }
        return rh.callbackRespondWithJsonBody(200,user)

        }

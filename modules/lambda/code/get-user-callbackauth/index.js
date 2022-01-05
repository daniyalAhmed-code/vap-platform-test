'use strict'

const customersController = require('dev-portal-common/customers-controller')
const rh   =  require('dev-portal-common/responsehandler')

exports.handler = async (req, res) => {
    if(typeof req.body == "string")
        req['body'] = JSON.parse(req.body)
    console.log(req)
    console.log('GET /admin/accounts/callbackauth/:userId')
    
    let userId = req.pathParameters.userId
    let user_details = await customersController.getAccountDetails(userId)

    if (user_details == null) {
        return rh.callbackRespondWithSimpleMessage(404,'Account doesnot Exists')
    }
    let secret_details = await customersController.getSecretDetails(user_details.CallBackAuthARN)
    let body ={
        "secret_details" :secret_details
    }    
    return rh.callbackRespondWithJsonBody(200,body)
}

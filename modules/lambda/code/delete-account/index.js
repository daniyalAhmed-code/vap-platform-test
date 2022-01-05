//@ts-check
'use strict'

const customersController = require('dev-portal-common/customers-controller')
const util = require('dev-portal-common/util')
const Joi = require('joi');
const rh   =  require('dev-portal-common/responsehandler')

exports.handler = async (req, res) => {
  console.log('DELETE /admin/accounts/:userId')
  if(typeof req.pathParameters == "string")
    req['pathParameters'] = JSON.parse(req.pathParameters)
  
    const userId = req.pathParameters.userId
  if (typeof userId !== 'string' || userId === '') {
    return rh.callbackRespondWithSimpleMessage(400,'Invalid value for "userId" URL parameter.')
    
  }

  if (util.getCognitoUserId(req) === userId) {
    return rh.callbackRespondWithSimpleMessage(400,'Invalid value for "userId" URL parameter: cannot delete yourself.')
    }

  await customersController.deleteAccountByUserId(userId)
  return rh.callbackRespondWithSimpleMessage(200,'User Has been deleted')
 
}

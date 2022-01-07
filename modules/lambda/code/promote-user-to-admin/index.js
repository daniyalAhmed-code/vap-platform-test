'use strict'

const customersController = require('dev-portal-common/customers-controller')
const AWS = require('aws-sdk')
const util = require('dev-portal-common/util')

const rh   =  require('dev-portal-common/responsehandler')

exports.handler = async (req, res) => {
  
  if(typeof req.pathParameters == "string")
    req['pathParameters'] = JSON.parse(req.pathParameters)
  
  const userId = req.pathParameters.userId
  if (!(typeof userId === 'string' && userId.length > 0)) {
      return rh.callbackRespondWithSimpleMessage(404, 'user not found')
  }

  try {
    const promoterUserId = util.getCognitoUserId(req)
    await customersController.addAccountToAdminsGroup({
      targetUserId: userId,
      promoterUserSub: util.getCognitoIdentitySub(req),
      promoterUserId
    })
    return rh.callbackRespondWithSimpleMessage(200,'success')
  } catch (error) {
    console.log('Error:', error)
    return rh.callbackRespondWithSimpleMessage(500,'Internal server error')

  }
}

//@ts-check
'use strict'

const customersController = require('dev-portal-common/customers-controller')
const util = require('dev-portal-common/util')
const Joi = require('joi');
const rh   =  require('dev-portal-common/responsehandler')

exports.handler = async (req, res) => {


      let UserPoolId = ""
      if(typeof req.pathParameters == "string")
        req['pathParameters'] = JSON.parse(req.pathParameters)

        let userId =req.pathParameters.id    
        let user_details = await customersController.getAccountDetails(userId)
  
        if (user_details == null) {
          return rh.callbackRespondWithSimpleMessage(404,'Account does not exists')
  
        }
      UserPoolId = `${process.env.MNO_UserPoolId}`
      const preLoginAccount = await customersController.deleteResource(
        UserPoolId,
        userId      
      )
      return rh.callbackRespondWithJsonBody(200,preLoginAccount)
    }   

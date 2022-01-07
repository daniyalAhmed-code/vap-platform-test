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
      UserPoolId = `${process.env.Third_Party_UserPoolId}`
      let userid =        req.pathParameters.id       
      const preLoginAccount = await customersController.deleteResource(
        UserPoolId,
        userid
      )
      return rh.callbackRespondWithJsonBody(200,preLoginAccount)
    }   

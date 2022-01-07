//@ts-check
'use strict'

const customersController = require('dev-portal-common/customers-controller')
const util = require('dev-portal-common/util')
const Joi = require('joi');
const rh   =  require('dev-portal-common/responsehandler')

exports.handler = async (req, res) => {
  if(typeof req.queryStringParameters == "string")
        req['queryStringParameters'] = JSON.parse(req.queryStringParameters)    
      let listResourceUsers = await customersController.getResourceUsers("Mno")
      if (listResourceUsers.Count == 0 )
        return rh.callbackRespondWithError(400,"No User for  Found")

      return rh.callbackRespondWithJsonBody(200,listResourceUsers)
    }   

'use strict'

const customersController = require('dev-portal-common/customers-controller')
const util = require('dev-portal-common/util')
const Joi = require('joi');
const AWS = require('aws-sdk')
const rh   =  require('dev-portal-common/responsehandler')

exports.handler = async (req, res) => {    
  if(typeof req.pathParameters == "string")
        req['pathParameters'] = JSON.parse(req.pathParameters)    
      console.log('GET /admin/accounts/:ResourceId')
      let ResourceId = req.pathParameters.id
      let user_details = await customersController.getResourceUser(ResourceId,"Mno")
  
      if (user_details == null) {
        return rh.callbackRespondWithSimpleMessage(404,'Account does not exists')

      }
      return rh.callbackRespondWithJsonBody(200,user_details)

    }

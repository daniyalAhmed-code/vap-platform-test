//@ts-check
'use strict'

const customersController = require('dev-portal-common/customers-controller')
const util = require('dev-portal-common/util')
const Joi = require('joi');
const rh   =  require('dev-portal-common/responsehandler')

exports.handler = async (req, res) => {
  if(typeof req.pathParameters == "string")
        req['pathParameters'] = JSON.parse(req.pathParameters)    
      let resourceId = req.pathParameters.id
      let get_single_resource = await customersController.getResourceById(resourceId)
      if (get_single_resource.Count == 0 )
        return rh.callbackRespondWithError(400,"No resource Found")

      return rh.callbackRespondWithJsonBody(200,get_single_resource.Items)
    }   

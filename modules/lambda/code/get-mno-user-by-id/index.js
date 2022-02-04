'use strict'

const customersController = require('dev-portal-common/customers-controller')
const util = require('dev-portal-common/util')
const Joi = require('joi');
const AWS = require('aws-sdk')
const rh   =  require('dev-portal-common/responsehandler')
const dynamoDb = new AWS.DynamoDB.DocumentClient()

exports.handler = async (req, res) => {    
  if(typeof req.pathParameters == "string")
        req['pathParameters'] = JSON.parse(req.pathParameters)    
      
      let ResourceId = req.pathParameters.id
      let user_details = await customersController.getResourceUser(ResourceId,"Mno")
  
      if (user_details == null) {
        return rh.callbackRespondWithSimpleMessage(404,'Account does not exists')

      }
      let client_id = user_details.Items[0].ClientId
      
      let user_mno_details = await customersController.getResourceUserMno(client_id)
      let mno_loction = user_mno_details.Items[0].ClientName.split(" ").slice(-1).pop()
      
      user_details.Items[0]['MnoLocation'] = mno_loction
      
      return rh.callbackRespondWithJsonBody(200,user_details)

    }

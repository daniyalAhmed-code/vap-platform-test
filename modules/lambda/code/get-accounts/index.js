'use strict'

const customersController = require('dev-portal-common/customers-controller')
const util = require('dev-portal-common/util')
const Joi = require('joi');
const AWS = require('aws-sdk')
const rh   =  require('dev-portal-common/responsehandler')

exports.handler = async (req, res) => {
      console.log('GET /admin/accounts')
      if(typeof req.queryStringParameters == "string")
        req['queryStringParameters'] = JSON.parse(req.queryStringParameters)    
      let accounts
    
      switch (req.queryStringParameters.filter) {
        // Not implemented yet
        // case 'pendingRequest': accounts = await customersController.listPendingRequestAccounts(); break
        case 'pendingInvite':
          accounts = await customersController.listPendingInviteAccounts();
          break
        case 'admin':
          accounts = await customersController.listAdminAccounts();
          break
        case 'registered':
          accounts = await customersController.listRegisteredAccounts();
          break
        default:
          return rh.callbackRespondWithSimpleMessage(400,'Invalid value for "filter" query parameter.')
      }
      let response = {
        "accounts" : accounts
      }

      return rh.callbackRespondWithJsonBody(200,response)
    }   

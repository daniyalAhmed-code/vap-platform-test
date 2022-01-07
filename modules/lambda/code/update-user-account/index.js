//@ts-check
'use strict'

const customersController = require('dev-portal-common/customers-controller')
const util = require('dev-portal-common/util')
const Joi = require('joi');
const rh   =  require('dev-portal-common/responsehandler')

exports.handler = async (req, res) => {

      const schema = Joi.object().keys({
    FirstName: Joi.string().regex(/^(?=.{3,50}$)[a-zA-Z]+(?:['_.\s][a-z]+)*$/).required().messages({
      'string.base': `"first name" should be a type of 'text'`,
      'string.empty': `"first name" cannot be an empty field`,
      'string.pattern.base': "first name cannot have space in between",
      'string.min': `"first name" should have a minimum length of 3`,
      'any.required': `"first name" is a required field`
    }),

    LastName: Joi.string().regex(/^(?=.{1,50}$)[a-zA-Z]+(?:['_.\s][a-z]+)*$/).required().messages({
      'string.base': `"last name" should be a type of 'text'`,
      'string.empty': `"last name" cannot be an empty field`,
      'string.min': `"last name" should have a minimum length of 3`,
      'string.pattern.base': "last name cannot have space in between",
      'any.required': `"last name" is a required field`
    }),
    CallbackAuthType: Joi.string().valid("apiKey","basicAuth","privateCertificate"),
    Mfa: Joi.boolean().required(),
    KeyRotationEnabled: Joi.boolean().default(false),
    CallBackUrl: Joi.string().required().messages({
      'string.empty': `"callback url" cannot be an empty field`
    }),
    isValidateCallBackAuth:Joi.boolean().default(true),
    CallBackAuth: Joi.when('CallbackAuthType', {is : "apiKey", then: Joi.string().required()})
    .when('CallbackAuthType', {is : "basicAuth", then: Joi.object().keys({username:Joi.string().required(),password:Joi.string().required()})})
    .when('CallbackAuthType', {is : "privateCertificate", then: Joi.string().required()})
    .when("isValidateCallBackAuth", {is : false, then: Joi.string().optional()}),

    Mno: Joi.string().required(),
    MnoLocation: Joi.string().required(),
    ApiKeyDuration: Joi.number().min(1).max(90).required().messages({
      'number.min': `"api duration key" cannot be less than 1`,
      'number.max': "api key duration cannot be greater than 90",
    })
  });

  if(typeof req.body == "string")
    req['body'] = JSON.parse(req.body)

    if(typeof req.pathParameters == "string")
    req['pathParameters'] = JSON.parse(req.pathParameters)
  
  let userId = req.pathParameters.userId
  
  if (typeof userId !== 'string' || userId === '') {
    res.status(400).json({
      message: 'Invalid value for "userId" URL parameter.'
    })
    return
  }
  let data = await customersController.getAccountDetails(userId)
  if (data == null) {
    return res.status(404).json({
      message: "Account doesnot Exists"
    })
  }
  
  if(!req.body.hasOwnProperty('KeyRotationEnabled'))
  {
    req.body.KeyRotationEnabled = false
  }
  
  if (!req.body.CallBackAuth) {
    req.body.isValidateCallBackAuth = false
    req.body.CallBackAuth = "NONE"
  }
  
  let body = await schema.validate(req.body);
  if ('error' in body) {
    res.status(400).json({
      message: body.error.details[0].message
    })
    return
  }

  body = Object.assign(data, body.value)

  const updateAccount = await customersController.updateAccountDetails(
    userId,
    data.CallBackAuthARN,
    body
  )
      
      return rh.callbackRespondWithJsonBody(200,updateAccount)
    }   

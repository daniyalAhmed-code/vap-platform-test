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
    Mfa: Joi.boolean().required(),
    ApiKeyId: Joi.object().keys({
      stage:Joi.array().items(Joi.object().keys({
        Name:Joi.string().valid("alpha","beta","production"),
      KeyRotationEnabled:Joi.boolean().default(false),
      CallBackUrl:Joi.string().required().messages({
        'string.empty': `"callback url" cannot be an empty field`
      }),
      CallbackAuthType: Joi.string().valid("apiKey","basicAuth","privateCertificate"),
      CallBackAuth: Joi.when('CallbackAuthType', {is : "apiKey", then: Joi.string().required()})
    .when('CallbackAuthType', {is : "basicAuth", then: Joi.object().keys({username:Joi.string().required(),password:Joi.string().required()})})
    .when('CallbackAuthType', {is : "privateCertificate", then: Joi.string().required()})
    .when("isValidateCallBackAuth", {is : false, then: Joi.string().optional()}),
    isValidateCallBackAuth:Joi.boolean().default(true),
    ApiKeyDuration: Joi.number().min(1).max(90).required().messages({
      'number.min': `"api duration key" cannot be less than 1`,
      'number.max': "api key duration cannot be greater than 90",
    }),
    CallBackAuthARN:Joi.string()
    }),           
    )}),
       
  });


  if(typeof req.body == "string")
    req['body'] = JSON.parse(req.body)

  if(typeof req.pathParameters == "string")
    req['pathParameters'] = JSON.parse(req.pathParameters)

  let userId = req.pathParameters.userId
  
  if (typeof userId !== 'string' || userId === '')
    return rh.callbackRespondWithError(400,'Invalid value for "userId" URL parameter.')

 
  let data = await customersController.getAccountDetails(userId)
  
  if (data == null)
    return rh.callbackRespondWithError(404,'Account does not Exists')
  
  for(let stage of req.body.ApiKeyId.stage){

  if (!stage.CallBackAuth)
    stage.CallBackAuth = "NONE"

  if(stage.hasOwnProperty('KeyRotationEnabled'))
    stage.KeyRotationEnabled = false


  
}  
  let body = await schema.validate(req.body);
  if ('error' in body) 
    return rh.callbackRespondWithError(400,body.error.details[0].message)

  body = Object.assign(data, body.value)
    
  const updateAccount = await customersController.updateAccountDetails(
    userId,
    body.ApiKeyId.stage,
    body
  )
      
  return rh.callbackRespondWithJsonBody(200,updateAccount)
}   

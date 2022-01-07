//@ts-check
'use strict'

const customersController = require('dev-portal-common/customers-controller')
const util = require('dev-portal-common/util')
const Joi = require('joi');
const rh   =  require('dev-portal-common/responsehandler')

exports.handler = async (req, res) => {

      const schema = Joi.object().keys({
        targetFirstName: Joi.string().regex(/^(?=.{3,50}$)[a-zA-Z]+(?:['_.\s][a-z]+)*$/).required().messages({
          'string.base': `"first name" should be a type of 'text'`,
          'string.empty': `"first name" cannot be an empty field`,
          'string.pattern.base': "first name cannot have space in between",
          'string.min': `"first name" should have a minimum length of 3`,
          'any.required': `"first name" is a required field`
        }),
    
        targetLastName: Joi.string().regex(/^(?=.{1,50}$)[a-zA-Z]+(?:['_.\s][a-z]+)*$/).required().messages({
          'string.base': `"last name" should be a type of 'text'`,
          'string.empty': `"last name" cannot be an empty field`,
          'string.min': `"last name" should have a minimum length of 3`,
          'string.pattern.base': "last name cannot have space in between",
          'any.required': `"last name" is a required field`
        }),
    
        targetPhoneNumber: Joi.string().regex(/^[\+]?[0-9]{3}[0-9]{3}[-\s\.]?[0-9]{4,6}$/).required().messages({
          'string.base': `"phone number" should be a type of 'text'`,
          'string.empty': `"phone number" cannot be an empty field`,
          'string.min': `"phone number" should have a minimum length of 9`,
          'string.pattern.base': "valid patterns are +31636363634",
          'any.required': `"phone number" is a required field`
        }),
        targetKeyRotationEnabled: Joi.boolean().default(false),
        targetMfa: Joi.boolean().required(),
        
        targetCallBackUrl: Joi.string().required().messages({
          'string.empty': `"callback url" cannot be an empty field`
        }),
        type: Joi.string().valid("apiKey","basicAuth","privateCertificate"),
        targetCallBackAuth: Joi.when('type', {is : "apiKey", then: Joi.string().required()})
        .when('type', {is : "basicAuth", then: Joi.object().keys({username:Joi.string().required(),password:Joi.string().required()})})
        .when('type', {is : "privateCertificate", then: Joi.string().required()}),
        targetMno: Joi.string().required(),
        targetMnoLocation: Joi.string().required(),
        targetApiKeyDuration: Joi.number().min(1).max(90).required().messages({
          'number.min': `"api duration key" cannot be less than 1`,
          'number.max': "api key duration cannot be greater than 90",
        }),
        targetEmailAddress: Joi.string().email().required().messages({
          'string.empty': `"email" cannot be an empty field`
        })
      });
    
    
      const inviterUserId = util.getCognitoIdentityId(req)
      console.log(`POST /admin/accounts for Cognito ID: ${inviterUserId}`)
    
      console.log(JSON.stringify(req, null, 2))
      
      if(typeof req.body == "string")
        req['body'] = JSON.parse(req.body)

      const {
        type,
        targetEmailAddress,
        targetPhoneNumber,
        targetFirstName,
        targetLastName,
        targetApiKeyDuration,
        targetMnoLocation,
        targetCallBackAuth,
        targetMno,
        targetMfa,
        targetKeyRotationEnabled,
        targetCallBackUrl
      } = req.body
      let body = await schema.validate(req.body);
      console.log(body.error)
    
      if ('error' in body) {
        return rh.callbackRespondWithSimpleMessage(400,body.error.details[0].message)
              }
    
      if (typeof targetEmailAddress !== 'string' || targetEmailAddress === '') {
        return rh.callbackRespondWithSimpleMessage(400,body.error.details[0].message)

      }

    
      const preLoginAccount = await customersController.createAccountInvite({
        type,
        targetEmailAddress,
        targetPhoneNumber,
        targetFirstName,
        targetLastName,
        targetApiKeyDuration,
        targetMnoLocation,
        targetCallBackAuth,
        targetMno,
        targetMfa,
        targetKeyRotationEnabled,
        targetCallBackUrl,
        inviterUserSub: util.getCognitoIdentitySub(req),
        inviterUserId
      })
      return rh.callbackRespondWithJsonBody(200,preLoginAccount)
    }   

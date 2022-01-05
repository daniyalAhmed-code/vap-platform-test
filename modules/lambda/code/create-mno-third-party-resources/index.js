//@ts-check
'use strict'

const customersController = require('dev-portal-common/customers-controller')
const util = require('dev-portal-common/util')
const Joi = require('joi');
const rh   =  require('dev-portal-common/responsehandler')

exports.handler = async (req, res) => {

      const schema = Joi.object().keys({
        ResourceName: Joi.string().regex(/^(?=.{3,50}$)[a-zA-Z]+(?:['_.\s][a-z]+)*$/).required().messages({
          'string.base': `"first name" should be a type of 'text'`,
          'string.empty': `"first name" cannot be an empty field`,
          'string.pattern.base': "first name cannot have space in between",
          'string.min': `"first name" should have a minimum length of 3`,
          'any.required': `"Resource name" is a required field`
        }),
        ResourceType: Joi.string().valid("Mno","ThirdParty"),
        EmailAddress: Joi.string().email().required().messages({
          'string.empty': `"email" cannot be an empty field`
        }),
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
    
        PhoneNumber: Joi.string().regex(/^[\+]?[0-9]{3}[0-9]{3}[-\s\.]?[0-9]{4,6}$/).required().messages({
          'string.base': `"phone number" should be a type of 'text'`,
          'string.empty': `"phone number" cannot be an empty field`,
          'string.min': `"phone number" should have a minimum length of 9`,
          'string.pattern.base': "valid patterns are (123) 456-7890,(123)456-7890,123-456-7890,123.456.7890,1234567890,+31636363634,075-63546725",
          'any.required': `"phone number" is a required field`
        }),
      });
    
    
      const inviterUserId = util.getCognitoIdentityId(req)
      console.log(`POST /admin/accounts for Cognito ID: ${inviterUserId}`)
    
      console.log(JSON.stringify(req, null, 2))
      
      if(typeof req.body == "string")
        req['body'] = JSON.parse(req.body)

      const {
        ResourceName,
        ResourceType,
        ResourceDetails,
        FirstName,
        LastName,
        PhoneNumber,
        EmailAddress
       
      } = req.body
      let body = await schema.validate(req.body);
      console.log(body.error)
    
      if ('error' in body) {
        return rh.callbackRespondWithSimpleMessage(400,'Invalid value for "targetEmailAddress" parameter.')
              }
    
      if (typeof ResourceType !== 'string' || ResourceType === '') {
        return rh.callbackRespondWithSimpleMessage(400,body.error.details[0].message)

      }
      let UserPoolId = `${process.env.UserPoolId}`
    
      const preLoginAccount = await customersController.createResourceDetails(
        ResourceName,
        ResourceType,
        ResourceDetails,
        UserPoolId,
        EmailAddress,
        PhoneNumber,
        FirstName,
        LastName,
        
      )
      return rh.callbackRespondWithJsonBody(200,preLoginAccount)
    }   

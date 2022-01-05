//@ts-check
'use strict'

const customersController = require('dev-portal-common/customers-controller')
const util = require('../../util')
const Joi = require('joi');
const AWS = require('aws-sdk')
const S3 = new AWS.S3();

exports.get = async (req, res) => {
  console.log('GET /admin/accounts')

  let accounts

  switch (req.query.filter) {
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
      res.status(400).json({
        message: 'Invalid value for "filter" query parameter.'
      })
      return
  }

  res.status(200).json({
    accounts
  })
}

exports.get_by_id = async (req, res) => {
    console.log('GET /admin/accounts/:userId')
    let userId = req.params.userId
    let user_details = await customersController.getAccountDetails(userId)

    if (user_details == null) {
        return res.status(404).json({
        message: "Account doesnot Exists"
        })
    }
    return res.status(200).json({
        "user_details" :user_details
    })
  }
  
  
exports.get_callback_auth_by_user_id = async (req, res) => {
    console.log('GET /admin/accounts/callbackauth/:userId')
    let userId = req.params.userId
    let user_details = await customersController.getAccountDetails(userId)

    if (user_details == null) {
        return res.status(404).json({
        message: "Account doesnot Exists"
        })
    }
    let secret_details = await customersController.getSecretDetails(user_details.CallBackAuthARN)
    return res.status(200).json({
        "secret_details" :secret_details
    })
  } 

exports.post = async (req, res) => {
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
      'string.pattern.base': "valid patterns are (123) 456-7890,(123)456-7890,123-456-7890,123.456.7890,1234567890,+31636363634,075-63546725",
      'any.required': `"phone number" is a required field`
    }),
    targetKeyRotationEnabled: Joi.boolean(),
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

  console.log(JSON.stringify(req.apiGateway.event, null, 2))

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
    res.status(400).json({
      message: body.error.details[0].message
    })
    return
  }

  if (typeof targetEmailAddress !== 'string' || targetEmailAddress === '') {
    res.status(400).json({
      message: 'Invalid value for "targetEmailAddress" parameter.'
    })
    return
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
  res.status(200).json(preLoginAccount)
}


exports.put = async (req, res) => {
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
    KeyRotationEnabled: Joi.boolean(),
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

  let userId = req.params.userId
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
  res.status(200).json(updateAccount)
}


exports.delete = async (req, res) => {
  console.log('DELETE /admin/accounts/:userId')

  const userId = req.params.userId
  if (typeof userId !== 'string' || userId === '') {
    res.status(400).json({
      message: 'Invalid value for "userId" URL parameter.'
    })
    return
  }

  if (util.getCognitoUserId(req) === userId) {
    res.status(400).json({
      message: 'Invalid value for "userId" URL parameter: cannot delete yourself.'
    })
    return
  }

  await customersController.deleteAccountByUserId(userId)
  res.status(200).json({})
}

exports.get_current_user_profile = async (req, res) => {
  
  let user = await customersController.getAccountDetails(req.apiGateway.event.requestContext.identity.cognitoIdentityId)
  if (user == null)
  {
    return res.status(404).json({
      message: "Account does not exists"
    })
  }
  return res.status(200).json({
    "user_details" :user
})
}


exports.generate_new_api_key = async (req, res) => {
  let userPoolId = process.env.UserPoolId
  let userId = req.params.userId
  let user = await customersController.getAccountDetails(userId)
  let newApi = null
  if (user == null)
  {
    return res.status(404).json({
      message: "Account does not exists"
    })
  }
  const data = await new Promise((resolve, reject) => {customersController.getApiKeyForCustomer(userId, reject, resolve) });

  let apiKeyVal = data.items[0].id
  // Remove previous allocations of userId
  let usagePlanId = await new Promise((resolve, reject) => {customersController.getUsagePlansForCustomer(userId, reject, resolve) });

  if(usagePlanId.items.hasOwnProperty("id")) {
    usagePlanId = usagePlanId.items[0].id
    await new Promise((resolve, reject) => {customersController.unsubscribe(userId, usagePlanId, reject, resolve)})
    await customersController.deletePreviousApiKey(apiKeyVal)
    newApi = await customersController.renewApiKey(userId, userPoolId, true)
    await new Promise((resolve, reject) => { customersController.subscribe(userId, usagePlanId, reject, resolve) })
  }
  else {
    
    console.log("in unsubscribed user call")
    await customersController.deletePreviousApiKey(apiKeyVal)
    newApi = await customersController.renewApiKey(userId, userPoolId, true)
  }
  
  return res.status(200).json({
    "user_api_details" :{
      "id":newApi.id,
      "name":newApi.name,
      "enabled":newApi.enabled
    }
  })
}

exports.update_profile_image = async (req, res) => {
  let userId = req.params.userId

  let data = await customersController.getAccountDetails(userId)
  if (data == null) {
    return res.status(404).json({
      message: "Account doesnot Exists"
    })
  }

  let ext = req.files.file.name.split('.')[1]
  const S3 = new AWS.S3();
  console.log(req.files.file)

  let path =  `ProfilePicture/${userId}.`+ ext
  let mimeType = req.files.file.mimetype

  let imageDetails =  {"ProfilePicture":path, "MimeType":mimeType}

  const params = {
    Bucket: process.env.WEBSITE_BUCKET_NAME,
    Key: `ProfilePicture/${userId}.`+ext, // File name you want to save as in S3
    Body: req.files.file.data,
    ContentType: req.files.file.mimetype
  };
  
  let body = Object.assign(data, imageDetails)

  await customersController.updateProfileImageLocation(
    userId,
    body
  )

  S3.upload(params, function(err, data) {
    if (err) {
        throw err;
    }
    res.send({
        "response_code": 200,
        "response_message": "Success",
        "response_data": data
    });
  });
}
//get user profile image
exports.get_profile_image = async (req, res) => {
  let userId = req.params.userId
  let _userdata = await customersController.getAccountDetails(userId)
  
  if (_userdata == null) {
    return res.status(404).json({
      message: "Account doesnot Exists"
    })
  }

  let profilePath = _userdata.Items[0].ProfilePath
  let mimeType  = _userdata.Items[0].MimeType

  var params = {
    Bucket: process.env.WEBSITE_BUCKET_NAME,
    Key: profilePath
   };

   let data =  S3.getObject(params, (err, rest) => {
    
    if (err) throw err;
    const b64 = Buffer.from(rest.Body).toString('base64');
    res.send(`<img src="data:${mimeType};base64,${b64}" />`);
  
   });
  
}
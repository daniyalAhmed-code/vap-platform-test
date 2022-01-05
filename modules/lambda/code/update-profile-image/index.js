//@ts-check
'use strict'
const customersController = require('dev-portal-common/customers-controller')
const util = require('dev-portal-common/util')
const Joi = require('joi');
const AWS = require('aws-sdk')
const S3 = new AWS.S3();
const rh   =  require('dev-portal-common/responsehandler')

exports.handler = async (req, res) => {
  if(typeof req.pathParameters == "string")
    req['pathParameters'] = JSON.parse(req.pathParameters)
  let userId = req.params.userId

  let data = await customersController.getAccountDetails(userId)
  if (data == null) {
    return rh.callbackRespondWithSimpleMessage(400,'Account doesnot Exists')

  }

  let ext = req.files.file.name.split('.')[1]
  console.log(req.files.file)
  
  let path =  `ProfilePicture/${userId}.`+ext
  
  const params = {
    Bucket: process.env.WEBSITE_BUCKET_NAME,
    Key: `ProfilePicture/${userId}.`+ext, // File name you want to save as in S3
    Body: req.files.file.data,
    ContentType: req.files.file.mimetype
  };
  let body = Object.assign(data, {"ProfilePicture":path} )
  console.log(body)
  await customersController.updateProfileImageLocation(
    userId,
    body
  )

  S3.upload(params, function(err, data) {
    if (err) {
        throw err;
    }
    let response_body = {
      "response_code": 200,
      "response_message": "Success",
      "response_data": data
  };
    return rh.callbackRespondWithJsonBody(200,response_body)
  });
}

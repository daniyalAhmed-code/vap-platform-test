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

  let userId = decodeURIComponent(req.pathParameters.userId)


  let data = await customersController.getAccountDetails(userId)

  if (data == null) {
    return rh.callbackRespondWithSimpleMessage(400,'Account doesnot Exists')
  }
  
  if(typeof req.body == "string")
    req['body'] = JSON.parse(req.body)
  
  let image_detail = req.body.body
  console.log(image_detail)
  let mimetype = image_detail.match(/[^:]\w+\/[\w-+\d.]+(?=;|,)/)[0];
  let ext = image_detail.match(/[^:/]\w+(?=;|,)/)[0];
  
  let path =  `ProfilePicture/${userId}.`+ext
  let imageDetails =  {"ProfilePath":path, "MimeType":mimetype}
  
  const params = {
    Bucket: process.env.WEBSITE_BUCKET_NAME,
    Key: `ProfilePicture/${userId}.`+ext, // File name you want to save as in S3
    Body: image_detail,
    ContentType: mimetype
  };
  
  let body = Object.assign(data, imageDetails )
  console.log(body)
  await customersController.updateProfileImageLocation(
    userId,
    body
  )


  let result = await S3.upload(params).promise()
  console.log(result)
  let response_body = {
    "response_code": 200,
    "response_message": "Success",
    "response_data": data
};
    return rh.callbackRespondWithJsonBody(200,response_body)
}

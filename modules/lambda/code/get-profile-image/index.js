'use strict'

const customersController = require('dev-portal-common/customers-controller')
const rh   =  require('dev-portal-common/responsehandler')
const AWS = require('aws-sdk')
const S3 = new AWS.S3();

exports.handler = async (req, res) => {
    console.log(req)
    if(typeof req.pathParameters == "string")
     req['pathParameters'] = JSON.parse(req.pathParameters)    
    
     let userId = decodeURIComponent(req.pathParameters.userId)

        
    let _userdata = await customersController.getAccountDetails(userId)

    console.log(_userdata)
    if (_userdata == null) {
        return rh.callbackRespondWithSimpleMessage(404,'Account doesnot Exists')
    }
        
    if (_userdata.hasOwnProperty("ProfilePath")) {
            
            let profilePath = _userdata.ProfilePath
            let mimeType  = _userdata.MimeType
            var params = {
                Bucket: process.env.WEBSITE_BUCKET_NAME,
                Key: profilePath
            };
            
        let data = await S3.getObject(params).promise()
        console.log(data)
        const b64 = Buffer.from(data.Body);
        // CHANGE THIS IF THE IMAGE YOU ARE WORKING WITH IS .jpg OR WHATEVER
        return rh.callbackRespondWithText(200,`${b64}`)
    }

    else
        return rh.callbackRespondWithSimpleMessage(404,'This user does not have any profile image set yet')
    }

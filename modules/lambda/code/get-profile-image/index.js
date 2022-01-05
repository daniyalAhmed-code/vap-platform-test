'use strict'

const customersController = require('dev-portal-common/customers-controller')
const rh   =  require('dev-portal-common/responsehandler')

exports.handler = async (req, res) => {
    if(typeof req.queryStringParameters == "string")
     req['queryStringParameters'] = JSON.parse(req.queryStringParameters)    
        let userId = req.queryStringParameters.userId
        let _userdata = await customersController.getAccountDetails(userId)
        if (_userdata == null) {
            return rh.callbackRespondWithSimpleMessage(404,'Account doesnot Exists')
        }
        let profilePath = _userdata.Items[0].ProfilePath

        var params = {
            Bucket: process.env.WEBSITE_BUCKET_NAME,
            Key: profilePath
        };
        
        let data =  S3.getObject(params, (err, rest) => {
            if (err) throw err;

            const b64 = Buffer.from(rest.Body).toString('base64');
            // CHANGE THIS IF THE IMAGE YOU ARE WORKING WITH IS .jpg OR WHATEVER
            const mimeType = 'image/png'; // e.g., image/png
            return rh.callbackRespondWithText(200,`<img src="data:${mimeType};base64,${b64}" />`)
        });

        }

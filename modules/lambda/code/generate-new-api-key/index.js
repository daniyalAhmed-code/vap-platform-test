const customersController = require('dev-portal-common/customers-controller')
const util = require('dev-portal-common/util')
const rh   =  require('dev-portal-common/responsehandler')
exports.handler = async (req,res) => {
    const schema = Joi.object().keys({
        stage: Joi.string().valid("prod","alpha","beta"),
      });
    
    if(typeof req.queryStringParameters == "string")
        req['queryStringParameters'] = JSON.parse(req.queryStringParameters)

    if(typeof req.body == "string")
        req['body'] = JSON.parse(req.body)
    const {stage} = req.body
    let body = await schema.validate(req.body);
    console.log(body.error)
    
    if ('error' in body) {
        return rh.callbackRespondWithSimpleMessage(400,body.error.details[0].message)
    }

    const identityId = util.getCognitoIdentityId(req)
    
    const userId = util.getCognitoUserId(req)

    let cognitoIdentityId = `${identityId}/${userId}/${stage}`

    let apiResponse = await new Promise((resolve, reject) => {
            customersController.getApiKeyForCustomer(cognitoIdentityId, reject, resolve)
          })

    let usagePlanId = await new Promise((resolve, reject) => {customersController.getUsagePlansForCustomer(cognitoIdentityId, reject, resolve) });

    if (usagePlanId.items.hasOwnProperty("id")) {
        usagePlanId = usagePlanId.items[0].id
        await new Promise((resolve, reject) => {customersController.unsubscribe(cognitoIdentityId, usagePlanId, reject, resolve)})
        await customersController.deletePreviousApiKey(apiResponse.items[0].id)
        await customersController.renewApiKey(identityId,userId, stage, true);
        await new Promise((resolve, reject) => {customersController.subscribe(cognitoIdentityId, usagePlanId, reject, resolve)})
    }
    else {
        console.log(apiResponse.items[0].value)
        let deleteapikey = await customersController.deletePreviousApiKey(apiResponse.items[0].id)
        await customersController.renewApiKey(identityId,userId, stage, true);
    }
    return rh.callbackRespondWithSimpleMessage(200,"Success")

    }    


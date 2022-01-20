const customersController = require('dev-portal-common/customers-controller')
const util = require('dev-portal-common/util')
const rh   =  require('dev-portal-common/responsehandler')
const Joi = require('joi');
const common = ('dev-portal-common/common')

exports.handler = async (req,res) => {
    const schema = Joi.object().keys({
        stage: Joi.string().valid(common.stages.production,common.stages.alpha,common.stages.beta),
      });
    
    if(typeof req.queryStringParameters == "string")
        req['queryStringParameters'] = JSON.parse(req.queryStringParameters)

    if(typeof req.body == "string")
        req['body'] = JSON.parse(req.body)

    const stage = req.body.stage
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

    let usagePlanId = await new Promise((resolve, reject) => {customersController.getUsagePlansForCustomer(userId, reject, resolve) });
    if (usagePlanId.items.hasOwnProperty("id")) {
        usagePlanId = usagePlanId.items[0].id
        await new Promise((resolve, reject) => {customersController.unsubscribe(cognitoIdentityId, usagePlanId, reject, resolve)})
        await customersController.deletePreviousApiKey(apiResponse.items[0].id)
        let newApiKey = await customersController.renewApiKey(identityId,userId, stage, true);
        await updateUser(identityId,newApiKey,stage)

        await new Promise((resolve, reject) => {customersController.subscribe(cognitoIdentityId, usagePlanId, reject, resolve)})
    }
    else {
        let deleteapikey = await customersController.deletePreviousApiKey(apiResponse.items[0].id)
        let newApiKey =await customersController.renewApiKey(identityId,userId, stage, true);
        await updateUser(identityId,newApiKey,stage)

    }
    return rh.callbackRespondWithSimpleMessage(200,"Success")

    }    
async function updateUser(identityId,newApiKey,stage) {
    let userdetails = await customersController.getAccountDetails(identityId)
        
    for(let user_stage of userdetails.ApiKeyId.stage)
    {
        if(user_stage.Name == stage)
            user_stage['id'] = newApiKey.id
    }
    let apis = userdetails.ApiKeyId.stage

    let updateuser = await customersController.updateCustomerApiKeyId(identityId,apis)
}
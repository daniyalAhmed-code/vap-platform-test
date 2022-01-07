//@ts-check
'use strict'

const customersController = require('dev-portal-common/customers-controller')
const util = require('dev-portal-common/util')
const Joi = require('joi');
const rh   =  require('dev-portal-common/responsehandler')

exports.handler = async (req, res) => {

    const schema = Joi.object().keys({
    ApiId: Joi.array().items(Joi.object().keys({Id:Joi.string().required()}))
    });

    if(typeof req.pathParameters == "string")
        req['pathParameters'] = JSON.parse(req.pathParameters)

    if(typeof req.body == "string")
        req['body'] = JSON.parse(req.body)
    console.log(JSON.stringify(req, null, 2))


    let ClientId = req.pathParameters.id
    let AllowedApis = await customersController.getAllowedApisForResource(ClientId)
    let body = await schema.validate(req.body);
    let ApiIds= [].concat(body.value.ApiId, AllowedApis.Item.ApiId)
    const UsagePlanPermission = await customersController.updateAllowedApisForResource(ClientId,
        ApiIds)
    return rh.callbackRespondWithJsonBody(200,UsagePlanPermission)
}   

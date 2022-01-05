//@ts-check
'use strict'

const customersController = require('dev-portal-common/customers-controller')
const util = require('dev-portal-common/util')
const Joi = require('joi');
const rh   =  require('dev-portal-common/responsehandler')

exports.handler = async (req, res) => {

    const schema = Joi.object().keys({
    ApiId: Joi.array().items(Joi.object.keys({Id:Joi.string().required()}))
    });

    console.log(JSON.stringify(req, null, 2))
    
    if(typeof req.body == "string")
        req['body'] = JSON.parse(req.body)
    if(typeof req.pathParameters == "string")
        req['pathParameters'] = JSON.parse(req.pathParameters)
    
    const {
        ApiId
    } = req.body
    let body = await schema.validate(req.body);

    const UsagePlanPermission = await customersController.updateAllowedApisForResource(
        ApiId)
    return rh.callbackRespondWithJsonBody(200,UsagePlanPermission)
}   

//@ts-check
'use strict'

const customersController = require('dev-portal-common/customers-controller')
const util = require('dev-portal-common/util')
const Joi = require('joi');
const rh   =  require('dev-portal-common/responsehandler')

exports.handler = async (req, res) => {

    const schema = Joi.object().keys({
    ClientType: Joi.string().valid("Mno","ThirdParty"),
    ClientId : Joi.string().required(),
    ApiId: Joi.array().items(Joi.object().keys({Id:Joi.string().required()}))
    });
    
    if(typeof req.body == "string")
    req['body'] = JSON.parse(req.body)

    const {
    ClientType,    
    ClientId,
    ApiId
    } = req.body
    let body = await schema.validate(req.body);

    const UsagePlanPermission = await customersController.createPermissionToAccessApis(
    ClientType,    
    ClientId,
    ApiId)
    return rh.callbackRespondWithJsonBody(200,UsagePlanPermission)
}   

//@ts-check
'use strict'

const customersController = require('dev-portal-common/customers-controller')
const util = require('dev-portal-common/util')
const Joi = require('joi');
const rh   =  require('dev-portal-common/responsehandler')

exports.handler = async (req, res) => {
    console.log(JSON.stringify(req, null, 2))
    
    if(typeof req.pathParameters == "string")
        req['pathParameters'] = JSON.parse(req.pathParameters)
    let ResourceId = req.pathParameters.ResourceId
   
    const UsagePlanPermission = await customersController.deleteAllowedApisForResource(ResourceId)
    return rh.callbackRespondWithJsonBody(200,UsagePlanPermission)
}   

//@ts-check
'use strict'

const customersController = require('dev-portal-common/customers-controller')
const util = require('dev-portal-common/util')
const Joi = require('joi');
const rh   =  require('dev-portal-common/responsehandler')

exports.handler = async (req, res) => {

    const inviterUserId = util.getCognitoIdentityId(req)
    console.log(`POST /admin/accounts for Cognito ID: ${inviterUserId}`)

    console.log(JSON.stringify(req, null, 2))
    
    if(typeof req.body == "string")
    req['body'] = JSON.parse(req.body)
    let ResourceName = req.pathParameters.ResourceName
   
    const UsagePlanPermission = await customersController.getAllowedApisForResource(
    ResourceName,
    )
    return rh.callbackRespondWithJsonBody(200,UsagePlanPermission)
}   

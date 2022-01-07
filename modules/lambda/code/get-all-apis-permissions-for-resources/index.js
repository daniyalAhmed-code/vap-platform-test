//@ts-check
'use strict'

const customersController = require('dev-portal-common/customers-controller')
const util = require('dev-portal-common/util')
const Joi = require('joi');
const rh   =  require('dev-portal-common/responsehandler')

exports.handler = async (req, res) => {


    console.log(JSON.stringify(req, null, 2))
   
    const UsagePlanPermission = await customersController.getAllApisForResource()
    return rh.callbackRespondWithJsonBody(200,UsagePlanPermission)
}   

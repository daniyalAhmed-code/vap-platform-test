//@ts-check
'use strict'

const customersController = require('dev-portal-common/customers-controller')
const util = require('dev-portal-common/util')
const Joi = require('joi');
const rh   =  require('dev-portal-common/responsehandler')

exports.handler = async (req, res) => {
  let Mno_details = []
  if(typeof req.queryStringParameters == "string")
        req['queryStringParameters'] = JSON.parse(req.queryStringParameters)    
      let listAllResourceType = await customersController.getAllResourceDetails("Mno")
      if (listAllResourceType.Count == 0 )
        return rh.callbackRespondWithError(400,"No resource Found")
      for(let items of listAllResourceType.Items){
        let Items = {}
        let mno_location = items.ClientName.split(" ").slice(-1).pop()
        console.log(mno_location)
        Items['ClientType']= items.ClientType
        Items['Id']= items.Id
        Items['Name']= items.ClientName,
        Items['MnoLocation']= mno_location,
        console.log(Mno_details.push(Items))
      }
      console.log(Mno_details)
      return rh.callbackRespondWithJsonBody(200,Mno_details)
    }   

'use strict'

const customersController = require('dev-portal-common/customers-controller')
const { promisify2 } = require('dev-portal-common/promisify2')
const util = require('dev-portal-common/util')

const rh   =  require('dev-portal-common/responsehandler')
const common = require('dev-portal-common/common')

exports.handler = async (req, res) => {

  let listAllUsers = await customersController.listAllUsers()
  for (let user of listAllUsers.Items){
      if (!user.ApiKeyId.hasOwnProperty("stage")){
        let userId = user.Id
        let username = user.Username
        await customersController.createExistingUsersApiKey(userId,username)
      }

  }
  return rh.callbackRespondWithSimpleMessage(200,"Success")

}
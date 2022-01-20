'use strict'

const customersController = require('dev-portal-common/customers-controller')

const rh   =  require('dev-portal-common/responsehandler')

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
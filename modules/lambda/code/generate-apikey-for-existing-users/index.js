'use strict'

const customersController = require('dev-portal-common/customers-controller')
const { promisify2 } = require('dev-portal-common/promisify2')
const util = require('dev-portal-common/util')

const rh   =  require('dev-portal-common/responsehandler')
const common = require('dev-portal-common/common')

exports.handler = async (req, res) => {

    let tableName = `${process.env.CustomerTableName}`
    let params = {
        TableName : tableName,
      }
    let listAllUsers = await customersController.listAllUsers()
    for (let user of listAllUsers.Items){
        if (typeof user.ApiKeyId == "string" && user.ApiKeyId !== "NO_API_KEY"){
            let apiKey = user.ApiKeyId
                await customersController.createExistingUsersApiKey({
                  userId: user.Username,
                  identityId: user.Id,
                  apiKeyId:apiKey
                })
        }

    }
    return rh.callbackRespondWithSimpleMessage(200,"Success")

}

'use strict'

const customersController = require('dev-portal-common/customers-controller')
const rh   =  require('dev-portal-common/responsehandler')

exports.handler = async (req, res) => {
      if(typeof req.body == "string")
        req['body'] = JSON.parse(req.body)
  
      console.log(req)
      const { targetEmailAddress } = req.body
      if (
        !(typeof targetEmailAddress === 'string' && targetEmailAddress.length > 0)
      ) {
        return rh.callbackRespondWithSimpleMessage(400,`Invalid value for "targetEmailAddress" parameter`)
        
    }      
      try {
        // const inviterUserId = util.getCognitoUserId(req)
        await customersController.resendAccountInvite({ targetEmailAddress })
        return rh.callbackRespondWithSimpleMessage(200,`Invite Sent`)
      } catch (error) {
        console.log('Error:', error)
        return rh.callbackRespondWithError(500,error)
      }
      }

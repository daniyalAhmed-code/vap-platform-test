'use strict'

const feedbackController = require('dev-portal-common/feedback-controller')
const util = require('dev-portal-common/util')
const feedbackEnabled = !!process.env.FeedbackSnsTopicArn
const rh   =  require('dev-portal-common/responsehandler')

exports.handler = async (req, res) => {

        const cognitoIdentityId = util.getCognitoIdentityId(req)
        console.log(`POST /feedback for Cognito ID: ${cognitoIdentityId}`)
        
        if (!feedbackEnabled) {
          return rh.callbackRespondWithSimpleMessage(401,'Customer feedback not enabled')
          
        } 
        else {
          await feedbackController.submitFeedback(cognitoIdentityId, req.body.message)
          return rh.callbackRespondWithSimpleMessage(200,'Success')

        }
        }


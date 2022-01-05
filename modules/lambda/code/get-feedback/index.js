'use strict'

const feedbackController = require('dev-portal-common/feedback-controller')
const util = require('dev-portal-common/util')
const feedbackEnabled = !!process.env.FeedbackSnsTopicArn
const rh   =  require('dev-portal-common/responsehandler')

exports.handler = async (req, res) => {

        console.log(`GET /feedback for Cognito ID: ${util.getCognitoIdentityId(req)}`)

        if (!feedbackEnabled) {
          return rh.callbackRespondWithSimpleMessage(401,'Customer feedback not enabled')
          }
         else {
          const feedback = await feedbackController.fetchFeedback()
          return rh.callbackRespondWithJsonBody(200,feedback)
    }
}
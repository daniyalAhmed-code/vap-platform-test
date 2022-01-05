'use strict'

const util = require('dev-portal-common/util')
const rh   =  require('dev-portal-common/responsehandler')

exports.handler = async (req, res) => {
  if(typeof req.pathParameters == "string")
    req['pathParameters'] = JSON.parse(req.pathParameters)
  console.log(`GET /catalog/${req.pathParameters.id}/export for Cognito ID: ${util.getCognitoIdentityId(req)}`)

      // note that we only return an SDK if the API is in the catalog
      // this is important because the lambda function has permission to fetch any API's SDK
      // we don't want to leak customer API shapes if they have privileged APIs not in the catalog
      const [restApiId, stageName] = req.pathParameters.id.split('_')
      const catalogObject = util.findApiInCatalog(restApiId, stageName, await util.catalog())
    
      if (!catalogObject) {
        return rh.callbackRespondWithSimpleMessage(400,`API with ID (${restApiId}) and Stage (${stageName}) could not be found.`)

      } else if (!catalogObject.sdkGeneration) {
        return rh.callbackRespondWithSimpleMessage(400,`API with ID (${restApiId}) and Stage (${stageName}) is not enabled for API export generation.`)

      } else {
        let { exportType, parameters } = req.queryStringParameters
        if (typeof parameters === 'string') {
          try { parameters = JSON.parse(parameters) } catch (e) {
            return rh.callbackRespondWithSimpleMessage(400,`Input parameters for API with ID (${restApiId}) and Stage (${stageName}) were a string, but not parsable JSON: ${parameters}`)
 
          }
        }

        const result = await util.apigateway.getExport({
          restApiId, exportType, stageName, parameters
        }).promise()
        let resp_body = {
          "type":parameters.accept,
          "body":result.body
        }
        return rh.callbackRespondWithJsonBody(200,resp_body)
      }
    }

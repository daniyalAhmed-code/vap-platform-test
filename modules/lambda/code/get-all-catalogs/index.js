'use strict'

const hash = require('object-hash')
const { getAllUsagePlans } = require('dev-portal-common/get-all-usage-plans')
const util = require('dev-portal-common/util')
const nodeUtil = require('util')

const inspect = o => JSON.stringify(o, null, 2)

// Let's try to minimize how many calls we make here.
const MAX_REST_API_LIMIT = 500

const rh   =  require('dev-portal-common/responsehandler')

exports.handler = async (req, res) => {

  try {
    const visibility = { apiGateway: [] }
    const catalogObject = await util.catalog()
    let restApiResult = await util.apigateway.getRestApis({
      limit: MAX_REST_API_LIMIT
    }).promise()
    const apis = restApiResult.items

    while (restApiResult.position != null) {
      restApiResult = await util.apigateway.getRestApis({
        limit: MAX_REST_API_LIMIT,
        position: restApiResult.position
      }).promise()
      for (const api of restApiResult.apis) apis.push(api)
    }

    console.log(`apis: ${inspect(apis)}`)

    const promises = []
    apis.forEach((api) => {
      promises.push(
        util.apigateway.getStages({ restApiId: api.id }).promise()
          .then((response) => response.item)
          .then((stages) => stages.forEach(stage => visibility.apiGateway.push({
            id: api.id,
            name: api.name,
            stage: stage.stageName,
            visibility: false
          })))
      )
    })
    await Promise.all(promises)

    console.log(`visibility initial: ${inspect(visibility)}`)

    // mark every api gateway managed api-stage in the catalog as visible
    catalogObject.apiGateway.forEach((usagePlan) => {
      console.log(`usage plan: ${nodeUtil.inspect(usagePlan, null, 2)}`)
      usagePlan.apis.forEach((api) => {
        console.log(`usage plan api: ${nodeUtil.inspect(api, null, 1)}`)
        visibility.apiGateway.map((apiEntry) => {
          if (apiEntry.id === api.apiId && apiEntry.stage === api.apiStage) {
            console.log(`matching apiEntry: ${inspect(apiEntry)}`)
            apiEntry.visibility = true
            apiEntry.sdkGeneration = api.sdkGeneration || false
          }

          return apiEntry
        })
      })
    })

    console.log(`visibility updated visibility: ${inspect(visibility)}`)

    const usagePlans = await getAllUsagePlans(util.apigateway)

    // In the case of apiGateway APIs, the client doesn't know if there are usage plan associated or not
    // so we need to provide that information. This can't be merged with the above loop:
    // (catalogObject.apiGateway.forEach((usagePlan) => ...
    // because the catalog only contains *visible* apis, and this loop needs to record the subscribability
    // of both visible and non-visible APIs.
    visibility.apiGateway.map((apiEntry) => {
      apiEntry.subscribable = false

      usagePlans.forEach((usagePlan) => {
        usagePlan.apiStages.forEach((apiStage) => {
          if (apiEntry.id === apiStage.apiId && apiEntry.stage === apiStage.stage) {
            apiEntry.subscribable = true
            apiEntry.usagePlanId = usagePlan.id
            apiEntry.usagePlanName = usagePlan.name
          }

          apiEntry.sdkGeneration = !!apiEntry.sdkGeneration
        })
      })

      return apiEntry
    })

    console.log(`visibility updated subscribable: ${inspect(visibility)}`)

    // mark every api in the generic catalog as visible
    catalogObject.generic.forEach((catalogEntry) => {
      console.log(`catalogEntry: ${nodeUtil.inspect(catalogEntry, null, 1)}`)
      // Unlike in the catalog and elsewhere, the visibility's `apiGateway` contains *all* API
      // Gateway-managed APIs, and only unmanaged APIs are in `visibility.generic`.
      if (catalogEntry.apiId != null) {
        const target = visibility.apiGateway.find((api) =>
          api.id === catalogEntry.apiId && api.stage === catalogEntry.apiStage
        )
        if (target != null) {
          target.visibility = true

          if (catalogEntry.sdkGeneration !== undefined) {
            target.sdkGeneration = catalogEntry.sdkGeneration
          }

          return
        }
      }

      if (!visibility.generic) {
        visibility.generic = {}
      }

      visibility.generic[catalogEntry.id] = {
        visibility: true,
        name: (catalogEntry.swagger && catalogEntry.swagger.info && catalogEntry.swagger.info.title) || 'Untitled'
      }
    })

    console.log(`visibility updated generic: ${inspect(visibility)}`)
    
    return rh.callbackRespondWithJsonBody(200,visibility)

  } catch (err) {
    console.error(`error: ${err.stack}`)
    return rh.callbackRespondWithSimpleMessage(500,'Internal Server Error')
    // TODO: Should this be 'error' or 'message'?
  }
}    
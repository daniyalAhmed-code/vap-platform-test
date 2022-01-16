const customersController = require('dev-portal-common/customers-controller')


exports.handler = async (event) => {
    console.log(event)
    let api_date
    let identityId = event.Id
    let userId     = event.UserPoolId
    let apiKeyVal = event.api_data.id
    let current_date = new Date()
    let stages = [common.stages.alpha,common.stages.beta,common.stages.prod]
    for (let stage of stages) {    
 
    if ('lastUpdatedDate' in event.api_data) {
        api_date = event.api_data.lastUpdatedDate;
    } else {
        api_date = event.api_data.createdDate;
    }
    
    let cognitoIdentityId = `${identityId}/${userId}/${stage}`

    let ApiDate = new Date(api_date);
    ApiDate.setDate(ApiDate.getDate() + event.ApiKeyDuration);

    if (ApiDate < current_date && event.KeyRotation) {
        let usagePlanId = await new Promise((resolve, reject) => {customersController.getUsagePlansForCustomer(cognitoIdentityId, reject, resolve) });
        if (usagePlanId.items.hasOwnProperty("id")) {
                
            usagePlanId = usagePlanId.items[0].id
            await new Promise((resolve, reject) => {customersController.unsubscribe(cognitoIdentityId, reject, resolve) });
            await customersController.deletePreviousApiKey(event.value)
            await customersController.renewApiKey(identityId, userId,stage, true);
            await new Promise((resolve, reject) => {customersController.subscribe(cognitoIdentityId, reject, resolve) });
            
        }
        else {
            await customersController.deletePreviousApiKey(event.value)
            await customersController.renewApiKey(identityId, userId, stage,true);
        }
    }
    }    
    const response = {
        statusCode: 200,
        body: JSON.stringify(event),
    };
    return response;
};
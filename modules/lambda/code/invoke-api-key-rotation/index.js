const customersController = require('dev-portal-common/customers-controller')


exports.handler = async (event) => {
    let api_date
    let identityId = event.Id
    let userId     = event.UserPoolId
    let stage = event.Name
    let api_id = event.api_data.value
    let current_date = new Date()
    
    if ('lastUpdatedDate' in event.api_data) {
        api_date = event.api_data.lastUpdatedDate;
    } else {
        api_date = event.api_data.createdDate;
    }
    
    let ApiDate = new Date(api_date);
    ApiDate.setDate(ApiDate.getDate() + event.ApiKeyDuration);
    if (ApiDate > current_date && event.KeyRotationEnabled) {
        let usagePlanId = await new Promise((resolve, reject) => {customersController.getUsagePlansForCustomer(userId, reject, resolve) });
        if (usagePlanId.items.hasOwnProperty("id")) {
            usagePlanId = usagePlanId.items[0].id
            await new Promise((resolve, reject) => {customersController.unsubscribe(identityId, usagePlanId, reject, resolve)})
            await customersController.deletePreviousApiKey(api_id)
            let newApiKey = await customersController.renewApiKey(identityId,userId, stage, true);
            await updateUser(identityId,newApiKey,stage)
            await new Promise((resolve, reject) => {customersController.subscribe(identityId, usagePlanId, reject, resolve)})
        }
        else {
            let deleteapikey = await customersController.deletePreviousApiKey(api_id)
            let newApiKey =await customersController.renewApiKey(identityId,userId, stage, true);
            await updateUser(identityId,newApiKey,stage)
        }
    }    
    const response = {
        statusCode: 200,
        body: JSON.stringify(event),
    };
    return response;
};

async function updateUser(identityId,newApiKey,stage) {
    let userdetails = await customersController.getAccountDetails(identityId)
        
    for(let user_stage of userdetails.ApiKeyId.stage)
    {
        if(user_stage.Name == stage)
            user_stage['id'] = newApiKey.id
    }
    let apis = userdetails.ApiKeyId.stage
    let updateuser = await customersController.updateCustomerApiKeyId(identityId,apis)
}
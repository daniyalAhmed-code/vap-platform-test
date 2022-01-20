//@ts-check
const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();
const lambda = new AWS.Lambda();
const customersController = require('dev-portal-common/customers-controller');

async function invokeLambda(payload, id, UserPoolId) {
    const cognitoIdentityId = id;
    const data = await new Promise((resolve, reject) => {customersController.getApiKeyForCustomer(cognitoIdentityId, reject, resolve) });
    payload['api_data'] = data.items[0];
    payload['Id'] = id
    payload['UserPoolId'] = UserPoolId
    const params = {
        FunctionName: process.env.InvokeLambdaFunction,
        InvocationType: 'Event',
        Payload: JSON.stringify(payload)
    };
    await lambda.invoke(params).promise();
}

exports.handler = async (event, context) => {
    let table_name = process.env.CustomersTableName;
    let params = {
        TableName: table_name
    };
    let response = await dynamodb.scan(params).promise();
    for (let item of response.Items) {
        let id = item.Id
        let userPoolid = item.UserPoolId
        for (let stage of item.ApiKeyId.stage)
            if (stage.hasOwnProperty("ApiKeyDuration") && stage.ApiKeyDuration != 0)
                await invokeLambda(stage, id, userPoolid);
    }
    context.done();
};
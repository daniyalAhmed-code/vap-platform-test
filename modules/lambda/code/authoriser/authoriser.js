//@ts-check

const AWS = require('aws-sdk');
const AuthPolicy = require('aws-auth-policy');

const log4js = require('log4js');
const logger = log4js.getLogger();
logger.level = process.env.LOG_LEVEL;
const dynamodb = new AWS.DynamoDB.DocumentClient();
const apigateway = new AWS.APIGateway();
const cognito = new AWS.CognitoIdentityServiceProvider();
const { v4: uuidv4 } = require('uuid');

const {
    getEnv
} = require('dev-portal-common/get-env');


const deny = (awsAccountId, apiOptions) => {
    console.log('Inside deny', awsAccountId, apiOptions);
    let policy = new AuthPolicy('', awsAccountId, apiOptions);
    policy.denyAllMethods();
    let iamPolicy = policy.build();
    return iamPolicy;
};


exports.handler = async (event, context, callback) => {
    console.log('Inside event', event);
    let apiKey;

    const tmp = event.methodArn.split(':');
    const apiGatewayArnTmp = tmp[5].split('/');
    const awsAccountId = tmp[4];
    const apiOptions = {
        region: tmp[3],
        restApiId: apiGatewayArnTmp[0],
        stage: apiGatewayArnTmp[1]
    };

    console.log(apiOptions);
    
    let apiId = event.requestContext.identity.apiKeyId;
    let userPoolId = getEnv("UserPoolId");
    let api_date;

    let current_date = new Date();
    try {
        apiKey = await apigateway.getApiKey({
            apiKey: apiId
        }).promise();
    } catch (err) {
        console.log(err);
        return deny(awsAccountId, apiOptions);
    }
    let client_id = ""
    let userId = apiKey.name.split("/")[0];
    let tableName = `${process.env.CustomersTableName}`;
    let apisResponse = await dynamodb.query({
        TableName: tableName,
        KeyConditionExpression: "Id = :id",
        ExpressionAttributeValues: {
            ":id": userId
        }
    }).promise();
    
    console.log(apisResponse);
    

    if (apisResponse.Count <= 0)
        return deny(awsAccountId, apiOptions);

    let username = apisResponse.Items[0].Username;
    let cognitoResponse = await cognito.adminGetUser({
        UserPoolId: userPoolId,
        Username: username
    }).promise();

     for (let userAttribute of cognitoResponse.UserAttributes)
      if(userAttribute.Name == 'custom:client_id')
         client_id =userAttribute.Value  

    console.log(cognitoResponse);

    await saveApiDetails(event, apisResponse.Items[0]);
    let ApiRolePermissionTableName = `${process.env.API_PERMISSION_TABLE_NAME}`
    let permissionsResponse = await dynamodb.query({
      TableName: ApiRolePermissionTableName,
      KeyConditionExpression: "client_id = :id",
      ExpressionAttributeValues: {
          ":id": client_id
      }
  }).promise();    

    if (!apisResponse.Items[0].hasOwnProperty("ApiKeyDuration")) {
        console.log("ApiKeyDuration not present");
        return generate_api_gateway_response(awsAccountId, apiOptions, permissionsResponse, username, userId);
    }
    
    console.log("ApiKeyDuration present");
    
    if ('lastUpdatedDate' in apiKey) {
        api_date = apiKey.lastUpdatedDate;
    } else {
        api_date = apiKey.createdDate;
    }
    
    let ApiDate = new Date(api_date);
    ApiDate.setDate(ApiDate.getDate() + apisResponse.Items[0].ApiKeyDuration);
    
    if (ApiDate > current_date) {
        return generate_api_gateway_response(awsAccountId, apiOptions, client_id,permissionsResponse ,username, userId);
    }
    else
        return deny(awsAccountId, apiOptions);
};


function generate_api_gateway_response(awsAccountId, apiOptions, client_id, permissionsResponse, username, userId) {
    if(`${process.env.IsEnabled}`)
    {
      if(!permissionsResponse.Item.ApiId.includes(apiOptions.restApiId))
        return deny(awsAccountId, apiOptions);
     }
    else{
        var authPolicy = new AuthPolicy(`${awsAccountId}`, awsAccountId, apiOptions);
        authPolicy.allowMethod(AuthPolicy.HttpVerb.ALL, "/*");
    }   
    var generated = authPolicy.build();
    generated["context"] = {
        "cognito_username": username,
        "user_id": userId
    };
    
    return generated;
}

async function saveApiDetails(event, user_data){
    try {
        
        console.log("in save api details");
        
        let current_time = Date.now();
        let request_submitted_date = new Date(current_time).toISOString();
        let request_submitted_epoch = Math.round(current_time / 1000);
        let data = {};
        
        data['RequestType'] = event.requestContext.httpMethod;
    
        if(event.hasOwnProperty("headers")) 
          data['Headers'] = event.headers;
    
        if(event.hasOwnProperty("multiValueHeaders"))
          data['MultiValueHeaders'] = event.multiValueHeaders;
    
        if(event.hasOwnProperty("queryStringParameters"))
          data['QueryStringParameters'] = event.queryStringParameters;
    
        if(event.hasOwnProperty("body"))
          data['Body'] = event.body;
    
        if(event.hasOwnProperty("path"))
          data['ApiPath'] = event.path;
          
        if(user_data.hasOwnProperty("MnoLocation"))
          data['MnoLocation'] = user_data.MnoLocation;
          
        if(user_data.hasOwnProperty("Mno"))
          data['Mno'] = user_data.Mno;
          
        if(event.requestContext.hasOwnProperty("domainName"))
          data['DomainName'] = event.requestContext.domainName;
    
        data['EmailAddress'] = user_data.EmailAddress;
        data['CreatedAt'] = request_submitted_date;
    
        let item = {
          UserId: user_data.Username,
          EpochTime: request_submitted_epoch
        };
        
        const params = {
          TableName: process.env.CustomerRequestLogTable,
          Item: Object.assign(item, data)
        };
        
        let respData = await dynamodb.put(params).promise();
        console.log(respData);
    }
    catch (ex) {
        console.error(ex);
    }
}
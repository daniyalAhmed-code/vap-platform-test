//@ts-check

const AWS = require('aws-sdk');
const AuthPolicy = require('aws-auth-policy');
const log4js = require('log4js');
const logger = log4js.getLogger();
logger.level = process.env.LOG_LEVEL;
const jwt = require('jsonwebtoken');
const request = require('request');
const jwkToPem = require('jwk-to-pem');
let PEMS = null;
const dynamodb = new AWS.DynamoDB.DocumentClient();

const toPem = (keyDictionary) => {
    return jwkToPem(Object.assign({}, {
        kty: keyDictionary.kty,
        n: keyDictionary.n,
        e: keyDictionary.e
    }));
};

const deny = (awsAccountId, apiOptions) => {
    console.log('Inside deny', awsAccountId, apiOptions);
    let policy = new AuthPolicy('', awsAccountId, apiOptions);
    policy.denyAllMethods();
    let iamPolicy = policy.build();
    return iamPolicy;
};

const getJWKS = async(jwtKeySetURI) => {
    console.time(`AUTHORIZER:getJWKS`);
    return new Promise((resolve, reject) => {
        request({
            url: jwtKeySetURI,
            json: true
        }, (error, response, body) => {
            console.timeEnd(`AUTHORIZER:getJWKS`);
            if (!error && response.statusCode === 200) {
                let pems = {};
                let keys = body['keys'];
                for (let keyIndex = 0; keyIndex < keys.length; keyIndex++) {
                    let kid = keys[keyIndex].kid;
                    pems[kid] = toPem(keys[keyIndex]);
                }
                resolve(pems);
            }
            else {
                logger.info("Failed to retrieve the keys from the well known user-pool URI, ");
                logger.info('Error-Code: ', response.statusCode);
                logger.info(error);
                //resolve(null);
                reject(error);
            }
        });
    });
};

const verifyJWT = async(token, pem, tokenIssuer) => {
    console.time(`AUTHORIZER:verifyJWT`);
    return new Promise(resolve => {
        jwt.verify(token, pem, {
            issuer: tokenIssuer
        }, function(err, payload) {
            console.timeEnd(`AUTHORIZER:verifyJWT`);
            if (err) {
                logger.info("Error while trying to verify the Token, returning deny-all policy", err.message);
                resolve(null);
            }
            resolve(payload);
        });
    });
};

const processAuthRequest = async(payload, awsAccountId, apiOptions) => {
    let allowedApis = []
    let ApiId = apiOptions.restApiId
    logger.info('payload', payload);
    if (!payload) {
        return deny(awsAccountId, apiOptions);
    }
    else {
        //Valid token. Generate the API Gateway policy for the user
        //Always generate the policy on value of 'sub' claim and not for
        // 'username' because username is reassignable
        //sub is UUID for a user which is never reassigned to another user.
        const pId = payload.sub;
        let policy = new AuthPolicy(pId, awsAccountId, apiOptions);

        // Check the Cognito group entry for permissions.
        // precedence
        let UserPoolId = payload.iss.split('/')[3]
        if (payload['cognito:groups']) {
            let user_groups = payload['cognito:groups'];
            let tableName = `${process.env.ApiRolePermissionTable}`;
            let apiPermissionTableName = `${process.env.ApiPermissionTable}`
            // GET the cuid from payload
            // if cuid == 'admin' tableName = `${process.env.STAGE}-admin-role-membership`
            // Get all APIs a user can execute
            let apisResponse = await dynamodb.scan({ TableName: tableName }).promise();
            let apiPermissionRespone = await dynamodb.scan({ TableName: apiPermissionTableName }).promise();
            console.log("api response below")
            console.log('apisResponse---', apisResponse);
            
            policy.allowMethod(AuthPolicy.HttpVerb.ALL, "/*");
            // Get list of all
            for (let ar of apisResponse.Items) {
                if (ar.hasOwnProperty('UserPoolId')){
                console.log("Has own property")
                if (user_groups.includes(ar.role) && ar.UserPoolId == UserPoolId ) {
                    console.log("in resource check")
                    console.log("in user-group")
                    console.log(apiPermissionRespone)
                    for (let api of ar.apis) {
                        console.log(apiPermissionRespone.Items[0].ApiId)
                        if (apiPermissionRespone.Items[0].ApiId.includes(ApiId))
                        {
                            allowedApis= apiPermissionRespone.Items[0].ApiId
                            console.log("in api")
                            policy.allowMethod(AuthPolicy.HttpVerb[api.method], api.api);
                        }
                
                    }
                
                }
            }
            else {
                if (user_groups.includes(ar.role)) {
                    
                    console.log("in user-group")
                    for (let api of ar.apis) {
                            policy.allowMethod(AuthPolicy.HttpVerb[api.method], api.api);
                        }
                    }
                }
        }
        }
        else {
            console.log("in else deny")
            return deny(awsAccountId, apiOptions);
        }
        // Get all the config
        let context = {};
        let cognitoIdentityId = ""
        let iamPolicy = policy.build();
        console.log(iamPolicy.policyDocument.Statement)
        let customerTable = `${process.env.CustomersTableName}`
        
        let customerParams = {
            ProjectionExpression: "Id",
            FilterExpression: "#username = :a",
            ExpressionAttributeNames: {
                "#username": "Username",
            },
            ExpressionAttributeValues: {
                ":a": payload['cognito:username']
           },
            TableName: customerTable
           };
        console.log("Is here after customer table")
        let customerResponse = await dynamodb.scan(customerParams).promise()
        if (customerResponse.Count == 0){
            let customerPreloginParams = {
            ProjectionExpression: "UserId",
            FilterExpression: "#username = :a",
            ExpressionAttributeNames: {
                "#username": "UserId",
            },
            ExpressionAttributeValues: {
                ":a": payload['cognito:username']
            },
            TableName: `${process.env.PreLoginAccountsTableName}`
            };
            customerResponse = await dynamodb.scan(customerPreloginParams).promise()
            console.log(customerResponse)
            cognitoIdentityId = customerResponse.Items[0].UserId
        }
        else
        {
            cognitoIdentityId = customerResponse.Items[0].Id
        }
        // let pool = tokenIssuer.substring(tokenIssuer.lastIndexOf('/') + 1);
        try {
            
            context.cognitoIdentityId = cognitoIdentityId
            context.Usersub = payload['cognito:username']
            context.UserId = payload['cognito:username']
            context.UserPoolId = UserPoolId
            context.apis =allowedApis.toString()
        }
        
        catch (e) {
            logger.error(e);
        }
        console.log(context)

        iamPolicy.context = context;
        console.log(iamPolicy.policyDocument.Statement)
        console.log(iamPolicy);
        return iamPolicy;
    }
};


exports.handler = async (event, context, callback) => {
    console.log('Inside event', event);
    console.log('Inside context', context);
    
    let apiKey;
    let cognitoGroupName = []
    let decoded
    const tmp = event.methodArn.split(':');
    const apiGatewayArnTmp = tmp[5].split('/');
    const awsAccountId = tmp[4];
    const apiOptions = {
        region: tmp[3],
        restApiId: apiGatewayArnTmp[0],
        stage: apiGatewayArnTmp[1]
    };
    try {
        let token = event.headers.authorizertoken
        if(event.headers.hasOwnProperty("authorizeToken"))
            token = event.headers.authorizerToken
            
        decoded = jwt.decode(token, {
            complete: true
        });
        if (!decoded) {
            logger.info('denied due to decoded error');
            console.log("denied due to decoded error")
            return deny(awsAccountId, apiOptions);
        }
        
    }
    catch (err) {
        logger.error(err);
    }
    // console.log("main deny")
    return await processAuthRequest(decoded.payload, awsAccountId, apiOptions);
    // return deny(awsAccountId, apiOptions);
}
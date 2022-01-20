'use strict'
const AWS = require('aws-sdk');
const dynamodb = new AWS.DynamoDB.DocumentClient();

const fs = require('fs');

exports.handler = async (req, res) => {
    let file = await fs.readFileSync('./datascript/customerRoleMapping.json', 'utf8');
    file = file.replace(/{{ADMIN_USERPOOL_ID}}/g, `${process.env.ADMIN_USERPOOL_ID}`);
    file = file.replace(/{{MNO_USERPOOL_ID}}/g, `${process.env.MNO_USERPOOL_ID}`);
    file = file.replace(/{{THIRD_PARTY_USERPOOL_ID}}/g, `${process.env.THIRD_PARTY_USERPOOL_ID}`);

    let data = JSON.parse(file)
    for (let resource of data) {
        const params = {
            TableName: `${process.env.ROLE_MAPPING_TABLE}`,
            Item: resource
        };
        let details = await dynamodb.put(params).promise()
        console.log(details)
}   

}
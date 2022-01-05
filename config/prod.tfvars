ENABLE_FEEDBACK_SUBMISSION = "admin@email.com"

NAME = "vap-api"

ENV = "prod"

USE_ROUTE53         = true
CUSTOM_DOMAIN_NAME  = "developer.vantageapi.com"
APIGATEWAY_CUSTOM_DOMAIN_NAME = "api.vantageapi.com"
HOSTED_ZONE_ID      = "Z08165742ETNW652P63SV"
ACM_CERTIFICATE_ARN = "arn:aws:acm:us-east-1:955069148083:certificate/c1f03d95-a7bc-4bbe-919c-e86a2d6e4fac"

COGNITO_ADMIN_GROUP_DESCRIPTION      = "Group for Admins"
COGNITO_REGISTERED_GROUP_DESCRIPTION = "Group for registered users"
COGNITO_USER_POOL_DOMAIN             = "vaprod"
MNO_COGNITO_USER_POOL_DOMAIN         = "vaprod-mno"
THIRD_PARTY_COGNITO_USER_POOL_DOMAIN = "vaprod-third-party"

ACCOUNT_REGISTRATION_MODE            = "invite"
ALLOW_ADMIN_CREATE_USER_ONLY         = true
ORIGIN_ID                            = true
API_KEY_ROTATION_TRIGGER_FREQUENCY = "cron(0 0 * * ? *)"

DEVELOPMENT_MODE = false
NODE_ENV         = "production"

LOGGING_BUCKET                  = "vap-prod-955069148083-logs"
locals {
  FEEDBACK_TABLE_NAME = var.IS_ADMIN ? var.FEEDBACK_TABLE_NAME : null
}

resource "aws_lambda_layer_version" "lambda-common-layer" {
  provider            = aws.src
  filename            = "${path.module}/layers/nodejs.zip"
  layer_name          = "dev-portal-common"
  compatible_runtimes = ["nodejs12.x"]
  source_code_hash    = "${filebase64sha256("${path.module}/layers/nodejs.zip")}"
}


resource "aws_lambda_function" "lambda_catalog_updater_lambda_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/catalog-updater.zip"
  function_name    = "${var.RESOURCE_PREFIX}-catalog-updater"
  role             = "${var.LAMBDA_CATALOG_UPDATER_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_catalog_updater_lambda_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "BucketName" = "${var.ARTIFACTS_S3_BUCKET_NAME}"
    }
  }
}

resource "aws_lambda_function" "lambda_backend_lambda_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/backend.zip"
  function_name    = "${var.RESOURCE_PREFIX}-backend"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_backend_lambda_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }
  environment {
    variables = {
      "NODE_ENV"                  = "${var.NODE_ENV}"
      "WEBSITE_BUCKET_NAME"       = "${var.WEBSITE_BUCKET_NAME}"
      "StaticBucketName"          = "${var.ARTIFACTS_S3_BUCKET_NAME}"
      "CustomersTableName"        = "${var.CUSTOMER_TABLE_NAME}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "FeedbackTableName"         = "${var.FEEDBACK_TABLE_NAME}"
      "FeedbackSnsTopicArn"       = "${var.FEEDBACK_SNS_TOPIC_ARN}"
      "UserPoolId"                = "${var.USERPOOL_ID}"
      "AdminsGroupName"           = "${var.ADMIN_GROUP_NAME}"
      "RegisteredGroupName"       = "${var.REGISTERED_GROUP_NAME}"
      "DevelopmentMode"           = "${var.DEVELOPMENT_MODE}"
      "CatalogUpdaterFunctionArn" = aws_lambda_function.lambda_catalog_updater_lambda_function.arn
    }
  }
}



resource "aws_lambda_function" "lambda_cognito_presignup_trigger_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/cognito-pre-signup-trigger.zip"
  function_name    = "${var.RESOURCE_PREFIX}-CognitoPreSignupTriggerFn"
  role             = "${var.LAMBDA_COGNITO_PRESIGNUP_TRIGGER_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_cognito_pre_signup_trigger_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "3"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "AccountRegistrationMode" = "${var.ACCOUNT_REGISTRATION_MODE}"
    }
  }
}

resource "aws_lambda_function" "lambda_cognito_post_confirmation_trigger_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/cognito-post-confirmation-trigger.zip"
  function_name    = "${var.RESOURCE_PREFIX}-CognitoPostConfirmationTriggerFn"
  role             = "${var.LAMBDA_COGNITO_POST_CONFIRMATION_TRIGGER_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_cognito_post_confirmation_trigger_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "3"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "AccountRegistrationMode"   = "${var.ACCOUNT_REGISTRATION_MODE}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "RegisteredGroupName"       = "${var.REGISTERED_GROUP_NAME}"
    }
  }
}

resource "aws_lambda_function" "lambda_cognito_post_authentication_trigger_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/cognito-post-authentication-trigger.zip"
  function_name    = "${var.RESOURCE_PREFIX}-CognitoPostAuthenticationTriggerFn"
  role             = "${var.LAMBDA_COGNITO_POST_AUTHENTICATION_TRIGGER_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_cognito_post_authentication_trigger_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "3"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "AccountRegistrationMode"   = "${var.ACCOUNT_REGISTRATION_MODE}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "CustomersTableName"        = "${var.CUSTOMER_TABLE_NAME}"
      "RegisteredGroupName"       = "${var.REGISTERED_GROUP_NAME}"
    }
  }
}

resource "aws_lambda_function" "lambda_cognito_userpool_client_settings_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/cfn-cognito-user-pools-client-settings.zip"
  function_name    = "${var.RESOURCE_PREFIX}-CognitoUserPoolClientSettingsBackingFn"
  role             = "${var.LAMBDA_COGNITO_USERPOOL_CLIENT_SETTING_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_cognito_userpool_client_settings_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "300"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
}


resource "aws_lambda_function" "lambda_cognito_userpool_domain_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/cfn-cognito-user-pools-domain.zip"
  function_name    = "${var.RESOURCE_PREFIX}-CognitoUserPoolDomainBackingFn"
  role             = "${var.LAMBDA_COGNITO_USERPOOL_DOMAIN_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_cognito_userpool_domain_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "300"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
}

resource "aws_lambda_function" "lambda_dump_v3_account_data_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/dump-v3-account-data.zip"
  function_name    = "${var.RESOURCE_PREFIX}-DumpV3AccountDataFn"
  role             = "${var.LAMBDA_DUMP_V3_ACCOUNT_ROLE_ARN}"
  handler          = "index.handler"
  memory_size      = 512
  source_code_hash = "${data.archive_file.lambda_dump_v3_account_data_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "300"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
 tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "UserPoolId"         = "${var.USERPOOL_ID}"
      "CustomersTableName" = "${var.CUSTOMER_TABLE_NAME}"
      "AdminGroupName"     = "${var.ADMIN_GROUP_NAME}"
    }
  }
}

resource "aws_lambda_function" "lambda_user_group_importer_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/user-group-importer.zip"
  function_name    = "${var.RESOURCE_PREFIX}-UserGroupImporter"
  role             = "${var.LAMBDA_USERGROUP_IMPORTER_ROLE_ARN}"
  handler          = "index.handler"
  memory_size      = 512
  source_code_hash = "${data.archive_file.lambda_user_group_importer_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "900"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "UserPoolId"          = "${var.USERPOOL_ID}"
      "CustomersTableName"  = "${var.CUSTOMER_TABLE_NAME}"
      "AdminGroupName"      = "${var.ADMIN_GROUP_NAME}"
      "RegisteredGroupName" = "${var.REGISTERED_GROUP_NAME}"
      "FeedbackTable"       = "${local.FEEDBACK_TABLE_NAME}"
    }
  }
}


resource "aws_lambda_function" "lambda_api_key_authoriser_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/authoriser.zip"
  function_name    = "${var.RESOURCE_PREFIX}-api-key-authoriser"
  role             = "${var.LAMBDA_AUTHORIZATION_ROLE_ARN}"
  handler          = "authoriser.handler"
  memory_size      = 512
  source_code_hash = "${data.archive_file.lambda_api_key_authoriser_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "900"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }
  environment {
    variables = {
      "UserPoolId"         = "${var.USERPOOL_ID}"
      "CustomersTableName" = "${var.CUSTOMER_TABLE_NAME}"
      "CustomerRequestLogTable" = "${var.CUSTOMER_REQUEST_LOGS_TABLE_NAME}"
      "ApiPermissionTableName" = "${var.API_PERMISSION_TABLE_NAME}"
      "IsEnabled"              = false
    }
  }
}


resource "aws_lambda_function" "lambda_cloudfront_security_function" {
  provider            = aws.global
  publish          = true
  filename         = "${path.module}/zip/cloudfront-security.zip"
  function_name    = "${var.RESOURCE_PREFIX}-cloudfront-security"
  role             = "${var.LAMBDA_CLOUDFRONT_SECURITY_ROLE_ARN}"
  handler          = "index.handler"
  memory_size      = 128
  source_code_hash = "${data.archive_file.lambda_cloudfront_security_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "30"

}

resource "aws_lambda_function" "lambda_api_key_rotation" {
  provider            = aws.src
  filename         = "${path.module}/zip/api-key-rotation.zip"
  function_name    = "${var.RESOURCE_PREFIX}-api-key-rotation"
  role             = "${var.LAMBDA_API_KEY_ROTATION_ROLE_ARN}"
  handler          = "index.handler"
  memory_size      = 512
  source_code_hash = "${data.archive_file.lambda_api_key_rotation_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "900"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "InvokeLambdaFunction" = "${var.RESOURCE_PREFIX}-invoke-api-key-rotation"
      "CustomersTableName" = "${var.CUSTOMER_TABLE_NAME}"
    }
  }
}

resource "aws_lambda_function" "lambda_invoke_api_key_rotation" {
  provider            = aws.src
  filename         = "${path.module}/zip/invoke-api-key-rotation.zip"
  function_name    = "${var.RESOURCE_PREFIX}-invoke-api-key-rotation"
  role             = "${var.LAMBDA_INVOKE_API_KEY_ROTATION_ROLE_ARN}"
  handler          = "index.handler"
  memory_size      = 512
  source_code_hash = "${data.archive_file.lambda_invoke_api_key_rotation_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "900"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "CustomersTableName" = "${var.CUSTOMER_TABLE_NAME}"
    }
  }
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [aws_lambda_function.lambda_cloudfront_security_function]

  destroy_duration = "900s"
}

resource "aws_s3_bucket_object" "upload_config_to_s3" {
  provider            = aws.src
  bucket       = "${var.WEBSITE_BUCKET_NAME}"
  key          = "config.js"
  content      = "${local.s3_config_rendered_content}"
  content_type = "application/javascript"
  source_hash  =  md5(local.s3_config_rendered_content)
}

resource "aws_s3_bucket_object" "upload_sdkGeneration_to_s3" {
  provider            = aws.src
  bucket       = "${var.ARTIFACTS_S3_BUCKET_NAME}"
  key          = "sdkGeneration.json"
  content      = "${local.s3_sdkGeneration_rendered_content}"
  content_type = "application/json"
  source_hash  =  md5(local.s3_sdkGeneration_rendered_content)
}

 resource "aws_s3_bucket_object" "upload_catalog_to_s3" {
   provider            = aws.src
   bucket       = "${var.ARTIFACTS_S3_BUCKET_NAME}"
   key          = "catalog.json"
   content      = "${local.s3_catalog_rendered_content}"
   content_type = "application/json"
   source_hash  =  md5(local.s3_catalog_rendered_content)
 }


resource "aws_lambda_permission" "lambda_authorizer_all_api_gateway_perm" {
  function_name = aws_lambda_function.lambda_api_key_authoriser_function.function_name
  statement_id  = "all-current-account-apigateways"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.AWS_REGION}:${var.AWS_ACCOUNT_ID}:*"
}


//NEW  LAMBDA FUNCTIONS

resource "aws_lambda_function" "lambda_signin_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/signin.zip"
  function_name    = "${var.RESOURCE_PREFIX}-signin"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_signin_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  environment {
    variables = {
      "NODE_ENV"                  = "${var.NODE_ENV}"
      "WEBSITE_BUCKET_NAME"       = "${var.WEBSITE_BUCKET_NAME}"
      "StaticBucketName"          = "${var.ARTIFACTS_S3_BUCKET_NAME}"
      "CustomersTableName"        = "${var.CUSTOMER_TABLE_NAME}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "FeedbackTableName"         = "${var.FEEDBACK_TABLE_NAME}"
      "FeedbackSnsTopicArn"       = "${var.FEEDBACK_SNS_TOPIC_ARN}"
      "UserPoolId"                = "${var.USERPOOL_ID}"
      "AdminsGroupName"           = "${var.ADMIN_GROUP_NAME}"
      "RegisteredGroupName"       = "${var.REGISTERED_GROUP_NAME}"
      "DevelopmentMode"           = "${var.DEVELOPMENT_MODE}"
      "CatalogUpdaterFunctionArn" = aws_lambda_function.lambda_catalog_updater_lambda_function.arn
    }
  }
}





resource "aws_lambda_function" "lambda_get_catalog_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/get-catalog.zip"
  function_name    = "${var.RESOURCE_PREFIX}-get-catalog"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_get_catalog_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "NODE_ENV"                  = "${var.NODE_ENV}"
      "WEBSITE_BUCKET_NAME"       = "${var.WEBSITE_BUCKET_NAME}"
      "StaticBucketName"          = "${var.ARTIFACTS_S3_BUCKET_NAME}"
      "CustomersTableName"        = "${var.CUSTOMER_TABLE_NAME}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "FeedbackTableName"         = "${var.FEEDBACK_TABLE_NAME}"
      "FeedbackSnsTopicArn"       = "${var.FEEDBACK_SNS_TOPIC_ARN}"
      "UserPoolId"                = "${var.USERPOOL_ID}"
      "AdminsGroupName"           = "${var.ADMIN_GROUP_NAME}"
      "RegisteredGroupName"       = "${var.REGISTERED_GROUP_NAME}"
      "DevelopmentMode"           = "${var.DEVELOPMENT_MODE}"
      "CatalogUpdaterFunctionArn" = aws_lambda_function.lambda_catalog_updater_lambda_function.arn
    }
  }
}

resource "aws_lambda_function" "lambda_get_apikey_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/get-apikey.zip"
  function_name    = "${var.RESOURCE_PREFIX}-get-apikey"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_get_apikey_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "NODE_ENV"                  = "${var.NODE_ENV}"
      "WEBSITE_BUCKET_NAME"       = "${var.WEBSITE_BUCKET_NAME}"
      "StaticBucketName"          = "${var.ARTIFACTS_S3_BUCKET_NAME}"
      "CustomersTableName"        = "${var.CUSTOMER_TABLE_NAME}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "FeedbackTableName"         = "${var.FEEDBACK_TABLE_NAME}"
      "FeedbackSnsTopicArn"       = "${var.FEEDBACK_SNS_TOPIC_ARN}"
      "UserPoolId"                = "${var.USERPOOL_ID}"
      "AdminsGroupName"           = "${var.ADMIN_GROUP_NAME}"
      "RegisteredGroupName"       = "${var.REGISTERED_GROUP_NAME}"
      "DevelopmentMode"           = "${var.DEVELOPMENT_MODE}"
      "CatalogUpdaterFunctionArn" = aws_lambda_function.lambda_catalog_updater_lambda_function.arn
    }
  }
}


resource "aws_lambda_function" "lambda_get_subscription_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/get-subscription.zip"
  function_name    = "${var.RESOURCE_PREFIX}-get-subscription"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_get_subscription_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "NODE_ENV"                  = "${var.NODE_ENV}"
      "WEBSITE_BUCKET_NAME"       = "${var.WEBSITE_BUCKET_NAME}"
      "StaticBucketName"          = "${var.ARTIFACTS_S3_BUCKET_NAME}"
      "CustomersTableName"        = "${var.CUSTOMER_TABLE_NAME}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "FeedbackTableName"         = "${var.FEEDBACK_TABLE_NAME}"
      "FeedbackSnsTopicArn"       = "${var.FEEDBACK_SNS_TOPIC_ARN}"
      "UserPoolId"                = "${var.USERPOOL_ID}"
      "AdminsGroupName"           = "${var.ADMIN_GROUP_NAME}"
      "RegisteredGroupName"       = "${var.REGISTERED_GROUP_NAME}"
      "DevelopmentMode"           = "${var.DEVELOPMENT_MODE}"
      "CatalogUpdaterFunctionArn" = aws_lambda_function.lambda_catalog_updater_lambda_function.arn
    }
  }
}

resource "aws_lambda_function" "lambda_update_subscription_usageplan_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/update-subscription-usageplan.zip"
  function_name    = "${var.RESOURCE_PREFIX}-update-subscription-usageplan"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_update_subscription_usageplan_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "NODE_ENV"                  = "${var.NODE_ENV}"
      "WEBSITE_BUCKET_NAME"       = "${var.WEBSITE_BUCKET_NAME}"
      "StaticBucketName"          = "${var.ARTIFACTS_S3_BUCKET_NAME}"
      "CustomersTableName"        = "${var.CUSTOMER_TABLE_NAME}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "FeedbackTableName"         = "${var.FEEDBACK_TABLE_NAME}"
      "FeedbackSnsTopicArn"       = "${var.FEEDBACK_SNS_TOPIC_ARN}"
      "UserPoolId"                = "${var.USERPOOL_ID}"
      "AdminsGroupName"           = "${var.ADMIN_GROUP_NAME}"
      "RegisteredGroupName"       = "${var.REGISTERED_GROUP_NAME}"
      "DevelopmentMode"           = "${var.DEVELOPMENT_MODE}"
      "CatalogUpdaterFunctionArn" = aws_lambda_function.lambda_catalog_updater_lambda_function.arn
    }
  }
}


resource "aws_lambda_function" "lambda_delete_subscription_usageplan_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/delete-subscription-usageplan.zip"
  function_name    = "${var.RESOURCE_PREFIX}-delete-subscription-usageplan"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_delete_subscription_usageplan_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "NODE_ENV"                  = "${var.NODE_ENV}"
      "WEBSITE_BUCKET_NAME"       = "${var.WEBSITE_BUCKET_NAME}"
      "StaticBucketName"          = "${var.ARTIFACTS_S3_BUCKET_NAME}"
      "CustomersTableName"        = "${var.CUSTOMER_TABLE_NAME}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "FeedbackTableName"         = "${var.FEEDBACK_TABLE_NAME}"
      "FeedbackSnsTopicArn"       = "${var.FEEDBACK_SNS_TOPIC_ARN}"
      "UserPoolId"                = "${var.USERPOOL_ID}"
      "AdminsGroupName"           = "${var.ADMIN_GROUP_NAME}"
      "RegisteredGroupName"       = "${var.REGISTERED_GROUP_NAME}"
      "DevelopmentMode"           = "${var.DEVELOPMENT_MODE}"
      "CatalogUpdaterFunctionArn" = aws_lambda_function.lambda_catalog_updater_lambda_function.arn
    }
  }
}

resource "aws_lambda_function" "lambda_get_subscription_usageplan_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/get-subscription-usageplan.zip"
  function_name    = "${var.RESOURCE_PREFIX}-get-subscription-usageplan"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_get_subscription_usageplan_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "NODE_ENV"                  = "${var.NODE_ENV}"
      "WEBSITE_BUCKET_NAME"       = "${var.WEBSITE_BUCKET_NAME}"
      "StaticBucketName"          = "${var.ARTIFACTS_S3_BUCKET_NAME}"
      "CustomersTableName"        = "${var.CUSTOMER_TABLE_NAME}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "FeedbackTableName"         = "${var.FEEDBACK_TABLE_NAME}"
      "FeedbackSnsTopicArn"       = "${var.FEEDBACK_SNS_TOPIC_ARN}"
      "UserPoolId"                = "${var.USERPOOL_ID}"
      "AdminsGroupName"           = "${var.ADMIN_GROUP_NAME}"
      "RegisteredGroupName"       = "${var.REGISTERED_GROUP_NAME}"
      "DevelopmentMode"           = "${var.DEVELOPMENT_MODE}"
      "CatalogUpdaterFunctionArn" = aws_lambda_function.lambda_catalog_updater_lambda_function.arn
    }
  }
}


resource "aws_lambda_function" "lambda_get_feedback_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/get-feedback.zip"
  function_name    = "${var.RESOURCE_PREFIX}-get-feedback"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_get_feedback_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }
  environment {
    variables = {
      "NODE_ENV"                  = "${var.NODE_ENV}"
      "WEBSITE_BUCKET_NAME"       = "${var.WEBSITE_BUCKET_NAME}"
      "StaticBucketName"          = "${var.ARTIFACTS_S3_BUCKET_NAME}"
      "CustomersTableName"        = "${var.CUSTOMER_TABLE_NAME}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "FeedbackTableName"         = "${var.FEEDBACK_TABLE_NAME}"
      "FeedbackSnsTopicArn"       = "${var.FEEDBACK_SNS_TOPIC_ARN}"
      "UserPoolId"                = "${var.USERPOOL_ID}"
      "AdminsGroupName"           = "${var.ADMIN_GROUP_NAME}"
      "RegisteredGroupName"       = "${var.REGISTERED_GROUP_NAME}"
      "DevelopmentMode"           = "${var.DEVELOPMENT_MODE}"
      "CatalogUpdaterFunctionArn" = aws_lambda_function.lambda_catalog_updater_lambda_function.arn
    }
  }
}

resource "aws_lambda_function" "lambda_post_feedback_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/post-feedback.zip"
  function_name    = "${var.RESOURCE_PREFIX}-post-feedback"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_post_feedback_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "NODE_ENV"                  = "${var.NODE_ENV}"
      "WEBSITE_BUCKET_NAME"       = "${var.WEBSITE_BUCKET_NAME}"
      "StaticBucketName"          = "${var.ARTIFACTS_S3_BUCKET_NAME}"
      "CustomersTableName"        = "${var.CUSTOMER_TABLE_NAME}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "FeedbackTableName"         = "${var.FEEDBACK_TABLE_NAME}"
      "FeedbackSnsTopicArn"       = "${var.FEEDBACK_SNS_TOPIC_ARN}"
      "UserPoolId"                = "${var.USERPOOL_ID}"
      "AdminsGroupName"           = "${var.ADMIN_GROUP_NAME}"
      "RegisteredGroupName"       = "${var.REGISTERED_GROUP_NAME}"
      "DevelopmentMode"           = "${var.DEVELOPMENT_MODE}"
      "CatalogUpdaterFunctionArn" = aws_lambda_function.lambda_catalog_updater_lambda_function.arn
    }
  }
}

resource "aws_lambda_function" "lambda_get_sdk_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/get-sdk.zip"
  function_name    = "${var.RESOURCE_PREFIX}-get-sdk"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_get_sdk_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "NODE_ENV"                  = "${var.NODE_ENV}"
      "WEBSITE_BUCKET_NAME"       = "${var.WEBSITE_BUCKET_NAME}"
      "StaticBucketName"          = "${var.ARTIFACTS_S3_BUCKET_NAME}"
      "CustomersTableName"        = "${var.CUSTOMER_TABLE_NAME}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "FeedbackTableName"         = "${var.FEEDBACK_TABLE_NAME}"
      "FeedbackSnsTopicArn"       = "${var.FEEDBACK_SNS_TOPIC_ARN}"
      "UserPoolId"                = "${var.USERPOOL_ID}"
      "AdminsGroupName"           = "${var.ADMIN_GROUP_NAME}"
      "RegisteredGroupName"       = "${var.REGISTERED_GROUP_NAME}"
      "DevelopmentMode"           = "${var.DEVELOPMENT_MODE}"
      "CatalogUpdaterFunctionArn" = aws_lambda_function.lambda_catalog_updater_lambda_function.arn
    }
  }
}

resource "aws_lambda_function" "lambda_export_api_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/export-api.zip"
  function_name    = "${var.RESOURCE_PREFIX}-export-api"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_export_api_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "NODE_ENV"                  = "${var.NODE_ENV}"
      "WEBSITE_BUCKET_NAME"       = "${var.WEBSITE_BUCKET_NAME}"
      "StaticBucketName"          = "${var.ARTIFACTS_S3_BUCKET_NAME}"
      "CustomersTableName"        = "${var.CUSTOMER_TABLE_NAME}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "FeedbackTableName"         = "${var.FEEDBACK_TABLE_NAME}"
      "FeedbackSnsTopicArn"       = "${var.FEEDBACK_SNS_TOPIC_ARN}"
      "UserPoolId"                = "${var.USERPOOL_ID}"
      "AdminsGroupName"           = "${var.ADMIN_GROUP_NAME}"
      "RegisteredGroupName"       = "${var.REGISTERED_GROUP_NAME}"
      "DevelopmentMode"           = "${var.DEVELOPMENT_MODE}"
      "CatalogUpdaterFunctionArn" = aws_lambda_function.lambda_catalog_updater_lambda_function.arn
    }
  }
}

resource "aws_lambda_function" "lambda_update_sdkgeneration_in_catalog_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/update-sdkgeneration-in-catalog.zip"
  function_name    = "${var.RESOURCE_PREFIX}-update-sdkgeneration-in-catalog"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_update_sdkgeneration_in_catalog_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "NODE_ENV"                  = "${var.NODE_ENV}"
      "WEBSITE_BUCKET_NAME"       = "${var.WEBSITE_BUCKET_NAME}"
      "StaticBucketName"          = "${var.ARTIFACTS_S3_BUCKET_NAME}"
      "CustomersTableName"        = "${var.CUSTOMER_TABLE_NAME}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "FeedbackTableName"         = "${var.FEEDBACK_TABLE_NAME}"
      "FeedbackSnsTopicArn"       = "${var.FEEDBACK_SNS_TOPIC_ARN}"
      "UserPoolId"                = "${var.USERPOOL_ID}"
      "AdminsGroupName"           = "${var.ADMIN_GROUP_NAME}"
      "RegisteredGroupName"       = "${var.REGISTERED_GROUP_NAME}"
      "DevelopmentMode"           = "${var.DEVELOPMENT_MODE}"
      "CatalogUpdaterFunctionArn" = aws_lambda_function.lambda_catalog_updater_lambda_function.arn
    }
  }
}

resource "aws_lambda_function" "lambda_delete_sdkgeneration_from_catalog_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/delete-sdkgeneration-from-catalog.zip"
  function_name    = "${var.RESOURCE_PREFIX}-delete-sdkgeneration-from-catalog"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_delete_sdkgeneration_from_catalog_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "NODE_ENV"                  = "${var.NODE_ENV}"
      "WEBSITE_BUCKET_NAME"       = "${var.WEBSITE_BUCKET_NAME}"
      "StaticBucketName"          = "${var.ARTIFACTS_S3_BUCKET_NAME}"
      "CustomersTableName"        = "${var.CUSTOMER_TABLE_NAME}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "FeedbackTableName"         = "${var.FEEDBACK_TABLE_NAME}"
      "FeedbackSnsTopicArn"       = "${var.FEEDBACK_SNS_TOPIC_ARN}"
      "UserPoolId"                = "${var.USERPOOL_ID}"
      "AdminsGroupName"           = "${var.ADMIN_GROUP_NAME}"
      "RegisteredGroupName"       = "${var.REGISTERED_GROUP_NAME}"
      "DevelopmentMode"           = "${var.DEVELOPMENT_MODE}"
      "CatalogUpdaterFunctionArn" = aws_lambda_function.lambda_catalog_updater_lambda_function.arn
    }
  }
}
resource "aws_lambda_function" "lambda_get_all_catalogs_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/get-all-catalogs.zip"
  function_name    = "${var.RESOURCE_PREFIX}-get-all-catalogs"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_get_all_catalogs_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "NODE_ENV"                  = "${var.NODE_ENV}"
      "WEBSITE_BUCKET_NAME"       = "${var.WEBSITE_BUCKET_NAME}"
      "StaticBucketName"          = "${var.ARTIFACTS_S3_BUCKET_NAME}"
      "CustomersTableName"        = "${var.CUSTOMER_TABLE_NAME}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "FeedbackTableName"         = "${var.FEEDBACK_TABLE_NAME}"
      "FeedbackSnsTopicArn"       = "${var.FEEDBACK_SNS_TOPIC_ARN}"
      "UserPoolId"                = "${var.USERPOOL_ID}"
      "AdminsGroupName"           = "${var.ADMIN_GROUP_NAME}"
      "RegisteredGroupName"       = "${var.REGISTERED_GROUP_NAME}"
      "DevelopmentMode"           = "${var.DEVELOPMENT_MODE}"
      "CatalogUpdaterFunctionArn" = aws_lambda_function.lambda_catalog_updater_lambda_function.arn
    }
  }
}

resource "aws_lambda_function" "lambda_add_new_api_to_catalog_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/update-catalog.zip"
  function_name    = "${var.RESOURCE_PREFIX}-update-catalog"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_add_new_api_to_catalog_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "NODE_ENV"                  = "${var.NODE_ENV}"
      "WEBSITE_BUCKET_NAME"       = "${var.WEBSITE_BUCKET_NAME}"
      "StaticBucketName"          = "${var.ARTIFACTS_S3_BUCKET_NAME}"
      "CustomersTableName"        = "${var.CUSTOMER_TABLE_NAME}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "FeedbackTableName"         = "${var.FEEDBACK_TABLE_NAME}"
      "FeedbackSnsTopicArn"       = "${var.FEEDBACK_SNS_TOPIC_ARN}"
      "UserPoolId"                = "${var.USERPOOL_ID}"
      "AdminsGroupName"           = "${var.ADMIN_GROUP_NAME}"
      "RegisteredGroupName"       = "${var.REGISTERED_GROUP_NAME}"
      "DevelopmentMode"           = "${var.DEVELOPMENT_MODE}"
      "CatalogUpdaterFunctionArn" = aws_lambda_function.lambda_catalog_updater_lambda_function.arn
    }
  }
}

resource "aws_lambda_function" "lambda_delete_api_from_catalog_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/delete-api-from-catalog.zip"
  function_name    = "${var.RESOURCE_PREFIX}-delete-api-from-catalog"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_delete_api_from_catalog_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "NODE_ENV"                  = "${var.NODE_ENV}"
      "WEBSITE_BUCKET_NAME"       = "${var.WEBSITE_BUCKET_NAME}"
      "StaticBucketName"          = "${var.ARTIFACTS_S3_BUCKET_NAME}"
      "CustomersTableName"        = "${var.CUSTOMER_TABLE_NAME}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "FeedbackTableName"         = "${var.FEEDBACK_TABLE_NAME}"
      "FeedbackSnsTopicArn"       = "${var.FEEDBACK_SNS_TOPIC_ARN}"
      "UserPoolId"                = "${var.USERPOOL_ID}"
      "AdminsGroupName"           = "${var.ADMIN_GROUP_NAME}"
      "RegisteredGroupName"       = "${var.REGISTERED_GROUP_NAME}"
      "DevelopmentMode"           = "${var.DEVELOPMENT_MODE}"
      "CatalogUpdaterFunctionArn" = aws_lambda_function.lambda_catalog_updater_lambda_function.arn
    }
  }
}

resource "aws_lambda_function" "lambda_get_all_accounts_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/get-accounts.zip"
  function_name    = "${var.RESOURCE_PREFIX}-get-accounts"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_get_all_accounts_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "NODE_ENV"                  = "${var.NODE_ENV}"
      "WEBSITE_BUCKET_NAME"       = "${var.WEBSITE_BUCKET_NAME}"
      "StaticBucketName"          = "${var.ARTIFACTS_S3_BUCKET_NAME}"
      "CustomersTableName"        = "${var.CUSTOMER_TABLE_NAME}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "FeedbackTableName"         = "${var.FEEDBACK_TABLE_NAME}"
      "FeedbackSnsTopicArn"       = "${var.FEEDBACK_SNS_TOPIC_ARN}"
      "UserPoolId"                = "${var.USERPOOL_ID}"
      "AdminsGroupName"           = "${var.ADMIN_GROUP_NAME}"
      "RegisteredGroupName"       = "${var.REGISTERED_GROUP_NAME}"
      "DevelopmentMode"           = "${var.DEVELOPMENT_MODE}"
      "CatalogUpdaterFunctionArn" = aws_lambda_function.lambda_catalog_updater_lambda_function.arn
    }
  }
}

resource "aws_lambda_function" "lambda_create_new_account_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/create-new-account.zip"
  function_name    = "${var.RESOURCE_PREFIX}-create-new-account"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_create_new_account_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "NODE_ENV"                  = "${var.NODE_ENV}"
      "WEBSITE_BUCKET_NAME"       = "${var.WEBSITE_BUCKET_NAME}"
      "StaticBucketName"          = "${var.ARTIFACTS_S3_BUCKET_NAME}"
      "CustomersTableName"        = "${var.CUSTOMER_TABLE_NAME}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "FeedbackTableName"         = "${var.FEEDBACK_TABLE_NAME}"
      "FeedbackSnsTopicArn"       = "${var.FEEDBACK_SNS_TOPIC_ARN}"
      "UserPoolId"                = "${var.USERPOOL_ID}"
      "AdminsGroupName"           = "${var.ADMIN_GROUP_NAME}"
      "RegisteredGroupName"       = "${var.REGISTERED_GROUP_NAME}"
      "DevelopmentMode"           = "${var.DEVELOPMENT_MODE}"
      "CatalogUpdaterFunctionArn" = aws_lambda_function.lambda_catalog_updater_lambda_function.arn
    }
  }
}

resource "aws_lambda_function" "lambda_promote_user_to_admin_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/promote-user-to-admin.zip"
  function_name    = "${var.RESOURCE_PREFIX}-promote-user-to-admin"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_promote_user_to_admin_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "NODE_ENV"                  = "${var.NODE_ENV}"
      "WEBSITE_BUCKET_NAME"       = "${var.WEBSITE_BUCKET_NAME}"
      "StaticBucketName"          = "${var.ARTIFACTS_S3_BUCKET_NAME}"
      "CustomersTableName"        = "${var.CUSTOMER_TABLE_NAME}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "FeedbackTableName"         = "${var.FEEDBACK_TABLE_NAME}"
      "FeedbackSnsTopicArn"       = "${var.FEEDBACK_SNS_TOPIC_ARN}"
      "UserPoolId"                = "${var.USERPOOL_ID}"
      "AdminsGroupName"           = "${var.ADMIN_GROUP_NAME}"
      "RegisteredGroupName"       = "${var.REGISTERED_GROUP_NAME}"
      "DevelopmentMode"           = "${var.DEVELOPMENT_MODE}"
      "CatalogUpdaterFunctionArn" = aws_lambda_function.lambda_catalog_updater_lambda_function.arn
    }
  }
}

resource "aws_lambda_function" "lambda_delete_user_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/delete-account.zip"
  function_name    = "${var.RESOURCE_PREFIX}-delete-account"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_delete_user_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "NODE_ENV"                  = "${var.NODE_ENV}"
      "WEBSITE_BUCKET_NAME"       = "${var.WEBSITE_BUCKET_NAME}"
      "StaticBucketName"          = "${var.ARTIFACTS_S3_BUCKET_NAME}"
      "CustomersTableName"        = "${var.CUSTOMER_TABLE_NAME}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "FeedbackTableName"         = "${var.FEEDBACK_TABLE_NAME}"
      "FeedbackSnsTopicArn"       = "${var.FEEDBACK_SNS_TOPIC_ARN}"
      "UserPoolId"                = "${var.USERPOOL_ID}"
      "AdminsGroupName"           = "${var.ADMIN_GROUP_NAME}"
      "RegisteredGroupName"       = "${var.REGISTERED_GROUP_NAME}"
      "DevelopmentMode"           = "${var.DEVELOPMENT_MODE}"
      "CatalogUpdaterFunctionArn" = aws_lambda_function.lambda_catalog_updater_lambda_function.arn
    }
  }
}


resource "aws_lambda_function" "lambda_get_user_callbackauth_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/get-user-callbackauth.zip"
  function_name    = "${var.RESOURCE_PREFIX}-get-user-callbackauth"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_get_user_callbackauth_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
 tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "NODE_ENV"                  = "${var.NODE_ENV}"
      "WEBSITE_BUCKET_NAME"       = "${var.WEBSITE_BUCKET_NAME}"
      "StaticBucketName"          = "${var.ARTIFACTS_S3_BUCKET_NAME}"
      "CustomersTableName"        = "${var.CUSTOMER_TABLE_NAME}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "FeedbackTableName"         = "${var.FEEDBACK_TABLE_NAME}"
      "FeedbackSnsTopicArn"       = "${var.FEEDBACK_SNS_TOPIC_ARN}"
      "UserPoolId"                = "${var.USERPOOL_ID}"
      "AdminsGroupName"           = "${var.ADMIN_GROUP_NAME}"
      "RegisteredGroupName"       = "${var.REGISTERED_GROUP_NAME}"
      "DevelopmentMode"           = "${var.DEVELOPMENT_MODE}"
      "CatalogUpdaterFunctionArn" = aws_lambda_function.lambda_catalog_updater_lambda_function.arn
    }
  }
}

resource "aws_lambda_function" "lambda_resend_invite_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/resend-invite.zip"
  function_name    = "${var.RESOURCE_PREFIX}-resend-invite"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_resend_invite_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "NODE_ENV"                  = "${var.NODE_ENV}"
      "WEBSITE_BUCKET_NAME"       = "${var.WEBSITE_BUCKET_NAME}"
      "StaticBucketName"          = "${var.ARTIFACTS_S3_BUCKET_NAME}"
      "CustomersTableName"        = "${var.CUSTOMER_TABLE_NAME}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "FeedbackTableName"         = "${var.FEEDBACK_TABLE_NAME}"
      "FeedbackSnsTopicArn"       = "${var.FEEDBACK_SNS_TOPIC_ARN}"
      "UserPoolId"                = "${var.USERPOOL_ID}"
      "AdminsGroupName"           = "${var.ADMIN_GROUP_NAME}"
      "RegisteredGroupName"       = "${var.REGISTERED_GROUP_NAME}"
      "DevelopmentMode"           = "${var.DEVELOPMENT_MODE}"
      "CatalogUpdaterFunctionArn" = aws_lambda_function.lambda_catalog_updater_lambda_function.arn
    }
  }
}


resource "aws_lambda_function" "lambda_get_current_user_profile_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/get-current-user-profile.zip"
  function_name    = "${var.RESOURCE_PREFIX}-get-current-user-profile"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_get_current_user_profile_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "NODE_ENV"                  = "${var.NODE_ENV}"
      "WEBSITE_BUCKET_NAME"       = "${var.WEBSITE_BUCKET_NAME}"
      "StaticBucketName"          = "${var.ARTIFACTS_S3_BUCKET_NAME}"
      "CustomersTableName"        = "${var.CUSTOMER_TABLE_NAME}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "FeedbackTableName"         = "${var.FEEDBACK_TABLE_NAME}"
      "FeedbackSnsTopicArn"       = "${var.FEEDBACK_SNS_TOPIC_ARN}"
      "UserPoolId"                = "${var.USERPOOL_ID}"
      "AdminsGroupName"           = "${var.ADMIN_GROUP_NAME}"
      "RegisteredGroupName"       = "${var.REGISTERED_GROUP_NAME}"
      "DevelopmentMode"           = "${var.DEVELOPMENT_MODE}"
      "CatalogUpdaterFunctionArn" = aws_lambda_function.lambda_catalog_updater_lambda_function.arn
    }
  }
}


resource "aws_lambda_function" "lambda_update_user_profile_image_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/update-profile-image.zip"
  function_name    = "${var.RESOURCE_PREFIX}-update-profile-image"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_update_user_profile_image_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "NODE_ENV"                  = "${var.NODE_ENV}"
      "WEBSITE_BUCKET_NAME"       = "${var.WEBSITE_BUCKET_NAME}"
      "StaticBucketName"          = "${var.ARTIFACTS_S3_BUCKET_NAME}"
      "CustomersTableName"        = "${var.CUSTOMER_TABLE_NAME}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "FeedbackTableName"         = "${var.FEEDBACK_TABLE_NAME}"
      "FeedbackSnsTopicArn"       = "${var.FEEDBACK_SNS_TOPIC_ARN}"
      "UserPoolId"                = "${var.USERPOOL_ID}"
      "AdminsGroupName"           = "${var.ADMIN_GROUP_NAME}"
      "RegisteredGroupName"       = "${var.REGISTERED_GROUP_NAME}"
      "DevelopmentMode"           = "${var.DEVELOPMENT_MODE}"
      "CatalogUpdaterFunctionArn" = aws_lambda_function.lambda_catalog_updater_lambda_function.arn
    }
  }
}


resource "aws_lambda_function" "lambda_get_user_profile_image_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/get-profile-image.zip"
  function_name    = "${var.RESOURCE_PREFIX}-get-profile-image"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_get_user_profile_image_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "NODE_ENV"                  = "${var.NODE_ENV}"
      "WEBSITE_BUCKET_NAME"       = "${var.WEBSITE_BUCKET_NAME}"
      "StaticBucketName"          = "${var.ARTIFACTS_S3_BUCKET_NAME}"
      "CustomersTableName"        = "${var.CUSTOMER_TABLE_NAME}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "FeedbackTableName"         = "${var.FEEDBACK_TABLE_NAME}"
      "FeedbackSnsTopicArn"       = "${var.FEEDBACK_SNS_TOPIC_ARN}"
      "UserPoolId"                = "${var.USERPOOL_ID}"
      "AdminsGroupName"           = "${var.ADMIN_GROUP_NAME}"
      "RegisteredGroupName"       = "${var.REGISTERED_GROUP_NAME}"
      "DevelopmentMode"           = "${var.DEVELOPMENT_MODE}"
      "CatalogUpdaterFunctionArn" = aws_lambda_function.lambda_catalog_updater_lambda_function.arn
    }
  }
}



resource "aws_lambda_function" "lambda_create_mno_third_party_resources_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/create-mno-third-party-resources.zip"
  function_name    = "${var.RESOURCE_PREFIX}-create-mno-third-party-resources"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_create_mno_third_party_resources_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "NODE_ENV"                  = "${var.NODE_ENV}"
      "WEBSITE_BUCKET_NAME"       = "${var.WEBSITE_BUCKET_NAME}"
      "StaticBucketName"          = "${var.ARTIFACTS_S3_BUCKET_NAME}"
      "CustomersTableName"        = "${var.CUSTOMER_TABLE_NAME}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "MnoThirdPartyResourceTableName" = "${var.MNO_THIRD_PARTY_RESOURCE_TABLE_NAME}"

      "FeedbackTableName"         = "${var.FEEDBACK_TABLE_NAME}"
      "FeedbackSnsTopicArn"       = "${var.FEEDBACK_SNS_TOPIC_ARN}"
      "MNO_UserPoolId"            = "${var.MNO_USERPOOL_ID}"
      "Third_Party_UserPoolId"    = "${var.THIRD_PARTY_USERPOOL_ID}"
      "AdminsGroupName"           = "${var.ADMIN_GROUP_NAME}"
      "RegisteredGroupName"       = "${var.REGISTERED_GROUP_NAME}"
      "DevelopmentMode"           = "${var.DEVELOPMENT_MODE}"
      "CatalogUpdaterFunctionArn" = aws_lambda_function.lambda_catalog_updater_lambda_function.arn
    }
  }
}



resource "aws_lambda_function" "lambda_get_mno_third_party_resources_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/get-mno-third-party-resources.zip"
  function_name    = "${var.RESOURCE_PREFIX}-get-mno-third-party-resources"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_backend_lambda_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "NODE_ENV"                  = "${var.NODE_ENV}"
      "WEBSITE_BUCKET_NAME"       = "${var.WEBSITE_BUCKET_NAME}"
      "StaticBucketName"          = "${var.ARTIFACTS_S3_BUCKET_NAME}"
      "CustomersTableName"        = "${var.CUSTOMER_TABLE_NAME}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "FeedbackTableName"         = "${var.FEEDBACK_TABLE_NAME}"
      "FeedbackSnsTopicArn"       = "${var.FEEDBACK_SNS_TOPIC_ARN}"
      "UserPoolId"                = "${var.USERPOOL_ID}"
      "AdminsGroupName"           = "${var.ADMIN_GROUP_NAME}"
      "RegisteredGroupName"       = "${var.REGISTERED_GROUP_NAME}"
      "DevelopmentMode"           = "${var.DEVELOPMENT_MODE}"
      "MnoThirdPartyResourceTableName" = "${var.MNO_THIRD_PARTY_RESOURCE_TABLE_NAME}"
      "CatalogUpdaterFunctionArn" = aws_lambda_function.lambda_catalog_updater_lambda_function.arn

    }
  }
} 

resource "aws_lambda_function" "lambda_create_permissions_for_api_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/create-permissions-for-api.zip"
  function_name    = "${var.RESOURCE_PREFIX}-create-permissions-for-api"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_backend_lambda_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "ApiPermissionTableName"    = "${var.API_PERMISSION_TABLE_NAME}"
      "UserPoolId"                = "${var.USERPOOL_ID}"
    }
  }
}

resource "aws_lambda_function" "lambda_get_allowed_apis_for_resource_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/get-allowed-apis-for-resource.zip"
  function_name    = "${var.RESOURCE_PREFIX}-get-allowed-apis-for-resource"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_create_permissions_for_api_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  environment {
    variables = {
      "ApiPermissionTableName"    = "${var.API_PERMISSION_TABLE_NAME}"
      "UserPoolId"                = "${var.USERPOOL_ID}"
    }
  }
}
resource "aws_lambda_function" "lambda_delete_allowed_api_for_resource_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/delete-allowed-apis-for-resource.zip"
  function_name    = "${var.RESOURCE_PREFIX}-delete-allowed-apis-for-resource"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_delete_allowed_api_for_resource_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "ApiPermissionTableName"    = "${var.API_PERMISSION_TABLE_NAME}"
      "UserPoolId"                = "${var.USERPOOL_ID}"
    }
  }
}

resource "aws_lambda_function" "lambda_update_allowed_api_for_resource_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/update-permissions-for-api.zip"
  function_name    = "${var.RESOURCE_PREFIX}-update-permissions-for-api"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_update_permissions_for_api_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "ApiPermissionTableName"    = "${var.API_PERMISSION_TABLE_NAME}"
      "UserPoolId"                = "${var.USERPOOL_ID}"
    }
  }
}


resource "aws_lambda_function" "lambda_developer_portal_authoriser_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/developer-portal-authoriser.zip"
  function_name    = "${var.RESOURCE_PREFIX}-developer-portal-authoriser"
  role             = "${var.DEVELOPER_PORTAL_AUTHORIZER_ROLE_ARN}"
  handler          = "authoriser.handler"
  memory_size      = 512
  source_code_hash = "${data.archive_file.lambda_developer_portal_authoriser_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "900"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }
  environment {
    variables = {
      "UserPoolId"         = "${var.USERPOOL_ID}"
      "ApiRolePermissionTable" = "${var.API_ROLE_PERMISSION_TABLE_NAME}"
      "CustomersTableName" = "${var.CUSTOMER_TABLE_NAME}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "ApiPermissionTable" = "${var.API_PERMISSION_TABLE_NAME}"
    }
  }
}


resource "aws_lambda_function" "lambda_get_mno_third_party_resources_by_id_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/get-mno-third-party-resources-by-id.zip"
  function_name    = "${var.RESOURCE_PREFIX}-get-mno-third-party-resources-by-id"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_backend_lambda_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }
  environment {
    variables = {
      "NODE_ENV"                  = "${var.NODE_ENV}"
      "WEBSITE_BUCKET_NAME"       = "${var.WEBSITE_BUCKET_NAME}"
      "StaticBucketName"          = "${var.ARTIFACTS_S3_BUCKET_NAME}"
      "CustomersTableName"        = "${var.CUSTOMER_TABLE_NAME}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "FeedbackTableName"         = "${var.FEEDBACK_TABLE_NAME}"
      "FeedbackSnsTopicArn"       = "${var.FEEDBACK_SNS_TOPIC_ARN}"
      "UserPoolId"                = "${var.USERPOOL_ID}"
      "AdminsGroupName"           = "${var.ADMIN_GROUP_NAME}"
      "RegisteredGroupName"       = "${var.REGISTERED_GROUP_NAME}"
      "DevelopmentMode"           = "${var.DEVELOPMENT_MODE}"
      "MnoThirdPartyResourceTableName" = "${var.MNO_THIRD_PARTY_RESOURCE_TABLE_NAME}"

      "CatalogUpdaterFunctionArn" = aws_lambda_function.lambda_catalog_updater_lambda_function.arn

    }
  }
} 

resource "aws_lambda_function" "lambda_get_third_party_resources_by_type_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/get-third-party-resources-by-type.zip"
  function_name    = "${var.RESOURCE_PREFIX}-get-third-party-resources-type-id"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_backend_lambda_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
 tracing_config {
    mode = "PassThrough"
  }
  environment {
    variables = {
      "NODE_ENV"                  = "${var.NODE_ENV}"
      "WEBSITE_BUCKET_NAME"       = "${var.WEBSITE_BUCKET_NAME}"
      "StaticBucketName"          = "${var.ARTIFACTS_S3_BUCKET_NAME}"
      "CustomersTableName"        = "${var.CUSTOMER_TABLE_NAME}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "FeedbackTableName"         = "${var.FEEDBACK_TABLE_NAME}"
      "FeedbackSnsTopicArn"       = "${var.FEEDBACK_SNS_TOPIC_ARN}"
      "UserPoolId"                = "${var.USERPOOL_ID}"
      "AdminsGroupName"           = "${var.ADMIN_GROUP_NAME}"
      "RegisteredGroupName"       = "${var.REGISTERED_GROUP_NAME}"
      "DevelopmentMode"           = "${var.DEVELOPMENT_MODE}"
      "CatalogUpdaterFunctionArn" = aws_lambda_function.lambda_catalog_updater_lambda_function.arn

    }
  }
} 

resource "aws_lambda_function" "lambda_get_mno_resources_by_type_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/get-mno-resources-by-type.zip"
  function_name    = "${var.RESOURCE_PREFIX}-get-mno-resources-type-id"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_backend_lambda_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }
  environment {
    variables = {
      "NODE_ENV"                  = "${var.NODE_ENV}"
      "WEBSITE_BUCKET_NAME"       = "${var.WEBSITE_BUCKET_NAME}"
      "StaticBucketName"          = "${var.ARTIFACTS_S3_BUCKET_NAME}"
      "CustomersTableName"        = "${var.CUSTOMER_TABLE_NAME}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "FeedbackTableName"         = "${var.FEEDBACK_TABLE_NAME}"
      "FeedbackSnsTopicArn"       = "${var.FEEDBACK_SNS_TOPIC_ARN}"
      "UserPoolId"                = "${var.USERPOOL_ID}"
      "AdminsGroupName"           = "${var.ADMIN_GROUP_NAME}"
      "RegisteredGroupName"       = "${var.REGISTERED_GROUP_NAME}"
      "DevelopmentMode"           = "${var.DEVELOPMENT_MODE}"
      "MnoThirdPartyResourceTableName" = "${var.MNO_THIRD_PARTY_RESOURCE_TABLE_NAME}"
      "CatalogUpdaterFunctionArn" = aws_lambda_function.lambda_catalog_updater_lambda_function.arn

    }
  }
} 


resource "aws_lambda_function" "lambda_get_third_party_resource_users_account_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/get-third-party-resource-users-accounts.zip"
  function_name    = "${var.RESOURCE_PREFIX}-get-third-party-resource-users-accounts"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_backend_lambda_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }
  environment {
    variables = {
      "NODE_ENV"                  = "${var.NODE_ENV}"
      "WEBSITE_BUCKET_NAME"       = "${var.WEBSITE_BUCKET_NAME}"
      "StaticBucketName"          = "${var.ARTIFACTS_S3_BUCKET_NAME}"
      "CustomersTableName"        = "${var.CUSTOMER_TABLE_NAME}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "FeedbackTableName"         = "${var.FEEDBACK_TABLE_NAME}"
      "FeedbackSnsTopicArn"       = "${var.FEEDBACK_SNS_TOPIC_ARN}"
      "UserPoolId"                = "${var.USERPOOL_ID}"
      "AdminsGroupName"           = "${var.ADMIN_GROUP_NAME}"
      "RegisteredGroupName"       = "${var.REGISTERED_GROUP_NAME}"
      "DevelopmentMode"           = "${var.DEVELOPMENT_MODE}"
      "CatalogUpdaterFunctionArn" = aws_lambda_function.lambda_catalog_updater_lambda_function.arn

    }
  }
} 

resource "aws_lambda_function" "lambda_get_mno_resource_users_account_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/get-mno-resource-users-accounts.zip"
  function_name    = "${var.RESOURCE_PREFIX}-get-mno-resource-users-accounts"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_backend_lambda_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }
  environment {
    variables = {
      "NODE_ENV"                  = "${var.NODE_ENV}"
      "WEBSITE_BUCKET_NAME"       = "${var.WEBSITE_BUCKET_NAME}"
      "StaticBucketName"          = "${var.ARTIFACTS_S3_BUCKET_NAME}"
      "CustomersTableName"        = "${var.CUSTOMER_TABLE_NAME}"
      "MnoThirdPartyResourceTableName" = "${var.MNO_THIRD_PARTY_RESOURCE_TABLE_NAME}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "FeedbackTableName"         = "${var.FEEDBACK_TABLE_NAME}"
      "FeedbackSnsTopicArn"       = "${var.FEEDBACK_SNS_TOPIC_ARN}"
      "UserPoolId"                = "${var.USERPOOL_ID}"
      "AdminsGroupName"           = "${var.ADMIN_GROUP_NAME}"
      "RegisteredGroupName"       = "${var.REGISTERED_GROUP_NAME}"
      "DevelopmentMode"           = "${var.DEVELOPMENT_MODE}"
      "CatalogUpdaterFunctionArn" = aws_lambda_function.lambda_catalog_updater_lambda_function.arn

    }
  }
} 

resource "aws_lambda_function" "lambda_get_mno_user_by_id_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/get-mno-user-by-id.zip"
  function_name    = "${var.RESOURCE_PREFIX}-get-mno-user-id-id"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_backend_lambda_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "NODE_ENV"                  = "${var.NODE_ENV}"
      "WEBSITE_BUCKET_NAME"       = "${var.WEBSITE_BUCKET_NAME}"
      "StaticBucketName"          = "${var.ARTIFACTS_S3_BUCKET_NAME}"
      "CustomersTableName"        = "${var.CUSTOMER_TABLE_NAME}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "FeedbackTableName"         = "${var.FEEDBACK_TABLE_NAME}"
      "FeedbackSnsTopicArn"       = "${var.FEEDBACK_SNS_TOPIC_ARN}"
      "UserPoolId"                = "${var.USERPOOL_ID}"
      "AdminsGroupName"           = "${var.ADMIN_GROUP_NAME}"
      "RegisteredGroupName"       = "${var.REGISTERED_GROUP_NAME}"
      "DevelopmentMode"           = "${var.DEVELOPMENT_MODE}"
      "CatalogUpdaterFunctionArn" = aws_lambda_function.lambda_catalog_updater_lambda_function.arn

    }
  }
} 

resource "aws_lambda_function" "lambda_get_third_party_user_by_id_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/get-third-party-user-by-id.zip"
  function_name    = "${var.RESOURCE_PREFIX}-get-third-party-user-id"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_backend_lambda_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }
  environment {
    variables = {
      "NODE_ENV"                  = "${var.NODE_ENV}"
      "WEBSITE_BUCKET_NAME"       = "${var.WEBSITE_BUCKET_NAME}"
      "StaticBucketName"          = "${var.ARTIFACTS_S3_BUCKET_NAME}"
      "CustomersTableName"        = "${var.CUSTOMER_TABLE_NAME}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "FeedbackTableName"         = "${var.FEEDBACK_TABLE_NAME}"
      "FeedbackSnsTopicArn"       = "${var.FEEDBACK_SNS_TOPIC_ARN}"
      "UserPoolId"                = "${var.USERPOOL_ID}"
      "AdminsGroupName"           = "${var.ADMIN_GROUP_NAME}"
      "RegisteredGroupName"       = "${var.REGISTERED_GROUP_NAME}"
      "DevelopmentMode"           = "${var.DEVELOPMENT_MODE}"
      "CatalogUpdaterFunctionArn" = aws_lambda_function.lambda_catalog_updater_lambda_function.arn

    }
  }
} 


resource "aws_lambda_function" "lambda_create_mno_resource_user_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/create-mno-resource-user.zip"
  function_name    = "${var.RESOURCE_PREFIX}-create-mno-resource-user"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_backend_lambda_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "NODE_ENV"                  = "${var.NODE_ENV}"
      "WEBSITE_BUCKET_NAME"       = "${var.WEBSITE_BUCKET_NAME}"
      "StaticBucketName"          = "${var.ARTIFACTS_S3_BUCKET_NAME}"
      "CustomersTableName"        = "${var.CUSTOMER_TABLE_NAME}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "FeedbackTableName"         = "${var.FEEDBACK_TABLE_NAME}"
      "FeedbackSnsTopicArn"       = "${var.FEEDBACK_SNS_TOPIC_ARN}"
      "MNO_UserPoolId"            = "${var.MNO_USERPOOL_ID}"
     "AdminsGroupName"           = "${var.ADMIN_GROUP_NAME}"
      "RegisteredGroupName"       = "${var.REGISTERED_GROUP_NAME}"
      "DevelopmentMode"           = "${var.DEVELOPMENT_MODE}"
      "CatalogUpdaterFunctionArn" = aws_lambda_function.lambda_catalog_updater_lambda_function.arn
      "MnoThirdPartyResourceTableName" = "${var.MNO_THIRD_PARTY_RESOURCE_TABLE_NAME}"


    }
  }
} 


resource "aws_lambda_function" "lambda_create_third_party_resource_user_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/create-third-party-resource-user.zip"
  function_name    = "${var.RESOURCE_PREFIX}-create-third-party-resource-user"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_backend_lambda_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "NODE_ENV"                  = "${var.NODE_ENV}"
      "WEBSITE_BUCKET_NAME"       = "${var.WEBSITE_BUCKET_NAME}"
      "StaticBucketName"          = "${var.ARTIFACTS_S3_BUCKET_NAME}"
      "CustomersTableName"        = "${var.CUSTOMER_TABLE_NAME}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "FeedbackTableName"         = "${var.FEEDBACK_TABLE_NAME}"
      "FeedbackSnsTopicArn"       = "${var.FEEDBACK_SNS_TOPIC_ARN}"
      "Third_Party_UserPoolId"    = "${var.THIRD_PARTY_USERPOOL_ID}"
     "AdminsGroupName"           = "${var.ADMIN_GROUP_NAME}"
      "RegisteredGroupName"       = "${var.REGISTERED_GROUP_NAME}"
      "DevelopmentMode"           = "${var.DEVELOPMENT_MODE}"
      "CatalogUpdaterFunctionArn" = aws_lambda_function.lambda_catalog_updater_lambda_function.arn

    }
  }
} 


//DELETE

resource "aws_lambda_function" "lambda_delete_third_party_resource_user_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/delete-third-party-resource-user.zip"
  function_name    = "${var.RESOURCE_PREFIX}-delete-third-party-resource"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_backend_lambda_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "NODE_ENV"                  = "${var.NODE_ENV}"
      "WEBSITE_BUCKET_NAME"       = "${var.WEBSITE_BUCKET_NAME}"
      "StaticBucketName"          = "${var.ARTIFACTS_S3_BUCKET_NAME}"
      "CustomersTableName"        = "${var.CUSTOMER_TABLE_NAME}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "FeedbackTableName"         = "${var.FEEDBACK_TABLE_NAME}"
      "FeedbackSnsTopicArn"       = "${var.FEEDBACK_SNS_TOPIC_ARN}"
       "Third_Party_UserPoolId"    = "${var.THIRD_PARTY_USERPOOL_ID}"
     "AdminsGroupName"           = "${var.ADMIN_GROUP_NAME}"
      "RegisteredGroupName"       = "${var.REGISTERED_GROUP_NAME}"
      "DevelopmentMode"           = "${var.DEVELOPMENT_MODE}"
      "CatalogUpdaterFunctionArn" = aws_lambda_function.lambda_catalog_updater_lambda_function.arn

    }
  }
} 


resource "aws_lambda_function" "lambda_delete_mno_resource_user_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/delete-mno-resource-user.zip"
  function_name    = "${var.RESOURCE_PREFIX}-delete-mno-resource-user"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_backend_lambda_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "NODE_ENV"                  = "${var.NODE_ENV}"
      "WEBSITE_BUCKET_NAME"       = "${var.WEBSITE_BUCKET_NAME}"
      "StaticBucketName"          = "${var.ARTIFACTS_S3_BUCKET_NAME}"
      "CustomersTableName"        = "${var.CUSTOMER_TABLE_NAME}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "FeedbackTableName"         = "${var.FEEDBACK_TABLE_NAME}"
      "FeedbackSnsTopicArn"       = "${var.FEEDBACK_SNS_TOPIC_ARN}"
      "MNO_UserPoolId"    = "${var.MNO_USERPOOL_ID}"
     "AdminsGroupName"           = "${var.ADMIN_GROUP_NAME}"
      "RegisteredGroupName"       = "${var.REGISTERED_GROUP_NAME}"
      "DevelopmentMode"           = "${var.DEVELOPMENT_MODE}"
      "CatalogUpdaterFunctionArn" = aws_lambda_function.lambda_catalog_updater_lambda_function.arn
      "MnoThirdPartyResourceTableName" = "${var.MNO_THIRD_PARTY_RESOURCE_TABLE_NAME}"


    }
  }
} 


resource "aws_lambda_function" "lambda_update_user_account_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/update-user-account.zip"
  function_name    = "${var.RESOURCE_PREFIX}-update-user-account"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_update_user_account_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "NODE_ENV"                  = "${var.NODE_ENV}"
      "WEBSITE_BUCKET_NAME"       = "${var.WEBSITE_BUCKET_NAME}"
      "StaticBucketName"          = "${var.ARTIFACTS_S3_BUCKET_NAME}"
      "CustomersTableName"        = "${var.CUSTOMER_TABLE_NAME}"
      "PreLoginAccountsTableName" = "${var.PRE_LOGIN_ACCOUNT_TABLE_NAME}"
      "FeedbackTableName"         = "${var.FEEDBACK_TABLE_NAME}"
      "FeedbackSnsTopicArn"       = "${var.FEEDBACK_SNS_TOPIC_ARN}"
      "UserPoolId"                = "${var.USERPOOL_ID}"
      "AdminsGroupName"           = "${var.ADMIN_GROUP_NAME}"
      "RegisteredGroupName"       = "${var.REGISTERED_GROUP_NAME}"
      "DevelopmentMode"           = "${var.DEVELOPMENT_MODE}"
      "CatalogUpdaterFunctionArn" = aws_lambda_function.lambda_catalog_updater_lambda_function.arn
    }
  }
}

resource "aws_lambda_function" "lambda_get_all_apis_for_resource_function" {
  provider            = aws.src
  filename         = "${path.module}/zip/get-all-apis-permissions-for-resources.zip"
  function_name    = "${var.RESOURCE_PREFIX}-get-all-apis-permissions-for-resources"
  role             = "${var.LAMBDA_BACKEND_ROLE_ARN}"
  handler          = "index.handler"
  source_code_hash = "${data.archive_file.lambda_create_permissions_for_api_function.output_base64sha256}"
  runtime          = "nodejs12.x"
  timeout          = "20"
  layers           = ["${aws_lambda_layer_version.lambda-common-layer.arn}"]
  tracing_config {
    mode = "PassThrough"
  }  
  environment {
    variables = {
      "ApiPermissionTableName"    = "${var.API_PERMISSION_TABLE_NAME}"
      "UserPoolId"                = "${var.USERPOOL_ID}"
    }
  }
}
resource "aws_iam_policy" "lambda_catalog_updater_policy" {
  provider         = aws.src
  name   = "${var.RESOURCE_PREFIX}-lambda-catalog-updater-policy"
  #tfsec:ignore:AWS099
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:log-group:/aws/lambda/${var.CATALOG_UPDATER_LAMBDA_NAME}:*"
        
    },
    {
      "Effect": "Allow",
      "Action": [
        "apigateway:GET",
        "apigateway:POST",
        "apigateway:PUT",
        "apigateway:PATCH",
        "apigateway:DELETE"
      ],
      "Resource": [
        "arn:aws:apigateway:${var.AWS_REGION}::/apikeys",
        "arn:aws:apigateway:${var.AWS_REGION}::/usageplans",
        "arn:aws:apigateway:${var.AWS_REGION}::/restapis",
        "arn:aws:apigateway:${var.AWS_REGION}::/apikeys/*",
        "arn:aws:apigateway:${var.AWS_REGION}::/restapis/*",
        "arn:aws:apigateway:${var.AWS_REGION}::/usageplans/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::${var.WEBSITE_BUCKET_NAME}",
        "arn:aws:s3:::${var.WEBSITE_BUCKET_NAME}/*",
        "arn:aws:s3:::${var.ARTIFACTS_S3_BUCKET_NAME}",
        "arn:aws:s3:::${var.ARTIFACTS_S3_BUCKET_NAME}/*"
      ]
    },
        {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::${var.ARTIFACTS_S3_BUCKET_NAME}",
        "arn:aws:s3:::${var.ARTIFACTS_S3_BUCKET_NAME}/*"
      ]
    },
    {
        "Effect": "Allow",
        "Action": [
            "lambda:InvokeFunction",
            "lambda:InvokeAsync"
        ],
        "Resource": "arn:aws:lambda:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:function:${var.CATALOG_UPDATER_LAMBDA_NAME}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:CreateSecret",
        "secretsmanager:PutSecretValue",
        "secretsmanager:GetSecretValue"
      ],
      "Resource": "arn:aws:secretsmanager:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:secret:*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda-catalog-updater-policy-role-attachment" {
  provider         = aws.src
  role       = var.LAMBDA_CATALOG_UPDATER_ROLE_NAME
  policy_arn = aws_iam_policy.lambda_catalog_updater_policy.arn
}



resource "aws_iam_policy" "lambda_backend_policy" {
  provider         = aws.src
  name   = "${var.RESOURCE_PREFIX}-lambda-backend-policy"
  #tfsec:ignore:AWS099
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:log-group:/aws/lambda/*"
        
    },
    {
      "Effect": "Allow",
      "Action": [
        "apigateway:GET",
        "apigateway:POST",
        "apigateway:PUT",
        "apigateway:PATCH",
        "apigateway:DELETE"
      ],
      "Resource": [
        "arn:aws:apigateway:${var.AWS_REGION}::/apikeys",
        "arn:aws:apigateway:${var.AWS_REGION}::/usageplans",
        "arn:aws:apigateway:${var.AWS_REGION}::/restapis",
        "arn:aws:apigateway:${var.AWS_REGION}::/apikeys/*",
        "arn:aws:apigateway:${var.AWS_REGION}::/restapis/*",
        "arn:aws:apigateway:${var.AWS_REGION}::/usageplans/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::${var.WEBSITE_BUCKET_NAME}/*",
        "arn:aws:s3:::${var.WEBSITE_BUCKET_NAME}",
        "arn:aws:s3:::${var.ARTIFACTS_S3_BUCKET_NAME}",
        "arn:aws:s3:::${var.ARTIFACTS_S3_BUCKET_NAME}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:Query",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
        "dynamodb:Scan"

      ],
      "Resource": [
        "arn:aws:dynamodb:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:table/${var.CUSTOMER_TABLE_NAME}",
        "${var.PRE_LOGIN_TABLE_ARN}",
        "${var.API_ROLE_PERMISSION_TABLE_ARN}",
        "${var.API_PERMISSION_TABLE_ARN}",
        "${var.MNO_THIRD_PARTY_RESOURCE_TABLE_ARN}"
        
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:PutObject"
      ],
      "Resource": [
        "arn:aws:s3:::${var.WEBSITE_BUCKET_NAME}/*",
        "arn:aws:s3:::${var.WEBSITE_BUCKET_NAME}",
        "arn:aws:s3:::${var.ARTIFACTS_S3_BUCKET_NAME}",
        "arn:aws:s3:::${var.ARTIFACTS_S3_BUCKET_NAME}/*"
      ]
    },
{
      "Effect": "Allow",
      "Action": [
        "cognito-idp:AdminListGroupsForUser",
        "cognito-idp:ListUsersInGroup",
        "cognito-idp:ListUsers",
        "cognito-idp:AdminCreateUser",
        "cognito-idp:AdminDeleteUser",
        "cognito-idp:AdminSetUserMFAPreference",
        "cognito-idp:AdminUpdateUserAttributes",
        "cognito-idp:AdminAddUserToGroup"
      ],
      "Resource": [
          "arn:aws:cognito-idp:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:userpool/${var.USERPOOL_ID}",
          "arn:aws:cognito-idp:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:userpool/*"
      ]
        
},
{
      "Effect": "Allow",
      "Action": [
        "lambda:InvokeFunction"
      ],
      "Resource": ["arn:aws:cognito-idp:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:userpool/${var.USERPOOL_ID}",
      "arn:aws:cognito-idp:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:userpool/${var.MNO_USERPOOL_ID}",
      "arn:aws:cognito-idp:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:userpool/${var.THIRD_PARTY_USERPOOL_ID}",
       "${var.CREATE_INITIAL_RESOURCES_LAMBDA_ARN}"
      ]

},
{
      "Effect": "Allow",
      "Action": [
        "secretsmanager:CreateSecret",
        "secretsmanager:PutSecretValue",
        "secretsmanager:GetSecretValue"
      ],
      "Resource": "arn:aws:secretsmanager:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:secret:*"
  },
  {
      "Effect": "Allow",
      "Action": [
        "iam:GetUser"
      ],
      "Resource": "arn:aws:iam::${var.CURRENT_ACCOUNT_ID}:user/*"
  }
]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda-backend-policy-role-attachment" {
  provider         = aws.src
  role       = var.LAMBDA_BACKEND_ROLE_NAME
  policy_arn = aws_iam_policy.lambda_backend_policy.arn
}




resource "aws_iam_policy" "lambda_asset_uploader_policy" {
  provider         = aws.src
  name   = "${var.RESOURCE_PREFIX}-lambda-asset-uploader-policy"
  #tfsec:ignore:AWS099
  policy = <<EOF
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Effect":"Allow",
         "Action":[
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
         ],
         "Resource": "arn:aws:logs:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:log-group:/aws/lambda/*"
      },
      {
         "Effect":"Allow",
         "Action":[
            "s3:PutObject"
         ],
         "Resource":[
            "arn:aws:s3:::${var.WEBSITE_BUCKET_NAME}/*",
            "arn:aws:s3:::${var.WEBSITE_BUCKET_NAME}"
         ]
      },
      {
         "Effect":"Allow",
         "Action":[
            "s3:PutObjectAcl"
         ],
         "Resource":[
            "arn:aws:s3:::${var.WEBSITE_BUCKET_NAME}/*",
            "arn:aws:s3:::${var.WEBSITE_BUCKET_NAME}"
         ]
      },
      {
         "Effect":"Allow",
         "Action":[
            "s3:ListBucket"
         ],
         "Resource":[
            "arn:aws:s3:::${var.WEBSITE_BUCKET_NAME}",
            "arn:aws:s3:::${var.WEBSITE_BUCKET_NAME}/*"
         ]
      },
      {
         "Effect":"Allow",
         "Action":[
            "s3:DeleteObject"
         ],
         "Resource":[
            "arn:aws:s3:::${var.WEBSITE_BUCKET_NAME}/*",
            "arn:aws:s3:::${var.WEBSITE_BUCKET_NAME}"
         ]
      },
      {
         "Effect":"Allow",
         "Action":[
            "s3:DeleteObject"
         ],
         "Resource":[
            "arn:aws:s3:::${var.ARTIFACTS_S3_BUCKET_NAME}",
            "arn:aws:s3:::${var.ARTIFACTS_S3_BUCKET_NAME}/*"
         ]
      },
      {
         "Effect":"Allow",
         "Action":[
            "s3:ListBucket"
         ],
         "Resource":[
            "arn:aws:s3:::${var.ARTIFACTS_S3_BUCKET_NAME}",
            "arn:aws:s3:::${var.ARTIFACTS_S3_BUCKET_NAME}/*"
         ]
      },
      {
         "Effect":"Allow",
         "Action":[
            "s3:GetObject",
            "s3:Putobject"
         ],
         "Resource":[
            "arn:aws:s3:::${var.ARTIFACTS_S3_BUCKET_NAME}/*",
            "arn:aws:s3:::${var.ARTIFACTS_S3_BUCKET_NAME}"
         ]
      }
   ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda-asset-uploader-policy-role-attachment" {
  provider         = aws.src
  role       = var.LAMBDA_ASSET_UPLOADER_ROLE_NAME
  policy_arn = aws_iam_policy.lambda_asset_uploader_policy.arn
}


//
resource "aws_iam_policy" "lambda_cognito_post_confirmation_trigger_policy" {
  provider         = aws.src
  name   = "${var.RESOURCE_PREFIX}-lambda-cognito-post-confirmation-trigger-policy"
  #tfsec:ignore:AWS099
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:log-group:/aws/lambda/${var.LAMBDA_COGNITO_POST_CONFIRMATION_NAME}:*"
        
    },
    {
        "Effect": "Allow",
        "Action": [
          "dynamodb:PutItem"
        ],
        "Resource": "${var.PRE_LOGIN_TABLE_ARN}"
        
    },
        {
        "Effect": "Allow",
        "Action": [
          "cognito-idp:AdminAddUserToGroup"
        ],
        "Resource": "${var.COGNITO_USER_POOL}"
        
    }
   ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda-cognito-post-confirmation-trigger-policy-role-attachment" {
  provider         = aws.src
  role       = var.LAMBDA_COGNITO_POST_CONFIRMATION_TRIGGER_ROLE_NAME
  policy_arn = aws_iam_policy.lambda_cognito_post_confirmation_trigger_policy.arn
}

//
resource "aws_iam_policy" "lambda_cognito_post_authentication_trigger_policy" {
  provider         = aws.src
  name   = "${var.RESOURCE_PREFIX}-lambda-cognito-post-authentication-trigger-policy"
  #tfsec:ignore:AWS099
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:log-group:/aws/lambda/${var.LAMBDA_COGNITO_POST_AUTHENTICATION_NAME}:*"
        
    },
    {
        "Effect": "Allow",
        "Action": [
          "dynamodb:PutItem",
          "dynamodb:Scan"
        ],
        "Resource": "${var.CUSTOMER_TABLE_ARN}"
        
    },
        {
        "Effect": "Allow",
        "Action": [
          "dynamodb:GetItem",
          "dynamodb:PutItem"
        ],
        "Resource": "${var.PRE_LOGIN_TABLE_ARN}"
    },
        {
        "Effect": "Allow",
        "Action": [
          "cognito-idp:AdminAddUserToGroup"
        ],
        "Resource": ["${var.COGNITO_USER_POOL}","${var.MNO_COGNITO_USER_POOL}","${var.THIRD_PARTY_COGNITO_USER_POOL}"]        
    }
   ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "lambda-cognito-post-authentication-trigger-policy-role-attachment" {
  provider         = aws.src
  role       = var.LAMBDA_COGNITO_POST_AUTHENTICATION_TRIGGER_ROLE_NAME
  policy_arn = aws_iam_policy.lambda_cognito_post_authentication_trigger_policy.arn
}

//
resource "aws_iam_policy" "lambda_cognito_userpool_client_setting_policy" {
  provider         = aws.src
  name   = "${var.RESOURCE_PREFIX}-lambda-cognito-userpool-client-setting-policy"
  #tfsec:ignore:AWS099
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:log-group:/aws/lambda/${var.LAMBDA_COGNITO_POST_AUTHENTICATION_NAME}:*"
        
    },
    {
        "Effect": "Allow",
        "Action": [
          "dynamodb:PutItem"
        ],
        "Resource": "${var.PRE_LOGIN_TABLE_ARN}"
        
    },
        {
        "Effect": "Allow",
        "Action": [
          "cognito-idp:AdminAddUserToGroup"
        ],
        "Resource": ["${var.COGNITO_USER_POOL}","${var.MNO_COGNITO_USER_POOL}","${var.THIRD_PARTY_COGNITO_USER_POOL}"]
        
    }
   ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda-cognito-userpool-client-setting-policy-role-attachment" {
  provider         = aws.src
  role       = var.LAMBDA_COGNITO_USERPOOL_CLIENT_SETTING_ROLE_NAME
  policy_arn = aws_iam_policy.lambda_cognito_userpool_client_setting_policy.arn
}

//
resource "aws_iam_policy" "lambda_cognito_presignup_trigger_policy" {
  provider         = aws.src
  name   = "${var.RESOURCE_PREFIX}-lambda-cognito-presignup-trigger-policy"
  #tfsec:ignore:AWS099
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:log-group:/aws/lambda/${var.COGNITO_USERPOOL_CLIENT_SETTINGS_NAME}:*"
    }
   ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda-cognito-presignup-trigger-policy-role-attachment" {
  provider         = aws.src
  role       = var.LAMBDA_COGNITO_PRESIGNUP_TRIGGER_ROLE_NAME
  policy_arn = aws_iam_policy.lambda_cognito_presignup_trigger_policy.arn
}


//CognitoUserPoolDomian
resource "aws_iam_policy" "manage_user_pool_domain" {
  provider         = aws.src
  name   = "${var.RESOURCE_PREFIX}-ManageUserPoolDomain"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
          "cognito-idp:CreateUserPoolDomain"
        ],
        "Resource": [
          "arn:aws:cognito-idp:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:userpool/${var.USERPOOL_ID}",
          "arn:aws:cognito-idp:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:userpool/${var.MNO_USERPOOL_ID}",
          "arn:aws:cognito-idp:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:userpool/${var.THIRD_PARTY_USERPOOL_ID}"
          ]        
    },
    {
        "Effect": "Allow",
        "Action": [
          "cognito-idp:DeleteUserPoolDomain"
        ],
        "Resource": [
          "arn:aws:cognito-idp:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:userpool/${var.USERPOOL_ID}",
          "arn:aws:cognito-idp:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:userpool/${var.MNO_USERPOOL_ID}",
          "arn:aws:cognito-idp:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:userpool/${var.THIRD_PARTY_USERPOOL_ID}"
          ]        
    },
    {
        "Effect": "Allow",
        "Action": [
          "cognito-idp:DescribeUserPoolDomain"
        ],
        "Resource": [
          "arn:aws:cognito-idp:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:userpool/${var.USERPOOL_ID}",
          "arn:aws:cognito-idp:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:userpool/${var.MNO_USERPOOL_ID}",
          "arn:aws:cognito-idp:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:userpool/${var.THIRD_PARTY_USERPOOL_ID}"
          ]
        
    }
   ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cognito-userpool-domain-manage-user-pool-policy-role-attachment" {
  provider         = aws.src
  role       = var.LAMBDA_COGNITO_USERPOOL_DOMAIN_ROLE_NAME
  policy_arn = aws_iam_policy.manage_user_pool_domain.arn
}
resource "aws_iam_role_policy_attachment" "cognito-userpool-domain-write-cloudwatch-policy-role-attachment" {
  provider         = aws.src
  role       = var.LAMBDA_COGNITO_USERPOOL_DOMAIN_ROLE_NAME
  policy_arn = aws_iam_policy.write_cloudwatch_logs_policy.arn
}

// DUMP V3 Account DATA
resource "aws_iam_policy" "read_customer_table_policy" {
  provider         = aws.src
  name   = "${var.RESOURCE_PREFIX}-ReadCustomersTable"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
          "dynamodb:Scan"
        ],
        "Resource": "${var.CUSTOMER_TABLE_ARN}"
        
    }
   ]
}
EOF
}


resource "aws_iam_policy" "list_user_pool_policy" {
  provider         = aws.src
  name   = "${var.RESOURCE_PREFIX}-ReadCognitoCustomersTable"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
          "cognito-idp:ListUsers",
          "cognito-idp:ListUsersInGroup"
        ],
        "Resource": "${var.COGNITO_USER_POOL}"
        
    }
   ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "dump-v3-account-read-customer-table-policy-role-attachment" {
  provider         = aws.src
  role       = var.LAMBDA_DUMP_V3_ACCOUNT_ROLE_NAME
  policy_arn = aws_iam_policy.read_customer_table_policy.arn
}
resource "aws_iam_role_policy_attachment" "dump-v3-account-write-cloud-watchlog-policy-role-attachment" {
  provider         = aws.src
  role       = var.LAMBDA_DUMP_V3_ACCOUNT_ROLE_NAME
  policy_arn = aws_iam_policy.write_cloudwatch_logs_policy.arn
}

resource "aws_iam_role_policy_attachment" "dump-v3-list-user-pool-policy-role-attachment" {
  provider         = aws.src
  role       = var.LAMBDA_DUMP_V3_ACCOUNT_ROLE_NAME
  policy_arn = aws_iam_policy.list_user_pool_policy.arn
}

// UserGroupImporter Polocies
resource "aws_iam_policy" "write_cloudwatch_logs_policy" {
  provider         = aws.src
  name   = "${var.RESOURCE_PREFIX}-WriteCloudWatchLogs"
  #tfsec:ignore:AWS099
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource": "arn:aws:logs:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:*"
        
    }
   ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda-write-cloudwatch-logs-role-attachment" {
  provider         = aws.src
  role       = var.LAMBDA_USERGROUP_IMPORTER_ROLE_NAME
  policy_arn = aws_iam_policy.write_cloudwatch_logs_policy.arn
}

resource "aws_iam_policy" "lambda_s3_get_object_policy" {
  provider         = aws.src
  name   = "${var.RESOURCE_PREFIX}-S3GetObject"
  #tfsec:ignore:AWS099
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource":  [
        "arn:aws:s3:::${var.ARTIFACTS_S3_BUCKET_NAME}/*",
        "arn:aws:s3:::${var.WEBSITE_BUCKET_NAME}/*"
      ]
    }
   ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda-s3-get-objects-role-attachment" {
  provider         = aws.src
  role       = var.LAMBDA_USERGROUP_IMPORTER_ROLE_NAME
  policy_arn = aws_iam_policy.lambda_s3_get_object_policy.arn
}

# resource "aws_iam_policy" "lambda_restore_tables_policy" {
#   name = "RestoreTables"
#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#         "Effect": "Allow",
#         "Action": [
#           "dynamodb:Scan"
#         ],
#         "Resource": [

#         ]"arn:aws:s3:::*/*"

#     }
#    ]
# }
# EOF
# }

# resource "aws_iam_role_policy_attachment" "lambda-write-cloudwatch-logs-role-attachment" {
#   role       = "${var.LAMBDA_USERGROUP_IMPORTER_ROLE_NAME}"
#   policy_arn = "${aws_iam_policy.lambda_s3_get_object_policy.arn}"
# }


resource "aws_iam_policy" "update_cognito_user_list_policy" {
  provider         = aws.src
  name   = "${var.RESOURCE_PREFIX}-CognitoUserGroup"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
          "cognito-idp:AdminCreateUser",
          "cognito-idp:AdminCreateUserToGroup"
        ],
        "Resource":"${var.COGNITO_USER_POOL}"
        
    }
   ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "update-config-user-s3-get-objects-role-attachment" {
  provider         = aws.src
  role       = var.LAMBDA_USERGROUP_IMPORTER_ROLE_NAME
  policy_arn = aws_iam_policy.update_cognito_user_list_policy.arn
}



# Lambda Permissions
resource "aws_lambda_permission" "pre_signup_lambda_permission" {
  provider         = aws.src
  function_name = var.LAMBDA_COGNITO_PRE_SIGNUP_NAME
  statement_id  = "${var.LAMBDA_COGNITO_PRE_SIGNUP_NAME}-lambda-permission"
  action        = "lambda:InvokeFunction"
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = "arn:aws:cognito-idp:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:userpool/${var.USERPOOL_ID}"

}
resource "aws_lambda_permission" "post_confirmation_lambda_permission" {
  provider         = aws.src
  function_name = var.LAMBDA_COGNITO_POST_CONFIRMATION_NAME
  statement_id  = "${var.LAMBDA_COGNITO_POST_CONFIRMATION_NAME}-lambda-permission"
  action        = "lambda:InvokeFunction"
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = "arn:aws:cognito-idp:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:userpool/${var.USERPOOL_ID}"
}
resource "aws_lambda_permission" "post_authentication_lambda_permission" {
  provider         = aws.src
  function_name = var.LAMBDA_COGNITO_POST_AUTHENTICATION_NAME
  statement_id  = "${var.LAMBDA_COGNITO_POST_AUTHENTICATION_NAME}-lambda-permission"
  action        = "lambda:InvokeFunction"
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = "arn:aws:cognito-idp:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:userpool/${var.USERPOOL_ID}"

}
resource "aws_lambda_permission" "cloudfront_security_lambda_permission" {
  provider         = aws.global
  function_name = var.LAMBDA_CLOUDFRONT_SECURITY
  statement_id  = "${var.LAMBDA_CLOUDFRONT_SECURITY}-security-lambda-permission"
  action        = "lambda:GetFunction"
  principal     = "replicator.lambda.amazonaws.com"
  source_arn = var.CLOUDFRONT_SECURITY_LAMBDA_QUALIFIED_ARN
}

//Cognito Admin group Policy

resource "aws_iam_policy" "cognito_admin_group_policy" {
  provider         = aws.src
  name   = "${var.RESOURCE_PREFIX}-CognitoAdminRole"
  #tfsec:ignore:AWS099
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
          "execute-api:Invoke"
        ],
        "Resource": "${var.API_GATEWAY_API}/prod/*/*"
    }
   ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cognito-admin-group-policy-role-attachment" {
  provider         = aws.src
  role       = var.COGNITO_ADMIN_GROUP_ROLE
  policy_arn = aws_iam_policy.cognito_admin_group_policy.arn
}

//Cognito Registered group Policy


resource "aws_iam_policy" "cognito_registered_group_policy" {
  provider         = aws.src
  name   = "${var.RESOURCE_PREFIX}-CognitoRegisteredRole"
  #tfsec:ignore:AWS099
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
          "execute-api:Invoke"
        ],
        "Resource": "${var.API_GATEWAY_API}/prod/*"
    },
    {
        "Effect": "Allow",
        "Action": [
          "execute-api:Invoke"
        ],
        "Resource": "${var.API_GATEWAY_API}/prod/*/admin/*"
    }
   ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cognito-registered-group-policy-role-attachment" {
  provider         = aws.src
  role       = var.COGNITO_REGISTERED_GROUP_ROLE
  policy_arn = aws_iam_policy.cognito_registered_group_policy.arn
}


resource "aws_iam_policy" "cloudfront_security_policy" {
  provider         = aws.src
  name   = "${var.RESOURCE_PREFIX}-Cloudfront-security"
  #tfsec:ignore:AWS099
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Effect": "Allow",
        "Action": [
           "lambda:CreateFunction",
            "lambda:GetFunction",
            "lambda:UpdateFunctionCode",
            "lambda:PublishVersion"
        ],
        "Resource": "arn:aws:lambda:*:*:*"
    },
    {
      "Effect": "Allow",
      "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:log-group:/aws/lambda/${var.LAMBDA_CLOUDFRONT_SECURITY}:*"
    },
    {
        "Effect": "Allow",
        "Action": [
          "iam:PassRole"
        ],
        "Resource": [
          "arn:aws:iam::${var.CURRENT_ACCOUNT_ID}:role/${var.LAMBDA_CATALOG_UPDATER_ROLE_NAME}",
          "arn:aws:iam::${var.CURRENT_ACCOUNT_ID}:role/${var.LAMBDA_BACKEND_ROLE_NAME}",
          "arn:aws:iam::${var.CURRENT_ACCOUNT_ID}:role/${var.LAMBDA_ASSET_UPLOADER_ROLE_NAME}",
          "arn:aws:iam::${var.CURRENT_ACCOUNT_ID}:role/${var.LAMBDA_COGNITO_POST_CONFIRMATION_TRIGGER_ROLE_NAME}",
          "arn:aws:iam::${var.CURRENT_ACCOUNT_ID}:role/${var.LAMBDA_COGNITO_POST_AUTHENTICATION_TRIGGER_ROLE_NAME}",
          "arn:aws:iam::${var.CURRENT_ACCOUNT_ID}:role/${var.LAMBDA_COGNITO_USERPOOL_CLIENT_SETTING_ROLE_NAME}",
          "arn:aws:iam::${var.CURRENT_ACCOUNT_ID}:role/${var.LAMBDA_COGNITO_PRESIGNUP_TRIGGER_ROLE_NAME}",
          "arn:aws:iam::${var.CURRENT_ACCOUNT_ID}:role/${var.LAMBDA_COGNITO_USERPOOL_DOMAIN_ROLE_NAME}",
          "arn:aws:iam::${var.CURRENT_ACCOUNT_ID}:role/${var.LAMBDA_DUMP_V3_ACCOUNT_ROLE_NAME}",
          "arn:aws:iam::${var.CURRENT_ACCOUNT_ID}:role/${var.LAMBDA_USERGROUP_IMPORTER_ROLE_NAME}",
          "arn:aws:iam::${var.CURRENT_ACCOUNT_ID}:role/${var.COGNITO_ADMIN_GROUP_ROLE}",
          "arn:aws:iam::${var.CURRENT_ACCOUNT_ID}:role/${var.COGNITO_REGISTERED_GROUP_ROLE}",
          "arn:aws:iam::${var.CURRENT_ACCOUNT_ID}:role/${var.LAMBDA_CLOUDFRONT_SECURITY_ROLE}",
          "arn:aws:iam::${var.CURRENT_ACCOUNT_ID}:role/${var.API_KEY_AUTHORIZATION_ROLE_NAME}",
          "arn:aws:iam::${var.CURRENT_ACCOUNT_ID}:role/${var.COGNITO_SMS_CALLER_ROLE_NAME}",
          "arn:aws:iam::${var.CURRENT_ACCOUNT_ID}:role/${var.LAMBDA_AUTHORIZATION_ROLE_NAME}",
          "arn:aws:iam::${var.CURRENT_ACCOUNT_ID}:role/${var.LAMBDA_API_KEY_ROTATION_ROLE_NAME}",
          "arn:aws:iam::${var.CURRENT_ACCOUNT_ID}:role/${var.LAMBDA_INVOKE_API_KEY_ROTATION_ROLE_NAME}"
        ]
    },
    {
        "Effect": "Allow",
        "Action": [
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:PutObject"
        ],
        "Resource": ["arn:aws:s3:::${var.ARTIFACTS_S3_BUCKET_NAME}/*", "arn:aws:s3:::${var.ARTIFACTS_S3_BUCKET_NAME}"]
    }

   ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cloudfront-security-policy-role-attachment" {
  provider         = aws.src
  role       = var.LAMBDA_CLOUDFRONT_SECURITY_ROLE
  policy_arn = aws_iam_policy.cloudfront_security_policy.arn
}

resource "aws_s3_bucket_policy" "bucekt_policy" {
  provider         = aws.src
  bucket = var.WEBSITE_BUCKET_NAME

  # Terraform's "jsonencode" function converts a
  # Terraform expression's result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "Policy1632784971110",
    Statement = [
      { Effect = "Allow",
        Principal = {
          "AWS" : "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${var.ORIGIN_ACCESS_IDENTITY}"
        },
        Action = [
                "s3:GetObject",
                "s3:GetObjectVersion"
              ],
        Resource = ["arn:aws:s3:::${var.WEBSITE_BUCKET_NAME}/*", "arn:aws:s3:::${var.WEBSITE_BUCKET_NAME}"]
      }
    ]
  })

}



resource "aws_iam_policy" "api_key_invocation_policy" {
  provider         = aws.src
  name   = "${var.RESOURCE_PREFIX}-api_key_invocation_policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "lambda:InvokeFunction",
      "Effect": "Allow",
      "Resource": "${var.API_KEY_AUTHORIZATION_LAMBDA_ARN}"
    },
    {
      "Effect": "Allow",
      "Action": [
          "apigateway:GET"
      ],
      "Resource": "arn:aws:apigateway:${var.AWS_REGION}::/apis/${var.API_GATEWAY_ID}"
    },
    {
      "Effect": "Allow",
      "Action": [
          "dynamodb:Query"
      ],
      "Resource": [
          "arn:aws:dynamodb:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:table/${var.CUSTOMER_TABLE_NAME}",
          "${var.PRE_LOGIN_TABLE_ARN}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
          "cognito-idp:AdminGetUser"
      ],
      "Resource": "${var.COGNITO_USER_POOL}"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "api_key_invocation_policy_role_attachment" {
  provider         = aws.src
  role       = var.API_KEY_AUTHORIZATION_ROLE_NAME
  policy_arn = aws_iam_policy.api_key_invocation_policy.arn
}


resource "aws_iam_policy" "cognito_sms_caller_role_policy" {
  provider = aws.src
  name     = "${var.RESOURCE_PREFIX}-cognito-sms-caller-role-policy"
  #tfsec:ignore:AWS099
  policy   = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sns:publish"
            ],
            "Resource": [
                "*"
            ]
        }
    ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "cognito_sns_policy_role_attachment" {
  provider   = aws.src
  role       = var.COGNITO_SMS_CALLER_ROLE_NAME
  policy_arn = aws_iam_policy.cognito_sms_caller_role_policy.arn
}


resource "aws_iam_policy" "lambda_authorizer_role_policy" {
  provider = aws.src
  name     = "${var.RESOURCE_PREFIX}-lambda-authorizer-role-policy"
  #tfsec:ignore:AWS099
  policy   = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
         "Effect":"Allow",
         "Action":[
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
         ],
         "Resource": "arn:aws:logs:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:log-group:/aws/lambda/${var.API_KEY_AUTHORIZATION_LAMBDA_NAME}:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "apigateway:GET"
            ],
            "Resource": "arn:aws:apigateway:*::/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:Query",
                "dynamodb:PutItem"
            ],
             "Resource": [
              "arn:aws:dynamodb:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:table/${var.CUSTOMER_TABLE_NAME}",
              "${var.PRE_LOGIN_TABLE_ARN}",
              "${var.CUSTOMER_REQUEST_LOGS_TABLE_ARN}",
              "${var.API_ROLE_PERMISSION_TABLE_ARN}",
              "${var.API_PERMISSION_TABLE_ARN}"

            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "cognito-idp:AdminGetUser"
            ],
            "Resource": "${var.COGNITO_USER_POOL}"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_authorizer_role_policy_attachement" {
  provider   = aws.src
  role       = var.LAMBDA_AUTHORIZATION_ROLE_NAME
  policy_arn = aws_iam_policy.lambda_authorizer_role_policy.arn
}


resource "aws_iam_policy" "lambda_api_key_rotation_role_policy" {
  provider         = aws.src
  name     = "${var.RESOURCE_PREFIX}-lambda-api-key-rotation-role-policy"
  #tfsec:ignore:AWS099
  policy   = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
          "Effect":"Allow",
          "Action":[
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents"
          ],
          "Resource": "arn:aws:logs:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:log-group:/aws/lambda/${var.API_KEY_ROTATION_LAMBDA_NAME}:*"
        },
        {
          "Effect": "Allow",
          "Action": [
              "apigateway:GET"
          ],
           "Resource": "arn:aws:apigateway:${var.AWS_REGION}::/apis/${var.API_GATEWAY_ID}"
        },
        {
          "Effect": "Allow",
          "Action": [
              "dynamodb:Scan"
          ],
          "Resource": [
              "arn:aws:dynamodb:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:table/${var.CUSTOMER_TABLE_NAME}"
            ]
        },
        {
          "Effect": "Allow",
          "Action": [
                "lambda:InvokeFunction"
          ],
          "Resource": [
              "arn:aws:lambda:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:function:${var.INVOKE_API_KEY_ROTATION_LAMBDA_NAME}"
            ]
        }
    ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "lambda_api_key_rotation_role_policy_attachement" {
  provider         = aws.src
  role       = var.LAMBDA_API_KEY_ROTATION_ROLE_NAME
  policy_arn = aws_iam_policy.lambda_api_key_rotation_role_policy.arn
}


resource "aws_iam_policy" "lambda_invoke_api_key_rotation_role_policy" {
  provider         = aws.src
  name     = "${var.RESOURCE_PREFIX}-lambda-invoke-api-key-rotation-role-policy"
  #tfsec:ignore:AWS099
  policy   = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
          "Effect":"Allow",
          "Action":[
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents"
          ],
          "Resource": "arn:aws:logs:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:log-group:/aws/lambda/${var.INVOKE_API_KEY_ROTATION_LAMBDA_NAME}:*"
        },
        {
          "Effect": "Allow",
          "Action": [
              "apigateway:POST",
              "apigateway:DELETE"
          ],
           "Resource": "arn:aws:apigateway:${var.AWS_REGION}::/apis/${var.API_GATEWAY_ID}"
        },
        {
          "Effect": "Allow",
          "Action": [
              "dynamodb:UpdateItem"
          ],
          "Resource": [
              "arn:aws:dynamodb:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:table/${var.CUSTOMER_TABLE_NAME}"
            ]
        }
    ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "lambda_invoke_api_key_rotation_role_policy_attachement" {
  provider         = aws.src
  role       = var.LAMBDA_INVOKE_API_KEY_ROTATION_ROLE_NAME
  policy_arn = aws_iam_policy.lambda_invoke_api_key_rotation_role_policy.arn
}





resource "aws_iam_policy" "lambda_developer_portal_authorizer_role_policy" {
  provider = aws.src
  name     = "${var.RESOURCE_PREFIX}-lambda-developer-portal-authorizer-role-policy"
  #tfsec:ignore:AWS099
  policy   = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
         "Effect":"Allow",
         "Action":[
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
         ],
         "Resource": "arn:aws:logs:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:log-group:/aws/lambda/${var.DEVELOPER_PORTAL_AUTHORIZATION_LAMBDA_NAME}:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "apigateway:GET"
            ],
            "Resource": "arn:aws:apigateway:*::/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "dynamodb:Query",
                "dynamodb:PutItem",
                "dynamodb:Scan"
            ],
             "Resource": [
              "arn:aws:dynamodb:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:table/${var.CUSTOMER_TABLE_NAME}",
              "${var.PRE_LOGIN_TABLE_ARN}",
              "${var.CUSTOMER_REQUEST_LOGS_TABLE_ARN}",
              "${var.API_ROLE_PERMISSION_TABLE_ARN}",
              "${var.API_PERMISSION_TABLE_ARN}"

            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "cognito-idp:AdminGetUser"
            ],
            "Resource": "${var.COGNITO_USER_POOL}"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_developer_portal_authorizer_role_policy_attachement" {
  provider   = aws.src
  role       = var.DEVELOPER_PORTAL_AUTHORIZER_ROLE_NAME
  policy_arn = aws_iam_policy.lambda_developer_portal_authorizer_role_policy.arn
}

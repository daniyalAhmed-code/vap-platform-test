locals {
  NO_CUSTOM_DOMAIN_NAME = var.CUSTOM_DOMAIN_NAME == "" ? var.DNS_NAME : null
  CUSTOM_DOMAIN_NAME    = var.CUSTOM_DOMAIN_NAME != null ? var.CUSTOM_DOMAIN_NAME : ""
  CALLBACK_URL          = local.NO_CUSTOM_DOMAIN_NAME == null ? local.CUSTOM_DOMAIN_NAME : local.NO_CUSTOM_DOMAIN_NAME
  LOGOUT_URL            = local.NO_CUSTOM_DOMAIN_NAME == null ? local.CUSTOM_DOMAIN_NAME : local.NO_CUSTOM_DOMAIN_NAME


}
resource "aws_cognito_user_pool" "cognito_user_pool" {
  name = var.COGNITO_USER_POOL
  admin_create_user_config {
    allow_admin_create_user_only = var.ALLOW_ADMIN_CREATE_USER_ONLY
    invite_message_template {
      email_subject = "Developer Portal - Invitation"
      email_message = "<h2>Developer Portal</h2><p>You have been invited to access the developer portal at <a href=${local.CUSTOM_DOMAIN_NAME}>${local.CUSTOM_DOMAIN_NAME}</a>.</p><p><b>Username:</b> {username} <br><b>Temporary Password</b> {####}</p>"
      sms_message   = "<p><b>Username:</b> {username} <br><b>Temporary Password</b> {####}</p>"
    }
  }
  
  mfa_configuration = "OPTIONAL"
  sms_configuration {
    external_id    = "${var.RESOURCE_PREFIX}-SMS-ROLE"
    sns_caller_arn = var.COGNITO_SMS_CALLER_ROLE_ARN
  }
  
  email_verification_subject = "Developer Portal - Invitation"
  email_verification_message = "'<h2>Developer Portal</h2><p>Your verification code is <b>{####}</b></p>'"
  auto_verified_attributes   = ["email"]
  username_attributes        = ["email"]

  lambda_config {
    pre_sign_up         = "arn:aws:lambda:${var.AWS_REGION}:${var.AWS_ACCOUNT_ID}:function:${var.RESOURCE_PREFIX}-CognitoPreSignupTriggerFn"
    post_confirmation   = "arn:aws:lambda:${var.AWS_REGION}:${var.AWS_ACCOUNT_ID}:function:${var.RESOURCE_PREFIX}-CognitoPostConfirmationTriggerFn"
    post_authentication = "arn:aws:lambda:${var.AWS_REGION}:${var.AWS_ACCOUNT_ID}:function:${var.RESOURCE_PREFIX}-CognitoPostAuthenticationTriggerFn"
  }
  password_policy {
    minimum_length    = 12
    require_lowercase = true
    require_numbers   = true
    temporary_password_validity_days = 7
  }
  schema {
    name                = "email"
    attribute_data_type = "String"
    mutable             = false    # false for "sub"
    required            = true     # true for "sub"
    string_attribute_constraints { # if it is a string
      min_length = 1               # 10 for "birthdate"
      max_length = 2048            # 10 for "birthdate"
    }
  }
  schema {
    name                = "phone_number"
    attribute_data_type = "String"
    mutable             = false    # false for "sub"
    required            = false    # true for "sub"
    string_attribute_constraints { # if it is a string
      min_length = 1               # 10 for "birthdate"
      max_length = 2048            # 10 for "birthdate"
    }
  }
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
}

resource "aws_cognito_user_pool_client" "cognito_user_pool_client" {
  name                                 = var.COGNITO_USER_POOL_CLIENT
  user_pool_id                         = aws_cognito_user_pool.cognito_user_pool.id
  allowed_oauth_flows_user_pool_client = "true"
  generate_secret                      = false
  refresh_token_validity               = 30
  prevent_user_existence_errors        = "ENABLED"
  callback_urls                        = ["https://${local.CALLBACK_URL}/index.html?action=login"]
  logout_urls                          = ["https://${local.LOGOUT_URL}/index.html?action=logout"]
  allowed_oauth_flows                  = ["implicit"]
  allowed_oauth_scopes                 = ["openid"]
  supported_identity_providers         = ["COGNITO"]

}

//cognito user identity

resource "aws_cognito_identity_pool" "cognito_identity_pool" {
  identity_pool_name               = "identity pool"
  allow_unauthenticated_identities = false
  allow_classic_flow               = true

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.cognito_user_pool_client.id
    provider_name           = "cognito-idp.${var.AWS_REGION}.amazonaws.com/${aws_cognito_user_pool.cognito_user_pool.id}"
    server_side_token_check = false
  }


}
resource "aws_cognito_user_pool_domain" "main" {
  domain       = var.COGNITO_USER_POOL_DOMAIN
  user_pool_id = aws_cognito_user_pool.cognito_user_pool.id
}

//cognito admin group
resource "aws_cognito_user_group" "cognito_admin_group" {
  name         = var.ADMIN_GROUP_NAME
  user_pool_id = aws_cognito_user_pool.cognito_user_pool.id
  description  = var.COGNITO_ADMIN_GROUP_DESCRIPTION
  precedence   = 0
  role_arn     = var.COGNITO_ADMIN_GROUP_ROLE_ARN
}
//cognito registered group
resource "aws_cognito_user_group" "cognito_registered_group" {
  name         = var.REGISTERED_GROUP_NAME
  user_pool_id = aws_cognito_user_pool.cognito_user_pool.id
  description  = var.COGNITO_REGISTERED_GROUP_DESCRIPTION
  precedence   = 1
  role_arn     = var.COGNITO_REGISTERED_GROUP_ROLE_ARN
}



resource "aws_iam_role" "authenticated" {
  name = "${var.RESOURCE_PREFIX}-cognito_authenticated"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "cognito-identity.amazonaws.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "authenticated" {
  name = "${var.RESOURCE_PREFIX}-authenticated_policy"
  role = aws_iam_role.authenticated.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "mobileanalytics:PutEvents",
        "cognito-sync:*",
        "cognito-identity:*"
      ],
      "Resource": [
        "arn:aws:cognito-sync:${var.AWS_REGION}:${var.AWS_ACCOUNT_ID}:identitypool/${aws_cognito_identity_pool.cognito_identity_pool.id}/identity/${aws_cognito_user_pool.cognito_user_pool.id}"
      ]
    }
  ]
}
EOF
}


resource "aws_cognito_identity_pool_roles_attachment" "main" {
  identity_pool_id = aws_cognito_identity_pool.cognito_identity_pool.id

  roles = {
    "authenticated" = "${aws_iam_role.authenticated.arn}"
  }
}


//third-party-COGNITO



resource "aws_cognito_user_pool" "third_party_cognito_user_pool" {
  name = var.THIRD_PARTY_COGNITO_USER_POOL
  admin_create_user_config {
    allow_admin_create_user_only = var.ALLOW_ADMIN_CREATE_USER_ONLY
    invite_message_template {
      email_subject = "Developer Portal - Invitation"
      email_message = "<h2>Developer Portal</h2><p>You have been invited to access the developer portal at <a href=${local.CUSTOM_DOMAIN_NAME}>${local.CUSTOM_DOMAIN_NAME}</a>.</p><p><b>Username:</b> {username} <br><b>Temporary Password</b> {####}</p>"
      sms_message   = "<p><b>Username:</b> {username} <br><b>Temporary Password</b> {####}</p>"
    }
  }



  email_verification_subject = "Developer Portal - Invitation"
  email_verification_message = "'<h2>Developer Portal</h2><p>Your verification code is <b>{####}</b></p>'"
  auto_verified_attributes   = ["email"]
  username_attributes        = ["email"]


  password_policy {
    minimum_length    = 12
    require_lowercase = true
    require_numbers   = true
    temporary_password_validity_days = 7
  }
  schema {
    name                = "email"
    attribute_data_type = "String"
    mutable             = false    # false for "sub"
    required            = true     # true for "sub"
    string_attribute_constraints { # if it is a string
      min_length = 1               # 10 for "birthdate"
      max_length = 2048            # 10 for "birthdate"
    }
  }
  schema {
    name                = "phone_number"
    attribute_data_type = "String"
    mutable             = false    # false for "sub"
    required            = false    # true for "sub"
    string_attribute_constraints { # if it is a string
      min_length = 1               # 10 for "birthdate"
      max_length = 2048            # 10 for "birthdate"
    }
  }
  schema {
    name                = "client_id"
    attribute_data_type = "String"
    mutable             = true    # false for "sub"
    required            = false    # true for "sub"
    string_attribute_constraints { # if it is a string
      min_length = 1               # 10 for "birthdate"
      max_length = 2048            # 10 for "birthdate"
    }
  }
  
  schema {
  name                = "client_type"
  attribute_data_type = "String"
  mutable             = true    # false for "sub"
  required            = false    # true for "sub"
  string_attribute_constraints { # if it is a string
    min_length = 1               # 10 for "birthdate"
    max_length = 2048            # 10 for "birthdate"
    }
  }
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
}

resource "aws_cognito_user_pool_client" "third_party_cognito_user_pool_client" {
  name                                 = var.THIRD_PARTY_COGNITO_USER_POOL_CLIENT
  user_pool_id                         = aws_cognito_user_pool.third_party_cognito_user_pool.id
  allowed_oauth_flows_user_pool_client = "true"
  generate_secret                      = false
  refresh_token_validity               = 30
  prevent_user_existence_errors        = "ENABLED"
  callback_urls                        = ["https://${local.CALLBACK_URL}/index.html?action=login"]
  logout_urls                          = ["https://${local.LOGOUT_URL}/index.html?action=logout"]
  allowed_oauth_flows                  = ["implicit"]
  allowed_oauth_scopes                 = ["openid"]
  supported_identity_providers         = ["COGNITO"]

}

//cognito user identity

resource "aws_cognito_identity_pool" "third_party_cognito_identity_pool" {
  identity_pool_name               = "third party identity pool"
  allow_unauthenticated_identities = false
  allow_classic_flow               = true

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.cognito_user_pool_client.id
    provider_name           = "cognito-idp.${var.AWS_REGION}.amazonaws.com/${aws_cognito_user_pool.third_party_cognito_user_pool.id}"
    server_side_token_check = false
  }
}
resource "aws_cognito_user_pool_domain" "third_party_main" {
  domain       = var.THIRD_PARTY_COGNITO_USER_POOL_DOMAIN
  user_pool_id = aws_cognito_user_pool.third_party_cognito_user_pool.id
}



//cognito admin group
resource "aws_cognito_user_group" "third_party_cognito_admin_group" {
  name         = var.THIRD_PARTY_ADMIN_GROUP_NAME
  user_pool_id = aws_cognito_user_pool.third_party_cognito_user_pool.id
  description  = var.COGNITO_ADMIN_GROUP_DESCRIPTION
  precedence   = 0
  role_arn     = var.COGNITO_ADMIN_GROUP_ROLE_ARN
}
//cognito registered group
resource "aws_cognito_user_group" "third_party_cognito_registered_group" {
  name         = var.REGISTERED_GROUP_NAME
  user_pool_id = aws_cognito_user_pool.third_party_cognito_user_pool.id
  description  = var.COGNITO_REGISTERED_GROUP_DESCRIPTION
  precedence   = 1
  role_arn     = var.COGNITO_REGISTERED_GROUP_ROLE_ARN
}



resource "aws_iam_role" "third_party_authenticated" {
  name = "${var.RESOURCE_PREFIX}-third_party_cognito_authenticated"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "cognito-identity.amazonaws.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "third_party_authenticated" {
  name = "${var.RESOURCE_PREFIX}-third-party-authenticated_policy"
  role = aws_iam_role.authenticated.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "mobileanalytics:PutEvents",
        "cognito-sync:*",
        "cognito-identity:*"
      ],
      "Resource": [
        "arn:aws:cognito-sync:${var.AWS_REGION}:${var.AWS_ACCOUNT_ID}:identitypool/${aws_cognito_identity_pool.cognito_identity_pool.id}/identity/${aws_cognito_user_pool.third_party_cognito_user_pool.id}"
      ]
    }
  ]
}
EOF
}


resource "aws_cognito_identity_pool_roles_attachment" "third_party_main" {
  identity_pool_id = aws_cognito_identity_pool.third_party_cognito_identity_pool.id

  roles = {
    "authenticated" = "${aws_iam_role.third_party_authenticated.arn}"
  }
}


//MNO-COGNITO


resource "aws_cognito_user_pool" "mno_cognito_user_pool" {
  name = var.MNO_COGNITO_USER_POOL
  admin_create_user_config {
    allow_admin_create_user_only = var.ALLOW_ADMIN_CREATE_USER_ONLY
    invite_message_template {
      email_subject = "Developer Portal - Invitation"
      email_message = "<h2>Developer Portal</h2><p>You have been invited to access the developer portal at <a href=${local.CUSTOM_DOMAIN_NAME}>${local.CUSTOM_DOMAIN_NAME}</a>.</p><p><b>Username:</b> {username} <br><b>Temporary Password</b> {####}</p>"
      sms_message   = "<p><b>Username:</b> {username} <br><b>Temporary Password</b> {####}</p>"
    }
  }



  email_verification_subject = "Developer Portal - Invitation"
  email_verification_message = "'<h2>Developer Portal</h2><p>Your verification code is <b>{####}</b></p>'"
  auto_verified_attributes   = ["email"]
  username_attributes        = ["email"]


  password_policy {
    minimum_length    = 12
    require_lowercase = true
    require_numbers   = true
    temporary_password_validity_days = 7
  }
  schema {
    name                = "email"
    attribute_data_type = "String"
    mutable             = false    # false for "sub"
    required            = true     # true for "sub"
    string_attribute_constraints { # if it is a string
      min_length = 1               # 10 for "birthdate"
      max_length = 2048            # 10 for "birthdate"
    }
  }
  schema {
    name                = "phone_number"
    attribute_data_type = "String"
    mutable             = false    # false for "sub"
    required            = false    # true for "sub"
    string_attribute_constraints { # if it is a string
      min_length = 1               # 10 for "birthdate"
      max_length = 2048            # 10 for "birthdate"
    }
  }
  schema {
    name                = "client_id"
    attribute_data_type = "String"
    mutable             = true    # false for "sub"
    required            = false    # true for "sub"
    string_attribute_constraints { # if it is a string
      min_length = 1               # 10 for "birthdate"
      max_length = 2048            # 10 for "birthdate"
    }
  }
  schema {
  name                = "client_type"
  attribute_data_type = "String"
  mutable             = true    # false for "sub"
  required            = false    # true for "sub"
  string_attribute_constraints { # if it is a string
    min_length = 1               # 10 for "birthdate"
    max_length = 2048            # 10 for "birthdate"
    }
  }
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }
}

resource "aws_cognito_user_pool_client" "mno_cognito_user_pool_client" {
  name                                 = var.MNO_COGNITO_USER_POOL_CLIENT
  user_pool_id                         = aws_cognito_user_pool.mno_cognito_user_pool.id
  allowed_oauth_flows_user_pool_client = "true"
  generate_secret                      = false
  refresh_token_validity               = 30
  prevent_user_existence_errors        = "ENABLED"
  callback_urls                        = ["https://${local.CALLBACK_URL}/index.html?action=login"]
  logout_urls                          = ["https://${local.LOGOUT_URL}/index.html?action=logout"]
  allowed_oauth_flows                  = ["implicit"]
  allowed_oauth_scopes                 = ["openid"]
  supported_identity_providers         = ["COGNITO"]

}

//cognito user identity

resource "aws_cognito_identity_pool" "mno_cognito_identity_pool" {
  identity_pool_name               = "identity pool"
  allow_unauthenticated_identities = false
  allow_classic_flow               = true

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.mno_cognito_user_pool_client.id
    provider_name           = "cognito-idp.${var.AWS_REGION}.amazonaws.com/${aws_cognito_user_pool.mno_cognito_user_pool.id}"
    server_side_token_check = false
  }
}
resource "aws_cognito_user_pool_domain" "mno_main" {
  domain       = var.MNO_COGNITO_USER_POOL_DOMAIN
  user_pool_id = aws_cognito_user_pool.mno_cognito_user_pool.id
}



//cognito admin group
resource "aws_cognito_user_group" "mno_cognito_admin_group" {
  name         = var.MNO_ADMIN_GROUP_NAME
  user_pool_id = aws_cognito_user_pool.mno_cognito_user_pool.id
  description  = var.COGNITO_ADMIN_GROUP_DESCRIPTION
  precedence   = 0
  role_arn     = var.COGNITO_ADMIN_GROUP_ROLE_ARN
}
//cognito registered group
resource "aws_cognito_user_group" "mno_cognito_registered_group" {
  name         = var.REGISTERED_GROUP_NAME
  user_pool_id = aws_cognito_user_pool.mno_cognito_user_pool.id
  description  = var.COGNITO_REGISTERED_GROUP_DESCRIPTION
  precedence   = 1
  role_arn     = var.COGNITO_REGISTERED_GROUP_ROLE_ARN
}



resource "aws_iam_role" "mno_authenticated" {
  name = "${var.RESOURCE_PREFIX}-mno-cognito_authenticated"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "cognito-identity.amazonaws.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "mno_authenticated" {
  name = "${var.RESOURCE_PREFIX}-mno-authenticated_policy"
  role = aws_iam_role.mno_authenticated.id
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "mobileanalytics:PutEvents",
        "cognito-sync:*",
        "cognito-identity:*"
      ],
      "Resource": [
        "arn:aws:cognito-sync:${var.AWS_REGION}:${var.AWS_ACCOUNT_ID}:identitypool/${aws_cognito_identity_pool.mno_cognito_identity_pool.id}/identity/${aws_cognito_user_pool.mno_cognito_user_pool.id}"
      ]
    }
  ]
}
EOF
}


resource "aws_cognito_identity_pool_roles_attachment" "mno_main" {
  identity_pool_id = aws_cognito_identity_pool.mno_cognito_identity_pool.id

  roles = {
    "authenticated" = "${aws_iam_role.mno_authenticated.arn}"
  }
} 
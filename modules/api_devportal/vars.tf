
variable "CORS_ALLOW_ORIGIN" {
  type    = string
  default = "*"
}


variable "allow_headers" {
  description = "Allow headers"
  type        = list(string)

  default = [
    "Authorization",
    "authorization",
    "Content-Type",
    "X-Amz-Date",
    "X-Amz-Security-Token",
    "X-Api-Key",
    "authorizertoken",
    "authorizerToken"
  ]
}

# var.allow_methods
variable "allow_methods" {
  description = "Allow methods"
  type        = list(string)

  default = [
    "*",
    # "HEAD",
    # "GET",
    # "POST",
    # "PUT",
    # "PATCH",
    # "DELETE",
  ]
}

# # var.allow_origin
variable "allow_origin" {
  description = "Allow origin"
  type        = string
  default     = "*"
}

# var.allow_max_age
variable "allow_max_age" {
  description = "Allow response caching time"
  type        = string
  default     = "7200"
}

# var.allowed_credentials
variable "allow_credentials" {
  description = "Allow credentials"
  default     = true
}

##################

variable "Strict_Transport_Security" {
  default = "max-age=31536000; includeSubDomains; preload"
}

variable "Referrer_Policy" {
  default = "same-origin"
}

variable "X_XSS_Protection" {
  default = "1; mode=block"
}

variable "X_Frame_Options" {
  default = "DENY"
}

variable "X_Content_Type_Options" {
  default = "nosniff"
}

variable "Content_Security_Policy" {
  default = "default-src 'self';"
}
# variable "CORS_ALLOW_ORIGIN" {}

# variable "COMMON_TAGS" {}
variable "ENV" {}
variable "RESOURCE_PREFIX" {}
variable "CURRENT_ACCOUNT_ID" {}
variable "AWS_REGION" {}


# variable "LAMBDA_ENTITY_AUTHORIZER_INVOKE_ARN" {}
variable "AUTHORIZATION" {
  default = "CUSTOM" // CUSTOM
}


variable "Base_Path" {
  default = "prod" //notification
}
variable "BACKEND_LAMBDA_NAME" {}
variable "BACKEND_LAMBDA_INVOKE_ARN" {}
variable "USE_CUSTOM_DOMAIN_NAME" {}
variable "DOMAIN_NAME" {}
variable "LAMBDA_SIGNIN_INVOKE_ARN" {}
variable "LAMBDA_GET_CATALOG_INVOKE_ARN" {}
variable "LAMBDA_GET_APIKEY_INVOKE_ARN" {}
variable "LAMBDA_GET_SDK_INVOKE_ARN" {}
variable "LAMBDA_GET_SUBSCRIPTION_INVOKE_ARN" {}
variable "LAMBDA_UPDATE_SUBSCRIPTION_USAGE_PLAN_INVOKE_ARN" {}
variable "LAMBDA_DELETE_SUBSCRIPTION_USAGE_PLAN_INVOKE_ARN" {}
variable "LAMBDA_GET_SUBSCRIPTION_USAGE_PLAN_INVOKE_ARN" {}
variable "LAMBDA_GET_FEEDBACK_INVOKE_ARN" {}
variable "LAMBDA_EXPORT_API_INVOKE_ARN" {}
variable "LAMBDA_POST_FEEDBACK_INVOKE_ARN" {}
variable "LAMBDA_UPDATE_SDK_GENERATION_IN_CATALOG_API_INVOKE_ARN" {}
variable "LAMBDA_DELETE_SDK_GENERATION_IN_CATALOG_API_INVOKE_ARN" {}
variable "LAMBDA_GET_ALL_CATALOGS_INVOKE_ARN" {}
variable "LAMBDA_GET_ALL_ACCOUNTS_INVOKE_ARN" {}
variable "LAMBDA_ADD_NEW_API_TO_CATALOGS_INVOKE_ARN" {}
variable "LAMBDA_DELETE_API_FROM_CATALOGS_INVOKE_ARN" {}
variable "LAMBDA_CREATE_NEW_ACCOUNT_INVOKE_ARN" {}
variable "LAMBDA_PROMOTE_USER_TO_ADMIN_INVOKE_ARN" {}
variable "LAMBDA_DELETE_USER_INVOKE_ARN" {}
variable "LAMBDA_GET_USER_CALLBACKAUTH_INVOKE_ARN" {}
variable "LAMBDA_GET_CURRENT_USER_PROFILE_INVOKE_ARN" {}
variable "LAMBDA_RESEND_INVITE_INVOKE_ARN" {}
variable "LAMBDA_GET_USER_PROFILE_IMAGE_INVOKE_ARN" {}
variable "LAMBDA_UPDATE_USER_PROFILE_IMAGE_INVOKE_ARN" {}
variable "GET_APIKEY_LAMBDA_NAME" {}
variable "GET_CURRENT_USER_PROFILE_LAMBDA_NAME" {}
variable "GET_CATALOG_LAMBDA_NAME" {}
variable "GET_SUBSCRIPTION_LAMBDA_NAME" {}
variable "UPDATE_SUBSCRIPTION_USAGE_PLAN_LAMBDA_NAME" {}
variable "DELETE_SUBSCRIPTION_USAGE_PLAN_LAMBDA_NAME" {}
variable "GET_SUBSCRIPTION_USAGE_PLAN_LAMBDA_NAME" {}
variable "GET_FEEDBACK_LAMBDA_NAME" {}
variable "POST_FEEDBACK_LAMBDA_NAME" {}
variable "GET_SDK_LAMBDA_NAME" {}
variable "EXPORT_API_LAMBDA_NAME" {}
variable "UPDATE_SDK_GENERATION_IN_CATALOG_API_LAMBDA_NAME" {}
variable "DELETE_SDK_GENERATION_IN_CATALOG_API_LAMBDA_NAME" {}
variable "GET_ALL_CATALOGS_LAMBDA_NAME" {}
variable "ADD_NEW_API_TO_CATALOGS_LAMBDA_NAME" {}
variable "DELETE_API_FROM_CATALOGS_LAMBDA_NAME" {}
variable "CREATE_NEW_ACCOUNT_LAMBDA_NAME" {}
variable "PROMOTE_USER_TO_ADMIN_LAMBDA_NAME" {}
variable "DELETE_USER_LAMBDA_NAME" {}
variable "GET_USER_CALLBACKAUTH_LAMBDA_NAME" {}
variable "RESEND_INVITE_LAMBDA_NAME" {}
variable "UPDATE_USER_PROFILE_IMAGE_LAMBDA_NAME" {}
variable "GET_USER_PROFILE_IMAGE_LAMBDA_NAME" {}
variable "GET_ALL_ACCOUNTS_LAMBDA_NAME" {}
variable "SIGNIN_LAMBDA_NAME" {}
variable "LAMBDA_CREATE_MNO_THIRD_PARTY_RESOURCE_INVOKE_ARN" {}
variable "CREATE_MNO_THIRD_PARTY_RESOURCE_LAMBDA_NAME" {}
variable "CREATE_PERMISION_FOR_API_LAMBDA_NAME" {}
variable "LAMBDA_CREATE_PERMISION_FOR_API_INVOKE_ARN" {}

variable "LAMBDA_GET_ALLOWED_APIS_FOR_RESOURCE_INVOKE_ARN" {}
variable "GET_ALLOWED_APIS_FOR_RESOURCE_LAMBDA_NAME" {}
variable "LAMBDA_DELETE_ALLOWED_APIS_FOR_RESOURCE_INVOKE_ARN" {}
variable "DELETE_ALLOWED_APIS_FOR_RESOURCE_LAMBDA_NAME" {}

variable "LAMBDA_GET_MNO_THIRD_PARTY_RESOURCE_INVOKE_ARN" {}
variable "GET_MNO_THIRD_PARTY_RESOURCE_LAMBDA_NAME" {}

variable "CERTIFICATE_ARN" {}

variable "API_KEY_AUTHORIZATION_ROLE_ARN" {}
variable "API_KEY_AUTHORIZATION_INVOKE_ARN" {}

variable "DEVELOPER_PORTAL_AUTHORIZATION_INVOKE_ARN" {}
variable "DEVELOPER_PORTAL_AUTHORIZATION_LAMBDA_NAME" {}
variable "LAMBDA_DEVELOPER_PORTAL_AUTHORIZER_ROLE_ARN" {}
variable "APIGATEWAY_CUSTOM_DOMAIN_NAME" {default = null}




resource "aws_api_gateway_rest_api" "api-gateway" {
  name        = "${var.RESOURCE_PREFIX}-backend-api"
  description = "API to trigger lambda function."
  binary_media_types = [
    "image/png",
    "application/octet-stream",
    "multipart/form-data",
    "image/jpeg"
  ]
}

resource "aws_api_gateway_domain_name" "this" {
  certificate_arn = var.CERTIFICATE_ARN
  domain_name     = var.APIGATEWAY_CUSTOM_DOMAIN_NAME
  security_policy = "TLS_1_2"
}

resource "aws_api_gateway_base_path_mapping" "api-gateway-base-path-mapping" {
  count       = var.APIGATEWAY_CUSTOM_DOMAIN_NAME != null ? 1 : 0
  api_id      = "${aws_api_gateway_rest_api.api-gateway.id}"
  stage_name  = "${aws_api_gateway_deployment.api-gateway-deployment.stage_name}"
  domain_name     = var.APIGATEWAY_CUSTOM_DOMAIN_NAME
}

resource "aws_api_gateway_resource" "version_resource" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  parent_id   = aws_api_gateway_rest_api.api-gateway.root_resource_id
  path_part   = "version"
}

resource "aws_api_gateway_resource" "version_number_resource" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  parent_id   = aws_api_gateway_resource.version_resource.id
  path_part   = "{v4_1_0}"
}



module "version_resource_OPTION" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.version_number_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  HTTP_METHOD                     = "OPTIONS"
  AUTHORIZATION                   = "NONE"
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
}

//ROOT resources
module "root_resource_OPTION" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_rest_api.api-gateway.root_resource_id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  HTTP_METHOD                     = "OPTIONS"
  AUTHORIZATION                   = "NONE"
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
}


module "root_resource" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_rest_api.api-gateway.root_resource_id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  AUTHORIZATION                   = var.AUTHORIZATION
  AUTHORIZER_ID = "${var.AUTHORIZATION == "CUSTOM" ? "${aws_api_gateway_authorizer.lambda_developer_portal_authorizer[0].id}" : ""}"
  
  HTTP_METHOD                     = "ANY"
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
  LAMBDA_INVOKE_ARN               = var.BACKEND_LAMBDA_INVOKE_ARN
  FUNCTION_NAME                   = var.BACKEND_LAMBDA_NAME
  LAMBDA_URI                      =  "arn:aws:apigateway:${var.AWS_REGION}:lambda:path/2015-03-31/functions/arn:aws:lambda:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:function:$${stageVariables.DevPortalFunctionName}/invocations"

  REQUEST_TEMPLATES = {
    "application/json" = <<EOF
    EOF
  }
}



// REGISTER POST API GATEWAY

# resource "aws_api_gateway_resource" "register_resource" {
#   rest_api_id = aws_api_gateway_rest_api.api-gateway.id
#   parent_id   = aws_api_gateway_rest_api.api-gateway.root_resource_id
#   path_part   = "register"
# }

# module "register_resource_OPTION" {
#   source                          = "./methods"
#   METHOD_VALUE                    = ""
#   API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
#   RESOURCE_ID                     = aws_api_gateway_resource.register_resource.id
#   INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
#   METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
#   HTTP_METHOD                     = "OPTIONS"
#   AUTHORIZATION                   = "NONE"
#   CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
#   AWS_REGION                      = var.AWS_REGION
# }

# module "register" {
#   source                          = "./methods"
#   METHOD_VALUE                    = ""
#   API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
#   RESOURCE_ID                     = aws_api_gateway_resource.register_resource.id
#   INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
#   METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
#   AUTHORIZATION                   = var.AUTHORIZATION
#   HTTP_METHOD                     = "POST"
#   LAMBDA_INVOKE_ARN               = var.BACKEND_LAMBDA_INVOKE_ARN
#   FUNCTION_NAME                   = var.BACKEND_LAMBDA_NAME
#   CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
#   AWS_REGION                      = var.AWS_REGION
#   REQUEST_TEMPLATES = {
#     "application/json" = <<EOF
#     EOF
#   }
# }

// REGISTER POST API END



//CATALOG POST API STARTS
resource "aws_api_gateway_resource" "catalog_resource" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  parent_id   = aws_api_gateway_rest_api.api-gateway.root_resource_id
  path_part   = "catalog"
}

module "catalog_resource_OPTION" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.catalog_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  HTTP_METHOD                     = "OPTIONS"
  AUTHORIZATION                   = "NONE"
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION

}

module "catalog" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.catalog_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  AUTHORIZATION                   = var.AUTHORIZATION
  AUTHORIZER_ID = "${var.AUTHORIZATION == "CUSTOM" ? "${aws_api_gateway_authorizer.lambda_developer_portal_authorizer[0].id}" : ""}"
  
  HTTP_METHOD                     = "GET"
  LAMBDA_INVOKE_ARN               = var.BACKEND_LAMBDA_INVOKE_ARN
  FUNCTION_NAME                   = var.BACKEND_LAMBDA_NAME
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
  LAMBDA_URI                      = var.LAMBDA_GET_CATALOG_INVOKE_ARN

  REQUEST_TEMPLATES = {
    "application/json" = <<EOF
    EOF
  }
}
//CATALOG POST API ENDS


//Feedback POST API STARTS
resource "aws_api_gateway_resource" "feedback_resource" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  parent_id   = aws_api_gateway_rest_api.api-gateway.root_resource_id
  path_part   = "feedback"
}


module "feedback_resource_OPTION" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.feedback_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  HTTP_METHOD                     = "OPTIONS"
  AUTHORIZATION                   = "NONE"
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
}

module "feedback_get" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.feedback_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  AUTHORIZATION = "${var.AUTHORIZATION}"
  AUTHORIZER_ID = "${var.AUTHORIZATION == "CUSTOM" ? "${aws_api_gateway_authorizer.lambda_developer_portal_authorizer[0].id}" : ""}"
  HTTP_METHOD                     = "GET"
  LAMBDA_INVOKE_ARN               = var.BACKEND_LAMBDA_INVOKE_ARN
  FUNCTION_NAME                   = var.BACKEND_LAMBDA_NAME
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
  LAMBDA_URI                      = var.LAMBDA_GET_FEEDBACK_INVOKE_ARN

  REQUEST_TEMPLATES = {
    "application/json" = <<EOF
    EOF
  }
}
module "feedback_post" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.feedback_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  AUTHORIZATION = "${var.AUTHORIZATION}"
  AUTHORIZER_ID = "${var.AUTHORIZATION == "CUSTOM" ? "${aws_api_gateway_authorizer.lambda_developer_portal_authorizer[0].id}" : ""}"
  
  
  HTTP_METHOD                     = "POST"
  LAMBDA_INVOKE_ARN               = var.BACKEND_LAMBDA_INVOKE_ARN
  FUNCTION_NAME                   = var.BACKEND_LAMBDA_NAME
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
  LAMBDA_URI                      = var.LAMBDA_POST_FEEDBACK_INVOKE_ARN


  REQUEST_TEMPLATES = {
    "application/json" = <<EOF
    EOF
  }
}
module "feedback_delete" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.feedback_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  AUTHORIZATION = "${var.AUTHORIZATION}"
  AUTHORIZER_ID = "${var.AUTHORIZATION == "CUSTOM" ? "${aws_api_gateway_authorizer.lambda_developer_portal_authorizer[0].id}" : ""}"
  
  
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
  HTTP_METHOD                     = "DELETE"
  LAMBDA_INVOKE_ARN               = var.BACKEND_LAMBDA_INVOKE_ARN
  FUNCTION_NAME                   = var.BACKEND_LAMBDA_NAME
  LAMBDA_URI                      = var.LAMBDA_POST_FEEDBACK_INVOKE_ARN

  REQUEST_TEMPLATES = {
    "application/json" = <<EOF
    EOF
  }
}


//FEEDBACK API ENDS

// catalog visibility api starts

resource "aws_api_gateway_resource" "admin_resource" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  parent_id   = aws_api_gateway_rest_api.api-gateway.root_resource_id
  path_part   = "admin"
}

resource "aws_api_gateway_resource" "apipermission_resource" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  parent_id   = aws_api_gateway_rest_api.api-gateway.root_resource_id
  path_part   = "api_permission"
}

resource "aws_api_gateway_resource" "apipermission_resourcename_resource" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  parent_id   = aws_api_gateway_resource.apipermission_resource.id
  path_part   = "{ResourceName}"
}


resource "aws_api_gateway_resource" "admin_catalog_resource" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  parent_id   = aws_api_gateway_resource.admin_resource.id
  path_part   = "catalog"
}

resource "aws_api_gateway_resource" "admin_account_resource" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  parent_id   = aws_api_gateway_resource.admin_resource.id
  path_part   = "accounts"
}

resource "aws_api_gateway_resource" "admin_account_mno_resource" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  parent_id   = aws_api_gateway_resource.admin_resource.id
  path_part   = "mno"
}

resource "aws_api_gateway_resource" "admin_account_mno_resourceid_resource" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  parent_id   = aws_api_gateway_resource.admin_resource.id
  path_part   = "{ResourceId}"
}

resource "aws_api_gateway_resource" "admin_account_callback_auth_resource" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  parent_id   = aws_api_gateway_resource.admin_resource.id
  path_part   = "callbackAuth"
}

resource "aws_api_gateway_resource" "admin_account_userid_resource" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  parent_id   = aws_api_gateway_resource.admin_account_resource.id
  path_part   = "{userId}"
}

resource "aws_api_gateway_resource" "admin_account_resend_invite_resource" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  parent_id   = aws_api_gateway_resource.admin_account_resource.id
  path_part   = "resendInvite"
}

resource "aws_api_gateway_resource" "admin_account_current_resource" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  parent_id   = aws_api_gateway_resource.admin_account_resource.id
  path_part   = "current"
}

resource "aws_api_gateway_resource" "admin_account_user_profile_resource" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  parent_id   = aws_api_gateway_resource.admin_account_current_resource.id
  path_part   = "getUserProfile"
}




resource "aws_api_gateway_resource" "admin_account_profile_image_resource" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  parent_id   = aws_api_gateway_resource.admin_resource.id
  path_part   = "profileImage"
}

resource "aws_api_gateway_resource" "admin_account_profile_image_user_id_resource" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  parent_id   = aws_api_gateway_resource.admin_account_profile_image_resource.id
  path_part   = "{userId}"
}



resource "aws_api_gateway_resource" "promote_to_admin_resource" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  parent_id   = aws_api_gateway_resource.admin_account_userid_resource.id
  path_part   = "promoteToAdmin"
}


resource "aws_api_gateway_resource" "admin_catalog_visibility_resource" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  parent_id   = aws_api_gateway_resource.admin_catalog_resource.id
  path_part   = "visibility"
}

resource "aws_api_gateway_resource" "admin_catalog_id_resource" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  parent_id   = aws_api_gateway_resource.admin_catalog_resource.id
  path_part   = "{id}"
}


//usageplan here


module "apipermission_resource_OPTION" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.apipermission_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  HTTP_METHOD                     = "OPTIONS"
  AUTHORIZATION                   = "NONE"
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
}


module "apipermission_resourcename_resource_OPTION" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.apipermission_resourcename_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  HTTP_METHOD                     = "OPTIONS"
  AUTHORIZATION                   = "NONE"
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
}



module "apipermission_resource_POST" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.apipermission_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  HTTP_METHOD                     = "POST"
  AUTHORIZATION = "${var.AUTHORIZATION}"
  AUTHORIZER_ID = "${var.AUTHORIZATION == "CUSTOM" ? "${aws_api_gateway_authorizer.lambda_developer_portal_authorizer[0].id}" : ""}"
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
  LAMBDA_URI                      = var.LAMBDA_CREATE_PERMISION_FOR_API_INVOKE_ARN
}

module "apipermission_resource_GET" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.apipermission_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  HTTP_METHOD                     = "GET"
  AUTHORIZATION = "${var.AUTHORIZATION}"
  AUTHORIZER_ID = "${var.AUTHORIZATION == "CUSTOM" ? "${aws_api_gateway_authorizer.lambda_developer_portal_authorizer[0].id}" : ""}"
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
  LAMBDA_URI                      = var.LAMBDA_GET_ALLOWED_APIS_FOR_RESOURCE_INVOKE_ARN

}

module "apipermission_resource_PUT" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.apipermission_resourcename_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  HTTP_METHOD                     = "PUT"
  AUTHORIZATION = "${var.AUTHORIZATION}"
  AUTHORIZER_ID = "${var.AUTHORIZATION == "CUSTOM" ? "${aws_api_gateway_authorizer.lambda_developer_portal_authorizer[0].id}" : ""}"
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
  LAMBDA_URI                      = var.LAMBDA_DELETE_ALLOWED_APIS_FOR_RESOURCE_INVOKE_ARN

}

module "apipermission_resource_DELETE" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.apipermission_resourcename_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  HTTP_METHOD                     = "DELETE"
  AUTHORIZATION = "${var.AUTHORIZATION}"
  AUTHORIZER_ID = "${var.AUTHORIZATION == "CUSTOM" ? "${aws_api_gateway_authorizer.lambda_developer_portal_authorizer[0].id}" : ""}"
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
  LAMBDA_URI                      = var.LAMBDA_DELETE_ALLOWED_APIS_FOR_RESOURCE_INVOKE_ARN
}



//visibility here

module "visibility_resource_OPTION" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.admin_catalog_visibility_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  HTTP_METHOD                     = "OPTIONS"
  AUTHORIZATION                   = "NONE"
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
}

module "visibility_get" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.admin_catalog_visibility_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  AUTHORIZATION = "${var.AUTHORIZATION}"
  AUTHORIZER_ID = "${var.AUTHORIZATION == "CUSTOM" ? "${aws_api_gateway_authorizer.lambda_developer_portal_authorizer[0].id}" : ""}"
  
  
  HTTP_METHOD                     = "GET"
  LAMBDA_INVOKE_ARN               = var.BACKEND_LAMBDA_INVOKE_ARN
  FUNCTION_NAME                   = var.BACKEND_LAMBDA_NAME
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
  LAMBDA_URI                      = var.LAMBDA_GET_ALL_CATALOGS_INVOKE_ARN


  REQUEST_TEMPLATES = {
    "application/json" = <<EOF
    EOF
  }
}
module "visibility_post" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.admin_catalog_visibility_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  AUTHORIZATION = "${var.AUTHORIZATION}"
  AUTHORIZER_ID = "${var.AUTHORIZATION == "CUSTOM" ? "${aws_api_gateway_authorizer.lambda_developer_portal_authorizer[0].id}" : ""}"
  
  
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
  HTTP_METHOD                     = "POST"
  LAMBDA_INVOKE_ARN               = var.BACKEND_LAMBDA_INVOKE_ARN
  FUNCTION_NAME                   = var.BACKEND_LAMBDA_NAME
  LAMBDA_URI                      = var.LAMBDA_ADD_NEW_API_TO_CATALOGS_INVOKE_ARN

  REQUEST_TEMPLATES = {
    "application/json" = <<EOF
    EOF
  }
}

# module "visibility_ANY" {
#   source                          = "./methods"
#   METHOD_VALUE                    = ""
#   API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
#   RESOURCE_ID                     = aws_api_gateway_resource.admin_catalog_visibility_resource.id
#   INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
#   METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
#   AUTHORIZATION                   = var.AUTHORIZATION
#   CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
#   AWS_REGION                      = var.AWS_REGION
#   HTTP_METHOD                     = "ANY"
#   LAMBDA_INVOKE_ARN               = var.BACKEND_LAMBDA_INVOKE_ARN
#   FUNCTION_NAME                   = var.BACKEND_LAMBDA_NAME

#   REQUEST_TEMPLATES = {
#     "application/json" = <<EOF
#     EOF
#   }
# }




//catalog visibility api ends

//proxy api starts


# resource "aws_api_gateway_resource" "proxy_resource" {
#   rest_api_id = aws_api_gateway_rest_api.api-gateway.id
#   parent_id   = aws_api_gateway_rest_api.api-gateway.root_resource_id
#   path_part   = "{proxy+}"
# }
# module "proxy_post" {
#   source                          = "./methods"
#   METHOD_VALUE                    = ""
#   API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
#   RESOURCE_ID                     = aws_api_gateway_resource.proxy_resource.id
#   INTEGRATION_RESPONSE_PARAMETERS = {}
#   METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
#   AUTHORIZATION                   = var.AUTHORIZATION
#   CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
#   AWS_REGION                      = var.AWS_REGION
#   HTTP_METHOD                     = "ANY"
#   LAMBDA_INVOKE_ARN               = var.BACKEND_LAMBDA_INVOKE_ARN
#   FUNCTION_NAME                   = var.BACKEND_LAMBDA_NAME
# }



# module "proxy_resource_OPTION" {
#   source                          = "./methods"
#   METHOD_VALUE                    = ""
#   API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
#   RESOURCE_ID                     = aws_api_gateway_resource.proxy_resource.id
#   INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
#   METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
#   CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
#   AWS_REGION                      = var.AWS_REGION
#   HTTP_METHOD                     = "OPTIONS"
#   AUTHORIZATION                   = "NONE"
# }

//proxy api ends

//NEW APIS

//SIGN IN 
resource "aws_api_gateway_resource" "sigin_resource" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  parent_id   = aws_api_gateway_rest_api.api-gateway.root_resource_id
  path_part   = "signin"
}

module "siginin_resource_OPTION" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.sigin_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  HTTP_METHOD                     = "OPTIONS"
  AUTHORIZATION                   = "NONE"
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
}

module "signin_post" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.sigin_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  HTTP_METHOD                     = "POST"
  AUTHORIZATION = "${var.AUTHORIZATION}"
  AUTHORIZER_ID = "${var.AUTHORIZATION == "CUSTOM" ? "${aws_api_gateway_authorizer.lambda_developer_portal_authorizer[0].id}" : ""}"
  
  
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
  LAMBDA_URI                      = var.LAMBDA_SIGNIN_INVOKE_ARN
}


//APIKEY
resource "aws_api_gateway_resource" "apikey_resource" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  parent_id   = aws_api_gateway_rest_api.api-gateway.root_resource_id
  path_part   = "apikey"
}

module "apiKey_resource_OPTION" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.apikey_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  HTTP_METHOD                     = "OPTIONS"
  AUTHORIZATION                   = "NONE"
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
}

module "apikey_get" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.apikey_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  HTTP_METHOD                     = "GET"
  AUTHORIZATION = "${var.AUTHORIZATION}"
  AUTHORIZER_ID = "${var.AUTHORIZATION == "CUSTOM" ? "${aws_api_gateway_authorizer.lambda_developer_portal_authorizer[0].id}" : ""}"
  
  
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
  LAMBDA_URI                      = var.LAMBDA_GET_APIKEY_INVOKE_ARN
}


//Subscription

resource "aws_api_gateway_resource" "subscription_resource" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  parent_id   = aws_api_gateway_rest_api.api-gateway.root_resource_id
  path_part   = "subscriptions"
}

resource "aws_api_gateway_resource" "usageplan_resource" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  parent_id   = aws_api_gateway_resource.subscription_resource.id
  path_part   = "{usageplanId}"
}

resource "aws_api_gateway_resource" "usage_resource" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  parent_id   = aws_api_gateway_resource.usageplan_resource.id
  path_part   = "usage"
}

module "subscription_resource_OPTION" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.subscription_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  HTTP_METHOD                     = "OPTIONS"
  AUTHORIZATION                   = "NONE"
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
}

module "subscription_get" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.subscription_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  HTTP_METHOD                     = "GET"
  AUTHORIZATION = "${var.AUTHORIZATION}"
  AUTHORIZER_ID = "${var.AUTHORIZATION == "CUSTOM" ? "${aws_api_gateway_authorizer.lambda_developer_portal_authorizer[0].id}" : ""}"
  
  
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
  LAMBDA_URI                      = var.LAMBDA_GET_SUBSCRIPTION_INVOKE_ARN
}




module "usageplan_resource_OPTION" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.usageplan_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  HTTP_METHOD                     = "OPTIONS"
  AUTHORIZATION                   = "NONE"
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
}


module "usagePlanId_put" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.usageplan_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  HTTP_METHOD                     = "PUT"
  AUTHORIZATION = "${var.AUTHORIZATION}"
  AUTHORIZER_ID = "${var.AUTHORIZATION == "CUSTOM" ? "${aws_api_gateway_authorizer.lambda_developer_portal_authorizer[0].id}" : ""}"
  
  
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
  LAMBDA_URI                      =var.LAMBDA_UPDATE_SUBSCRIPTION_USAGE_PLAN_INVOKE_ARN
}

module "usagePlanId_delete" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.usageplan_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  HTTP_METHOD                     = "DELETE"
  AUTHORIZATION = "${var.AUTHORIZATION}"
  AUTHORIZER_ID = "${var.AUTHORIZATION == "CUSTOM" ? "${aws_api_gateway_authorizer.lambda_developer_portal_authorizer[0].id}" : ""}"
  
  
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
  LAMBDA_URI                      =var.LAMBDA_DELETE_SUBSCRIPTION_USAGE_PLAN_INVOKE_ARN
}

module "usage_resource_OPTION" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.usage_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  HTTP_METHOD                     = "OPTIONS"
  AUTHORIZATION                   = "NONE"
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
}


module "usage_get" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.usage_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  HTTP_METHOD                     = "GET"
  AUTHORIZATION = "${var.AUTHORIZATION}"
  AUTHORIZER_ID = "${var.AUTHORIZATION == "CUSTOM" ? "${aws_api_gateway_authorizer.lambda_developer_portal_authorizer[0].id}" : ""}"
  
  
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
  LAMBDA_URI                      = var.LAMBDA_GET_SUBSCRIPTION_USAGE_PLAN_INVOKE_ARN
}

//CATALOG

resource "aws_api_gateway_resource" "catalog_id_resource" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  parent_id  = aws_api_gateway_resource.catalog_resource.id
  path_part   = "{id}"
}
resource "aws_api_gateway_resource" "catalog_id_sdk_resource" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  parent_id  = aws_api_gateway_resource.catalog_id_resource.id
  path_part   = "sdk"
}
resource "aws_api_gateway_resource" "catalog_id_export_resource" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  parent_id  = aws_api_gateway_resource.catalog_id_resource.id
  path_part   = "export"
}

module "sdk_resource_OPTION" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.catalog_id_sdk_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  HTTP_METHOD                     = "OPTIONS"
  AUTHORIZATION                   = "NONE"
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
}

module "export_resource_OPTION" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.catalog_id_export_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  HTTP_METHOD                     = "OPTIONS"
  AUTHORIZATION                   = "NONE"
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
}

module "sdk_get" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.catalog_id_sdk_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  HTTP_METHOD                     = "GET"
  AUTHORIZATION = "${var.AUTHORIZATION}"
  AUTHORIZER_ID = "${var.AUTHORIZATION == "CUSTOM" ? "${aws_api_gateway_authorizer.lambda_developer_portal_authorizer[0].id}" : ""}"
  
  
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
  LAMBDA_URI                      = var.LAMBDA_GET_SDK_INVOKE_ARN
}
module "export_get" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.catalog_id_export_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  HTTP_METHOD                     = "GET"
  AUTHORIZATION = "${var.AUTHORIZATION}"
  AUTHORIZER_ID = "${var.AUTHORIZATION == "CUSTOM" ? "${aws_api_gateway_authorizer.lambda_developer_portal_authorizer[0].id}" : ""}"
  
  
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
  LAMBDA_URI                      = var.LAMBDA_EXPORT_API_INVOKE_ARN
}

resource "aws_api_gateway_resource" "admin_catalog_visibility_id_resource" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  parent_id   = aws_api_gateway_resource.admin_catalog_visibility_resource.id
  path_part   = "{id}"
}
resource "aws_api_gateway_resource" "admin_catalog_visibility_id_sdkGeneration_resource" {
  rest_api_id = aws_api_gateway_rest_api.api-gateway.id
  parent_id   = aws_api_gateway_resource.admin_catalog_id_resource.id
  path_part   = "sdkGeneration"
}

module "visibility_id_resource_OPTION" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.admin_catalog_visibility_id_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  HTTP_METHOD                     = "OPTIONS"
  AUTHORIZATION                   = "NONE"
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
}



module "visibility_delete" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.admin_catalog_visibility_id_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  AUTHORIZATION = "${var.AUTHORIZATION}"
  AUTHORIZER_ID = "${var.AUTHORIZATION == "CUSTOM" ? "${aws_api_gateway_authorizer.lambda_developer_portal_authorizer[0].id}" : ""}"
  
  
  HTTP_METHOD                     = "DELETE"
  LAMBDA_INVOKE_ARN               = var.BACKEND_LAMBDA_INVOKE_ARN
  FUNCTION_NAME                   = var.BACKEND_LAMBDA_NAME
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
  LAMBDA_URI                      =var.LAMBDA_DELETE_API_FROM_CATALOGS_INVOKE_ARN
  REQUEST_TEMPLATES = {
    "application/json" = <<EOF
    EOF
  }
}

module "sdkGeneration_resource_OPTION" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.admin_catalog_visibility_id_sdkGeneration_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  HTTP_METHOD                     = "OPTIONS"
  AUTHORIZATION                   = "NONE"
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
}


module "sdkGeneration_put" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.admin_catalog_visibility_id_sdkGeneration_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  AUTHORIZATION = "${var.AUTHORIZATION}"
  AUTHORIZER_ID = "${var.AUTHORIZATION == "CUSTOM" ? "${aws_api_gateway_authorizer.lambda_developer_portal_authorizer[0].id}" : ""}"
  
  
  HTTP_METHOD                     = "PUT"
  LAMBDA_INVOKE_ARN               = var.BACKEND_LAMBDA_INVOKE_ARN
  FUNCTION_NAME                   = var.BACKEND_LAMBDA_NAME
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
  LAMBDA_URI                      =var.LAMBDA_UPDATE_SDK_GENERATION_IN_CATALOG_API_INVOKE_ARN
  REQUEST_TEMPLATES = {
    "application/json" = <<EOF
    EOF
  }
}

//IS HERE

module "sdkGeneration_delete" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.admin_catalog_visibility_id_sdkGeneration_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  AUTHORIZATION = "${var.AUTHORIZATION}"
  AUTHORIZER_ID = "${var.AUTHORIZATION == "CUSTOM" ? "${aws_api_gateway_authorizer.lambda_developer_portal_authorizer[0].id}" : ""}"
  
  
  HTTP_METHOD                     = "DELETE"
  LAMBDA_INVOKE_ARN               = var.BACKEND_LAMBDA_INVOKE_ARN
  FUNCTION_NAME                   = var.BACKEND_LAMBDA_NAME
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
  LAMBDA_URI                      =var.LAMBDA_DELETE_SDK_GENERATION_IN_CATALOG_API_INVOKE_ARN

  REQUEST_TEMPLATES = {
    "application/json" = <<EOF
    EOF
  }
}

// Admin/account
module "admin_account_resource_OPTION" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.admin_account_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  HTTP_METHOD                     = "OPTIONS"
  AUTHORIZATION                   = "NONE"
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
}

module "account_get" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.admin_account_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  AUTHORIZATION = "${var.AUTHORIZATION}"
  AUTHORIZER_ID = "${var.AUTHORIZATION == "CUSTOM" ? "${aws_api_gateway_authorizer.lambda_developer_portal_authorizer[0].id}" : ""}"
  
  
  HTTP_METHOD                     = "GET"
  LAMBDA_INVOKE_ARN               = var.BACKEND_LAMBDA_INVOKE_ARN
  FUNCTION_NAME                   = var.BACKEND_LAMBDA_NAME
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
  LAMBDA_URI                      =var.LAMBDA_GET_ALL_ACCOUNTS_INVOKE_ARN
  REQUEST_TEMPLATES = {
    "application/json" = <<EOF
    EOF
  }
}

module "account_post" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.admin_account_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  AUTHORIZATION = "${var.AUTHORIZATION}"
  AUTHORIZER_ID = "${var.AUTHORIZATION == "CUSTOM" ? "${aws_api_gateway_authorizer.lambda_developer_portal_authorizer[0].id}" : ""}"
  
  
  HTTP_METHOD                     = "POST"
  LAMBDA_INVOKE_ARN               = var.BACKEND_LAMBDA_INVOKE_ARN
  FUNCTION_NAME                   = var.BACKEND_LAMBDA_NAME
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
  LAMBDA_URI                      =var.LAMBDA_CREATE_NEW_ACCOUNT_INVOKE_ARN
  REQUEST_TEMPLATES = {
    "application/json" = <<EOF
    EOF
  }
}

module "account_userid_get" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.admin_account_userid_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  AUTHORIZATION = "${var.AUTHORIZATION}"
  AUTHORIZER_ID = "${var.AUTHORIZATION == "CUSTOM" ? "${aws_api_gateway_authorizer.lambda_developer_portal_authorizer[0].id}" : ""}"
  
  
  HTTP_METHOD                     = "GET"
  LAMBDA_INVOKE_ARN               = var.BACKEND_LAMBDA_INVOKE_ARN
  FUNCTION_NAME                   = var.BACKEND_LAMBDA_NAME
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
  LAMBDA_URI                      =var.LAMBDA_GET_CURRENT_USER_PROFILE_INVOKE_ARN

  REQUEST_TEMPLATES = {
    "application/json" = <<EOF
    EOF
  }
}

module "admin_account_userid_resource_OPTION" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.admin_account_userid_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  HTTP_METHOD                     = "OPTIONS"
  AUTHORIZATION                   = "NONE"
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
}

module "account_userid_promote_to_admin" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.promote_to_admin_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  AUTHORIZATION = "${var.AUTHORIZATION}"
  AUTHORIZER_ID = "${var.AUTHORIZATION == "CUSTOM" ? "${aws_api_gateway_authorizer.lambda_developer_portal_authorizer[0].id}" : ""}"
  
  
  HTTP_METHOD                     = "PUT"
  LAMBDA_INVOKE_ARN               = var.BACKEND_LAMBDA_INVOKE_ARN
  FUNCTION_NAME                   = var.BACKEND_LAMBDA_NAME
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
  LAMBDA_URI                      =var.LAMBDA_PROMOTE_USER_TO_ADMIN_INVOKE_ARN

  REQUEST_TEMPLATES = {
    "application/json" = <<EOF
    EOF
  }
}

module "promote_to_admin_resource_OPTION" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.promote_to_admin_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  HTTP_METHOD                     = "OPTIONS"
  AUTHORIZATION                   = "NONE"
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
}


module "account_userid_delete" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.admin_account_userid_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  AUTHORIZATION = "${var.AUTHORIZATION}"
  AUTHORIZER_ID = "${var.AUTHORIZATION == "CUSTOM" ? "${aws_api_gateway_authorizer.lambda_developer_portal_authorizer[0].id}" : ""}"
  
  HTTP_METHOD                     = "DELETE"
  LAMBDA_INVOKE_ARN               = var.BACKEND_LAMBDA_INVOKE_ARN
  FUNCTION_NAME                   = var.BACKEND_LAMBDA_NAME
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
  LAMBDA_URI                      =var.LAMBDA_DELETE_USER_INVOKE_ARN

  REQUEST_TEMPLATES = {
    "application/json" = <<EOF
    EOF
  }
}

//CallBackAuth

module "account_callbackauth" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.admin_account_callback_auth_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  AUTHORIZATION = "${var.AUTHORIZATION}"
  AUTHORIZER_ID = "${var.AUTHORIZATION == "CUSTOM" ? "${aws_api_gateway_authorizer.lambda_developer_portal_authorizer[0].id}" : ""}"
  
  
  HTTP_METHOD                     = "POST"
  LAMBDA_INVOKE_ARN               = var.BACKEND_LAMBDA_INVOKE_ARN
  FUNCTION_NAME                   = var.BACKEND_LAMBDA_NAME
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
  LAMBDA_URI                      =var.LAMBDA_GET_USER_CALLBACKAUTH_INVOKE_ARN

  REQUEST_TEMPLATES = {
    "application/json" = <<EOF
    EOF
  }
}

module "callbackauth_resource_OPTION" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.admin_account_callback_auth_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  HTTP_METHOD                     = "OPTIONS"
  AUTHORIZATION                   = "NONE"
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
}


//resend invite

module "resendInvite_post" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.admin_account_resend_invite_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  AUTHORIZATION = "${var.AUTHORIZATION}"
  AUTHORIZER_ID = "${var.AUTHORIZATION == "CUSTOM" ? "${aws_api_gateway_authorizer.lambda_developer_portal_authorizer[0].id}" : ""}"
  
  
  HTTP_METHOD                     = "POST"
  LAMBDA_INVOKE_ARN               = var.BACKEND_LAMBDA_INVOKE_ARN
  FUNCTION_NAME                   = var.BACKEND_LAMBDA_NAME
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
  LAMBDA_URI                      =var.LAMBDA_RESEND_INVITE_INVOKE_ARN

  REQUEST_TEMPLATES = {
    "application/json" = <<EOF
    EOF
  }
}

module "resendInvite_resource_OPTION" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.admin_account_resend_invite_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  HTTP_METHOD                     = "OPTIONS"
  AUTHORIZATION                   = "NONE"
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
}


module "userProfile_get" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.admin_account_user_profile_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  AUTHORIZATION = "${var.AUTHORIZATION}"
  AUTHORIZER_ID = "${var.AUTHORIZATION == "CUSTOM" ? "${aws_api_gateway_authorizer.lambda_developer_portal_authorizer[0].id}" : ""}"
  
  
  HTTP_METHOD                     = "GET"
  LAMBDA_INVOKE_ARN               = var.BACKEND_LAMBDA_INVOKE_ARN
  FUNCTION_NAME                   = var.BACKEND_LAMBDA_NAME
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
  LAMBDA_URI                      =var.LAMBDA_GET_CURRENT_USER_PROFILE_INVOKE_ARN

  REQUEST_TEMPLATES = {
    "application/json" = <<EOF
    EOF
  }
}

module "userProfile_resource_OPTION" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.admin_account_user_profile_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  HTTP_METHOD                     = "OPTIONS"
  AUTHORIZATION                   = "NONE"
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
}



module "MnoResource_post" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.admin_account_mno_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  AUTHORIZATION = "${var.AUTHORIZATION}"
  AUTHORIZER_ID = "${var.AUTHORIZATION == "CUSTOM" ? "${aws_api_gateway_authorizer.lambda_developer_portal_authorizer[0].id}" : ""}"
  
  HTTP_METHOD                     = "POST"
  LAMBDA_INVOKE_ARN               = var.BACKEND_LAMBDA_INVOKE_ARN
  FUNCTION_NAME                   = var.BACKEND_LAMBDA_NAME
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
  LAMBDA_URI                      =var.LAMBDA_CREATE_MNO_THIRD_PARTY_RESOURCE_INVOKE_ARN

  REQUEST_TEMPLATES = {
    "application/json" = <<EOF
    EOF
  }
}


module "MnoResource_get" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.admin_account_mno_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  AUTHORIZATION = "${var.AUTHORIZATION}"
  AUTHORIZER_ID = "${var.AUTHORIZATION == "CUSTOM" ? "${aws_api_gateway_authorizer.lambda_developer_portal_authorizer[0].id}" : ""}"
  
  HTTP_METHOD                     = "GET"
  LAMBDA_INVOKE_ARN               = var.BACKEND_LAMBDA_INVOKE_ARN
  FUNCTION_NAME                   = var.BACKEND_LAMBDA_NAME
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
  LAMBDA_URI                      =var.LAMBDA_CREATE_MNO_THIRD_PARTY_RESOURCE_INVOKE_ARN

  REQUEST_TEMPLATES = {
    "application/json" = <<EOF
    EOF
  }
}

module "Mno_resource_OPTION" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.admin_account_mno_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  HTTP_METHOD                     = "OPTIONS"
  AUTHORIZATION                   = "NONE"
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
}


# module "MnoResource_get" {
#   source                          = "./methods"
#   METHOD_VALUE                    = ""
#   API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
#   RESOURCE_ID                     = aws_api_gateway_resource.admin_account_mno_resourceid_resource.id
#   INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
#   METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
#   AUTHORIZATION = "${var.AUTHORIZATION}"
#   AUTHORIZER_ID = "${var.AUTHORIZATION == "CUSTOM" ? "${aws_api_gateway_authorizer.lambda_authorizer[0].id}" : ""}"
  
#   HTTP_METHOD                     = "GET"
#   LAMBDA_INVOKE_ARN               = var.BACKEND_LAMBDA_INVOKE_ARN
#   FUNCTION_NAME                   = var.BACKEND_LAMBDA_NAME
#   CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
#   AWS_REGION                      = var.AWS_REGION
#   LAMBDA_URI                      =var.LAMBDA_GET_MNO_THIRD_PARTY_RESOURCE_INVOKE_ARN

#   REQUEST_TEMPLATES = {
#     "application/json" = <<EOF
#     EOF
#   }
# }

module "Mno_resourceid_OPTION" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.admin_account_mno_resourceid_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  HTTP_METHOD                     = "OPTIONS"
  AUTHORIZATION                   = "NONE"
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
}


module "profileImage_resource_OPTION" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.admin_account_profile_image_user_id_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  HTTP_METHOD                     = "OPTIONS"
  AUTHORIZATION                   = "NONE"
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
}

module "profileImage_get" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.admin_account_profile_image_user_id_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  AUTHORIZATION = "${var.AUTHORIZATION}"
  AUTHORIZER_ID = "${var.AUTHORIZATION == "CUSTOM" ? "${aws_api_gateway_authorizer.lambda_developer_portal_authorizer[0].id}" : ""}"
  
  
  HTTP_METHOD                     = "GET"
  LAMBDA_INVOKE_ARN               = var.BACKEND_LAMBDA_INVOKE_ARN
  FUNCTION_NAME                   = var.BACKEND_LAMBDA_NAME
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
  LAMBDA_URI                        =var.LAMBDA_GET_USER_PROFILE_IMAGE_INVOKE_ARN
    REQUEST_TEMPLATES = {
      "application/json" = <<EOF
    EOF
  }
}

module "profileImage_put" {
  source                          = "./methods"
  METHOD_VALUE                    = ""
  API_GATEWAY_ID                  = aws_api_gateway_rest_api.api-gateway.id
  RESOURCE_ID                     = aws_api_gateway_resource.admin_account_profile_image_user_id_resource.id
  INTEGRATION_RESPONSE_PARAMETERS = local.integration_response_parameters
  METHOD_RESPONSE_PARAMETERS      = local.method_response_parameters
  AUTHORIZATION = "${var.AUTHORIZATION}"
  AUTHORIZER_ID = "${var.AUTHORIZATION == "CUSTOM" ? "${aws_api_gateway_authorizer.lambda_developer_portal_authorizer[0].id}" : ""}"
  
  
  HTTP_METHOD                     = "PUT"
  LAMBDA_INVOKE_ARN               = var.BACKEND_LAMBDA_INVOKE_ARN
  FUNCTION_NAME                   = var.BACKEND_LAMBDA_NAME
  CURRENT_ACCOUNT_ID              = var.CURRENT_ACCOUNT_ID
  AWS_REGION                      = var.AWS_REGION
  LAMBDA_URI                      =var.LAMBDA_UPDATE_USER_PROFILE_IMAGE_INVOKE_ARN
  REQUEST_TEMPLATES = {
    "application/json" = <<EOF
    EOF
  }
}

### --- API Deployment Starts --- ###

resource "aws_api_gateway_deployment" "api-gateway-deployment" {
  depends_on = [
    "module.version_resource_OPTION.API_GATEWAY_METHOD",
    "module.root_resource_OPTION.API_GATEWAY_METHOD",
    "module.feedback_resource_OPTION.API_GATEWAY_METHOD",
    "module.catalog_resource_OPTION.API_GATEWAY_METHOD",
    "module.visibility_resource_OPTION.API_GATEWAY_METHOD",
    "module.Mno_resource_OPTION.API_GATEWAY_METHOD",
    "module.Mno_resourceid_OPTION.API_GATEWAY_METHOD",

    "module.siginin_resource_OPTION.API_GATEWAY_METHOD",
    "module.apiKey_resource_OPTION.API_GATEWAY_METHOD",
    "module.subscription_resource_OPTION.API_GATEWAY_METHOD",    
    "module.usageplan_resource_OPTION.API_GATEWAY_METHOD",
    "module.sdk_resource_OPTION.API_GATEWAY_METHOD",
    "module.export_resource_OPTION.API_GATEWAY_METHOD",
    "module.visibility_id_resource_OPTION.API_GATEWAY_METHOD",
    "module.export_resource_OPTION.API_GATEWAY_METHOD",
    "module.sdkGeneration_resource_OPTION.API_GATEWAY_METHOD",
    "module.admin_account_resource_OPTION.API_GATEWAY_METHOD",
    "module.admin_account_userid_resource_OPTION.API_GATEWAY_METHOD",
    "module.usage_resource_OPTION.API_GATEWAY_METHOD",

    # "module.promote_to_admin_resource_OPTION.API_GATEWAY_METHOD",
    "module.apikey_get.API_GATEWAY_METHOD",
    "module.apikey_get.API_GATEWAY_INTEGRATION",
    "module.apikey_get.API_GATEWAY_RESPONSE_200",
    
    "module.sdk_get.API_GATEWAY_METHOD",
    "module.sdk_get.API_GATEWAY_INTEGRATION",
    "module.sdk_get.API_GATEWAY_RESPONSE_200",

    "module.export_get.API_GATEWAY_METHOD",
    "module.export_get.API_GATEWAY_INTEGRATION",
    "module.export_get.API_GATEWAY_RESPONSE_200",

    "module.visibility_delete.API_GATEWAY_METHOD",
    "module.visibility_delete.API_GATEWAY_INTEGRATION",
    "module.visibility_delete.API_GATEWAY_RESPONSE_200",


    "module.sdkGeneration_delete.API_GATEWAY_METHOD",
    "module.sdkGeneration_delete.API_GATEWAY_INTEGRATION",
    "module.sdkGeneration_delete.API_GATEWAY_RESPONSE_200",


    "module.account_get.API_GATEWAY_METHOD",
    "module.account_get.API_GATEWAY_INTEGRATION",
    "module.account_get.API_GATEWAY_RESPONSE_200",
    
    "module.account_post.API_GATEWAY_METHOD",
    "module.account_post.API_GATEWAY_INTEGRATION",
    "module.account_post.API_GATEWAY_RESPONSE_200",

    "module.account_userid_get.API_GATEWAY_METHOD",
    "module.account_userid_get.API_GATEWAY_INTEGRATION",
    "module.account_userid_get.API_GATEWAY_RESPONSE_200",
    
    "module.account_userid_promote_to_admin.API_GATEWAY_METHOD",
    "module.account_userid_promote_to_admin.API_GATEWAY_INTEGRATION",
    "module.account_userid_promote_to_admin.API_GATEWAY_RESPONSE_200",
    
    "module.account_userid_delete.API_GATEWAY_METHOD",
    "module.account_userid_delete.API_GATEWAY_INTEGRATION",
    "module.account_userid_delete.API_GATEWAY_RESPONSE_200",
    
    "module.account_callbackauth.API_GATEWAY_METHOD",
    "module.account_callbackauth.API_GATEWAY_INTEGRATION",
    "module.account_callbackauth.API_GATEWAY_RESPONSE_200",
    
    "module.resendInvite_post.API_GATEWAY_METHOD",
    "module.resendInvite_post.API_GATEWAY_INTEGRATION",
    "module.resendInvite_post.API_GATEWAY_RESPONSE_200",
        
    "module.userProfile_get.API_GATEWAY_METHOD",
    "module.userProfile_get.API_GATEWAY_INTEGRATION",
    "module.userProfile_get.API_GATEWAY_RESPONSE_200",

    "module.subscription_get.API_GATEWAY_METHOD",
    "module.subscription_get.API_GATEWAY_INTEGRATION",
    "module.subscription_get.API_GATEWAY_RESPONSE_200",


    "module.profileImage_get.API_GATEWAY_METHOD",
    "module.profileImage_get.API_GATEWAY_INTEGRATION",
    "module.profileImage_get.API_GATEWAY_RESPONSE_200",


    "module.catalog.API_GATEWAY_METHOD",
    "module.catalog.API_GATEWAY_INTEGRATION",
    "module.catalog.API_GATEWAY_RESPONSE_200",

    "module.feedback_get.API_GATEWAY_METHOD",
    "module.feedback_get.API_GATEWAY_INTEGRATION",
    "module.feedback_get.API_GATEWAY_RESPONSE_200",
    "module.feedback_post.API_GATEWAY_METHOD",
    "module.feedback_post.API_GATEWAY_INTEGRATION",
    "module.feedback_post.API_GATEWAY_RESPONSE_200",

    "module.feedback_delete.API_GATEWAY_METHOD",
    "module.feedback_delete.API_GATEWAY_INTEGRATION",
    "module.feedback_delete.API_GATEWAY_RESPONSE_200",

    "module.signin_post.API_GATEWAY_METHOD",
    "module.signin_post.API_GATEWAY_INTEGRATION",
    "module.signin_post.API_GATEWAY_RESPONSE_200",

    "module.visibility_get.API_GATEWAY_METHOD",
    "module.visibility_get.API_GATEWAY_INTEGRATION",
    "module.visibility_get.API_GATEWAY_RESPONSE_200",
    "module.visibility_post.API_GATEWAY_METHOD",
    "module.visibility_post.API_GATEWAY_INTEGRATION",
    "module.visibility_post.API_GATEWAY_RESPONSE_200",

    # "module.proxy_post.API_GATEWAY_METHOD",
    # "module.proxy_post.API_GATEWAY_INTEGRATION",
    # "module.proxy_post.API_GATEWAY_RESPONSE_200",
  ]
  rest_api_id       = aws_api_gateway_rest_api.api-gateway.id
  stage_name        = "prod"
  stage_description = "1.0"
  description       = "1.0"

  variables = {
    "DevPortalFunctionName" = "${var.RESOURCE_PREFIX}-backend"
  }

  lifecycle {
    create_before_destroy = true
  }
}




resource "aws_api_gateway_authorizer" "lambda_authorizer" {
  name                   = "${var.RESOURCE_PREFIX}-lambda-authorizer"
  rest_api_id            = aws_api_gateway_rest_api.api-gateway.id
  authorizer_uri         = var.API_KEY_AUTHORIZATION_INVOKE_ARN
  authorizer_credentials = var.API_KEY_AUTHORIZATION_ROLE_ARN
  count            = "${var.AUTHORIZATION == "CUSTOM" ? 1 : 0}"
}

resource "aws_api_gateway_authorizer" "lambda_developer_portal_authorizer" {
  name                   = "${var.RESOURCE_PREFIX}-developer-portal-lambda-authorizer"
  rest_api_id            = aws_api_gateway_rest_api.api-gateway.id
  authorizer_uri         = var.DEVELOPER_PORTAL_AUTHORIZATION_INVOKE_ARN
  authorizer_credentials = var.LAMBDA_DEVELOPER_PORTAL_AUTHORIZER_ROLE_ARN
  type             = "REQUEST"
  authorizer_result_ttl_in_seconds = "0"
  identity_source        = "method.request.header.authorizerToken"

  count            = "${var.AUTHORIZATION == "CUSTOM" ? 1 : 0}"
}

resource "aws_lambda_permission" "siginin_post_lambda_permission" {
  function_name = var.SIGNIN_LAMBDA_NAME
  statement_id  = "SIGNIN-LAMBDA-PERMISSION"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api-gateway.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "get_api_key_lambda_permission" {
  function_name = var.GET_APIKEY_LAMBDA_NAME
  statement_id  = "GET-APIKEY-LAMBDA-PERMISSION"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api-gateway.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "get_current_user_profile_lambda_permission" {
  function_name = var.GET_CURRENT_USER_PROFILE_LAMBDA_NAME
  statement_id  = "GET-CURRENT-USER-PROFILE-LAMBDA-PERMISSION"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api-gateway.execution_arn}/*/*/*"
}


resource "aws_lambda_permission" "get_catalog_lambda_permission" {
  function_name = var.GET_CATALOG_LAMBDA_NAME
  statement_id  = "GET-CATALOG-LAMBDA-PERMISSION"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api-gateway.execution_arn}/*"
}

resource "aws_lambda_permission" "get_subscription_lambda_permission" {
  function_name = var.GET_SUBSCRIPTION_LAMBDA_NAME
  statement_id  = "GET-SUBSCRIPTION-LAMBDA-PERMISSION"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api-gateway.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "update_subscription_lambda_permission" {
  function_name = var.UPDATE_SUBSCRIPTION_USAGE_PLAN_LAMBDA_NAME
  statement_id  = "UPDATE-SUBSCRIPTION-USAGE-PLAN-LAMBDA-PERMISSION"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api-gateway.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "delete_subscription_usage_plan_lambda_permission" {
  function_name = var.DELETE_SUBSCRIPTION_USAGE_PLAN_LAMBDA_NAME
  statement_id  = "DELETE-SUBSCRIPTION-USAGE-PLAN-LAMBDA-PERMISSION"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api-gateway.execution_arn}/*/*/*"
}
resource "aws_lambda_permission" "get_subscription_usage_plan_lambda_permission" {
  function_name = var.GET_SUBSCRIPTION_USAGE_PLAN_LAMBDA_NAME
  statement_id  = "GET-SUBSCRIPTION-USAGE-PLAN-LAMBDA-PERMISSION"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api-gateway.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "get_feedback_lambda_permission" {
  function_name = var.GET_FEEDBACK_LAMBDA_NAME
  statement_id  = "GET-FEEDBACK-LAMBDA-NAME"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api-gateway.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "post_feedback_lambda_permission" {
  function_name = var.POST_FEEDBACK_LAMBDA_NAME
  statement_id  = "POST-FEEDBACK-LAMBDA-PERMISSION"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api-gateway.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "get_sdk_lambda_permission" {
  function_name = var.GET_SDK_LAMBDA_NAME
  statement_id  = "GET-SDK-LAMBDA-PERMISSION"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api-gateway.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "export_api_lambda_permission" {
  function_name = var.EXPORT_API_LAMBDA_NAME
  statement_id  = "EXPORT-API-LAMBDA-PERMISSION"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api-gateway.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "update_sdk_generation_in_catalog_api_lambda_permission" {
  function_name = var.UPDATE_SDK_GENERATION_IN_CATALOG_API_LAMBDA_NAME
  statement_id  = "UPDATE-SDK-GENERATION-IN-CATALOG-API-LAMBDA-PERMISSION"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api-gateway.execution_arn}/*"
}

resource "aws_lambda_permission" "delete_sdk_generation_in_catalog_api_lambda_permission" {
  function_name = var.DELETE_SDK_GENERATION_IN_CATALOG_API_LAMBDA_NAME
  statement_id  = "DELETE-SDK-GENERATION-IN-CATALOG-API-LAMBDA-PERMISSION"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api-gateway.execution_arn}/*"
}

resource "aws_lambda_permission" "get_all_catalogs_lambda_permission" {
  function_name = var.GET_ALL_CATALOGS_LAMBDA_NAME
  statement_id  = "GET-ALL-CATALOGS-LAMBDA-PERMISSION"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api-gateway.execution_arn}/*/*/*"
}



resource "aws_lambda_permission" "add_new_api_to_catalogs_lambda_permission" {
  function_name = var.ADD_NEW_API_TO_CATALOGS_LAMBDA_NAME
  statement_id  = "ADD-NEW-API-TO-CATALOGS-LAMBDA-PERMISSION"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api-gateway.execution_arn}/*"

}
resource "aws_lambda_permission" "delete_api_from_catalogs_lambda_permission" {
  function_name = var.DELETE_API_FROM_CATALOGS_LAMBDA_NAME
  statement_id  = "DELETE-API-FROM-CATALOGS-LAMBDA-PERMISSION"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api-gateway.execution_arn}/*"
}

resource "aws_lambda_permission" "create_new_account_lambda_permission" {
  function_name = var.CREATE_NEW_ACCOUNT_LAMBDA_NAME
  statement_id  = "CREATE-NEW-ACCOUNT-LAMBDA-PERMISSION"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api-gateway.execution_arn}/*/*/*"
}
resource "aws_lambda_permission" "delete_user_lambda_permission" {
  function_name = var.DELETE_USER_LAMBDA_NAME
  statement_id  = "DELETE_USER_LAMBDA_PERMISSION"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api-gateway.execution_arn}/*/*/*"
}
resource "aws_lambda_permission" "promote_user_to_admin_lambda_name" {
  function_name = var.PROMOTE_USER_TO_ADMIN_LAMBDA_NAME
  statement_id  = "PROMOTE-USER-TO-ADMIN-LAMBDA-PERMISSION"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api-gateway.execution_arn}/*/*/*"
}
resource "aws_lambda_permission" "resend_invite_lambda_permission" {
  function_name = var.RESEND_INVITE_LAMBDA_NAME
  statement_id  = "RESEND_INVITE_LAMBDA_PERMISSION"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api-gateway.execution_arn}/*/*/*"
}
resource "aws_lambda_permission" "get_user_callbackauth_lambda_permission" {
  function_name = var.GET_USER_CALLBACKAUTH_LAMBDA_NAME
  statement_id  = "GET_USER_CALLBACKAUTH_LAMBDA_PERMISSION"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api-gateway.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "update_user_profile_image_lambda_permission" {
  function_name = var.UPDATE_USER_PROFILE_IMAGE_LAMBDA_NAME
  statement_id  = "UPDATE_USER_PROFILE_IMAGE_LAMBDA_PERMISSION"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api-gateway.execution_arn}/*/*/*"
}
resource "aws_lambda_permission" "get_user_profile_image_lambda_permission" {
  function_name = var.GET_USER_PROFILE_IMAGE_LAMBDA_NAME
  statement_id  = "GET_USER_PROFILE_IMAGE_LAMBDA_PERMISSION"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api-gateway.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "get_all_account_lambda_permission" {
  function_name = var.GET_ALL_ACCOUNTS_LAMBDA_NAME
  statement_id  = "GET_ALL_ACCOUNTS_LAMBDA__PERMISSION"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api-gateway.execution_arn}/*/*/*"
}


resource "aws_lambda_permission" "create_mno_third_party_resource_lambda_permission" {
  function_name = var.CREATE_MNO_THIRD_PARTY_RESOURCE_LAMBDA_NAME
  statement_id  = "CREATE_MNO_THIRD_PARTY_RESOURCE_PERMISSION"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api-gateway.execution_arn}/*/*/*"
}


resource "aws_lambda_permission" "create_api_permissions_for_mno_lambda_permission" {
  function_name = var.CREATE_PERMISION_FOR_API_LAMBDA_NAME
  statement_id  = "CREATE_PERMISION_FOR_API_LAMBDA_PERMISSION"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api-gateway.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "get_allowed_apis_for_resource_lambda_permission" {
  function_name = var.GET_ALLOWED_APIS_FOR_RESOURCE_LAMBDA_NAME
  statement_id  = "GET_ALLOWED_APIS_FOR_RESOURCE_LAMBDA_PERMISSION"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api-gateway.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "delete_allowed_apis_for_resource_lambda_permission" {
  function_name = var.DELETE_ALLOWED_APIS_FOR_RESOURCE_LAMBDA_NAME
  statement_id  = "GET_ALLOWED_APIS_FOR_RESOURCE_LAMBDA_PERMISSION"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api-gateway.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "get_mno_third_party_resource_lambda_permission" {
  function_name = var.GET_MNO_THIRD_PARTY_RESOURCE_LAMBDA_NAME
  statement_id  = "GET_MNO_THIRD_PARTY_RESOURCE_LAMBDA_PERMISSION"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api-gateway.execution_arn}/*/*/*"
}



resource "aws_lambda_permission" "lambda_developer_portal_authorizer_permission" {
  function_name = var.DEVELOPER_PORTAL_AUTHORIZATION_LAMBDA_NAME
  statement_id  = "DEVELOPER_PORTAL_AUTHORIZATION_LAMBDA_PERMISSION"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.AWS_REGION}:${var.CURRENT_ACCOUNT_ID}:*"
}

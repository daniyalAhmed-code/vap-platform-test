locals {
  USER_LOGIN_URL = "${var.USERPOOL_DOMAIN}/login?response_type=token&client_id=${var.USERPOOL_CLIENT_ID}&redirect_uri=https://${var.DOMAIN_NAME}/index.html?action=login"
  USER_LOGOUT_URL = "${var.USERPOOL_DOMAIN}/logout?response_type=token&client_id=${var.USERPOOL_CLIENT_ID}&logout_uri=https://${var.DOMAIN_NAME}/index.html?action=logout"
  
  MNO_LOGIN_URL = "${var.MNO_COGNITO_USER_POOL_DOMAIN}/login?response_type=token&client_id=${var.MNO_USERPOOL_CLIENT_ID}&redirect_uri=https://${var.DOMAIN_NAME}/index.html?action=login"
  MNO_LOGOUT_URL = "${var.MNO_COGNITO_USER_POOL_DOMAIN}/logout?response_type=token&client_id=${var.MNO_USERPOOL_CLIENT_ID}&logout_uri=https://${var.DOMAIN_NAME}/index.html?action=logout"

  THIRD_PARTY_LOGIN_URL = "${var.THIRD_PARTY_COGNITO_USER_POOL_DOMAIN}/login?response_type=token&client_id=${var.THIRD_PARTY_USERPOOL_CLIENT_ID}&redirect_uri=https://${var.DOMAIN_NAME}/index.html?action=login"
  THIRD_PARTY_LOGOUT_URL = "${var.THIRD_PARTY_COGNITO_USER_POOL_DOMAIN}/logout?response_type=token&client_id=${var.THIRD_PARTY_USERPOOL_CLIENT_ID}&logout_uri=https://${var.DOMAIN_NAME}/index.html?action=logout"  

  s3_config_rendered_content        = templatefile("${path.module}/template/config.tmpl", { FeedbackEnabled = var.FEEDBACK_ENABLED, UserPoolDomain = var.USERPOOL_DOMAIN, UserPoolClientId = var.USERPOOL_CLIENT_ID, UserPoolId = var.USERPOOL_ID, IdentityPoolId = var.IDENTITYPOOL_ID, Region = var.AWS_REGION, RestApiId = var.API_GATEWAY_API, ApiGatewayCustomDomainName = var.APIGATEWAY_CUSTOM_DOMAIN_NAME , USER_LOGIN_URL= local.USER_LOGIN_URL, USER_LOGOUT_URL = local.USER_LOGOUT_URL , MNO_LOGIN_URL = local.MNO_LOGIN_URL , MNO_LOGOUT_URL = local.MNO_LOGOUT_URL , THIRD_PARTY_LOGIN_URL = local.THIRD_PARTY_LOGIN_URL , THIRD_PARTY_LOGOUT_URL = local.THIRD_PARTY_LOGOUT_URL  })
  s3_sdkGeneration_rendered_content = templatefile("${path.module}/template/sdkGeneration.tmpl", {})
  s3_catalog_rendered_content       = templatefile("${path.module}/template/catalog.tmpl", {})
}
locals {
  s3_config_rendered_content        = templatefile("${path.module}/template/config.tmpl", { FeedbackEnabled = var.FEEDBACK_ENABLED, UserPoolDomain = var.USERPOOL_DOMAIN, UserPoolClientId = var.USERPOOL_CLIENT_ID, UserPoolId = var.USERPOOL_ID, IdentityPoolId = var.IDENTITYPOOL_ID, Region = var.AWS_REGION, RestApiId = var.API_GATEWAY_API, ApiGatewayCustomDomainName = var.APIGATEWAY_CUSTOM_DOMAIN_NAME })
  s3_sdkGeneration_rendered_content = templatefile("${path.module}/template/sdkGeneration.tmpl", {})
  s3_catalog_rendered_content       = templatefile("${path.module}/template/catalog.tmpl", {})
}
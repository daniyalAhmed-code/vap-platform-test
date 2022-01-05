output "outputs" {
  value = module.cognito.COGNITO_USERPOOL_DOMAIN
}
output "domain_output" {
  value = module.cloudfront.CLOUDFRONT_DOMAIN
}

output "lambda_authorizer_invoke_arn" {
  value = module.lambda.API_KEY_AUTHORIZATION_INVOKE_ARN
}

output "api_gateway_custom_domain_name" {
  value = var.APIGATEWAY_CUSTOM_DOMAIN_NAME
}

output "dev_portal_domain_name" {
  value = var.CUSTOM_DOMAIN_NAME
}
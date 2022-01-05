output "API_GATEWAY_API" {
  value = aws_api_gateway_rest_api.api-gateway.execution_arn
}
output "API_GATEWAY_ID" {
  value = aws_api_gateway_rest_api.api-gateway.id
}

output "API_GATEWAY_CLOUDFRONT_DOMAIN" {
  value = aws_api_gateway_domain_name.this.cloudfront_domain_name
}

output "API_GATEWAY_CLOUDFRONT_ZONE_ID" {
  value = aws_api_gateway_domain_name.this.cloudfront_zone_id
}
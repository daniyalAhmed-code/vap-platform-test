output "API_GATEWAY_METHOD" {
  value = "${aws_api_gateway_method.lambda_method}"
}

output "API_GATEWAY_INTEGRATION" {
  value = "${aws_api_gateway_integration.lambda_integration}"
}

output "API_GATEWAY_RESPONSE_200" {
  value = "${aws_api_gateway_method_response.lambda_method_response_200}"
}
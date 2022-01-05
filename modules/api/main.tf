## Swagger file
data "template_file" "swagger" {
  template = file(var.swagger_file)
  vars     = var.swagger_vars
}

## Lambda
resource "aws_lambda_permission" "this" {
  count         = length(var.lambda_functions_names)
  function_name = var.lambda_functions_names[count.index]
  statement_id  = "APIGatewayAny"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.this.arn}/*/*/*"
}

## API Rest
resource "aws_api_gateway_rest_api" "this" {
  name                         = var.name
  body                         = data.template_file.swagger.rendered
  disable_execute_api_endpoint = true
  api_key_source               = "AUTHORIZER"
}

## API Gateway
resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  description = var.description
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.this))
  }
  lifecycle {
    create_before_destroy = true
  }
}

## API Stage
resource "aws_api_gateway_stage" "this" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  deployment_id = aws_api_gateway_deployment.this.id
  stage_name    = var.env
}

## Add WAF
resource "aws_wafv2_web_acl_association" "this" {
  count        = var.waf_acl_id != "" ? 1 : 0
  resource_arn = aws_api_gateway_stage.this.arn
  web_acl_arn  = var.waf_acl_id
}

## Logs
resource "aws_cloudwatch_log_group" "this" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.this.id}/${var.env}"
  retention_in_days = var.log_retention_days
}

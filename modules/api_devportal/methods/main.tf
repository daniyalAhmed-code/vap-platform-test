##### Option method Started #####
resource "aws_api_gateway_method" "options_root_method" {
    rest_api_id = "${var.API_GATEWAY_ID}"
    resource_id   = "${var.RESOURCE_ID}"
    http_method   = "OPTIONS"
    authorization = "NONE"
    count            = "${var.HTTP_METHOD == "OPTIONS" ? 1 : 0}"
}
resource "aws_api_gateway_integration" "options_root_integration" {
    rest_api_id = "${var.API_GATEWAY_ID}"
    resource_id   = "${var.RESOURCE_ID}"
    http_method   = "OPTIONS"
    type          = "MOCK"
    passthrough_behavior    = "WHEN_NO_MATCH"
    count            = "${var.HTTP_METHOD == "OPTIONS" ? 1 : 0}"
    request_templates = {
        "application/json" = "{ \"statusCode\": 200 }"
    }
    depends_on = [
        "aws_api_gateway_method.options_root_method",
    ]
}
resource "aws_api_gateway_method_response" "options_root_method_response_200" {
    rest_api_id = "${var.API_GATEWAY_ID}"
    resource_id   = "${var.RESOURCE_ID}" 
    http_method = "OPTIONS"
    status_code = "200"
    count            = "${var.HTTP_METHOD == "OPTIONS" ? 1 : 0}"
    response_parameters = "${var.METHOD_RESPONSE_PARAMETERS}"
    response_models = {
        "application/json" = "Empty"
    }
    depends_on = [
        "aws_api_gateway_method.options_root_method",
    ]
}
resource "aws_api_gateway_integration_response" "options_root_integration_response" {
    rest_api_id = "${var.API_GATEWAY_ID}"
    resource_id   = "${var.RESOURCE_ID}"
    http_method = "OPTIONS"
    status_code = "200"
    response_parameters = "${var.INTEGRATION_RESPONSE_PARAMETERS}"
    count            = "${var.HTTP_METHOD == "OPTIONS" ? 1 : 0}"
    depends_on = [
        "aws_api_gateway_integration.options_root_integration",
        "aws_api_gateway_method_response.options_root_method_response_200",
    ]
}

##### Option method Ended #####

#### Method Creation Started  ####
resource "aws_api_gateway_method" "lambda_method" {
  rest_api_id = "${var.API_GATEWAY_ID}"
  resource_id   = "${var.RESOURCE_ID}"
  http_method   = "${var.HTTP_METHOD}"
  authorization = "${var.AUTHORIZATION}"
  authorizer_id = "${var.AUTHORIZER_ID}"
  count            = "${var.HTTP_METHOD != "OPTIONS" ? 1 : 0}"
  
}
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = "${var.API_GATEWAY_ID}"
  resource_id   = "${var.RESOURCE_ID}"
  http_method             = "${var.HTTP_METHOD}"
  type                    = "AWS_PROXY"
  uri = var.LAMBDA_URI
  passthrough_behavior    = "WHEN_NO_MATCH"
  integration_http_method = "POST"
  count            = "${var.HTTP_METHOD != "OPTIONS" ? 1 : 0}"
  
  request_templates = "${var.REQUEST_TEMPLATES}"
    depends_on = [
        "aws_api_gateway_method.lambda_method",
    ]
}
resource "aws_api_gateway_method_response" "lambda_method_response_200" {
  rest_api_id = "${var.API_GATEWAY_ID}"
  resource_id   = "${var.RESOURCE_ID}"
  http_method = "${var.HTTP_METHOD}"
  status_code = "200"
  count            = "${var.HTTP_METHOD != "OPTIONS" && var.HTTP_METHOD != "ANY" ? 1 : 0}" 
  response_parameters = "${var.METHOD_RESPONSE_PARAMETERS}"
    depends_on = [
        "aws_api_gateway_method.lambda_method",
    ]
}

resource "aws_api_gateway_integration_response" "lambda_integration_response" {
  rest_api_id = "${var.API_GATEWAY_ID}"
  resource_id   = "${var.RESOURCE_ID}"
  http_method = "${var.HTTP_METHOD}"
  status_code = "200"
  count            = "${var.HTTP_METHOD != "OPTIONS" && var.HTTP_METHOD != "ANY" ? 1 : 0}"
  response_parameters = "${var.INTEGRATION_RESPONSE_PARAMETERS}"
  response_templates = {
    "application/json" = ""
  }
  depends_on = ["aws_api_gateway_integration.lambda_integration", "aws_api_gateway_method_response.lambda_method_response_200"]
}

#### Method Creation Ended  ####


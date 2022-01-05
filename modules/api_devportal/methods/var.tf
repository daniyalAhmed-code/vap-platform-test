variable "HTTP_METHOD" {}
variable "AUTHORIZATION" {}

variable "METHOD_RESPONSE_PARAMETERS" {}
variable "INTEGRATION_RESPONSE_PARAMETERS" {}  
variable "RESOURCE_ID" {}
variable "API_GATEWAY_ID" {} 
variable "METHOD_VALUE" {}
variable "LAMBDA_INVOKE_ARN" {
    default = ""
}
variable "REQUEST_TEMPLATES" {
     type = map(string)
    default = {}
}
variable "SOURCE_ARN" {
    default = ""
}
variable "FUNCTION_NAME" {
    default = ""
}
variable "AUTHORIZER_ID" {
    default = ""
}
variable "REQUEST_PARAMETERS" {default = false}
variable "CURRENT_ACCOUNT_ID"{}
variable "AWS_REGION" {}

variable "LAMBDA_URI" {default = null}
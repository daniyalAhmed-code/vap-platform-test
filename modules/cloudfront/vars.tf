variable "AWS_REGION" {}
variable "CUSTOM_DOMAIN_NAME" {}
variable "DEVELOPMENT_MODE" {}
variable "DEV_PORTAL_SITE_S3_BUCKET" {}
variable "ORIGIN_ID" {}
variable "CLOUDFRONT_SECURITY_HEADER_SETUP" {}
variable "ARTIFACTS_S3_BUCKET_NAME" {}
variable "ACM_CERTIFICATE_ARN" {}
variable "BUCKET_REGIONAL_DOMAIN_NAME" {}
variable "RESOURCE_PREFIX" {}
variable "LOGGING_BUCKET" {}

### WAF ###
variable "waf_acl_id" {
  description = "WAF ID to add to Cloudfront"
  type        = string
  default     = ""
}
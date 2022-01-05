resource "aws_route53_record" "dev-ns" {
  count   = var.CUSTOM_DOMAIN_NAME != "" ? 1 : 0
  zone_id = var.HOSTED_ZONE_ID
  name    = var.CUSTOM_DOMAIN_NAME
  type    = "A"
  alias {
    name                   = var.DNS_NAME
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = true
  }

}
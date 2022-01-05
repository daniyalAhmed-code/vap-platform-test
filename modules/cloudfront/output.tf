
output "id" {
  value = aws_cloudfront_origin_access_identity.cloudfront_origin_access_identity.id
}

output "CLOUDFRONT_DOMAIN" {
  value = length(aws_cloudfront_distribution.s3_distribution) > 0 ? aws_cloudfront_distribution.s3_distribution[0].domain_name : aws_cloudfront_distribution.default_domain_cloudfront_distribution[0].domain_name
}

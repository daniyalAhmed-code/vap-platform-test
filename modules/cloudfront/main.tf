resource "aws_cloudfront_origin_access_identity" "cloudfront_origin_access_identity" {
  comment = var.RESOURCE_PREFIX
}



resource "aws_cloudfront_distribution" "s3_distribution" {
  count               = var.CUSTOM_DOMAIN_NAME != "" ? 1 : 0
  default_root_object = "index.html"
  enabled             = true
  http_version        = "http1.1"
  web_acl_id          = var.waf_acl_id

  aliases = [var.CUSTOM_DOMAIN_NAME]
  origin {
    domain_name = var.AWS_REGION == "us-east-1" ? "${var.DEV_PORTAL_SITE_S3_BUCKET}.s3.amazonaws.com" : "${var.DEV_PORTAL_SITE_S3_BUCKET}.s3.amazonaws.com"
    origin_id   = var.BUCKET_REGIONAL_DOMAIN_NAME

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cloudfront_origin_access_identity.cloudfront_access_identity_path
    }
  }
  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = "403"
    response_code         = "403"
    response_page_path    = "/index.html"
  }
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = var.BUCKET_REGIONAL_DOMAIN_NAME
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }

    }
    lambda_function_association {
      event_type   = "origin-response"
      lambda_arn   = var.CLOUDFRONT_SECURITY_HEADER_SETUP
      include_body = false
    }
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"

    }
  }

  logging_config {
    include_cookies = false
    bucket          = "${var.LOGGING_BUCKET}.s3.amazonaws.com"
    prefix          = "cloudfront-logs"
  }
  
  viewer_certificate {
    acm_certificate_arn = var.ACM_CERTIFICATE_ARN
    ssl_support_method  = "sni-only"
    minimum_protocol_version =  "TLSv1.2_2021"
  }
}


resource "aws_cloudfront_distribution" "default_domain_cloudfront_distribution" {
  count               = var.CUSTOM_DOMAIN_NAME == "" ? 1 : 0
  enabled             = true
  default_root_object = "index.html"
  http_version        = "http1.1"
  //  web_acl_id          = var.waf_acl_id

  origin {
    domain_name = var.AWS_REGION == "us-east-1" ? "${var.DEV_PORTAL_SITE_S3_BUCKET}.s3.amazonaws.com" : "${var.DEV_PORTAL_SITE_S3_BUCKET}.s3-${var.AWS_REGION}.amazonaws.com"
    origin_id   = var.BUCKET_REGIONAL_DOMAIN_NAME

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cloudfront_origin_access_identity.cloudfront_access_identity_path
    }
  }
  custom_error_response {
    error_caching_min_ttl = 300
    error_code            = "403"
    response_code         = "403"
    response_page_path    = "/index.html"
  }
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = var.BUCKET_REGIONAL_DOMAIN_NAME
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }

    }
    lambda_function_association {
      event_type   = "origin-response"
      lambda_arn   = var.CLOUDFRONT_SECURITY_HEADER_SETUP
      include_body = false
    }
  }
  
  restrictions {
    geo_restriction {
      restriction_type = "none"

    }
  }

  logging_config {
    include_cookies = false
    bucket          = "${var.LOGGING_BUCKET}.s3.amazonaws.com"
    prefix          = "cloudfront-logs"
  }
  
  viewer_certificate {
    cloudfront_default_certificate = true
    ssl_support_method             = "sni-only"
    minimum_protocol_version =  "TLSv1.2_2021"
  }
}

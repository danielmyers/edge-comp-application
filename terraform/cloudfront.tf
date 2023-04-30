
locals {
  movies_origin_id = "movies_lb_origin"
}

resource "aws_cloudfront_distribution" "movies_cloudfront" {
  origin {
    domain_name = aws_route53_record.movies-source-api.fqdn
    origin_id   = local.movies_origin_id
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled = true
  comment = "Movies Cloudfront"

  aliases = ["<Custom Edge Domain>"]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "POST", "PUT", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.movies_origin_id

    forwarded_values {
      query_string = true
      headers = [
        "Origin",
        "Host",
        "Referer",
        "Authorization"
      ]

      cookies {
        forward           = "whitelist"
        whitelisted_names = ["csrftoken", "_app_session"]
      }
    }

    min_ttl                = 0
    default_ttl            = 120
    max_ttl                = 240
    compress               = true
    viewer_protocol_policy = "allow-all"
  }

  ordered_cache_behavior {
    path_pattern     = "/api/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS", "POST", "PUT", "PATCH", "DELETE"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.movies_origin_id

    forwarded_values {
      query_string = true
      headers = [
        "Origin",
        "Host",
        "Referer",
        "Authorization"
      ]

      cookies {
        forward           = "whitelist"
        whitelisted_names = ["csrftoken", "_app_session"]
      }
    }

    min_ttl                = 0
    default_ttl            = 300
    max_ttl                = 600
    compress               = true
    viewer_protocol_policy = "allow-all"
  }

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA"]
    }
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.nkuproject_acm_cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}
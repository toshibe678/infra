# Root Objectのhtmlを省略することが出来るようにファンクション
resource "aws_cloudfront_function" "cloudfront_s3_acm_function" {
  name    = "cloudfront_s3_acm_function"
  runtime = "cloudfront-js-1.0"
  comment = "cloudfront_s3_acm base object function"
  publish = true
  code    = file("${path.module}/function.js")
}

# キャッシュポリシーの作成
resource "aws_cloudfront_cache_policy" "this" {
  name    = local.uppercase_domain_name
  comment = local.uppercase_domain_name

  default_ttl = 86400
  max_ttl     = 31536000
  min_ttl     = 1
  parameters_in_cache_key_and_forwarded_to_origin {
    cookies_config {
      cookie_behavior = "none"
    }
    headers_config {
      header_behavior = "none"
    }
    query_strings_config {
      query_string_behavior = "none"
    }
    enable_accept_encoding_brotli = true
    enable_accept_encoding_gzip   = true
  }
}

# オリジンリクエストポリシーの作成
resource "aws_cloudfront_origin_request_policy" "this" {
  name    = local.uppercase_domain_name
  comment = local.uppercase_domain_name
  cookies_config {
    cookie_behavior = "none"
  }
  headers_config {
    header_behavior = "none"
  }
  query_strings_config {
    query_string_behavior = "none"
  }
}

resource "aws_cloudfront_distribution" "cfd" {
  aliases             = ["${var.site_domain}"]
  #  aliases             = []
  comment             = "${var.site_domain}"
  tags                = {}
  enabled             = true
  is_ipv6_enabled     = true
  price_class         = "PriceClass_200"
  default_root_object = "index.html"

  origin {
    domain_name = aws_s3_bucket.origin_bucket.bucket_regional_domain_name
    origin_id   = "${var.site_domain}"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.logging_bucket.bucket_domain_name
  }

  default_cache_behavior {
    allowed_methods          = ["GET", "HEAD"]
    cached_methods           = ["GET", "HEAD"]
    target_origin_id         = "${var.site_domain}"
    # httpでアクセスされた場合、httpsにリダイレクト
    viewer_protocol_policy   = "redirect-to-https"
    compress                 = true
    cache_policy_id          = aws_cloudfront_cache_policy.this.id
    origin_request_policy_id = aws_cloudfront_origin_request_policy.this.id

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.cloudfront_s3_acm_function.arn
    }
  }

  custom_error_response {
    error_caching_min_ttl = "300"
    error_code            = "403"
    response_code         = "200"
    # Nuxt や Next.js で SSG を用いていて 404.html など専用ページがあれば置き換えてください。
    response_page_path    = "/index.html"
  }

  custom_error_response {
    error_caching_min_ttl = "300"
    error_code            = "404"
    response_code         = "200"
    # Nuxt や Next.js で SSG を用いていて 404.html など専用ページがあれば置き換えてください。
    response_page_path    = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  #  #とりあえずCloudFrontドメインの証明書を利用する場合はこちら
  #  viewer_certificate {
  #    cloudfront_default_certificate = true
  #  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.main_cert.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}

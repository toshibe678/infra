resource "aws_s3_bucket" "origin_bucket" {
  bucket        = "origin-bucket-${var.site_domain}"
  acl           = "private"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "origin_bucket" {
  bucket                  = aws_s3_bucket.origin_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "logging_bucket" {
  bucket        = "cloudfront-logs.${var.site_domain}"
  acl           = "log-delivery-write"
  force_destroy = true

  lifecycle_rule {
    id      = "s3-cloudfront-logs-transitions"
    tags    = {}
    enabled = true

    transition {
      days          = "90"
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = "180"
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}

resource "aws_s3_bucket_public_access_block" "logging_bucket" {
  bucket                  = aws_s3_bucket.logging_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

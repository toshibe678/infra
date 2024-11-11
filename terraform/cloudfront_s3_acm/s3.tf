resource "aws_s3_bucket" "origin_bucket" {
  bucket        = "origin-bucket-${var.site_domain}"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "origin_bucket_acl" {
  bucket = aws_s3_bucket.origin_bucket.id
  acl    = "private"
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
  force_destroy = true
}

resource "aws_s3_bucket_acl" "logging_bucket_acl" {
  bucket = aws_s3_bucket.logging_bucket.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_public_access_block" "logging_bucket" {
  bucket                  = aws_s3_bucket.logging_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "logging_bucket_lifecycle" {
  bucket = aws_s3_bucket.logging_bucket.id

  rule {
    id     = "s3-cloudfront-logs-transitions"
    status = "Enabled"

    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 180
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}

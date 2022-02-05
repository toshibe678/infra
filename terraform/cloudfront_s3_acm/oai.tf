resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "access-identity-ap-northeast-1-cloudfront-resource"
}

data "aws_iam_policy_document" "origin_access_identity_policy" {
  statement {
    sid       = "OriginAccessIdentity"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.origin_bucket.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "origin_bucket_policy" {
  bucket = aws_s3_bucket.origin_bucket.id
  policy = data.aws_iam_policy_document.origin_access_identity_policy.json
}

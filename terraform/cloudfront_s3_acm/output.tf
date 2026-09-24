output "cloudfront_domain_name" {
  description = "CloudFrontディストリビューションのドメイン名"
  value       = aws_cloudfront_distribution.cfd.domain_name
}

output "cloudfront_distribution_id" {
  description = "CloudFrontディストリビューションのID"
  value       = aws_cloudfront_distribution.cfd.id
}

output "origin_bucket_name" {
  description = "配信元S3バケット名"
  value       = aws_s3_bucket.origin_bucket.bucket
}

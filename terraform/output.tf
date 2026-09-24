output "blog_cloudfront_domain_name" {
  description = "ブログ用CloudFrontのドメイン名"
  value       = module.cloudfront_s3_acm.cloudfront_domain_name
}

output "stg_blog_cloudfront_domain_name" {
  description = "ステージング用ブログCloudFrontのドメイン名"
  value       = module.stg_cloudfront_s3_acm.cloudfront_domain_name
}

# 静的サイトのブログ置き場
module "cloudfront_s3_acm" {
  source = "./cloudfront_s3_acm"
  site_domain = "toshi.click"
  account_id = "073855610728"
}


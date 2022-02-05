# 静的サイトのブログ置き場
module "cloudfront_s3_acm" {
  source = "./cloudfront_s3_acm"
  site_domain = "toshi.click"
  account_id = "073855610728"
}

#module "common" {
#  source = "modules/common"
#}

#module "organization" {
#  source = "/modules/organization"
#}

#module "network" {
#  source = "modules/network"
#}

#module "iam" {
#  source = "modules/iam"
#}



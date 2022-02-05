provider "aws" {
  region = "ap-northeast-1"
  assume_role {
    role_arn = "arn:aws:iam::${var.account_id}:role/admin_role"
  }
}
provider "aws" {
    region = "us-east-1"
    alias  = "us-east-1"
    assume_role {
      role_arn = "arn:aws:iam::${var.account_id}:role/admin_role"
    }
}
locals {
  uppercase_domain_name = join("" , [for v in split(".", var.site_domain): title(v)])
}

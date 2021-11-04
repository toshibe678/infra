terraform {
  backend "s3" {
    bucket         = "toshi-terraform-state"
    region         = "ap-northeast-1"
    key            = "terraform.tfstate"
    encrypt        = true
    dynamodb_table = "toshi-terraform-dynamodb"
    # profile = "root-admin"
  }
}

# S3にあるtfstateを使う設定
data "terraform_remote_state" "main" {
  backend = "s3"

  config = {
    bucket = "toshi-terraform-state"
    key    = "terraform.tfstate"
    region = "ap-northeast-1"
  }
}

# S3にあるtfstateを使う設定
data "terraform_remote_state" "common" {
  backend = "s3"

  config = {
    bucket = "toshi-terraform-state"
    key    = "terraform.tfstate"
    region = "ap-northeast-1"
  }
}

# S3バックエンドの設定
terraform {
  backend "s3" {
    bucket = "abe365.org"
    key    = "cloudflere.tfstate"
    region = "ap-northeast-1"
    encrypt        = true
  }
}

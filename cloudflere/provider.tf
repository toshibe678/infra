terraform {
  required_version = ">= 1.8.0"
  required_providers {
    # https://registry.terraform.io/providers/hashicorp/aws/latest
    aws = ">= 5.94.0"
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}
# 認証は環境変数 (CLOUDFLARE_API_TOKEN 等) で渡す。
# API レートリミット(429)対策: plan の refresh で多数の record を読むため、
# 既定(rps=4 / retries=3 / max_backoff=30)では 429 と throttling 由来の
# Authentication error(10000) が頻発する。リクエスト速度を抑えつつ、
# スロットリング時は長めにバックオフ・リトライする。
provider "cloudflare" {
  rps         = 2
  retries     = 5
  min_backoff = 2
  max_backoff = 60
}

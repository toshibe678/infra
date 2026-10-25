terraform {
  required_version = ">= 1.8.0"
  required_providers {
    # https://registry.terraform.io/providers/hashicorp/aws/latest
    aws = ">= 5.94.0"
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}
# 認証は環境変数 (CLOUDFLARE_API_TOKEN 等) で渡す。
# provider v5 では rps/retries/min_backoff/max_backoff は廃止された（SDK が 429 を自動リトライ）。
# API レートリミット(429)をさらに抑えたい場合は CI で `terraform plan -parallelism=2` 等にする。
provider "cloudflare" {}

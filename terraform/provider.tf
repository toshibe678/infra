terraform {
  required_version = ">= 1.8.0"
  required_providers {
    # https://registry.terraform.io/providers/hashicorp/aws/latest
    aws = ">= 5.94.0"
  }
}
provider "cloudflare" {}

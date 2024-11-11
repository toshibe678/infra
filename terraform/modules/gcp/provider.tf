terraform {
  required_providers {
    # https://registry.terraform.io/providers/hashicorp/aws/latest
    aws = ">= 5.75.0"
    google = {
      source  = "hashicorp/google"
      version = ">= 6.10.0"
    }
  }
}
provider "google" {
  project = var.project
  region  = "asia-northeast1"
}

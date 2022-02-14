terraform {
  cloud {
    hostname = "app.terraform.io"
    organization = "toshibe-infra-root"
    workspaces {
      tags = ["main"]
    }
  }
}


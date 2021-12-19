terraform {
  cloud {
    hostname = "app.terraform.io"
    organization = "toshibe-infra"
    workspaces {
      tags = ["main"]
    }
  }
}


terraform {
  cloud {
    hostname = "app.terraform.io"
    organization = "toshibe-infra"
    workspaces {
      tags = ["main"]
    }
  }
}

data "terraform_remote_state" "main" {
  backend = "remote"
  config = {
    organization = "toshibe-infra"
    workspaces = {
      name = "main"
    }
  }
}

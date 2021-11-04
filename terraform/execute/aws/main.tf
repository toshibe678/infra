provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

module "common" {
  source = "../../modules/common"
}

module "organization" {
  source = "../../modules/organization"
}

module "network" {
  source = "../../modules/network"
}

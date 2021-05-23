provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region = "${var.region}"
}

module "common" {
  source = "../../modules/common"
}

# インターネット上のモジュール使用する場合
module "consul" {
  source  = "hashicorp/consul/aws"
  servers = 3
}

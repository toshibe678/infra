terraform {
  required_version = ">= 0.15.0"
    backend "s3" {
        bucket = "toshi-terraform-state"
        region = "ap-northeast-1"
        key = "terraform.tfstate"
        encrypt = true
        dynamodb_table = "toshi-terraform-dynamodb"
  }
}
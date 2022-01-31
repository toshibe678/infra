provider "aws" {
  region  = "ap-northeast-1"
  assume_role {
    role_arn = "arn:aws:iam::073855610728:role/admin_role"
  }
}

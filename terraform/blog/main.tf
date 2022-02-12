provider "aws" {
  region = "ap-northeast-1"
  assume_role {
    role_arn = "arn:aws:iam::${var.account_id}:role/admin_role"
  }
}
provider "aws" {
  region = "us-east-1"
  alias  = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::${var.account_id}:role/admin_role"
  }
}

resource "aws_iam_user" "blog-deploy-user" {
  name = "blog-deploy-user"
}

## Policy
resource "aws_iam_policy" "blog-deploy-policy" {
  name        = "blog-deploy-policy"
  description = "blog-deploy-policy"
  policy      = "${file("${path.module}/blog-deploy-policy.json")}"
}

resource "aws_iam_user_policy_attachment" "blog-deploy-attach" {
  user       = "${aws_iam_user.blog-deploy-user.name}"
  policy_arn = "${aws_iam_policy.blog-deploy-policy.arn}"
}

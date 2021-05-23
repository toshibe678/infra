# 機密情報暗号化用のKMSkey作成
resource "aws_kms_key" "base_kms_key" {
  description             = "The basic Master Key"
  enable_key_rotation     = true
  is_enabled              = true
  deletion_window_in_days = 30
}

resource "aws_kms_alias" "base_kms_key_alias" {
  name          = "alias/base_kms_key"
  target_key_id = aws_kms_key.base_kms_key.key_id
}

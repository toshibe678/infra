# Gootleで管理できるようにするためのTXTレコード
resource "cloudflare_record" "google_site_verification" {
  name    = "@"                 # サブドメイン名
  ttl     = 1                   # TTL
  type    = "TXT"               # レコードタイプ
  value   = "google-site-verification=wZG7KblLx-c8CWkc-HAhfb3uZNyafFM9BjENdMq7Oyk"
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}

# gmailで利用可能にするためのMXレコード
resource "cloudflare_record" "gmail" {
  name    = "@"                 # サブドメイン名
  ttl     = 1                   # TTL
  type    = "MX"                # レコードタイプ
  value   = "SMTP.GOOGLE.COM."  # MXレコードの値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
  priority = "1"
}

# Azure Entra IDのドメイン検証用のTXTレコード
resource "cloudflare_record" "azure_id" {
  name    = "@"                         # サブドメイン名
  ttl     = 1                           # TTL
  type    = "TXT"                       # レコードタイプ
  value   = "MS=ms58497783"             # Azure Entra IDのドメイン検証用の値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}

# resource "cloudflare_record" "dev" {
#   name    = "dev"                           # サブドメイン名
#   proxied = true                            # Cloudflare のプロキシを利用するか
#   ttl     = 1                               # TTL
#   type    = "CNAME"                         # レコードタイプ
#   value   = "xxxxx.cloudfront.net"          # CloudFront を想定した値
#   zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
# }

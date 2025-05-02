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

resource "cloudflare_record" "infra" {
  name    = "infra"                           # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.0.101"          # CloudFront を想定した値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}
resource "cloudflare_record" "dxp4800" {
  name    = "dxp4800"                           # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.0.245"          # CloudFront を想定した値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}
resource "cloudflare_record" "dxp4800-sub" {
  name    = "dxp4800-sub"                           # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.0.246"          # CloudFront を想定した値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}
resource "cloudflare_record" "dxp2800" {
  name    = "dxp2800"                           # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.0.247"          # CloudFront を想定した値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}
resource "cloudflare_record" "qnapnas1" {
  name    = "qnapnas1"                           # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.0.241"          # CloudFront を想定した値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}
resource "cloudflare_record" "qnapnas2" {
  name    = "qnapnas2"                           # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.0.242"          # CloudFront を想定した値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}

resource "cloudflare_record" "rasdev" {
  name    = "rasdev"                           # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.0.111"          # CloudFront を想定した値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}
resource "cloudflare_record" "raspi" {
  name    = "raspi"                           # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.0.112"          # CloudFront を想定した値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}

resource "cloudflare_record" "sae" {
  name    = "sae"                           # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.0.113"          # CloudFront を想定した値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}
resource "cloudflare_record" "kaede" {
  name    = "kaede"                           # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.0.114"          # CloudFront を想定した値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}

resource "cloudflare_record" "shiki" {
  name    = "shiki"                           # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.0.115"          # CloudFront を想定した値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}
resource "cloudflare_record" "kako" {
  name    = "kako"                           # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.0.116"          # CloudFront を想定した値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}

resource "cloudflare_record" "ranko" {
  name    = "ranko"                           # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.77.77"          # CloudFront を想定した値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}
resource "cloudflare_record" "shigure" {
  name    = "shigure"                           # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.77.100"          # CloudFront を想定した値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}

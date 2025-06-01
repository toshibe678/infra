### ----------------------------------------------------------------------------------------------------
# サーバー
### ----------------------------------------------------------------------------------------------------
resource "cloudflare_record" "shigure" {
  name    = "shigure"                           # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.0.100"          # CloudFront を想定した値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}
resource "cloudflare_record" "vpn_shigure" {
  name    = "vpn.shigure"                           # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.101.71"          # CloudFront を想定した値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}
resource "cloudflare_record" "mayu" {
  name    = "mayu"                           # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.77.200"          # CloudFront を想定した値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}
resource "cloudflare_record" "vpn_mayu" {
  name    = "vpn.mayu"                           # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.101.72"          # CloudFront を想定した値
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
resource "cloudflare_record" "vpn_ranko" {
  name    = "vpn.ranko"                           # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.101.73"          # CloudFront を想定した値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}
resource "cloudflare_record" "infra1" {
  name    = "infra1"                           # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.0.101"          # CloudFront を想定した値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}
resource "cloudflare_record" "infra2" {
  name    = "infra2"                           # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.0.102"          # CloudFront を想定した値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}
resource "cloudflare_record" "monitoring" {
  name    = "monitoring"                           # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.100.253"          # CloudFront を想定した値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}
### ----------------------------------------------------------------------------------------------------
# NAS
### ----------------------------------------------------------------------------------------------------
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
resource "cloudflare_record" "vpn_qnapnas" {
  name    = "vpn.qnapnas"                           # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.101.91"          # CloudFront を想定した値
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
resource "cloudflare_record" "qnapnas-infra" {
  name    = "qnapnas-infra"                           # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.0.243"          # CloudFront を想定した値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}
### ----------------------------------------------------------------------------------------------------
# raspi
### ----------------------------------------------------------------------------------------------------
resource "cloudflare_record" "rasdev" {
  name    = "rasdev"                           # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.0.111"          # CloudFront を想定した値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}
resource "cloudflare_record" "vpn_rasdev" {
  name    = "vpn.rasdev"                           # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.101.52"          # CloudFront を想定した値
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
resource "cloudflare_record" "vpn_raspi" {
  name    = "vpn.raspi"                           # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.101.51"          # CloudFront を想定した値
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
resource "cloudflare_record" "vpn_sae" {
  name    = "vpn.sae"                           # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.101.53"          # CloudFront を想定した値
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
resource "cloudflare_record" "vpn_kaede" {
  name    = "vpn.kaede"                           # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.101.54"          # CloudFront を想定した値
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
resource "cloudflare_record" "vpn_shiki" {
  name    = "vpn.shiki"                           # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.101.55"          # CloudFront を想定した値
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
resource "cloudflare_record" "vpn_kako" {
  name    = "vpn.kako"                           # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.101.56"          # CloudFront を想定した値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}
### ----------------------------------------------------------------------------------------------------
# その他VPNオンリー
### ----------------------------------------------------------------------------------------------------
resource "cloudflare_record" "vpn_ayaka" {
  name    = "vpn.ayaka"                           # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.101.57"          # CloudFront を想定した値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}

### ----------------------------------------------------------------------------------------------------
# グローバルで必要なドメイン設定
### ----------------------------------------------------------------------------------------------------
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
  value   = "smtp.google.com"  # MXレコードの値
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

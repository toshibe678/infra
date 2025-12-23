### ----------------------------------------------------------------------------------------------------
# RDP接続先WinPC
### ----------------------------------------------------------------------------------------------------
resource "cloudflare_record" "toshipc01" {
  name    = "toshipc01"                           # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.77.10"          # CloudFront を想定した値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}
resource "cloudflare_record" "vpn_toshipc01" {
  name    = "vpn.toshipc01"                           # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.101.10"          # CloudFront を想定した値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}
resource "cloudflare_record" "toshi-notepc" {
  name    = "toshi-notepc"                           # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.100.21"          # CloudFront を想定した値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}
resource "cloudflare_record" "toshipc02" {
  name    = "toshipc02"                           # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.77.22"          # CloudFront を想定した値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}
resource "cloudflare_record" "vpn_toshipc02" {
  name    = "vpn.toshipc02"                           # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.101.11"          # CloudFront を想定した値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}
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
resource "cloudflare_record" "toshi-gamepc" {
  name    = "toshi-gamepc"                           # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.77.77"          # CloudFront を想定した値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}
resource "cloudflare_record" "vpn_toshi-gamepc" {
  name    = "vpn.toshi-gamepc"                           # サブドメイン名
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
resource "cloudflare_record" "k8s1" {
  name    = "k8s1"                           # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.100.11"       # CloudFront を想定した値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}
resource "cloudflare_record" "k8s2" {
  name    = "k8s2"                         # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.100.12"      # CloudFront を想定した値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}
resource "cloudflare_record" "k8s3" {
  name    = "k8s3"                         # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.100.13"      # CloudFront を想定した値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}
resource "cloudflare_record" "monitoring" {
  name    = "monitoring"                           # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.100.51"       # CloudFront を想定した値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}
resource "cloudflare_record" "dify" {
  name    = "dify"                         # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.100.52"      # CloudFront を想定した値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}
resource "cloudflare_record" "vpn-dev" {
  name    = "vpn-dev"                         # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.100.53"      # CloudFront を想定した値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}
resource "cloudflare_record" "llm-proxy" {
  name    = "llm-proxy"                         # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.100.54"      # CloudFront を想定した値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}
resource "cloudflare_record" "develop" {
  name    = "develop"                         # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.100.55"      # CloudFront を想定した値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}
resource "cloudflare_record" "ai-test" {
  name    = "ai-test"                         # サブドメイン名
  proxied = false                            # Cloudflare のプロキシを利用するか
  ttl     = 1                               # TTL
  type    = "A"                             # レコードタイプ
  value   = "192.168.100.56"      # CloudFront を想定した値
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
# spf
resource "cloudflare_record" "spf" {
  name    = "@"                 # サブドメイン名
  ttl     = 3600                   # TTL
  type    = "TXT"                # レコードタイプ
  value   = "v=spf1 include:_spf.google.com include:spf.protection.outlook.com include:amazonses.com ~all"
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
  priority = "1"
}
# dkim
resource "cloudflare_record" "google_domainkey" {
  name    = "google._domainkey" # サブドメイン名
  ttl     = 3600                 # TTL
  type    = "TXT"                # レコードタイプ
  value   = "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAkeMp8Uehg3dxoo7mT3VwIsU3plwgRTbYp3upFfHS6hrb2y4PsMnz8/rZVfpUexA2Sh+4lVAPyWSA/JYe9QLzPzoX/idyZ/9Uq8uASvH2yIyS6p+fsmP4fLwBouln0ip471oLKmzxv3Vys+vMmqL2qMUxP+WOpsN7c3h92WM8Z07ub8hiXKn1+3DH2wJEg4Vh69LCmXOCwzeb2hR3rhRJx/RIwEfXLJWFeUhK8smArk00hNMVlc6Qm/ZvQduNEWAIRRyFraFJ3exyZ/9QKJfgtmUegnmXO9SaTYO1uQHOTNcybgAa5Auu8YeDH3JmlSaMltr/x0rHzVTFbCC6vks4IwIDAQAB"
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
  priority = "1"
}
# dmarc
resource "cloudflare_record" "_dmarc" {
  name    = "_dmarc" # サブドメイン名
  ttl     = 3600                 # TTL
  type    = "TXT"                # レコードタイプ
  value   = "v=DMARC1; p=reject; rua=mailto:info@toshi.click; ruf=mailto:info@toshi.click; pct=100; adkim=s; aspf=s"
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
  priority = "1"
}
# MS365のドメイン検証用のTXTレコード
resource "cloudflare_record" "ms365" {
  name    = "@"                         # サブドメイン名
  ttl     = 3600                        # TTL
  type    = "TXT"                       # レコードタイプ
  value   = "MS=ms53238597"             # Azure Entra IDのドメイン検証用の値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}
# Azure Entra IDのドメイン検証用のTXTレコード
resource "cloudflare_record" "azure_id" {
  name    = "@"                         # サブドメイン名
  ttl     = 1                           # TTL
  type    = "TXT"                       # レコードタイプ
  value   = "MS=ms58497783"             # Azure Entra IDのドメイン検証用の値
  zone_id = "46b5be479776a4897b109614bd8c6a8a" # Cloudflare のゾーン ID
}

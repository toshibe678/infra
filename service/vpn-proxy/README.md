# VPN Proxy Service

VPN接続クライアントから拠点内のVPN非接続サーバーへアクセスするためのリバースプロキシサービス

## 概要

WireGuard VPNサーバーは拠点外のVPSで運用されており、VPNクライアント間の通信は可能ですが、拠点内のVPN非接続サーバー（開発環境、監視サーバー等）へは直接アクセスできません。

このvpn-proxyサービスを**VPN接続されたサーバー上**で稼働させることで、VPNクライアントから拠点内のVPN非接続サーバーへのアクセスを中継します。

## アーキテクチャ

```
[VPN Client] --VPN--> [VPN Server (VPS)] --VPN--> [vpn-proxy (VPN接続)] --LAN--> [非VPN接続サーバー群]
                                                          ↓
                                                    [Nginx Proxy]
                                                          ↓
                                        ┌─────────────────┼─────────────────┐
                                        ↓                 ↓                 ↓
                                [開発サーバー]      [監視サーバー]       [AIテストサーバー]
                              192.168.100.55    192.168.100.51    192.168.100.56
```

## 主要機能

- **リバースプロキシ**: Nginxによる複数バックエンドサーバーへのルーティング
- **監視統合**: Prometheus Node Exporterによるメトリクス収集
- **セキュリティ**: レート制限、アクセス制御、セキュリティヘッダー
- **WebSocket対応**: 双方向通信が必要なアプリケーションに対応
- **VPN内部通信**: NAT越しのためHTTPのみ（VPNトンネル内で暗号化済み）

## 技術スタック

| コンポーネント | 技術 | 用途 |
|------------|------|------|
| Reverse Proxy | Nginx Alpine | HTTPプロキシ、ロードバランシング |
| Monitoring | Node Exporter | システムメトリクス収集 |
| Container | Docker Compose | サービスオーケストレーション |

## 前提条件

1. **VPN接続**: このサービスを稼働させるサーバーはWireGuard VPNに接続されている必要があります
2. **ネットワークアクセス**: 拠点内LAN (192.168.100.0/24) へのアクセスが可能であること
3. **Docker環境**: Docker及びDocker Composeがインストール済み

## セットアップ

### 1. 環境変数設定

```bash
cd /home/toshi/git/infra/service/vpn-proxy
cp .env.example .env
```

`.env`ファイルを編集し、プロキシするバックエンドサーバーの情報を設定：

```bash
# Environment
ENVIRONMENT=dev  # 開発環境はdev、本番環境はprod

# バックエンドサーバー設定
DEV_SERVER_HOST=192.168.100.55
DEV_SERVER_PORT=8080

MONITORING_SERVER_HOST=192.168.100.51
MONITORING_SERVER_PORT=3000

AI_TEST_SERVER_HOST=192.168.100.56
AI_TEST_SERVER_PORT=8080
```

### 2. Nginxプロキシ設定

プロキシするバックエンドサーバーを定義：

```bash
cd nginx/conf.d
cp proxy-backends.conf.example proxy-backends.conf
```

`proxy-backends.conf`を編集し、必要なバックエンドサーバーの設定を追加：

```nginx
upstream develop_backend {
    server 192.168.100.55:8080;
}

server {
    listen 80;
    server_name develop-proxy.vpn.local;
    
    location / {
        proxy_pass http://develop_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 3. データディレクトリ作成

```bash
mkdir -p logs/nginx
```

### 4. サービス起動

```bash
docker compose up -d
```

## 使用方法

### VPNクライアントからのアクセス

VPNに接続したクライアントから、vpn-proxyのIPアドレスまたはホスト名を使用してアクセス：

```bash
# vpn-proxyが 10.0.0.5 で稼働している場合
curl http://10.0.0.5/health  # ヘルスチェック

# 開発サーバーへのプロキシアクセス（ホスト名ベースルーティング）
curl -H "Host: develop-proxy.vpn.local" http://10.0.0.5/
```

### DNS設定（推奨）

VPNクライアント側で `/etc/hosts` またはDNSサーバーに以下を追加：

```
10.0.0.5  develop-proxy.vpn.local
10.0.0.5  monitoring-proxy.vpn.local
10.0.0.5  ai-test-proxy.vpn.local
10.0.0.5  mcp-proxy.vpn.local
```

これにより、以下のようなアクセスが可能になります：

```bash
curl http://develop-proxy.vpn.local/
curl http://monitoring-proxy.vpn.local/
curl http://ai-test-proxy.vpn.local/
curl -H "Authorization: Bearer ${AUTH_TOKEN}" http://mcp-proxy.vpn.local/health
```

### MCP Servers経由アクセス

VPN経由でMCPサーバーを利用する場合：

```bash
# ヘルスチェック
curl http://mcp-proxy.vpn.local/health

# MCP エンドポイントへのアクセス（認証トークン必須）
curl -H "Authorization: Bearer ${AUTH_TOKEN}" http://mcp-proxy.vpn.local/git
curl -H "Authorization: Bearer ${AUTH_TOKEN}" http://mcp-proxy.vpn.local/github
curl -H "Authorization: Bearer ${AUTH_TOKEN}" http://mcp-proxy.vpn.local/filesystem
```

認証トークン（`AUTH_TOKEN`）は拠点内MCPサーバーの `.env` ファイルで確認可能です。


## 監視

### Prometheusメトリクス

Node Exporterメトリクスは `/metrics` エンドポイントで公開：

```bash
curl http://10.0.0.5/metrics
```

### Prometheus設定例

```yaml
scrape_configs:
  - job_name: 'vpn-proxy'
    static_configs:
      - targets: ['10.0.0.5:80']
    metrics_path: '/metrics'
```

### ログ確認

```bash
# Nginxアクセスログ
docker compose logs -f nginx

# Node Exporterログ
docker compose logs -f node-exporter

# ログファイル（ホスト側）
tail -f logs/nginx/access.log
tail -f logs/nginx/error.log
```

## セキュリティ

### アクセス制御

特定のVPNサブネットからのみアクセスを許可する場合、`nginx/conf.d/default.conf`に以下を追加：

```nginx
location /metrics {
    # VPNサブネットのみ許可
    allow 10.0.0.0/24;
    deny all;
    
    proxy_pass http://node-exporter:9100/metrics;
}
```

### レート制限

デフォルトで以下のレート制限が設定されています：

- 一般アクセス: 10リクエスト/秒
- 厳格な制限: 3リクエスト/秒
- 同時接続数: 10接続/IP

## トラブルシューティング

### バックエンドサーバーに接続できない

1. **ネットワーク疎通確認**
   ```bash
   docker compose exec nginx ping -c 3 192.168.100.55
   ```

2. **ルーティング確認**
   ```bash
   docker compose exec nginx ip route
   ```

3. **Nginxエラーログ確認**
   ```bash
   docker compose logs nginx | grep error
   ```

### VPNクライアントからアクセスできない

1. **VPN接続確認**
   ```bash
   # VPNクライアント側で実行
   ping 10.0.0.5
   ```

2. **Firewall確認**（vpn-proxyサーバー側）
   ```bash
   sudo iptables -L -n -v | grep 80
   ```

3. **Docker ネットワーク確認**
   ```bash
   docker network inspect vpn-proxy-network
   ```

### メトリクスが取得できない

```bash
# Node Exporter起動確認
docker compose ps node-exporter

# 直接アクセステスト
docker compose exec nginx wget -qO- http://node-exporter:9100/metrics
```

## メンテナンス

### サービス再起動

```bash
docker compose restart
```

### 設定リロード（Nginxのみ）

```bash
docker compose exec nginx nginx -s reload
```

### ログローテーション

定期的にログファイルをローテーション：

```bash
# ログローテーション設定例（/etc/logrotate.d/vpn-proxy）
/home/toshi/git/infra/service/vpn-proxy/logs/nginx/*.log {
    daily
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 root root
    sharedscripts
    postrotate
        docker compose -f /home/toshi/git/infra/service/vpn-proxy/docker-compose.yml exec nginx nginx -s reopen
    endscript
}
```

## ネットワーク設定の注意事項

### NAT越しの制約

このサービスはNAT越しでインターネットにアクセスするため、以下の制約があります：

1. **Let's Encrypt使用不可**: 外部からの80/443ポートへのアクセスができないため、Let's Encryptによる自動SSL証明書取得は不可能
2. **HTTP通信**: VPN内部通信のみのため、HTTPで運用（WireGuardトンネル自体が暗号化されているため、追加のSSL/TLSは不要）
3. **VPN内部のみアクセス可能**: インターネットから直接アクセスできない（VPN接続必須）

### セキュリティ考慮事項

- **VPN暗号化**: WireGuardによる通信の暗号化により、HTTPでも安全に通信可能
- **アクセス制限**: VPNネットワーク内部のみからアクセス可能
- **レート制限**: 不正アクセス防止のため、Nginxレベルでレート制限を実装

## 今後の拡張

- [ ] TCP/UDPストリームプロキシ対応（SSH、データベース等）
- [ ] 認証機能追加（Basic Auth等、VPN認証の追加層として）
- [ ] アクセスログの集約とGrafanaダッシュボード統合
- [ ] Fail2Banによる自動IP制限
- [ ] 負荷分散（複数バックエンドサーバーへのロードバランシング）
- [ ] 自己署名証明書によるHTTPS化（オプション）

## 関連ドキュメント

- [WireGuard Dashboard](../wgdashboard/README.md) - VPN管理ダッシュボード
- [Monitoring Service](../monitoring/README.md) - Prometheus/Grafana監視基盤
- [AGENTS.md](../../AGENTS.md) - プロジェクト全体の構成

## ライセンス

このプロジェクトに準拠

## サポート

問題が発生した場合は、Issue を作成してください。

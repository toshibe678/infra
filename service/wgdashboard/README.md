# WGDashboard - WireGuard Management Dashboard

WireGuard VPNの管理ダッシュボード（グローバルアクセス対応・Let's Encrypt SSL自動更新）

## 概要

WGDashboardは、WireGuardの設定を視覚的に管理できるWebベースのダッシュボードです。
ホスト側で動作しているWireGuardの設定を直接管理します。

**セキュリティ機能**：
- Let's Encrypt自動SSL証明書更新
- Basic認証による二段階認証
- レート制限（DDoS対策）
- セキュリティヘッダー（HSTS、CSP等）
- HTTPS強制リダイレクト

## DNS設定

- **ドメイン**: vpn-dev.abe365.org
- **IPアドレス**: CONOHA VPSのグローバルIP
- **DNS管理**: Cloudflare (cloudflere/records.tf)
- **アクセス**: グローバルからHTTPSでアクセス可能

## サービス構成

### コンポーネント

| サービス | 説明 |
|---------|------|
| wgdashboard | WireGuard管理ダッシュボード |
| nginx | リバースプロキシ（HTTPS終端、Basic認証） |
| certbot | Let's Encrypt SSL証明書自動更新 |

## 前提条件

### ホスト側のWireGuard設定

このサービスはホスト側で動作しているWireGuardを管理します。

```bash
# WireGuardがインストールされていることを確認
wg --version

# WireGuard設定の確認
ls -la /etc/wireguard/

# WireGuardサービスの状態確認
sudo systemctl status wg-quick@wg0
```

### ドメイン設定

```bash
# DNSがVPSのIPを指していることを確認
dig vpn-dev.abe365.org
# または
nslookup vpn-dev.abe365.org
```

## セットアップ手順

### 1. 環境変数の設定

```bash
cp .env.example .env
vim .env  # 必要な環境変数を設定
```

### 2. Let's Encrypt SSL証明書の取得

```bash
# 初期セットアップスクリプトに実行権限を付与
chmod +x init-letsencrypt.sh

# スクリプトを編集してメールアドレスを設定
vim init-letsencrypt.sh
# EMAIL="admin@abe365.org" を自分のメールアドレスに変更

# SSL証明書を取得（初回のみ）
./init-letsencrypt.sh
```

**重要**: 初回は必ずテストモード（STAGING=1）で動作確認してください。
Let's Encryptには週5回までの制限があります。

### 3. Basic認証の設定

```bash
# Basic認証ユーザー作成スクリプトに実行権限を付与
chmod +x create-htpasswd.sh

# Basic認証ユーザーを作成
./create-htpasswd.sh
# ユーザー名とパスワードを入力

# nginxを再起動
docker-compose restart nginx
```

### 4. サービスの起動

```bash
# 全サービスを起動
docker-compose up -d

# ログを確認
docker-compose logs -f
```

### 5. アクセス確認

```bash
# HTTPSでアクセス
https://vpn-dev.abe365.org

# 認証情報
# 1段階目: Basic認証（./create-htpasswd.shで設定したユーザー名/パスワード）
# 2段階目: WGDashboard認証（.envで設定したWG_DASHBOARD_USERNAME/PASSWORD）
```

## 環境変数

以下の環境変数を`.env`ファイルに設定してください：

| 変数名 | 説明 | 必須 | デフォルト |
|--------|------|------|-----------|
| WG_DASHBOARD_USERNAME | ダッシュボードユーザー名 | × | admin |
| WG_DASHBOARD_PASSWORD | ダッシュボードパスワード | ✓ | - |
| TZ | タイムゾーン | × | Asia/Tokyo |

## アクセス方法

サービス起動後、以下のURLでアクセス可能です：

- **Dashboard**: http://vpn-dev.abe365.org

## 機能

### 主な機能

- **設定管理**: WireGuardインターフェースの作成・編集・削除
- **ピア管理**: クライアント（ピア）の追加・削除・編集
- **QRコード生成**: モバイルデバイス用の設定QRコード生成
- **統計情報**: 接続状態、トラフィック統計の表示
- **ログ表示**: WireGuardログの閲覧

### 操作例

#### 新しいピアの追加

1. ダッシュボードにログイン
2. 「Peers」タブを開く
3. 「Add Peer」をクリック
4. ピア情報を入力（名前、IPアドレス等）
5. 「Save」をクリック
6. QRコードまたは設定ファイルをダウンロード

#### 接続状態の確認

1. ダッシュボードのトップページ
2. 各ピアの接続状態、最終接続時刻、データ転送量を確認

## データ永続化

以下のディレクトリにデータが保存されます：

- `./data/wgdashboard/`: ダッシュボード設定・データベース
- `./data/wgdashboard/log/`: ログファイル
- `/etc/wireguard/`: WireGuard設定（ホスト側）

## トラブルシューティング

### ダッシュボードにアクセスできない

```bash
# コンテナの状態確認
docker-compose ps

# ログの確認
docker-compose logs wgdashboard

# nginxログの確認
docker-compose logs nginx
```

### WireGuard設定が表示されない

```bash
# ホスト側のWireGuard設定を確認
sudo ls -la /etc/wireguard/

# コンテナ内から設定を確認
docker-compose exec wgdashboard ls -la /etc/wireguard/

# 権限の確認（コンテナがアクセスできるか）
docker-compose exec wgdashboard cat /etc/wireguard/wg0.conf
```

### WireGuardが起動しない

```bash
# ホスト側のWireGuardサービス確認
sudo systemctl status wg-quick@wg0

# 手動で再起動
sudo systemctl restart wg-quick@wg0

# ダッシュボードから設定を適用
# Dashboard → Settings → Apply Configuration
```

## セキュリティ

### 実装されているセキュリティ対策

#### 1. **多層認証**
- **Basic認証**（nginx層）: 不正アクセスの第一防御
- **WGDashboard認証**: アプリケーション層の認証

#### 2. **SSL/TLS暗号化**
- Let's Encrypt証明書（自動更新）
- TLS 1.2/1.3のみ許可
- 強力な暗号スイート設定
- OCSP Stapling有効化

#### 3. **レート制限**
- 通常リクエスト: 10req/s（バースト20まで許可）
- ログインエンドポイント: 3req/分（ブルートフォース対策）
- 同時接続数制限: 10接続/IP

#### 4. **セキュリティヘッダー**
- HSTS（HTTP Strict Transport Security）
- X-Frame-Options（クリックジャッキング対策）
- X-Content-Type-Options（MIMEスニッフィング対策）
- CSP（Content Security Policy）
- X-XSS-Protection

#### 5. **その他**
- HTTP→HTTPS強制リダイレクト
- 隠しファイルへのアクセス拒否
- 詳細なアクセスログ

### 推奨追加設定

#### Fail2Ban導入（オプション）

ホスト側にFail2Banをインストールして、ブルートフォース攻撃を防御：

```bash
# ホスト側にFail2Banをインストール
sudo apt-get install fail2ban

# WGDashboard用フィルター作成
sudo vim /etc/fail2ban/filter.d/wgdashboard.conf
```

```ini
[Definition]
failregex = ^<HOST> -.*"(GET|POST|HEAD).*" (401|403|404)
ignoreregex =
```

```bash
# Jail設定
sudo vim /etc/fail2ban/jail.local
```

```ini
[wgdashboard]
enabled = true
port = http,https
logpath = /var/log/nginx/access.log
maxretry = 5
bantime = 3600
findtime = 600
```

```bash
# Fail2Ban再起動
sudo systemctl restart fail2ban

# 状態確認
sudo fail2ban-client status wgdashboard
```

#### IP制限（オプション）

特定のIPアドレスからのみアクセスを許可する場合：

`nginx/nginx.conf`のHTTPSサーバーブロックに追加：

```nginx
server {
    listen 443 ssl http2;
    server_name vpn-dev.abe365.org;
    
    # IP制限
    allow 1.2.3.4;      # 許可するIP
    allow 5.6.7.0/24;   # 許可するネットワーク
    deny all;           # その他は拒否
    
    # ... 残りの設定
}
```

#### CloudflareのProxy経由（推奨）

Cloudflare DNSでProxyを有効にすると：
- DDoS攻撃の軽減
- 実際のサーバーIPの隠蔽
- Cloudflare WAF利用可能

**注意**: WireGuard自体（UDP 51820）はCloudflare Proxyを使用できません。
管理ダッシュボードのみProxyを使用してください。

### パスワード管理

#### Basic認証パスワード変更

```bash
# 既存ユーザーのパスワード変更
./create-htpasswd.sh
# 同じユーザー名を入力して新しいパスワードを設定

# nginxを再起動
docker-compose restart nginx
```

#### WGDashboardパスワード変更

```bash
# .envファイルを編集
vim .env
# WG_DASHBOARD_PASSWORDを変更

# wgdashboardを再起動
docker-compose restart wgdashboard
```

### 定期的なセキュリティ確認

```bash
# SSL証明書の有効期限確認
docker-compose run --rm certbot certificates

# nginxアクセスログの確認（不審なアクセス）
docker-compose exec nginx tail -f /var/log/nginx/access.log

# WGDashboardログの確認
docker-compose logs wgdashboard | grep -i error
```

## メンテナンス

### SSL証明書の管理

#### 証明書の状態確認

```bash
# 証明書情報の表示
docker-compose run --rm certbot certificates

# 証明書の有効期限確認
openssl x509 -in ./data/certbot/conf/live/vpn-dev.abe365.org/cert.pem -noout -dates
```

#### 手動更新

```bash
# 証明書の手動更新
docker-compose run --rm certbot renew

# nginxをリロード
docker-compose exec nginx nginx -s reload
```

#### 証明書の再取得（トラブル時）

```bash
# 既存の証明書を削除
sudo rm -rf ./data/certbot/conf/live/vpn-dev.abe365.org
sudo rm -rf ./data/certbot/conf/archive/vpn-dev.abe365.org
sudo rm -rf ./data/certbot/conf/renewal/vpn-dev.abe365.org.conf

# 初期化スクリプトを再実行
./init-letsencrypt.sh
```

### バックアップ

```bash
# WireGuard設定のバックアップ
sudo tar -czf wireguard_backup_$(date +%Y%m%d).tar.gz /etc/wireguard/

# ダッシュボードデータのバックアップ
tar -czf wgdashboard_backup_$(date +%Y%m%d).tar.gz ./data/wgdashboard/
```

### 復元

```bash
# WireGuard設定の復元
sudo tar -xzf wireguard_backup_YYYYMMDD.tar.gz -C /

# ダッシュボードデータの復元
tar -xzf wgdashboard_backup_YYYYMMDD.tar.gz
```

### アップデート

```bash
# イメージの更新
docker-compose pull

# サービスの再起動
docker-compose down
docker-compose up -d
```

## 統合

### Ansible連携

このダッシュボードは、Ansibleで管理されているWireGuardサーバーと連携します：

- **Ansible設定**: `ansible/wireguard.yml`
- **WireGuardロール**: `ansible/dependency_roles/wireguard/`
- **クライアント設定**: `ansible/wireguard_client.yml`

### 監視連携

monitoring.abe365.org（Grafana）と連携してWireGuardの統計を可視化可能：

```bash
# WireGuard Exporterの追加を検討
# Grafana DashboardでVPN統計を表示
```

## 参考リンク

- [WGDashboard GitHub](https://github.com/donaldzou/WGDashboard)
- [WGDashboard公式サイト](https://wgdashboard.dev)
- [WireGuard公式ドキュメント](https://www.wireguard.com/)
- [WireGuard Quick Start](https://www.wireguard.com/quickstart/)

## 既知の問題

### Docker内からホストのWireGuardを制御

- `network_mode: host`を使用してホストネットワークにアクセス
- `privileged: true`で必要な権限を付与
- コンテナから直接`wg`コマンドを実行可能

### nginxとの連携

- wgdashboardは`network_mode: host`のため、nginxは別ネットワーク
- `extra_hosts`でホストへのアクセスを確保

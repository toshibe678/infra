# WGDashboard - WireGuard Management Dashboard

WireGuard VPNの管理ダッシュボード（環境別設定対応・開発環境はHTTP、本番環境はLet's Encrypt SSL）

## 概要

WGDashboardは、WireGuardの設定を視覚的に管理できるWebベースのダッシュボードです。
ホスト側で動作しているWireGuardの設定を直接管理します。

**環境別対応**：
- **開発環境** (`vpn-dev.abe365.org`): HTTP通信、内部ネットワークのみ、SSL無し
- **本番環境** (`vpn.toshi.click`): HTTPS通信、Let's Encrypt自動SSL更新、グローバルアクセス対応

**セキュリティ機能**：
- 環境別のSSL設定（本番環境のみLet's Encrypt）
- Basic認証による二段階認証
- レート制限（DDoS対策）
- セキュリティヘッダー（本番環境は厳格）
- HTTPS強制リダイレクト（本番環境のみ）

## DNS設定と環境区分

| 環境 | ドメイン | SSL | アクセス |
|------|---------|-----|--------|
| 開発 | vpn-dev.abe365.org | 無し（HTTP） | 内部ネットワークのみ |
| 本番 | vpn.toshi.click | あり（Let's Encrypt） | グローバル（HTTPS） |

**DNS管理**: Cloudflare (cloudflere/records.tf)

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
vim .env  # 認証情報と OTP 設定を変更
```

**環境別設定**:

```dotenv
# 開発環境（内部ネットワーク、HTTP）
ENVIRONMENT=dev

# WGDashboard認証情報（アプリ層のみ）
WGDASHBOARD_USERNAME=admin
WGDASHBOARD_PASSWORD=your_secure_password

# OTP（ワンタイムパスワード）2FAを有効化（推奨）
ENABLE_TOTP=true
```

**セキュリティ構成**:
- nginx の Basic認証は削除（OTP で対応）
- WGDashboard のアプリケーション層で認証 + OTP を実装

# 本番環境（インターネット接続、HTTPS）
ENVIRONMENT=prod
```

### 2. 開発環境セットアップ（HTTP、SSLなし）

```bash
# .envで認証情報を設定
# - ENVIRONMENT=dev
# - WGDASHBOARD_USERNAME / WGDASHBOARD_PASSWORD
# - ENABLE_TOTP=true（OTP有効化）

# サービス起動
docker-compose up -d

# ログ確認
docker-compose logs -f
```

**アクセス方法**:
```
http://vpn-dev.abe365.org:80
```

**初回ログイン**:
1. WGDashboard認証: `.env`で設定した`WGDASHBOARD_USERNAME`/`WGDASHBOARD_PASSWORD`
2. OTP設定画面: QRコードをスキャンして認証器アプリに登録

### 3. 本番環境セットアップ（HTTPS、Let's Encrypt）

```bash
# .envで認証情報を設定
# - ENVIRONMENT=prod
# - WGDASHBOARD_USERNAME / WGDASHBOARD_PASSWORD
# - ENABLE_TOTP=true（OTP有効化）

# Let's Encrypt SSL証明書の取得
chmod +x init-letsencrypt.sh
vim init-letsencrypt.sh
# EMAIL="admin@example.com" を自分のメールアドレスに変更
./init-letsencrypt.sh

# 全サービスを起動（certbotを含む）
docker-compose --profile prod up -d

# ログ確認
docker-compose logs -f
```

**アクセス方法**:
```
https://vpn.toshi.click
```

**初回ログイン**:
1. WGDashboard認証: `.env`で設定した`WGDASHBOARD_USERNAME`/`WGDASHBOARD_PASSWORD`
2. OTP設定画面: QRコードをスキャンして認証器アプリに登録

# 全サービスを起動（certbotを含む）
docker-compose --profile prod up -d

# ログ確認
docker-compose logs -f
```

**アクセス方法**:
```
https://vpn.toshi.click
```

### 4. サービスの動作確認

## 環境変数

以下の環境変数を`.env`ファイルに設定してください：

| 変数名 | 説明 | 必須 | デフォルト |
|--------|------|------|-----------|
| ENVIRONMENT | 環境の選択 (dev/prod) | × | dev |
| WGDASHBOARD_USERNAME | WGDashboard認証ユーザー名 | × | admin |
| WGDASHBOARD_PASSWORD | WGDashboard認証パスワード | ✓ | - |
| ENABLE_TOTP | OTP 2FA有効化（推奨） | × | true |
| TZ | タイムゾーン | × | Asia/Tokyo |

**認証設定**:
- nginx: Basic認証なし（OTP で直接保護）
- WGDashboard: ユーザー名/パスワード + OTP 2FA
- セキュリティ: OTP（Google Authenticator等）で強化

**環境の詳細**:
- `dev`: 開発環境（HTTP、内部ネットワーク）
  - nginxはHTTPで動作
  - certbotは起動しない
- `prod`: 本番環境（HTTPS、Let's Encrypt）
  - nginxはHTTPSで動作
  - certbotが自動更新を管理

## アクセス方法

### 開発環境

```
http://vpn-dev.abe365.org
```

**認証**:
1. ユーザー名/パスワード: `.env`の`WGDASHBOARD_*`
2. OTP コード: Google Authenticator 等で生成

### 本番環境

```
https://vpn.toshi.click
```

**認証**:
1. ユーザー名/パスワード: `.env`の`WGDASHBOARD_*`
2. OTP コード: Google Authenticator 等で生成

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

### 環境確認

```bash
# 現在の環境を確認
cat .env | grep ENVIRONMENT

# 使用されているnginx設定ファイルを確認
docker-compose exec nginx cat /etc/nginx/nginx.conf | head -20
```

### ダッシュボードにアクセスできない

**開発環境（HTTP）**:
```bash
# コンテナの状態確認
docker-compose ps

# nginxログの確認
docker-compose logs nginx

# ポート80が使用可能か確認
sudo netstat -tlnp | grep :80
```

**本番環境（HTTPS）**:
```bash
# SSL証明書が取得できているか確認
ls -la ./data/certbot/conf/live/

# 証明書の有効期限確認
openssl x509 -in ./data/certbot/conf/live/vpn.toshi.click/cert.pem -noout -dates

# certbotのログを確認
docker-compose logs certbot
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

### 実装されているセキュリティ機能

#### 認証と認可

- **WGDashboard認証**: ユーザー名とパスワード
- **OTP 2FA**: Google Authenticator や Microsoft Authenticator での二要素認証
- **nginx**: Basic認証なし（OTP で直接保護）

#### 開発環境（HTTP）

- **WGDashboard認証**: ユーザー名 + パスワード + OTP
- **SSL/TLS**: なし（内部ネットワークのため）
- **セキュリティヘッダー**: 最小限
- **レート制限**: 通常10req/s、ログイン3req/分
- **用途**: ローカルネットワーク内での開発・管理

#### 本番環境（HTTPS）

- **WGDashboard認証**: ユーザー名 + パスワード + OTP
- **SSL/TLS**: Let's Encrypt（自動更新）
- **セキュリティヘッダー**: 厳格（HSTS、CSP、OCSP Stapling等）
- **レート制限**: 通常10req/s、ログイン3req/分
- **HTTP強制リダイレクト**: HTTPS強制（HSTS有効）

### 本番環境で実装されているセキュリティ対策

#### 1. **OTP による二要素認証**
- Google Authenticator、Microsoft Authenticator 対応
- バックアップコード発行
- タイムベース（TOTP）実装

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

#### WGDashboardパスワード変更

```bash
# .envファイルを編集
vim .env
# WGDASHBOARD_USERNAME / WGDASHBOARD_PASSWORD を変更

# wgdashboardを再起動
docker-compose restart wgdashboard
```

**注意**: WGDashboardは環境変数`username`/`password`で初回起動時にアカウントを作成します。
変更した認証情報を反映するには、既存のデータベースをクリアして再起動する必要がある場合があります：

```bash
# データベースのバックアップ（念のため）
cp -r ./data/wgdashboard ./data/wgdashboard.backup

# データベースを削除（認証情報がリセットされる）
rm -rf ./data/wgdashboard/*

# 再起動（新しい認証情報で初期化）
docker-compose restart wgdashboard
```

#### OTP設定変更

OTP設定はWebインターフェースから管理します：

```bash
# Webインターフェースにログイン
# Settings → Account → Two-Factor Authentication (TOTP)
# 既存のOTPを無効化・再設定可能
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

# Requirements Document

## Introduction

vpn-proxy サービスは、WireGuard VPN 接続されたサーバー上で稼働する nginx ベースのリバースプロキシである。
VPN クライアントが VPN 経由でアクセスする際に、VPN 非接続の拠点内 LAN サーバー群（monitoring、develop、ai-test、mcp-servers 等）へのルーティングを担う。

本仕様は vpn-proxy サービスの Nginx 設定・Ansible ロール化・Ansible による自動管理を対象とする。
各 Service（monitoring、dify、mcp-servers 等）自体の内部設定は対象外とする。

## Boundary Context

- **In scope**: vpn-proxy 上の nginx リバースプロキシ設定、バックエンドルーティング定義、SSL/TLS 設定（VPN 内自己署名）、レート制限・セキュリティヘッダー、Prometheus 監視統合、Ansible によるデプロイ自動化
- **Out of scope**: 各バックエンドサービス（monitoring、develop 等）の内部設定、WireGuard VPN サーバー自体の設定、Cloudflare DNS レコード管理（外部公開ではないため）
- **Adjacent expectations**: WireGuard VPN が正常稼働していること、バックエンドサーバー群（192.168.100.0/24）が LAN 到達可能であること

## Requirements

### 要件 1: バックエンドルーティング

**Objective:** インフラ管理者として、各 Service（monitoring・develop・ai-test・mcp-servers 等）へのルーティングルールを一元管理したい。これにより VPN クライアントから個別サービスへ透過的にアクセスできるようにする。

#### Acceptance Criteria

1. The vpn-proxy shall ホスト名ベースのバーチャルホスト（`server_name`）でリクエストを各バックエンドにルーティングする。
2. When リクエストが未定義のホスト名で到達した場合、the vpn-proxy shall HTTP 404 レスポンスを返す。
3. The vpn-proxy shall 各バックエンドに対して `upstream` ブロックを定義し、追加サーバーによるロードバランシング拡張ができる構造にする。
4. When バックエンドが `conf.d/` 配下の個別設定ファイルに分割されている場合、the vpn-proxy shall `include conf.d/*.conf` ディレクティブで全設定を読み込む。
5. The vpn-proxy shall 各バックエンド向けに `proxy_set_header Host`・`X-Real-IP`・`X-Forwarded-For`・`X-Forwarded-Proto` を付与してプロキシする。

### 要件 2: WebSocket サポート

**Objective:** インフラ管理者として、Grafana Live・Dify・Jupyter 等の WebSocket を使用するサービスへの接続を維持したい。これによりリアルタイム通信が必要なアプリケーションを VPN 越しに利用できるようにする。

#### Acceptance Criteria

1. The vpn-proxy shall WebSocket アップグレードが必要なバックエンドに対して `proxy_http_version 1.1`・`Upgrade`・`Connection upgrade` ヘッダーを設定する。
2. While WebSocket 接続が確立されている間、the vpn-proxy shall 接続を維持し通信を中継する。
3. If WebSocket ハンドシェイクが失敗した場合、the vpn-proxy shall エラーレスポンスをクライアントに返す。

### 要件 3: SSL/TLS 終端（VPN 内部 HTTPS）

**Objective:** インフラ管理者として、VPN 内部通信でも HTTPS を強制したい。これにより VPN トンネル内でもサービス間通信の機密性と整合性を確保できるようにする。

#### Acceptance Criteria

1. The vpn-proxy shall HTTP (80) へのリクエストを HTTPS (443) へ 301 リダイレクトする。
2. The vpn-proxy shall TLSv1.2 および TLSv1.3 のみを許可し、旧バージョンを拒否する。
3. The vpn-proxy shall 自己署名証明書（`nginx/ssl/cert.pem` / `key.pem`）を使用して SSL 終端する。
4. Where 証明書ファイルが存在しない場合、the vpn-proxy shall 起動を拒否しエラーを記録する。
5. The vpn-proxy shall 証明書に複数の SAN（サービス名ごとの `*.vpn.local` ドメイン）を含む自己署名証明書の生成手順をドキュメントに記載する。

### 要件 4: レート制限とアクセス制御

**Objective:** インフラ管理者として、不正アクセスや過負荷を防止したい。これにより VPN 内部からのリクエストであっても適切な制限を設けてサービスを保護できるようにする。

#### Acceptance Criteria

1. The vpn-proxy shall 一般エンドポイントに対して 10 リクエスト/秒 のレート制限を適用する。
2. The vpn-proxy shall 同一 IP からの同時接続数を最大 10 接続に制限する。
3. If レート制限を超過したリクエストが到達した場合、the vpn-proxy shall HTTP 429 を返す。
4. Where VPN サブネット制限が有効な場合、the vpn-proxy shall 許可サブネット（`ALLOWED_VPN_SUBNET`）以外からのアクセスを拒否する。
5. The vpn-proxy shall `X-Frame-Options`・`X-Content-Type-Options`・`X-XSS-Protection` 等のセキュリティレスポンスヘッダーを付与する。

### 要件 5: ヘルスチェックと Prometheus 監視

**Objective:** インフラ管理者として、vpn-proxy 自体の死活監視とメトリクス収集を行いたい。これにより Prometheus/Grafana ダッシュボードで一元的に監視できるようにする。

#### Acceptance Criteria

1. The vpn-proxy shall `/health` エンドポイントに対して HTTP 200 と `"healthy"` を返す。
2. The vpn-proxy shall `/metrics` エンドポイントで Node Exporter（`node-exporter:9100/metrics`）にプロキシしてシステムメトリクスを公開する。
3. While Node Exporter が起動している間、the vpn-proxy shall `/metrics` のレスポンスを Prometheus スクレイプ形式で返す。
4. If Node Exporter が到達不能な場合、the vpn-proxy shall `/metrics` に対して HTTP 502 を返す。
5. The vpn-proxy shall ヘルスチェックリクエストをアクセスログに記録しない（`access_log off`）。

### 要件 6: ログ管理

**Objective:** インフラ管理者として、各バックエンドへのアクセスログとエラーログをホスト側から参照できるようにしたい。これにより問題発生時の調査と監査が容易になるようにする。

#### Acceptance Criteria

1. The vpn-proxy shall バックエンドごとに個別のアクセスログファイル（`/var/log/nginx/<service>.access.log`）を生成する。
2. The vpn-proxy shall エラーログを `/var/log/nginx/<service>.error.log` に `warn` レベル以上で記録する。
3. The vpn-proxy shall ログディレクトリ `./logs/nginx/` をホスト側にボリュームマウントして永続化する。
4. The vpn-proxy shall プロキシ情報（`$upstream_addr`・`$upstream_response_time`・`$upstream_status`）を含むカスタムログフォーマットでアクセスログを記録する。

### 要件 7: Ansible による自動デプロイ

**Objective:** インフラ管理者として、vpn-proxy の設定・起動・更新を Ansible で冪等的に管理したい。これにより手動作業をなくし再現可能なデプロイを実現できるようにする。

#### Acceptance Criteria

1. The vpn-proxy Ansible role shall Docker Compose による vpn-proxy サービスの起動・停止・再起動を管理する。
2. The vpn-proxy Ansible role shall 自己署名証明書が存在しない場合に自動生成する。
3. The vpn-proxy Ansible role shall nginx 設定ファイルの変更を検知し、変更時に `nginx -s reload` を実行する。
4. When `-C`（チェックモード）で実行した場合、the vpn-proxy Ansible role shall 実際の変更を行わず差分のみを報告する。
5. The vpn-proxy Ansible role shall `.env` ファイルを `ansible-vault` 暗号化された変数から生成する。
6. If Nginx 設定の構文チェック（`nginx -t`）が失敗した場合、the vpn-proxy Ansible role shall デプロイを中断しエラーを報告する。

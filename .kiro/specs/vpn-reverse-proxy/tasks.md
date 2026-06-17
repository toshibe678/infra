# 実装計画

## タスク一覧

---

- [x] 1. 基盤整備: Docker Compose 設定とディレクトリ構造の確立

- [x] 1.1 Docker Compose サービス定義を最終形に整備する
  - nginx:alpine（stable）と prom/node-exporter の 2 サービス構成を確認する
  - HTTP (80) / HTTPS (443) ポートマッピングを定義する
  - `./nginx/ssl:/etc/nginx/ssl:ro` SSL 証明書ボリュームマウントを追加する
  - `./logs/nginx:/var/log/nginx` ログボリュームマウントを追加する
  - Docker 内部ネットワーク `vpn-proxy-network` を定義し、node-exporter はポート非公開（expose のみ）にする
  - `docker compose config` で設定検証が通ること
  - _Requirements: 6.3, 7.1_

- [x] 1.2 ログディレクトリとファイル構造を準備する
  - `service/vpn-proxy/logs/nginx/` ディレクトリを作成し `.gitkeep` を配置する
  - `service/vpn-proxy/nginx/ssl/` ディレクトリを作成し `.gitignore` で証明書ファイルを除外する
  - `.env.example` にすべての環境変数スキーマ（`ALLOWED_VPN_SUBNET` を含む）を定義する
  - ディレクトリ構造が設計ドキュメントのファイル構造計画と一致すること
  - _Requirements: 6.3_

---

- [x] 2. Nginx グローバル設定（nginx.conf）の整備

- [x] 2.1 レート制限ゾーンとログフォーマットを nginx.conf に定義する
  - `limit_req_zone` で `general`（10r/s）・`strict`（3r/s）ゾーンを定義する
  - `limit_conn_zone` で `conn_limit` ゾーンを定義する
  - `limit_req_status 429`・`limit_conn_status 429` をグローバルに設定する
  - `log_format proxy_log` に `$upstream_addr`・`$upstream_response_time`・`$upstream_status` を含める
  - `include /etc/nginx/conf.d/*.conf` ディレクティブを設定する
  - `server_tokens off` を設定する
  - `worker_processes auto` を設定する
  - `docker compose exec nginx nginx -t` で構文チェックが通ること
  - _Requirements: 1.4, 4.1, 4.2, 4.3, 6.4_
  - _Boundary: NginxConfig_

- [x] 2.2 グローバルセキュリティヘッダーを nginx.conf に設定する
  - `X-Frame-Options: SAMEORIGIN` を追加する
  - `X-Content-Type-Options: nosniff` を追加する
  - `X-XSS-Protection: 1; mode=block` を追加する
  - `Referrer-Policy: no-referrer-when-downgrade` を追加する
  - `curl -k https://localhost/health -I` のレスポンスヘッダーにすべてのセキュリティヘッダーが含まれること
  - _Requirements: 4.5_
  - _Boundary: NginxSecurity_

---

- [x] 3. SSL/TLS 設定と HTTP→HTTPS リダイレクトの実装

- [x] 3.1 (P) default.conf に HTTP→HTTPS リダイレクトと 443 SSL リッスンを実装する
  - HTTP (80) catch-all server ブロックで `return 301 https://$host$request_uri` を設定する
  - HTTPS (443) server ブロックに `default_server` を設定し未定義ホストへ 404 を返す
  - `ssl_certificate /etc/nginx/ssl/cert.pem` と `ssl_certificate_key /etc/nginx/ssl/key.pem` を参照する
  - `ssl_protocols TLSv1.2 TLSv1.3` を設定し旧バージョンを明示的に除外する
  - `ssl_ciphers HIGH:!aNULL:!MD5` を設定する
  - `curl http://localhost/` が 301 リダイレクトを返すこと
  - `curl -k https://localhost/` が未定義ホストに対し 404 を返すこと
  - _Requirements: 1.2, 3.1, 3.2, 3.3, 3.4_
  - _Boundary: NginxSSL_
  - _Depends: 2.1_

---

- [x] 4. ヘルスチェックと Prometheus 監視エンドポイントの実装

- [x] 4.1 (P) default.conf に /health・/metrics エンドポイントを実装する
  - HTTPS (443) server ブロックに `/health` location を追加し HTTP 200 + `"healthy\n"` を返す
  - `/health` location に `access_log off` を設定する
  - `/metrics` location に `proxy_pass http://node-exporter:9100/metrics` を設定する
  - `ALLOWED_VPN_SUBNET` が設定されている場合、`/metrics` に `allow`/`deny` ディレクティブを追加する
  - Node Exporter が到達不能な場合に `/metrics` が 502 を返すこと
  - `curl -k https://localhost/health` が `"healthy"` を含む 200 を返すこと
  - `curl -k https://localhost/metrics` が Prometheus テキスト形式のレスポンスを返すこと
  - _Requirements: 5.1, 5.2, 5.4, 5.5_
  - _Boundary: NginxHealth_
  - _Depends: 3.1_

---

- [x] 5. バックエンドルーティングと WebSocket 対応の実装

- [x] 5.1 Ansible テンプレートでバックエンド仮想ホスト設定を生成できるようにする
  - `backend.conf.j2` テンプレートを作成し `vpn_proxy_backends` リストをループ処理する
  - 各バックエンドに `upstream <service>_backend` ブロックを定義する（拡張可能な構造）
  - HTTPS (443) server ブロックに `server_name <service>.vpn.local` を設定する
  - `proxy_set_header Host`・`X-Real-IP`・`X-Forwarded-For`・`X-Forwarded-Proto` を付与する
  - `websocket: true` のバックエンドに `proxy_http_version 1.1`・`Upgrade`・`Connection "upgrade"` を設定する
  - `proxy_read_timeout` をバックエンドごとに設定する（AI 系は 300s）
  - サービスごとのアクセスログ（`/var/log/nginx/<service>.access.log`）とエラーログを設定する
  - `limit_req zone=general burst=20 nodelay` と `limit_conn conn_limit 10` を各 location に適用する
  - `curl -k -H "Host: monitoring-proxy.vpn.local" https://localhost/` がバックエンドに到達すること
  - _Requirements: 1.1, 1.3, 1.5, 2.1, 2.2, 2.3, 4.1, 4.2, 6.1, 6.2_
  - _Boundary: NginxVirtualHost_
  - _Depends: 2.1, 3.1_

---

- [x] 6. Ansible ロールの基盤整備

- [x] 6.1 vpn_proxy Ansible ロールのディレクトリ構造とデフォルト変数を定義する
  - `ansible/inner_roles/vpn_proxy/` 配下に `defaults/`・`tasks/`・`templates/`・`handlers/` を作成する
  - `defaults/main.yml` に `vpn_proxy_backends`（全バックエンドエントリ）を定義する
  - `defaults/main.yml` に SSL 設定変数（`vpn_proxy_ssl_days: 825`・`vpn_proxy_ssl_curve: secp384r1`）を定義する
  - `defaults/main.yml` にレート制限変数（`vpn_proxy_rate_limit_general`・`vpn_proxy_conn_limit`・`vpn_proxy_burst`）を定義する
  - `defaults/main.yml` に `vpn_proxy_service_dir` と `vpn_proxy_allowed_subnet` を定義する
  - `ansible-lint inner_roles/vpn_proxy/` が変数定義ファイルで警告なく通ること
  - _Requirements: 7.1, 7.4, 7.5_
  - _Boundary: AnsibleRole_

- [x] 6.2 nginx reload ハンドラーと .env テンプレートを作成する
  - `handlers/main.yml` に `nginx_reload` ハンドラーを定義する（`docker compose exec nginx nginx -s reload`）
  - 初回起動時は `ignore_errors: yes` で保護する
  - `templates/env.j2` を作成し Vault 変数から `.env` ファイルを生成するテンプレートを実装する
  - `templates/default.conf.j2` を作成し `/health`・`/metrics` エンドポイントの HTTP/HTTPS 両サーバーブロックをテンプレート化する
  - `.env` テンプレートに `ALLOWED_VPN_SUBNET` 変数が含まれること
  - _Requirements: 7.3, 7.5_
  - _Boundary: AnsibleRole_

---

- [x] 7. Ansible タスクパイプラインの実装

- [x] 7.1 証明書自動生成タスクを実装する
  - `tasks/main.yml` にログディレクトリ作成タスクを追加する
  - `stat` モジュールで `cert.pem` の存在を確認するタスクを追加する
  - 証明書が存在しない場合に `openssl req` で EC-P384 自己署名証明書を生成するタスクを追加する（`creates` オプションで冪等性を保証）
  - SAN に全バックエンドサービスの `*.vpn.local` ドメインを含める
  - Ansible 実行後に `nginx/ssl/cert.pem` と `nginx/ssl/key.pem` が存在すること
  - _Requirements: 3.5, 7.2_
  - _Boundary: AnsibleRole_

- [x] 7.2 設定ファイル配置と nginx 構文チェックタスクを実装する
  - `.env` ファイル配置タスクを追加する（template モジュール + Vault 変数、変更時 handler 通知）
  - `nginx.conf` 配置タスクを追加する（変更時 `nginx_reload` handler 通知）
  - `default.conf` 配置タスクを追加する（`default.conf.j2` テンプレート、変更時 handler 通知）
  - `vpn_proxy_backends` ループでバックエンド設定ファイルを配置するタスクを追加する（変更時 handler 通知）
  - `nginx -t` 構文チェックタスクを追加し `failed_when: result.rc != 0` でデプロイを中断させる
  - nginx 設定を変更してロールを再実行したとき `nginx_reload` ハンドラーがトリガーされること
  - `nginx -t` が失敗する設定を配置したとき Ansible がエラーで停止すること
  - _Requirements: 7.3, 7.5, 7.6_
  - _Boundary: AnsibleRole_

- [x] 7.3 Docker Compose 起動管理タスクとプレイブックを実装する
  - `docker compose up -d` 実行タスクを追加する（冪等: コンテナ既存の場合は変更なし）
  - `ansible/vpn_proxy.yml` プレイブックを作成し `home_servers` グループ内の `vpn-proxy.abe365.org` を対象に指定する
  - `ansible-playbook -C vpn_proxy.yml` のチェックモードで実際の変更を行わず差分のみ報告されること
  - `docker compose ps` で nginx と node-exporter が `running` 状態になること
  - _Requirements: 7.1, 7.4_
  - _Boundary: AnsibleRole_

---

- [ ] 8. 統合検証

- [ ] 8.1 Nginx 設定と SSL 疎通確認を検証する
  - `curl http://localhost/` が 301 リダイレクトを返すことを確認する
  - `curl -k https://localhost/health` が `"healthy"` を含む 200 を返すことを確認する
  - `curl -k https://localhost/metrics` が Prometheus テキスト形式を返すことを確認する
  - `curl -k -H "Host: undefined.vpn.local" https://localhost/` が 404 を返すことを確認する
  - `curl -k -H "Host: monitoring-proxy.vpn.local" https://localhost/` がバックエンドに到達することを確認する
  - 全検証ステップが成功すること
  - _Requirements: 1.2, 3.1, 5.1, 5.2_

- [ ] 8.2 レート制限とセキュリティヘッダーの動作を検証する
  - `ab -n 100 -c 20 https://localhost/health` を実行し 429 レスポンスが返ることを確認する
  - `curl -k https://localhost/health -I` のレスポンスに `X-Frame-Options`・`X-Content-Type-Options`・`X-XSS-Protection` が含まれることを確認する
  - レスポンスヘッダーに `Server: nginx` バージョン情報が含まれないことを確認する
  - _Requirements: 4.3, 4.5_

- [ ] 8.3* Ansible チェックモードと lint 検証を実施する
  - `ansible-playbook -C vpn_proxy.yml` で差分のみ報告されること（実変更なし）を確認する
  - `ansible-lint inner_roles/vpn_proxy/` が警告なく通ることを確認する
  - _Requirements: 7.4_

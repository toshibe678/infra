# service/ デプロイ変数一覧（Ansible role `service_compose` 向け）

Agent A (service/担当) が Task #4 で洗い出した、各サービスの env キー / config_files / healthcheck / ハードコード是正点。
Agent B はこれを元に `service_compose` role の `vars/<service>.yml` を作成してください。

凡例:
- **env キー**: `.env.example` 由来。秘密値はキー名のみ（vault化前提）。`(default: x)` はdocker-compose.yml側のデフォルト値。
- **config_files**: リポジトリから対象ホストへ同期すべき相対パス（`service/<name>/` 基準）。data/・logs/・secrets類は対象外。
- **healthcheck**: デプロイ後の起動確認コマンド。
- **ハードコード是正点**: localhost/固定IP/固定URLなどenv化すべき箇所。

---

## dify

サブモジュール (`service/dify/dify`) 配下の Dify 本体を `dify/docker/docker-compose.yaml` で起動する構成。
`service/dify/docker-compose.yml` は node-exporter のみの補助compose。

- **compose**: `dify/docker/docker-compose.yaml`（サブモジュール内。`docker-compose-template.yaml`から自動生成されるので直接編集禁止）, `docker-compose.yml`（node-exporter）
- **env ファイル配置先**: `dify/docker/.env`（`service/dify/.env.example` をコピーして生成。dify公式の巨大envなので全キーではなく主要キーのみ抜粋）

### env キー（主要のみ・全量は `.env.example` 参照）

| キー | 用途 | 備考 |
|---|---|---|
| SECRET_KEY | アプリ署名鍵 | `openssl rand -base64 42` で生成、vault必須 |
| INIT_PASSWORD | 初期管理者パスワード | vault必須 |
| DB_PASSWORD | PostgreSQLパスワード | vault必須 |
| DB_USERNAME / DB_DATABASE | DB接続情報 | デフォルトのままで可 |
| REDIS_PASSWORD | Redisパスワード | vault必須 |
| WEAVIATE_API_KEY | Weaviate APIキー | vault必須（デフォルト値は公式サンプル値なので要変更） |
| LOG_LEVEL | ログレベル | INFO/DEBUG/ERROR |
| CONSOLE_API_URL / CONSOLE_WEB_URL / SERVICE_API_URL / TRIGGER_URL / APP_API_URL / APP_WEB_URL / FILES_URL | 外部公開URL | 現状 `http://dify.abe365.org` 固定。**HTTPS化検討**（README記載のSSL設定をするなら `https://` に統一すべき） |
| INTERNAL_FILES_URL | プラグイン用内部URL | `http://api:5001`（Docker内部名なので変更不要） |
| PLUGIN_DAEMON_KEY / PLUGIN_DIFY_INNER_API_KEY | プラグインデーモン認証鍵 | vault必須 |
| NGINX_SSL_CERT_KEY_FILENAME | SSL鍵ファイル名 | `dify.key` |

それ以外（S3/Azure/Aliyun/Oracle等の各種ストレージ・ベクトルDBプロバイダ用キー）は未使用のため**配布不要**（デフォルトの`.env.example`に同梱されている公式テンプレートの一部）。

### config_files

- `.env.example`（→ `dify/docker/.env` に展開して使用）
- `docker-compose.yml`（node-exporter補助）

サブモジュール本体（`dify/dify/docker/docker-compose.yaml` 等）は `git submodule update --init --recursive` で取得するものなので config_files 同期の対象外（Ansible側でsubmodule初期化コマンドを叩く想定）。

### healthcheck

```bash
docker compose exec -T nginx nginx -t   # ※ dify/docker配下にnginxサービスがある場合
docker compose -f dify/docker/docker-compose.yaml ps
curl -fsS http://dify.abe365.org/health || curl -fsS http://localhost/health
```

### ハードコード是正点

- `CONSOLE_API_URL` 等6つの `*_URL` が `http://dify.abe365.org`（HTTP固定）。README手順ではSSL証明書を作成する記載があるため、本番運用するなら `https://` への統一を検討。
- `EXPOSE_PLUGIN_DEBUGGING_HOST=localhost`、`ENDPOINT_URL_TEMPLATE=http://localhost/e/{hook_id}`、`OTLP_BASE_ENDPOINT=http://localhost:4318` が `localhost` 固定（プラグインデバッグ・OTel用途で通常は変更不要だが、env化候補として記録）。

---

## llm-proxy

LiteLLM Proxy + PostgreSQL + Redis + Nginx 構成。

### env キー

| キー | 用途 | 必須/vault |
|---|---|---|
| LITELLM_MASTER_KEY | LiteLLM管理者キー | vault必須 |
| LITELLM_LOG | ログレベル | (default: INFO) |
| STORE_MODEL_IN_DB | モデルをDB管理するか | (default: True) |
| UI_USERNAME / UI_PASSWORD | 管理UIログイン | vault必須(PASSWORD) |
| DOCS_URL / ROOT_REDIRECT_URL | パス設定 | 任意 |
| DB_PASSWORD | PostgreSQLパスワード | vault必須 |
| DATABASE_URL | DB接続文字列 | `DB_PASSWORD`から組み立て |
| REDIS_PASSWORD | Redisパスワード | vault必須 |
| OPENAI_API_KEY / ANTHROPIC_API_KEY / AZURE_API_KEY / AZURE_API_BASE | 外部LLM APIキー | vault必須(キー類) |
| AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY / AWS_REGION_NAME | Bedrock認証 | vault必須 |
| BEDROCK_NOVA_MICRO_ARN / BEDROCK_NOVA_LITE_ARN / BEDROCK_NOVA_PRO_ARN / BEDROCK_NOVA2_LITE_ARN / BEDROCK_CLAUDE_SONNET_4_5_ARN / BEDROCK_CLAUDE_HAIKU_4_5_ARN / BEDROCK_CLAUDE_OPUS_4_5_ARN | Bedrock推論プロファイルARN | AWSアカウントID含むため非秘匿だがvault推奨 |
| GCP_PROJECT_ID / GCP_REGION / VERTEX_LOCATION | Vertex AI設定 | 非秘匿 |
| GOOGLE_APPLICATION_CREDENTIALS / GOOGLE_APPLICATION_CREDENTIALS_JSON | GCPサービスアカウント | vault必須（ファイル配置で対応、envでなくsecret file） |

### config_files

- `config/config.yaml`（LiteLLMモデル定義・ルーティング設定）
- `nginx/nginx.conf`

`config/gcp-credentials.json` はcompose上でマウント参照されるが秘密ファイルのため config_files 対象外（vault/secret管理）。
**8サービス横断で.gitignore×composeマウントを突き合わせ調査済み**: ファイル単位でcomposeマウントされかつgitignore対象の秘密ファイルは、本サービスの`gcp-credentials.json`のみ（他サービスのgitignore対象はnginx/ssl証明書やnode_modules等でconfig_files対象外）。vaultからJSON鍵の内容を1つの文字列変数として渡し、デプロイ時に`config/gcp-credentials.json`としてファイル書き出しする専用タスクが必要（Agent B Task #5で対応）。

### healthcheck

```bash
docker compose exec -T nginx nginx -t
curl -fsS https://llm-proxy.abe365.org/health
```

### ハードコード是正点

- `config/config.yaml` の Ollamaモデル `api_base: http://toshi-gamepc.abe365.org:11434` が5箇所ハードコード。社内固定GPU機なので外部ドメインそのもので問題ないが、変更時の保守性のため `OLLAMA_HOST_URL` 等のenv化を検討候補として記録（current: 是正必須ではない）。
- `nginx.conf` の `server_name llm-proxy.abe365.org` は固定で問題なし（ドメインは仕様）。

---

## mcp-servers

Nginx + MCP Gateway + 各種MCPサーバー（git/github/filesystem/postgres/fetch/playwright）+ PostgreSQL + Redis 構成。

### env キー

| キー | 用途 | vault |
|---|---|---|
| NODE_ENV | (default: production) | 非秘匿 |
| DB_USER / DB_PASSWORD / DB_NAME | PostgreSQL | PASSWORDのみvault |
| DATABASE_URL | DB接続文字列 | DB_PASSWORDから組み立て |
| REDIS_PASSWORD / REDIS_URL | Redis | PASSWORDのみvault |
| AUTH_TOKEN | MCP Gateway認証トークン | vault必須 |
| GITHUB_TOKEN / GITHUB_PERSONAL_ACCESS_TOKEN | GitHub MCP | vault必須 |
| GIT_ALLOWED_REPOS | Git MCP許可パス | (default: /repos) |
| FILESYSTEM_ALLOWED_PATHS | Filesystem MCP許可パス | (default: /workspace) |
| POSTGRES_MCP_URL | Postgres MCP接続文字列 | vault必須(パスワード含む) |
| FETCH_USER_AGENT | Fetch MCP User-Agent | (default: MCP-Fetch/1.0) |
| GMAIL_CLIENT_ID / GMAIL_CLIENT_SECRET / GMAIL_REFRESH_TOKEN | Gmail MCP（任意） | vault必須・未使用なら空のまま |
| SLACK_BOT_TOKEN / SLACK_APP_TOKEN | Slack MCP（任意） | vault必須・compose未参照（任意拡張用） |
| NOTION_API_KEY / NOTION_DATABASE_ID | Notion MCP（任意） | vault必須・compose未参照 |
| AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY / AWS_REGION / AWS_PROFILE | AWS MCP（任意） | vault必須・compose未参照 |
| UPSTASH_REDIS_URL / UPSTASH_REDIS_TOKEN | Context7/Upstash（任意） | vault必須・compose未参照 |

### config_files

- `nginx/nginx.conf`
- `gateway/server.js`, `gateway/package.json`（MCP Gatewayの実装本体。`./gateway:/app` でマウントされる）

`mcp-servers/playwright/package-lock.json` は依存ロックファイルでconfig_files対象（リポジトリ管理下なら同期）。`repos/`, `workspace/`, `data/` は除外。

### healthcheck

```bash
docker compose exec -T nginx nginx -t
curl -fsS https://mcp.abe365.org/health
```

### ハードコード是正点

- `nginx.conf` の `/metrics` ロケーションが `proxy_pass http://localhost:9100/metrics;` となっている。同一nginxコンテナ内のlocalhostにはnode-exporterは存在せず（node-exporterは別コンテナ、かつ`mcp-network`にポート非公開で接続）、**実体として動作しないハードコードバグ**。本来は `http://node-exporter:9100/metrics` のようにサービス名で参照すべき。要修正点としてAgent Bおよびmainへ報告。
- `.env.example` のSlack/Notion/AWS/Upstash系キーはcompose側で未参照（将来拡張用の予約キー）。現状は配布不要だが、将来MCPサーバーを追加する際の参照用に残置で問題なし。

---

## monitoring

Prometheus + Alertmanager + Grafana + SNMP Exporter + Nginx + Node Exporter 構成（Loki/Tempo/Promtail/otel-collectorはコメントアウトで未使用）。

### env キー

| キー | 用途 | vault |
|---|---|---|
| SLACK_WEBHOOK_URL | Alertmanager通知先 | vault必須 |
| UID / GID | （`.env.example`記載だが compose内では未参照。今後のボリューム権限調整用と思われる） | 非秘匿 |
| BASE_URL | Grafana/Prometheusの外部公開URL基点 | **要修正（下記参照）** |
| GRAFANA_ADMIN_USER / GRAFANA_ADMIN_PASSWORD | Grafana管理者 | PASSWORDのみvault |

### config_files

- `config/nginx.conf`
- `config/prometheus.yml`
- `config/prom-rules.yml`
- `config/alertmanager.yml.template`（`${SLACK_WEBHOOK_URL}`等のテンプレート変数を含む想定。実体生成方法はAgent B側で確認要）
- `config/grafana-datasources.yml`
- `config/grafana-dashboards.yml`
- `config/snmp.yml`
- `dashboards/`配下のJSON群（Grafanaダッシュボード定義、存在する場合）

未使用設定（コメントアウト中のためconfig_files対象外、ただし参考保持）: `config/loki-config.yml`, `config/promtail-config.yml`, `config/tempo-config.yml`, `config/otel-collector.yml`。`config/snmp.yml.backup`はバックアップファイルなので同期不要。

### healthcheck

```bash
docker compose exec -T nginx nginx -t
curl -fsS https://monitoring.abe365.org/grafana/login
curl -fsS https://monitoring.abe365.org/prometheus/-/healthy
```

### ハードコード是正点

- `.env.example` の `BASE_URL=http://localhost` がデフォルト値のままだと `nginx.conf` の `server_name monitoring.abe365.org` と食い違う。**`BASE_URL=https://monitoring.abe365.org` に修正してデプロイすべき**（`GF_SERVER_ROOT_URL`や`--web.external-url`がこの値を使うため、`localhost`のままだとGrafana/PrometheusのリンクやリダイレクトがNginx経由のアクセスと一致しない）。Agent Bのrole varsでは本番値を明示すること。
- `UID`/`GID` が `.env.example` にあるがどのサービスからも参照されていない（将来のボリューム所有者調整用の予約キーと思われる。現状は無害だが要不要を要確認）。

---

## siem

Elasticsearch + Kibana + Logstash + Node Exporter 構成（開発用、認証無効）。
**Task #4 の指示により README/compose を本タスクで補完済み**（`service/siem/README.md` 新規執筆、`docker-compose.yml` の `node-exporter` の `container_name` が `wgdashboard-node-exporter` という他サービスからのコピペミスだったため `siem-node-exporter` に修正）。

### env キー

なし（`.env`/`.env.example` 自体が存在しない構成。`STACK_VERSION`はcompose内で `${STACK_VERSION:-9.1.2}` という未設定時デフォルトのみで、現状envファイル化されていない）。
Ansible側で必要なら `.env.example`（`STACK_VERSION=9.1.2` のみ）を新設して統一感を出す案もあるが、**現状compose側はデフォルト値で完結しており追加は必須ではない**。

### config_files

- `logstash/config/logstash.yml`
- `logstash/pipeline/logstash.conf`

### healthcheck

```bash
docker compose ps
curl -fsS http://localhost:9200/_cluster/health?pretty
curl -fsS http://localhost:5601/api/status   # Kibana
```

（nginxサービスが無いため `nginx -t` 系のhealthcheckは対象外）

### ハードコード是正点

- 修正済み: `node-exporter` の `container_name: wgdashboard-node-exporter` → `siem-node-exporter`（コピペミス）。
- `xpack.security.enabled=false` で認証無効（開発用と明記済み、本番投入時は要再検討。本タスクでは「過剰実装しない」方針のため変更せず現状維持）。
- 他サービス（monitoring, dify, llm-proxy, wgdashboard）すべてが `node-exporter` で `9100:9100` をホストへ直接公開しており、同一ホストに複数サービスを共存させる場合はポート競合する。**これは siem 固有ではなく全サービス共通の設計事項**なので、mainおよびAgent Cへの報告事項として記録（複数サービスを1ホストに同居させるなら `ports` を削除して内部ネットワークのみにするか、ホストごとに1サービスの前提か要確認）。

---

## wgdashboard

WGDashboard (WireGuard管理) + Nginx + Node Exporter 構成。`network_mode: host` を使用。

### env キー

| キー | 用途 | vault |
|---|---|---|
| ENVIRONMENT | `dev` または `prod`（nginx設定ファイル切替に使用: `nginx-${ENVIRONMENT}.conf`） | 非秘匿 |
| WGDASHBOARD_USERNAME / WGDASHBOARD_PASSWORD | WGDashboard認証 | PASSWORDのみvault |
| ENABLE_TOTP | OTP 2FA有効化 | (default: true、ただしcompose内では未参照=README記載のみで実装側が見ているかは要確認) |
| TZ | タイムゾーン | (default: Asia/Tokyo) |

### config_files

- `nginx/nginx-dev.conf`
- `nginx/nginx-prod.conf`

（`ENVIRONMENT`の値に応じてどちらか一方が`nginx.conf`としてマウントされる。両方を常に同期しておくこと）

### healthcheck

```bash
docker compose exec -T nginx nginx -t
curl -fsS https://vpn-dev.abe365.org/health   # dev環境
curl -fsS https://vpn.toshi.click/health      # prod環境
```

### ハードコード是正点

- `nginx-prod.conf` の upstream が `server localhost:10086;` 固定。`wgdashboard`サービスは `network_mode: host` のためコンテナ名解決ができず`localhost`参照は意図的な設計（README「既知の問題」にも記載あり）。**是正不要、仕様**。
- `docker-compose.yml` の `node-exporter` だけ `networks: - wireguard-network`（bridge）に接続されている一方、`wgdashboard`本体と`nginx`は`network_mode: host`。node-exporterが他コンテナと通信する想定が無いなら問題ないが、構成の一貫性として要確認点として記録。
- `ENABLE_TOTP` が `.env.example`/READMEに記載されているが `docker-compose.yml` の `environment:` には渡されていない（WGDashboard公式機能としてアプリ内部設定かenv経由か要確認。現状configとして渡されていないため**機能していない可能性**、是正点として報告）。

---

## サービス間の横断的な是正・確認事項（mainへの報告用）

1. **mcp-servers/nginx/nginx.conf の `/metrics` が `localhost:9100` を指していて実体が無い**（同コンテナにnode-exporterは存在しない）。動作確認すると404/502になる可能性が高い。修正候補: `http://node-exporter:9100/metrics` だが、現状compose上で `node-exporter` サービスは `mcp-network` には接続されているのでサービス名解決は可能（ポートを`expose`しているので到達可）。
2. **monitoring の `BASE_URL` デフォルトが `http://localhost` のまま** で nginx の `server_name monitoring.abe365.org` と不整合。デプロイ時は明示的に `https://monitoring.abe365.org` を設定する必要あり。
3. **wgdashboard の `ENABLE_TOTP` がcomposeに渡されていない**（README記載の機能が有効化されない可能性）。
4. **node-exporterの`9100`ポートが dify/llm-proxy/monitoring/siem/wgdashboard 全サービスでホスト直接公開**。複数サービスを同一ホストに共存させる運用なら衝突するため、デプロイ先ホスト構成（1サービス1VM想定か等）の確認が必要。
5. **siemに `container_name: wgdashboard-node-exporter` というコピペミスがあったため本タスクで `siem-node-exporter` に修正済み**（Task #4内で対応）。

---

## 補足: dify のサブモジュール構成について

`service/dify/dify` は外部サブモジュール（langgenius/dify）であり、その配下の `docker/.env`, `docker/docker-compose.yaml` 等は本リポジトリのコミット対象外（サブモジュール側の追跡ファイル）。
Ansible `service_compose` role でdifyをデプロイする場合、通常の「config_filesをrsync/copyする」フローに加えて以下が必要になる点をAgent Bは留意してください:

```bash
git submodule update --init --recursive
cp service/dify/.env.example service/dify/dify/docker/.env
# SECRET_KEY等のvault値を.envへ反映する処理が別途必要
```

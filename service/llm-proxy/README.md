# LLM Proxy Service

LLM API統合プロキシサーバー（LiteLLM）の構成

## 概要

LiteLLMを使用した統一的なLLM APIプロキシサービスです。
複数のLLMプロバイダー（OpenAI, Anthropic, Azure, AWS Bedrock, Google Cloud Vertex AI）を単一のインターフェースで利用できます。

## 対応モデル

### AWS Bedrock
- **Amazon Nova シリーズ**: Nova Micro / Lite / Pro (v1)
- **Amazon Nova 2 シリーズ**: Nova 2 Micro / Lite / Pro (v2)
- **Claude 4.5**: Sonnet / Haiku / Opus
- **Amazon Titan**: Text Express / Embed
- **Cohere**: Command Text

### Google Cloud Vertex AI
- **Claude 4.5**: Sonnet / Haiku / Opus
- **Gemini 2.0**: Flash / Flash Thinking (experimental)
- **Gemini 1.5**: Pro / Flash / Flash-8B

### フォールオーバー構成
- **Claude 4.5 Sonnet**: Bedrock → Vertex AI
- **Claude 4.5 Haiku**: Bedrock → Vertex AI
- **Claude 4.5 Opus**: Bedrock → Vertex AI
- **Claude Code用**: Anthropic Claude → Ollama (qwen3-coder:30b)
- **GitHub Copilot用**: GitHub Copilot → Ollama (qwen3-coder:30b)

### ローカル Ollama モデル（`toshi-gamepc`、RTX 5070 Ti 16GB）

| 別名（`model_name`） | Ollama のモデル | 備考 |
|---|---|---|
| `rtx5070ti-qwen3-coder-30b` | `qwen3-coder:30b` | 主モデル。19GB で VRAM に全量は載らず、一部 CPU に載る見込み |
| `rtx5070ti-gemma4-12b` | `gemma4:12b-it-q4_K_M` | 旧 `rtx5070ti-gemma3-12b` の置き換え |
| `rtx5070ti-qwen3-8b` | `qwen3:8b` | 軽量 |
| `rtx5070ti-deepseek-r1-8b` | `deepseek-r1:8b` | |

- `litellm_params.model` は `ollama_chat/`（`/api/chat`）を使い、各モデルに `model_info.supports_function_calling: true` を付けています（OpenCode の tool call 用）。
- `num_ctx` は渡していません（LiteLLM v1.106.3 での挙動が未確認のため、実機確認後に決めます）。
- `rtx5070ti-qwen3-coder-14b` は Ollama に該当モデルが存在しないため削除しました。

### クレジット優先ルーティング（今回追加）

- `claude-code-sonnet`: 通常はAnthropic Claude APIを使用し、レート制限/課金上限等の失敗時のみ `claude-code-local-fallback` へ切り替え
- `github-copilot-coder`: 通常はGitHub Copilot APIを使用し、上限到達や失敗時のみ `github-copilot-local-fallback` へ切り替え
- ローカルfallbackは `qwen3-coder:30b`（`ollama_chat/`）を使用（19GB のため一部 CPU に載る見込み。実測は未実施）

## DNS設定

- **ドメイン**: llm-proxy.abe365.org
- **IPアドレス**: 192.168.100.54
- **DNS管理**: Cloudflare (cloudflere/records.tf)

## サービス構成

### コンポーネント

- **litellm**: LiteLLM プロキシサーバー
- **db**: PostgreSQL データベース（使用履歴・設定保存）
- **redis**: キャッシュ層（オプション）

## セットアップ手順

### 1. 環境変数の設定

```bash
cp .env.example .env
vim .env  # 必要な環境変数を設定
```

### 2. GCPサービスアカウントの設定（VertexAI使用時）

```bash
# GCPコンソールからサービスアカウントJSONをダウンロード
# 必要な権限: Vertex AI User

# JSONファイルを配置
cp /path/to/service-account.json config/gcp-credentials.json

# .envファイルでパスを指定
echo "GOOGLE_APPLICATION_CREDENTIALS=/app/gcp-credentials.json" >> .env
echo "GCP_PROJECT_ID=your-project-id" >> .env
echo "GCP_REGION=us-central1" >> .env
echo "VERTEX_LOCATION=us-central1" >> .env
```

または、JSON内容を環境変数として設定：

```bash
# Base64エンコード（推奨）
cat config/gcp-credentials.json | base64 -w 0 > /tmp/gcp-creds-base64.txt
echo "GOOGLE_APPLICATION_CREDENTIALS_JSON=$(cat /tmp/gcp-creds-base64.txt)" >> .env
```

### 3. 自己署名証明書の作成（HTTPS）

```bash
mkdir -p nginx/ssl && cd nginx/ssl
openssl req -x509 -nodes -newkey ec -pkeyopt ec_paramgen_curve:secp384r1 -days 825 \
    -keyout ./key.pem \
    -out ./cert.pem \
    -subj "/CN=llm-proxy.abe365.org" \
    -addext "subjectAltName=DNS:llm-proxy.abe365.org"
```

### 4. サービスの起動

```bash
docker-compose up -d
```

### 4. 動作確認

```bash
# ヘルスチェック
curl https://llm-proxy.abe365.org/health

# モデル一覧
curl https://llm-proxy.abe365.org/models \
  -H "Authorization: Bearer ${LITELLM_MASTER_KEY}"
```

## 環境変数

以下の環境変数を`.env`ファイルに設定してください：

| 変数名 | 説明 | 必須 |
|--------|------|------|
| LITELLM_MASTER_KEY | マスターキー（認証用） | ✓ |
| DB_PASSWORD | PostgreSQLパスワード | ✓ |
| REDIS_PASSWORD | Redisパスワード | ✓ |
| AWS_ACCESS_KEY_ID | AWS アクセスキーID（Bedrock使用時） | △ |
| AWS_SECRET_ACCESS_KEY | AWS シークレットアクセスキー（Bedrock使用時） | △ |
| AWS_REGION_NAME | AWSリージョン（Bedrock使用時） | △ |
| GCP_PROJECT_ID | GCPプロジェクトID（VertexAI使用時） | △ |
| GCP_REGION | GCPリージョン（VertexAI使用時） | △ |
| VERTEX_LOCATION | Vertex AIロケーション | △ |
| GOOGLE_APPLICATION_CREDENTIALS | GCPサービスアカウントJSONパス | △ |
| DATABASE_URL | データベース接続URL | × |
| LITELLM_LOG | ログレベル | × |

## API使用例

### OpenAI互換APIとして使用

```python
import openai

client = openai.OpenAI(
    api_key="your-litellm-master-key",
    base_url="https://llm-proxy.abe365.org"
)

response = client.chat.completions.create(
    model="gpt-4",
    messages=[{"role": "user", "content": "Hello!"}]
)
```

### cURLでの使用

```bash
curl https://llm-proxy.abe365.org/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${LITELLM_MASTER_KEY}" \
  -d '{
    "model": "gpt-4",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

### AWS Bedrockモデルの使用

```python
import openai

client = openai.OpenAI(
    api_key="your-litellm-master-key",
    base_url="https://llm-proxy.abe365.org"
)

# Claude 4.5 Sonnet
response = client.chat.completions.create(
    model="bedrock-claude-4.5-sonnet",
    messages=[{"role": "user", "content": "Explain quantum computing"}]
)

# Amazon Nova Pro
response = client.chat.completions.create(
    model="bedrock-nova-pro",
    messages=[{"role": "user", "content": "Write a poem"}]
)

# Amazon Nova 2 Pro（最新世代）
response = client.chat.completions.create(
    model="bedrock-nova2-pro",
    messages=[{"role": "user", "content": "Analyze this data"}]
)
```

### Google Cloud VertexAIモデルの使用

```python
import openai

client = openai.OpenAI(
    api_key="your-litellm-master-key",
    base_url="https://llm-proxy.abe365.org"
)

# Claude 4.5 Sonnet
response = client.chat.completions.create(
    model="vertex-claude-4.5-sonnet",
    messages=[{"role": "user", "content": "Explain machine learning"}]
)

# Gemini 2.0 Flash（最新）
response = client.chat.completions.create(
    model="vertex-gemini-2.0-flash",
    messages=[{"role": "user", "content": "What is quantum computing?"}]
)

# Gemini 2.0 Flash Thinking（推論特化・実験版）
response = client.chat.completions.create(
    model="vertex-gemini-2.0-flash-thinking",
    messages=[{"role": "user", "content": "Solve this complex problem..."}]
)

# Gemini 1.5 Pro（長いコンテキスト対応）
response = client.chat.completions.create(
    model="vertex-gemini-1.5-pro",
    messages=[{"role": "user", "content": "Analyze this document..."}]
)
```

### フォールオーバー機能の使用

Bedrockのクォータ上限時に自動的にVertexAIにフォールオーバーします：

```python
import openai

client = openai.OpenAI(
    api_key="your-litellm-master-key",
    base_url="https://llm-proxy.abe365.org"
)

# 自動フォールオーバー: Bedrock -> Vertex AI
# Bedrockでレート制限エラーが発生すると自動的にVertex AIに切り替わる

# Claude 4.5 Sonnet
response = client.chat.completions.create(
    model="claude-4.5-sonnet-fallback",
    messages=[{"role": "user", "content": "Explain AI safety"}]
)

# Claude 4.5 Haiku（高速版）
response = client.chat.completions.create(
    model="claude-4.5-haiku-fallback",
    messages=[{"role": "user", "content": "Quick summary needed"}]
)

# Claude 4.5 Opus（最高性能版）
response = client.chat.completions.create(
    model="claude-4.5-opus-fallback",
    messages=[{"role": "user", "content": "Write a detailed technical analysis"}]
)
```

## 機能

- **統一API**: 複数のLLM（OpenAI/Anthropic/Azure/AWS Bedrock/Google VertexAI）を単一のOpenAI互換APIで利用
- **自動フォールオーバー**: プロバイダーのクォータ上限時に別プロバイダーへ自動切り替え
- **ロードバランシング**: 複数のエンドポイント間での負荷分散（使用量ベース/レイテンシベース）
- **キャッシング**: Redisによるレスポンスキャッシュでコスト削減
- **使用量追跡**: データベースでの詳細な使用履歴記録
- **認証**: マスターキーによるAPI認証
- **レート制限**: ユーザー/キー単位での利用制限設定

## モニタリング

### ログの確認

```bash
docker-compose logs -f litellm
```
## トラブルシューティング

### プロバイダー接続エラー

```bash
# 設定ファイルの検証
docker-compose exec litellm cat /app/config.yaml

# 環境変数の確認
docker-compose exec litellm env | grep API_KEY
```

### データベース接続エラー

```bash
# データベースの状態確認
docker-compose exec db pg_isready -U llmproxy
```

## LiteLLM 更新と OpenCode 向け運用手順

イメージは `ghcr.io/berriai/litellm:v1.106.3` に固定しています（旧: `main-v1.83.14-stable`）。
以下のコマンド例は一般的な docker compose の慣行に基づくもので、実環境での検証が必要です。

### 1. 反映前の確認

確認が済むまで llm-proxy ホストへ反映しません。

- リリースノートの確認結果（v1.83 から v1.106 の調査の要約。通読できていない範囲があり、**未確認**）
  - 起動時に `prisma migrate deploy` が自動実行されます。イメージを戻しても DB は戻りません。
  - v1.104.0 から、master key が未設定・空・公知の値（`sk-1234` など）だと起動しません。
  - `LITELLM_SALT_KEY` をモデル追加後に変えると、保存済みの認証情報が復号できなくなります。
  - v1.85.0 から `/metrics` は既定で認証が必要です（この構成は `require_auth_for_metrics_endpoint: false` 済み）。
  - v1.104.0 から予算超過は HTTP 422 を返します。
  - v1.106.3 で cosign の署名鍵が変更されました。
  - 反映前に https://docs.litellm.ai/release_notes と GitHub のリリースを確認してください。
- GHCR のタグの実在確認: `docker manifest inspect ghcr.io/berriai/litellm:v1.106.3`（2026-10-25 に実在を確認済み。反映の直前にもう一度確認します）
- `LITELLM_MASTER_KEY` が空や公知の値でないこと。
- `LITELLM_SALT_KEY` を変えないこと。ただし現在の `docker-compose.yml` の `litellm.environment` には `LITELLM_SALT_KEY` がなく（`vars/services/llm-proxy.yml` の `service_compose_env` も同様）、コンテナに渡っていない可能性が高いです。反映前に、稼働中のコンテナで次を実行して現状を確認します（値は画面やログに出さず、設定の有無だけを見ます）。
  - `docker compose exec litellm sh -c 'test -n "$LITELLM_SALT_KEY" && echo set || echo unset'`
  - `set` の場合: その値を更新前に保管し、更新後も同じ値を渡し続けます。
  - `unset` の場合: **今回の更新では `LITELLM_SALT_KEY` を追加しません**（追加すると保存済みの認証情報が復号できなくなる恐れがあります）。v1.106.3 が未設定の salt key をどう扱うか（master key を代わりに使うか）は**未確認**のため、リリースノートと docs（https://docs.litellm.ai/docs/proxy/prod）で確認してから反映します。
- 新しい版のコンテナが `config.yaml` を読み込めること。本番のホスト以外で確認します。難しければ DB のコピーに対して起動し、ログに migration エラーが無いことを確認します。

### 2. バックアップ

```bash
docker compose exec -T db pg_dump -U llmproxy -Fc litellm > <保存先>/litellm_YYYYMMDD.dump
chmod 0600 <保存先>/litellm_YYYYMMDD.dump
```

- 保存先は llm-proxy ホスト上の**リポジトリ外**にし、権限は `0600` とします。コミットしません（仮想キーや認証情報を含みうるため）。
- 別の DB への `pg_restore` による復元確認を、反映前に一度行います。行わない場合は、その理由を記録します。
- `config.yaml`、`LITELLM_MASTER_KEY`、`LITELLM_SALT_KEY` も更新前の値を保管します。

### 3. 反映の手順

1. 変更が infra の `develop` ブランチに取り込み済みであること（ホストの `~/infra` checkout を `git.yml` が更新します）。
2. `-l llm-proxy.abe365.org` で対象を絞ります（`home_servers` は 5 台あり、絞らないと他のホストに流れます）。
3. `--check -D` で差分を確認します。
4. 依頼者の承認を得ます。
5. 本適用します。

### 4. 反映後の確認

- `/health/liveliness`
- `/health/readiness`（`db: connected` であること）
- `/v1/models`（仮想キーで。定義したモデルがすべて出ること）
- Ollama のモデル 1 つへの問い合わせ
- `--detailed_debug` のログに migration エラーが無いこと

### 5. 戻し方

旧イメージ（`main-v1.83.14-stable`）と、更新前のダンプの `pg_restore` を**セットで**戻します。DB が進んでいる場合、イメージだけ戻すのは非推奨です。config.yaml、salt key、master key も更新前の値に戻します。

### 6. OpenCode 用の仮想キーの発行と失効

- 発行: `POST /key/generate`（master key で認証）。`models` で許可モデルを `rtx5070ti-*` に限定し、`max_budget` と `budget_duration`、`duration` を指定します。管理 UI の Virtual Keys ページからも発行できます。
- 失効: 管理 UI、または API（`/key/delete`）。リクエスト形式は**未確認**のため、`/docs` の OpenAPI で確認してください。
- 予算を超えると 422 が返ります。
- 発行したキーは平文でコミットしません。ansible_for_wsl の Vault 暗号化ファイルに入れます。

### 7. モデルの取得

`toshi-gamepc` で次を実行します。

```bash
ollama pull qwen3-coder:30b
ollama pull gemma4:12b-it-q4_K_M
ollama pull qwen3:8b
ollama pull deepseek-r1:8b
```

**文脈長（反映前の必須確認）**: OpenCode の設定（`ansible_for_wsl/develop.yml`）は各モデルに `context: 32768` を宣言しています。一方、この構成の LiteLLM は `num_ctx` を Ollama に渡しておらず（v1.106.3 での挙動が未確認のため）、Ollama の既定の文脈長は小さい場合があります。その場合、プロンプトが黙って切り詰められ、tool call の失敗や空応答として現れます。次のどちらかを、実測の前に行います。

- `toshi-gamepc` の Ollama の文脈長を 32768 以上にする（例: サービスの環境変数 `OLLAMA_CONTEXT_LENGTH=32768`、またはモデルごとの Modelfile で `PARAMETER num_ctx 32768`）。設定後、`ollama show <モデル>` や `ollama ps` で反映を確認します。16GB の VRAM では、文脈長を増やすと KV キャッシュ分の使用量も増えるため、VRAM の実測と合わせて決めます。
- 設定できない、または VRAM が足りない場合は、`ansible_for_wsl/develop.yml` の `context` を、Ollama 側の実際の文脈長以下に下げます。

VRAM（16GB）に載らない 17GB 超のモデル（`qwen3-coder:30b` は 19GB）は、一部 CPU に載る見込みです。`gemma4:12b-it-q4_K_M` のタグの実在と、`deepseek-r1:8b`・`gemma4` が tools に対応していることは**未確認**です。`ollama pull` のあとに `ollama show` で確認し、対応していないモデルは `config.yaml` の `model_info.supports_function_calling` を外すか、一覧から外します。tool call の成功率と VRAM 使用量の実測は依頼者が行い、結果に応じてモデル定義を差し替えます。

### 8. OpenCode（WSL）側との一致

OpenCode 側のモデル一覧（ansible_for_wsl の `develop.yml`）と、`config.yaml` の `rtx5070ti-*` の別名は、過不足なく一致させる必要があります。

## セキュリティ

- LITELLM_MASTER_KEYは強固なランダム文字列を使用
- LLMプロバイダーのAPIキーは環境変数で管理
- 本番環境ではHTTPSを使用
- APIキーの定期的なローテーション

## 参考リンク

- [LiteLLM Documentation](https://docs.litellm.ai/)
- [LiteLLM GitHub](https://github.com/BerriAI/litellm)

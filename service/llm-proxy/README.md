# LLM Proxy Service

LLM API統合プロキシサーバー（LiteLLM）の構成

## 概要

LiteLLMを使用した統一的なLLM APIプロキシサービスです。
複数のLLMプロバイダー（OpenAI, Anthropic, Azure, など）を単一のインターフェースで利用できます。

## DNS設定

- **ドメイン**: llm-proxy.abe365.org
- **IPアドレス**: 192.168.100.54
- **DNS管理**: Cloudflare (cloudflere/records.tf)

## サービス構成

### コンポーネント

- **litellm**: LiteLLM プロキシサーバー
- **db**: PostgreSQL データベース（使用履歴・設定保存）
- **redis**: キャッシュ層（オプション）
- **prometheus**: メトリクス収集（オプション）

## セットアップ手順

### 1. 環境変数の設定

```bash
cp .env.example .env
vim .env  # 必要な環境変数を設定
```

### 2. LiteLLM設定ファイルの作成

```bash
mkdir -p config
cp config/config.yaml.example config/config.yaml
vim config/config.yaml  # LLMプロバイダー設定
```

### 3. GCPサービスアカウントの設定（VertexAI使用時）

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

### 4. サービスの起動

```bash
docker-compose up -d
```

### 5. 動作確認

```bash
# ヘルスチェック
curl http://llm-proxy.abe365.org:4000/health

# モデル一覧
curl http://llm-proxy.abe365.org:4000/models \
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

## 設定例

### config/config.yaml

```yaml
model_list:
  - model_name: gpt-4
    litellm_params:
      model: azure/gpt-4
      api_base: https://your-endpoint.openai.azure.com
      api_key: os.environ/AZURE_API_KEY
      api_version: "2023-05-15"
  
  - model_name: claude-3
    litellm_params:
      model: anthropic/claude-3-opus-20240229
      api_key: os.environ/ANTHROPIC_API_KEY
  
  - model_name: bedrock-claude
    litellm_params:
      model: bedrock/anthropic.claude-3-sonnet-20240229-v1:0
      aws_access_key_id: os.environ/AWS_ACCESS_KEY_ID
      aws_secret_access_key: os.environ/AWS_SECRET_ACCESS_KEY
      aws_region_name: os.environ/AWS_REGION_NAME
  
  - model_name: bedrock-titan
    litellm_params:
      model: bedrock/amazon.titan-text-express-v1
      aws_access_key_id: os.environ/AWS_ACCESS_KEY_ID
      aws_secret_access_key: os.environ/AWS_SECRET_ACCESS_KEY
      aws_region_name: os.environ/AWS_REGION_NAME

litellm_settings:
  drop_params: true
  set_verbose: false
  cache: true
  cache_params:
    type: redis
    host: redis
    port: 6379
    password: os.environ/REDIS_PASSWORD
```

## API使用例

### OpenAI互換APIとして使用

```python
import openai

client = openai.OpenAI(
    api_key="your-litellm-master-key",
    base_url="http://llm-proxy.abe365.org:4000"
)

response = client.chat.completions.create(
    model="gpt-4",
    messages=[{"role": "user", "content": "Hello!"}]
)
```

### cURLでの使用

```bash
curl http://llm-proxy.abe365.org:4000/v1/chat/completions \
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
    base_url="http://llm-proxy.abe365.org:4000"
)

# Bedrock Claude
response = client.chat.completions.create(
    model="bedrock-claude",
    messages=[{"role": "user", "content": "Explain quantum computing"}]
)

# Bedrock Titan
response = client.chat.completions.create(
    model="bedrock-titan",
    messages=[{"role": "user", "content": "Write a poem"}]
)
```

### Google Cloud VertexAIモデルの使用

```python
import openai

client = openai.OpenAI(
    api_key="your-litellm-master-key",
    base_url="http://llm-proxy.abe365.org:4000"
)

# Vertex AI Claude
response = client.chat.completions.create(
    model="vertex-claude-3-sonnet",
    messages=[{"role": "user", "content": "Explain machine learning"}]
)

# Vertex AI Gemini Pro
response = client.chat.completions.create(
    model="vertex-gemini-pro",
    messages=[{"role": "user", "content": "What is quantum computing?"}]
)

# Vertex AI Gemini 1.5 Pro (長いコンテキスト対応)
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
    base_url="http://llm-proxy.abe365.org:4000"
)

# 自動フォールオーバー: Bedrock -> Vertex AI
# Bedrockでレート制限エラーが発生すると自動的にVertex AIに切り替わる
response = client.chat.completions.create(
    model="claude-3-sonnet-fallback",
    messages=[{"role": "user", "content": "Explain AI safety"}]
)

# Opusモデルも同様
response = client.chat.completions.create(
    model="claude-3-opus-fallback",
    messages=[{"role": "user", "content": "Write a technical analysis"}]
)
```

## 機能

- **統一API**: 複数のLLM（OpenAI/Anthropic/Azure/AWS Bedrock/Google VertexAI）を単一のOpenAI互換APIで利用
- **自動フォールオーバー**: プロバイダーのクォータ上限時に別プロバイダーへ自動切り替え
- **ロードバランシング**: 複数のエンドポイント間での負荷分散（使用量ベース/レイテンシベース）
- **キャッシング**: Redisによるレスポンスキャッシュでコスト削減
- **使用量追跡**: データベースでの詳細な使用履歴記録
- **認証**: マスターキーによるAPI認証
- **メトリクス**: Prometheusでのメトリクス収集・可視化
- **レート制限**: ユーザー/キー単位での利用制限設定

## モニタリング

### ログの確認

```bash
docker-compose logs -f litellm
```

### Prometheusメトリクス

- URL: http://llm-proxy.abe365.org:9090
- メトリクスエンドポイント: http://llm-proxy.abe365.org:4000/metrics

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

## セキュリティ

- LITELLM_MASTER_KEYは強固なランダム文字列を使用
- LLMプロバイダーのAPIキーは環境変数で管理
- 本番環境ではHTTPSを使用
- APIキーの定期的なローテーション

## 参考リンク

- [LiteLLM Documentation](https://docs.litellm.ai/)
- [LiteLLM GitHub](https://github.com/BerriAI/litellm)

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

## セキュリティ

- LITELLM_MASTER_KEYは強固なランダム文字列を使用
- LLMプロバイダーのAPIキーは環境変数で管理
- 本番環境ではHTTPSを使用
- APIキーの定期的なローテーション

## 参考リンク

- [LiteLLM Documentation](https://docs.litellm.ai/)
- [LiteLLM GitHub](https://github.com/BerriAI/litellm)

# AI Testing and Experimentation Environment

AI/ML実験・検証環境の構成

## 概要

ローカルLLM実行、モデルトレーニング、ベクトルデータベース、MLOpsツールなど、
AI/ML開発に必要な各種サービスを統合した実験環境です。

## DNS設定

- **ドメイン**: ai-test.abe365.org
- **IPアドレス**: 192.168.100.56
- **DNS管理**: Cloudflare (cloudflere/records.tf)

## サービス構成

### コンポーネント

| サービス | ポート | 説明 |
|---------|--------|------|
| ollama | 11434 | ローカルLLM実行環境 |
| open-webui | 3000 | Ollama用WebUI |
| langserve | 8000 | LangChain API サーバー |
| mlflow | 5000 | モデル追跡・管理 |
| qdrant | 6333 | ベクトルデータベース |
| text-generation-webui | 7860 | テキスト生成UI |
| ray-head | 8265 | 分散ML処理 |
| postgres | - | MLflow用DB |

## 前提条件

### NVIDIA GPU使用時

```bash
# NVIDIA Docker Runtimeのインストール
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update
sudo apt-get install -y nvidia-docker2
sudo systemctl restart docker

# 確認
docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi
```

### CPU専用環境

`docker-compose.yml`からGPU関連の設定を削除：

```yaml
# この部分を削除
deploy:
  resources:
    reservations:
      devices:
        - driver: nvidia
          count: all
          capabilities: [gpu]
```

## セットアップ手順

### 1. 環境変数の設定

```bash
cp .env.example .env
vim .env  # 必要な環境変数を設定
```

### 2. LangServe用Dockerfileの作成

```bash
mkdir -p langserve
cat > langserve/Dockerfile << 'EOF'
FROM python:3.11-slim
WORKDIR /app
RUN pip install langchain langserve fastapi uvicorn
COPY . /app
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF
```

### 3. 自己署名証明書の作成（HTTPS）

```bash
mkdir -p nginx/ssl && cd nginx/ssl
openssl req -x509 -nodes -newkey ec -pkeyopt ec_paramgen_curve:secp384r1 -days 825 \
  -keyout ./key.pem \
  -out ./cert.pem \
  -subj "/CN=ai-test.abe365.org" \
  -addext "subjectAltName=DNS:ai-test.abe365.org"
```

### 4. サービスの起動

```bash
# 全サービス起動
docker-compose up -d

# GPU不要なサービスのみ
docker-compose up -d open-webui mlflow qdrant postgres
```

### 4. Ollamaモデルのダウンロード

```bash
# コンテナ内でモデルダウンロード
docker-compose exec ollama ollama pull llama2
docker-compose exec ollama ollama pull mistral
docker-compose exec ollama ollama pull codellama
```

## アクセス方法

| サービス | URL | 用途 |
|---------|-----|------|
| Open WebUI | https://ai-test.abe365.org/ | LLMチャット |
| MLflow | https://ai-test.abe365.org/mlflow/ | モデル管理 |
| Qdrant | https://ai-test.abe365.org/qdrant/ | ベクトルDB管理 |
| Text Gen WebUI | https://ai-test.abe365.org/text-gen/ | テキスト生成 |
| Ray Dashboard | https://ai-test.abe365.org/ray/ | 分散処理管理 |

## 環境変数

| 変数名 | 説明 | 必須 |
|--------|------|------|
| WEBUI_SECRET_KEY | WebUIシークレットキー | ✓ |
| POSTGRES_PASSWORD | PostgreSQLパスワード | ✓ |
| OPENAI_API_KEY | OpenAI APIキー | × |
| ANTHROPIC_API_KEY | Anthropic APIキー | × |

## 使用例

### Ollamaでのローカル推論

```python
import requests

response = requests.post(
    "http://ai-test.abe365.org:11434/api/generate",
    json={
        "model": "llama2",
        "prompt": "Why is the sky blue?",
        "stream": False
    }
)
print(response.json()["response"])
```

### Qdrantでのベクトル検索

```python
from qdrant_client import QdrantClient

client = QdrantClient(url="https://ai-test.abe365.org/qdrant")

# コレクション作成
client.create_collection(
    collection_name="test_collection",
    vectors_config={"size": 384, "distance": "Cosine"}
)

# ベクトル追加
client.upsert(
    collection_name="test_collection",
    points=[
        {
            "id": 1,
            "vector": [0.1] * 384,
            "payload": {"text": "Sample text"}
        }
    ]
)
```

### MLflowでの実験記録

```python
import mlflow

mlflow.set_tracking_uri("https://ai-test.abe365.org/mlflow/")

with mlflow.start_run():
    mlflow.log_param("learning_rate", 0.001)
    mlflow.log_metric("accuracy", 0.95)
    mlflow.log_artifact("model.pkl")
```

## データ永続化

- `./data/ollama/`: Ollamaモデル
- `./data/mlflow/`: MLflow成果物
- `./data/postgres/`: データベース
- `./data/qdrant/`: ベクトルデータ
- `./data/text-generation-webui/`: 生成モデル

## トラブルシューティング

### GPU認識されない

```bash
# NVIDIAドライバー確認
nvidia-smi

# Docker GPU設定確認
docker run --rm --gpus all nvidia/cuda:11.8.0-base-ubuntu22.04 nvidia-smi
```

### Ollamaモデルダウンロードが遅い

```bash
# ミラーサイト使用（環境変数）
OLLAMA_HOST=http://mirror.example.com docker-compose up -d
```

### メモリ不足

```yaml
# docker-compose.ymlでメモリ制限を調整
services:
  ollama:
    deploy:
      resources:
        limits:
          memory: 16G
```

## ベンチマーク

### LLM推論速度テスト

```bash
# Ollamaベンチマーク
docker-compose exec ollama ollama run llama2 "Generate a 100-word essay"
```

### ベクトル検索性能

```python
import time
from qdrant_client import QdrantClient

client = QdrantClient(url="https://ai-test.abe365.org/qdrant")

start = time.time()
results = client.search(
    collection_name="test_collection",
    query_vector=[0.1] * 384,
    limit=10
)
print(f"Search time: {time.time() - start:.4f}s")
```

## セキュリティ

- WebUIには認証を設定
- 外部公開する場合はVPN経由推奨
- APIキーは環境変数で管理
- 定期的なデータバックアップ

## パフォーマンスチューニング

### GPU最適化

```yaml
environment:
  - CUDA_VISIBLE_DEVICES=0,1  # 使用GPU指定
  - OLLAMA_NUM_GPU=2          # GPU数
```

### メモリ設定

```yaml
environment:
  - OLLAMA_MAX_LOADED_MODELS=2  # 同時ロードモデル数
```

## 参考リンク

- [Ollama Documentation](https://ollama.ai/docs)
- [Open WebUI](https://github.com/open-webui/open-webui)
- [MLflow Documentation](https://mlflow.org/docs/latest/index.html)
- [Qdrant Documentation](https://qdrant.tech/documentation/)
- [LangChain Documentation](https://python.langchain.com/)
- [Ray Documentation](https://docs.ray.io/)

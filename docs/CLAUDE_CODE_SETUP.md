# Claude Code セルフホストランナー統合ガイド

## 概要

このドキュメントでは、GitHub Actions のセルフホストランナー上で Claude Code を動作させ、ローカルネットワーク内の LLM Proxy（LiteLLM）を経由して AWS Bedrock または Google Vertex AI の Claude モデルを利用する方法について説明します。

## アーキテクチャ

```
GitHub Actions (Self-hosted Runner)
    ↓
LLM Proxy (llm-proxy.abe365.org:80)
    ↓
AWS Bedrock / Google Vertex AI
    ↓
Claude Models (claude-3-sonnet, claude-3-opus)
```

### 主要コンポーネント

1. **GitHub Actions セルフホストランナー**
   - ローカルネットワーク内で動作
   - 外部への直接アクセスを制限

2. **LLM Proxy (LiteLLM)**
   - エンドポイント: `http://llm-proxy.abe365.org/v1`
   - OpenAI互換APIを提供
   - AWS Bedrock → Google Vertex AI の自動フォールオーバー機能

3. **クラウドLLMプロバイダー**
   - AWS Bedrock: 高速・低コスト
   - Google Vertex AI: フォールバック用

## セキュリティとガバナンス

### セキュリティ上のメリット

- **外部アクセス制限**: セルフホストランナーから外部LLM APIへの直接接続を防止
- **集中管理**: LLM Proxyで全てのAPIキーを管理
- **監査ログ**: すべてのLLM呼び出しをLLM Proxyで記録
- **レート制限**: LLM Proxyでの使用量制御
- **認証**: `LITELLM_MASTER_KEY`による統一認証

### ネットワーク構成

```
Self-hosted Runner (192.168.100.x)
    ↓ Local Network Only
LLM Proxy (192.168.100.54)
    ↓ Internet Access Required
AWS Bedrock / GCP Vertex AI
```

## セットアップ手順

### 1. LLM Proxy の準備

LLM Proxy は既に `service/llm-proxy/` で構成済みです。

#### 必要な設定確認

```bash
cd service/llm-proxy

# .envファイルの確認
cat .env

# 必要な環境変数:
# - LITELLM_MASTER_KEY: GitHub Actions Secretに設定する
# - AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY: Bedrock用
# - GCP_PROJECT_ID / GOOGLE_APPLICATION_CREDENTIALS: Vertex AI用
```

#### LLM Proxy 起動確認

```bash
# サービス起動
docker-compose up -d

# ヘルスチェック
curl http://llm-proxy.abe365.org/health

# モデル一覧確認
curl http://llm-proxy.abe365.org/models \
  -H "Authorization: Bearer ${LITELLM_MASTER_KEY}"
```

### 2. GitHub Secrets の設定

リポジトリまたは Organization レベルで以下の Secret を設定してください：

| Secret名 | 説明 | 取得方法 |
|----------|------|---------|
| `LITELLM_MASTER_KEY` | LLM Proxyのマスターキー | `service/llm-proxy/.env` の `LITELLM_MASTER_KEY` |

設定手順：
```
1. GitHub リポジトリの Settings > Secrets and variables > Actions
2. "New repository secret" をクリック
3. Name: LITELLM_MASTER_KEY
4. Value: (LLM Proxyの.envファイルから取得)
5. "Add secret" をクリック
```

### 3. セルフホストランナーの設定

#### 既存のセルフホストランナーへのセットアップ

Ansible playbook を使用してセルフホストランナーに必要なパッケージをインストールします：

```bash
cd ansible

# Claude Code用の依存関係をインストール
ansible-playbook -i hosts_all.yml claude_code_setup.yml \
  --limit="monitoring.abe365.org" \
  --vault-password-file ~/.ssh/.ansible_vault_pass
```

#### 手動セットアップ（Ansible未使用の場合）

```bash
# ランナーマシンにSSH接続
ssh user@runner-host

# Python 3.11以上のインストール
sudo apt update
sudo apt install -y python3.11 python3-pip

# 必要なPythonパッケージ
pip3 install openai anthropic requests
```

### 4. GitHub Actions Workflow の作成

`.github/workflows/claude-code.yml` が作成済みです。

#### 使用方法

##### 手動実行

```
1. GitHub リポジトリの Actions タブ
2. "Claude Code Integration" を選択
3. "Run workflow" をクリック
4. タスクの説明を入力（例：「このコードのセキュリティを確認して」）
5. "Run workflow" をクリック
```

##### Pull Requestで自動実行

```
1. Pull Request を作成
2. ラベル "claude-code" を追加
3. Workflow が自動実行される
4. Claude の分析結果がコメントとして追加される
```

### 5. 動作確認

#### テスト実行

```bash
# ローカルからLLM Proxyをテスト
curl -X POST http://llm-proxy.abe365.org/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${LITELLM_MASTER_KEY}" \
  -d '{
    "model": "claude-3-sonnet-fallback",
    "messages": [
      {"role": "user", "content": "Hello! Please respond in Japanese."}
    ],
    "max_tokens": 100
  }'
```

期待される応答：
```json
{
  "id": "chatcmpl-...",
  "object": "chat.completion",
  "created": 1234567890,
  "model": "claude-3-sonnet-fallback",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "こんにちは！..."
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 10,
    "completion_tokens": 20,
    "total_tokens": 30
  }
}
```

## 利用可能なモデル

LLM Proxy経由で利用可能な Claude モデル：

| モデル名 | プロバイダー | 説明 |
|---------|------------|------|
| `bedrock-claude-3-opus` | AWS Bedrock | 最高性能（高コスト） |
| `bedrock-claude-3-sonnet` | AWS Bedrock | バランス型（推奨） |
| `bedrock-claude-3-haiku` | AWS Bedrock | 高速・低コスト |
| `vertex-claude-3-opus` | GCP Vertex AI | フォールバック用 |
| `vertex-claude-3-sonnet` | GCP Vertex AI | フォールバック用 |
| `claude-3-sonnet-fallback` | Bedrock→Vertex | 自動フォールオーバー（推奨） |
| `claude-3-opus-fallback` | Bedrock→Vertex | 自動フォールオーバー |

### 推奨モデル

- **通常使用**: `claude-3-sonnet-fallback`
  - Bedrockでクォータ制限時に自動的にVertex AIへ切り替え
  - 可用性が高い

- **高性能が必要**: `claude-3-opus-fallback`
  - より高度な推論能力
  - コストは高め

## Workflow の詳細

### 環境変数

```yaml
env:
  # LLM Proxy設定
  OPENAI_API_BASE: http://llm-proxy.abe365.org/v1
  OPENAI_API_KEY: ${{ secrets.LITELLM_MASTER_KEY }}
  # 使用モデル
  CLAUDE_MODEL: claude-3-sonnet-fallback
  # 日本語応答
  LANG: ja_JP.UTF-8
```

### カスタマイズ例

#### タイムアウトの変更

```yaml
jobs:
  claude-code-task:
    timeout-minutes: 60  # デフォルト30分から変更
```

#### 使用するモデルの変更

```yaml
env:
  CLAUDE_MODEL: claude-3-opus-fallback  # より高性能なモデル
```

#### プロンプトのカスタマイズ

Python スクリプト内の `prompt` 変数を編集：

```python
prompt = f"""あなたはインフラストラクチャコードのエキスパートです。
以下の観点でレビューしてください：
1. セキュリティ
2. パフォーマンス
3. 保守性

{task}
"""
```

## トラブルシューティング

### LLM Proxy接続エラー

```bash
# LLM Proxyのステータス確認
docker-compose -f service/llm-proxy/docker-compose.yml ps

# ログ確認
docker-compose -f service/llm-proxy/docker-compose.yml logs -f litellm
```

**原因と対処法：**

1. **LLM Proxyが起動していない**
   ```bash
   docker-compose -f service/llm-proxy/docker-compose.yml up -d
   ```

2. **ネットワーク接続の問題**
   ```bash
   # ランナーからLLM Proxyへの接続確認
   curl http://llm-proxy.abe365.org/health
   ```

3. **認証エラー（401 Unauthorized）**
   - GitHub Secrets の `LITELLM_MASTER_KEY` が正しいか確認
   - LLM Proxy の `.env` ファイルと一致しているか確認

### モデルエラー

**エラー**: `Model 'claude-3-sonnet-fallback' not found`

**対処法**:
```bash
# LLM Proxyの設定確認
cat service/llm-proxy/config/config.yaml

# モデルリスト確認
curl http://llm-proxy.abe365.org/models \
  -H "Authorization: Bearer ${LITELLM_MASTER_KEY}"
```

### AWS Bedrock / GCP Vertex AI エラー

**エラー**: `AWS credentials not configured`

**対処法**:
```bash
# LLM Proxyの環境変数確認
docker-compose -f service/llm-proxy/docker-compose.yml exec litellm env | grep AWS

# 必要に応じて.envファイルを更新
vim service/llm-proxy/.env

# 再起動
docker-compose -f service/llm-proxy/docker-compose.yml restart litellm
```

## モニタリングと監査

### 使用量の確認

```bash
# Prometheusメトリクス
curl http://llm-proxy.abe365.org:9090/metrics

# LiteLLMダッシュボード（設定済みの場合）
# http://llm-proxy.abe365.org/ui
```

### ログの確認

```bash
# LiteLLMログ
docker-compose -f service/llm-proxy/docker-compose.yml logs -f litellm

# データベースで使用履歴確認
docker-compose -f service/llm-proxy/docker-compose.yml exec db psql -U llmproxy -d litellm
```

```sql
-- 最近のリクエスト
SELECT * FROM litellm_request_log ORDER BY created_at DESC LIMIT 10;

-- モデル別使用統計
SELECT model, COUNT(*), SUM(total_tokens) 
FROM litellm_request_log 
GROUP BY model;
```

## セキュリティベストプラクティス

1. **APIキーの定期ローテーション**
   ```bash
   # 新しいマスターキーを生成
   openssl rand -hex 32
   
   # .envファイルを更新
   # GitHub Secretsも更新
   ```

2. **レート制限の設定**
   - `service/llm-proxy/config/config.yaml` で設定
   - ユーザー/キー単位での制限

3. **ネットワーク分離**
   - セルフホストランナーはLLM Proxyのみにアクセス可能
   - LLM Proxyのみが外部LLM APIにアクセス

4. **監査ログの保持**
   - すべてのLLM呼び出しをデータベースに記録
   - 定期的なログレビュー

## 今後の拡張

### 計画中の機能

- [ ] Claude Code CLI ツールの統合
- [ ] VS Code 拡張機能のセルフホスト対応
- [ ] より詳細な使用量レポート
- [ ] コスト最適化の自動化
- [ ] 複数のセルフホストランナー間での負荷分散

### 参考リンク

- [LiteLLM Documentation](https://docs.litellm.ai/)
- [AWS Bedrock Claude Models](https://docs.aws.amazon.com/bedrock/latest/userguide/what-is-bedrock.html)
- [Google Vertex AI Anthropic](https://cloud.google.com/vertex-ai/docs/generative-ai/model-reference/claude)
- [GitHub Actions Self-hosted Runners](https://docs.github.com/en/actions/hosting-your-own-runners)

## サポート

問題が発生した場合は、以下を確認してください：

1. LLM Proxyのログ
2. GitHub Actions のワークフローログ
3. セルフホストランナーのログ

それでも解決しない場合は、Issue を作成してください。

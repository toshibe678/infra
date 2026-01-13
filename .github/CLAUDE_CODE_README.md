# Claude Code 統合 README

## 概要

このディレクトリには、GitHub Actions のセルフホストランナーで Claude Code を LLM Proxy 経由で利用するための設定ファイルが含まれています。

## ファイル一覧

```
.
├── .github/
│   └── workflows/
│       └── claude-code.yml          # Claude Code workflow定義
├── ansible/
│   └── claude_code_setup.yml        # セルフホストランナーセットアップ用Playbook
└── docs/
    └── CLAUDE_CODE_SETUP.md         # 詳細なセットアップガイド
```

## クイックスタート

### 1. LLM Proxy が稼働していることを確認

```bash
curl http://llm-proxy.abe365.org/health
# 期待: {"status": "healthy"}
```

### 2. セルフホストランナーをセットアップ

```bash
cd ansible
ansible-playbook -i hosts_all.yml claude_code_setup.yml \
  --limit="monitoring.abe365.org" \
  --vault-password-file ~/.ssh/.ansible_vault_pass
```

### 3. GitHub Secrets を設定

1. GitHub リポジトリの **Settings** → **Secrets and variables** → **Actions**
2. **New repository secret** をクリック
3. 以下を追加：
   - Name: `LITELLM_MASTER_KEY`
   - Value: (service/llm-proxy/.env から取得)

### 4. Workflow を実行

#### 手動実行

1. **Actions** タブを開く
2. **Claude Code Integration** を選択
3. **Run workflow** をクリック
4. タスクを入力（例：「このインフラコードをレビューして」）

#### Pull Request で自動実行

1. Pull Request を作成
2. ラベル `claude-code` を追加
3. 自動的に Claude がコードをレビュー

## 利用可能なモデル

| モデル名 | 特徴 | 推奨用途 |
|---------|------|---------|
| `claude-3-sonnet-fallback` | バランス型、自動フォールオーバー | 通常使用（推奨） |
| `claude-3-opus-fallback` | 高性能、自動フォールオーバー | 複雑なタスク |
| `bedrock-claude-3-haiku` | 高速・低コスト | 簡単なタスク |

## アーキテクチャ

```
┌─────────────────────────────────────┐
│  GitHub Actions (Self-hosted)       │
│  - Python 3.11                      │
│  - openai, anthropic packages       │
└──────────────┬──────────────────────┘
               │ HTTP (Local Network)
               ▼
┌─────────────────────────────────────┐
│  LLM Proxy (llm-proxy.abe365.org)   │
│  - LiteLLM                          │
│  - OpenAI互換API                    │
│  - 認証・ログ・フォールオーバー      │
└──────────────┬──────────────────────┘
               │ HTTPS (Internet)
        ┌──────┴──────┐
        ▼             ▼
┌──────────────┐ ┌──────────────┐
│ AWS Bedrock  │ │ GCP Vertex   │
│ (Primary)    │ │ (Fallback)   │
└──────────────┘ └──────────────┘
```

## セキュリティ

### 実装済みのセキュリティ対策

- ✅ セルフホストランナーから外部LLM APIへの直接接続なし
- ✅ LLM Proxy での集中認証とAPIキー管理
- ✅ すべてのLLM呼び出しのログ記録
- ✅ レート制限とコスト管理
- ✅ ローカルネットワーク内での通信

### ベストプラクティス

1. **API キーの定期ローテーション**
   ```bash
   # 新しいキーを生成
   openssl rand -hex 32
   # LLM ProxyとGitHub Secretsの両方を更新
   ```

2. **使用量の定期監視**
   ```bash
   # Prometheusメトリクスで確認
   curl http://llm-proxy.abe365.org:9090/metrics | grep litellm
   ```

3. **最小権限の原則**
   - Workflow に必要な最小限の permissions のみ付与
   - API キーは Organization Secrets に保存

## トラブルシューティング

### よくある問題と解決策

#### 1. "401 Unauthorized" エラー

**原因**: API キーが正しくない

**解決策**:
```bash
# LLM Proxyの.envファイルを確認
cat service/llm-proxy/.env | grep LITELLM_MASTER_KEY

# GitHub Secretsと一致しているか確認
```

#### 2. "Connection refused" エラー

**原因**: LLM Proxy が起動していない、またはネットワーク問題

**解決策**:
```bash
# LLM Proxyの起動確認
docker-compose -f service/llm-proxy/docker-compose.yml ps

# 起動していない場合
docker-compose -f service/llm-proxy/docker-compose.yml up -d

# ランナーから接続確認
curl http://llm-proxy.abe365.org/health
```

#### 3. "Model not found" エラー

**原因**: 指定したモデルが LLM Proxy で設定されていない

**解決策**:
```bash
# 利用可能なモデルを確認
curl http://llm-proxy.abe365.org/models \
  -H "Authorization: Bearer ${LITELLM_MASTER_KEY}"

# 設定ファイルを確認
cat service/llm-proxy/config/config.yaml
```

#### 4. Python パッケージが見つからない

**原因**: セルフホストランナーに必要なパッケージがインストールされていない

**解決策**:
```bash
# Ansible playbookを再実行
cd ansible
ansible-playbook -i hosts_all.yml claude_code_setup.yml \
  --limit="your-runner-host"
```

## カスタマイズ

### Workflow のカスタマイズ

#### タイムアウトの変更

`.github/workflows/claude-code.yml`:
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

Python スクリプト部分を編集：
```python
prompt = f"""あなたは{専門分野}のエキスパートです。
以下の観点で分析してください：
1. {観点1}
2. {観点2}

{task}
"""
```

### Ansible Playbook のカスタマイズ

追加のホストを対象にする場合、`claude_code_setup.yml` の hosts セクションを編集：

```yaml
hosts:
  - monitoring.abe365.org
  - develop.abe365.org
  - your-new-host.abe365.org  # 追加
```

## モニタリング

### 使用量の確認

```bash
# Prometheusでメトリクスを確認
curl http://llm-proxy.abe365.org:9090/metrics | grep litellm_

# データベースで詳細な使用履歴を確認
docker-compose -f service/llm-proxy/docker-compose.yml exec db \
  psql -U llmproxy -d litellm -c \
  "SELECT model, COUNT(*), SUM(total_tokens) FROM litellm_request_log GROUP BY model;"
```

### ログの確認

```bash
# LLM Proxyのログ
docker-compose -f service/llm-proxy/docker-compose.yml logs -f litellm

# GitHub Actions のログ
# Actionsタブ → 該当のworkflow run → ログを確認
```

## 参考資料

- [詳細セットアップガイド](docs/CLAUDE_CODE_SETUP.md)
- [LLM Proxy README](service/llm-proxy/README.md)
- [LiteLLM Documentation](https://docs.litellm.ai/)
- [GitHub Actions Documentation](https://docs.github.com/actions)

## サポート

問題や質問がある場合は、以下を添えて Issue を作成してください：

1. エラーメッセージの全文
2. 実行していた操作
3. 関連するログ（機密情報を除く）
4. 環境情報（OS、Python バージョンなど）

---

**作成日**: 2026-01-08  
**最終更新**: 2026-01-08  
**バージョン**: 1.0.0

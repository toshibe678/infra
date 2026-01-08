# Claude Code 統合クイックリファレンス

## 🚀 すぐに使い始める

### 前提条件チェック

```bash
# 1. LLM Proxyの稼働確認
curl http://llm-proxy.abe365.org/health
# ✓ 期待: {"status": "healthy"}

# 2. セルフホストランナーの確認
# GitHub > Settings > Actions > Runners
# ✓ 稼働中のランナーが表示されること
```

### 初回セットアップ（5分）

```bash
# Step 1: セルフホストランナーに依存関係をインストール
cd ansible
ansible-playbook -i hosts_all.yml claude_code_setup.yml \
  --limit="monitoring.abe365.org"

# Step 2: GitHub Secretsを設定
# GitHub > Settings > Secrets and variables > Actions
# - Name: LITELLM_MASTER_KEY
# - Value: (service/llm-proxy/.envから取得)

# Step 3: テスト実行
LITELLM_MASTER_KEY=your-key python3 scripts/test_claude_integration.py
```

## 📋 使用方法

### 方法1: 手動でタスクを実行

1. **GitHub Actions タブ** を開く
2. **"Claude Code Integration"** を選択
3. **"Run workflow"** をクリック
4. タスクを入力:
   ```
   このTerraformコードのセキュリティリスクを確認して
   ```
5. **"Run workflow"** をクリック

### 方法2: Pull Requestで自動レビュー

1. Pull Request を作成
2. ラベル **"claude-code"** を追加
3. 自動的にClaudeがコードをレビュー
4. コメントとして結果が追加される

## 🎯 実用例

### インフラコードのセキュリティチェック

```yaml
# Workflow trigger時のタスク例
Task: |
  以下の観点でこのインフラコードをレビューしてください：
  1. セキュリティ脆弱性（ハードコードされた認証情報、過度な権限など）
  2. ベストプラクティス違反
  3. コスト最適化の機会
  4. 可用性とスケーラビリティの懸念
  
  日本語で簡潔に報告してください。
```

### Ansibleプレイブックの改善提案

```yaml
Task: |
  このAnsibleプレイブックについて：
  1. 冪等性の問題はないか
  2. エラーハンドリングは適切か
  3. パフォーマンス改善の余地はないか
  4. セキュリティ上の懸念点
  
  具体的な改善コードも提示してください。
```

### Dockerfileの最適化

```yaml
Task: |
  このDockerfileを以下の観点で最適化してください：
  1. イメージサイズの削減
  2. ビルド時間の短縮
  3. セキュリティの強化（脆弱性のある基底イメージ、rootユーザー使用など）
  4. マルチステージビルドの活用
  
  最適化されたDockerfileを提示してください。
```

## 🔧 利用可能なモデル比較

| モデル | 速度 | コスト | 品質 | 推奨用途 |
|--------|------|--------|------|---------|
| `claude-3-sonnet-fallback` | ⚡⚡⚡ | 💰💰 | ⭐⭐⭐⭐ | **通常使用（推奨）** |
| `claude-3-opus-fallback` | ⚡⚡ | 💰💰💰 | ⭐⭐⭐⭐⭐ | 複雑な分析・設計レビュー |
| `bedrock-claude-3-haiku` | ⚡⚡⚡⚡ | 💰 | ⭐⭐⭐ | 簡単な質問・軽微な修正 |

### モデル選択ガイド

**通常のコードレビュー → `claude-3-sonnet-fallback`**
- バランスが取れた性能
- 自動フォールオーバーで可用性が高い

**アーキテクチャ設計のレビュー → `claude-3-opus-fallback`**
- より深い洞察と提案
- 複雑な技術的判断が必要な場合

**軽微な質問・確認 → `bedrock-claude-3-haiku`**
- 高速・低コスト
- シンプルなタスク向け

## ⚡ よく使うコマンド

```bash
# LLM Proxyの状態確認
docker-compose -f service/llm-proxy/docker-compose.yml ps

# LLM Proxyの再起動
docker-compose -f service/llm-proxy/docker-compose.yml restart

# 利用可能なモデル一覧
curl http://llm-proxy.abe365.org/models \
  -H "Authorization: Bearer ${LITELLM_MASTER_KEY}" | jq -r '.data[].id'

# 統合テスト実行
LITELLM_MASTER_KEY=your-key python3 scripts/test_claude_integration.py

# 使用量確認（データベース）
docker-compose -f service/llm-proxy/docker-compose.yml exec db \
  psql -U llmproxy -d litellm -c \
  "SELECT model, COUNT(*), SUM(total_tokens) FROM litellm_request_log WHERE created_at > NOW() - INTERVAL '24 hours' GROUP BY model;"
```

## 🐛 トラブルシューティング

### エラー: "401 Unauthorized"

```bash
# 原因: APIキーが間違っている
# 解決策:
cat service/llm-proxy/.env | grep LITELLM_MASTER_KEY
# GitHub Secretsと一致しているか確認
```

### エラー: "Connection refused"

```bash
# 原因: LLM Proxyが起動していない
# 解決策:
docker-compose -f service/llm-proxy/docker-compose.yml up -d
curl http://llm-proxy.abe365.org/health
```

### エラー: "Model not found"

```bash
# 原因: モデルが設定されていない
# 解決策:
cat service/llm-proxy/config/config.yaml | grep -A5 "model_name:"
```

### Workflow が実行されない

```bash
# 原因1: セルフホストランナーが停止している
# 解決策: GitHub > Settings > Actions > Runners で確認

# 原因2: Pythonパッケージがインストールされていない
# 解決策:
ansible-playbook -i hosts_all.yml claude_code_setup.yml --limit="your-runner"
```

## 📊 使用量モニタリング

### 今日の使用量確認

```bash
docker-compose -f service/llm-proxy/docker-compose.yml exec db \
  psql -U llmproxy -d litellm -c \
  "SELECT 
    model,
    COUNT(*) as requests,
    SUM(prompt_tokens) as prompt_tokens,
    SUM(completion_tokens) as completion_tokens,
    SUM(total_tokens) as total_tokens
   FROM litellm_request_log 
   WHERE created_at > CURRENT_DATE
   GROUP BY model 
   ORDER BY total_tokens DESC;"
```

### 週間レポート

```bash
docker-compose -f service/llm-proxy/docker-compose.yml exec db \
  psql -U llmproxy -d litellm -c \
  "SELECT 
    DATE(created_at) as date,
    COUNT(*) as requests,
    SUM(total_tokens) as tokens
   FROM litellm_request_log 
   WHERE created_at > NOW() - INTERVAL '7 days'
   GROUP BY DATE(created_at)
   ORDER BY date DESC;"
```

## 🔒 セキュリティチェックリスト

- [ ] LITELLM_MASTER_KEYは強固なランダム文字列（32文字以上）
- [ ] APIキーはGitHub Secretsに保存（リポジトリまたはOrganization）
- [ ] LLM Proxyのログを定期的に監視
- [ ] 使用量制限を設定（service/llm-proxy/config/config.yaml）
- [ ] セルフホストランナーのネットワークアクセスを制限
- [ ] APIキーを定期的にローテーション（3ヶ月ごと推奨）

## 📚 関連ドキュメント

- **詳細セットアップガイド**: [docs/CLAUDE_CODE_SETUP.md](../docs/CLAUDE_CODE_SETUP.md)
- **LLM Proxy設定**: [service/llm-proxy/README.md](../service/llm-proxy/README.md)
- **全体アーキテクチャ**: [AGENTS.md](../AGENTS.md)

## 🆘 サポート

問題が解決しない場合：

1. **ログを確認**
   ```bash
   # LLM Proxyログ
   docker-compose -f service/llm-proxy/docker-compose.yml logs -f litellm
   
   # GitHub Actionsログ
   # Actions タブ → 該当のworkflow run
   ```

2. **Issue作成**
   - エラーメッセージ全文
   - 実行していた操作
   - 関連ログ（機密情報は除く）

---

**更新日**: 2026-01-08  
**バージョン**: 1.0.0

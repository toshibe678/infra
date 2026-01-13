# Claude Code 統合実装サマリー

## 📋 実装概要

セキュリティとガバナンスの観点から、GitHub Actions のセルフホストランナー上で Claude Code を動作させ、外部への直接アクセスを制限するために、ローカルネットワーク内の LLM Proxy（LiteLLM）を経由して AWS Bedrock または Google Vertex AI の Claude モデルを利用する基盤を構築しました。

## 🎯 達成した目標

### セキュリティとガバナンス

✅ **外部アクセス制限**
- セルフホストランナーから外部LLM APIへの直接接続を防止
- すべてのLLM呼び出しはLLM Proxy経由で実行

✅ **集中管理**
- APIキーはLLM Proxyで一元管理
- GitHub Actions WorkflowではLITELLM_MASTER_KEYのみを使用

✅ **監査ログ**
- すべてのLLM呼び出しをデータベースに記録
- Prometheusメトリクスでリアルタイム監視

✅ **認証とアクセス制御**
- GitHub Secrets経由での安全なAPI認証
- ローカルネットワーク内での通信に制限

### 技術実装

✅ **GitHub Actions Workflow**
- 手動実行とPull Request自動実行に対応
- OpenAI互換APIでClaudeを利用
- 日本語での応答設定

✅ **Ansible自動化**
- セルフホストランナーへの依存関係自動インストール
- 設定ファイルの自動生成
- 接続テストの実行

✅ **マルチクラウド対応**
- AWS Bedrock（プライマリ）
- Google Vertex AI（フォールバック）
- 自動フォールオーバー機能

## 📁 実装ファイル一覧

### GitHub Actions Workflow
```
.github/workflows/claude-code.yml
```
- 手動実行: タスクを指定して実行
- 自動実行: "claude-code"ラベル付きPRで自動レビュー
- LLM Proxy経由でClaude APIを呼び出し
- 結果をPRコメントまたはArtifactとして保存

### Ansible Playbook
```
ansible/claude_code_setup.yml
```
- Python 3.11とpipのインストール
- 必要なPythonパッケージ（openai, anthropic）のインストール
- 設定ファイルの生成
- LLM Proxy接続テスト

### ドキュメント
```
docs/CLAUDE_CODE_SETUP.md              # 詳細セットアップガイド（7.7KB）
docs/CLAUDE_CODE_QUICKREF.md           # クイックリファレンス（5.0KB）
docs/CLAUDE_CODE_DEPLOYMENT_CHECKLIST.md  # デプロイチェックリスト（5.4KB）
docs/example.env                       # 環境変数設定例
.github/CLAUDE_CODE_README.md          # 統合README（5.1KB）
```

### テストスクリプト
```
scripts/test_claude_integration.py     # 統合テストスクリプト（2.7KB）
```
- LLM Proxy接続テスト
- Claude API呼び出しテスト
- エラーハンドリング検証

### 更新ファイル
```
AGENTS.md                              # プロジェクト進捗を更新
README.md                              # Claude Code統合へのリンク追加
```

## 🏗️ アーキテクチャ

```
┌─────────────────────────────────────────────┐
│  GitHub Actions (Self-hosted Runner)        │
│  ┌───────────────────────────────────────┐  │
│  │ Python 3.11                           │  │
│  │ - openai package                      │  │
│  │ - anthropic package                   │  │
│  └───────────────────────────────────────┘  │
└────────────────┬────────────────────────────┘
                 │ HTTP (Local Network Only)
                 │ http://llm-proxy.abe365.org/v1
                 │
┌────────────────▼────────────────────────────┐
│  LLM Proxy (192.168.100.54)                 │
│  ┌───────────────────────────────────────┐  │
│  │ LiteLLM                               │  │
│  │ - OpenAI互換API                       │  │
│  │ - 認証 (LITELLM_MASTER_KEY)           │  │
│  │ - ログ記録 (PostgreSQL)               │  │
│  │ - メトリクス (Prometheus)             │  │
│  │ - 自動フォールオーバー                │  │
│  └───────────────────────────────────────┘  │
└────────────────┬────────────────────────────┘
                 │ HTTPS (Internet)
        ┌────────┴────────┐
        ▼                 ▼
┌──────────────┐  ┌──────────────┐
│ AWS Bedrock  │  │ GCP Vertex   │
│ (Primary)    │  │ AI           │
│              │  │ (Fallback)   │
│ Claude 3     │  │ Claude 3     │
│ - Sonnet     │  │ - Sonnet     │
│ - Opus       │  │ - Opus       │
│ - Haiku      │  │ - Haiku      │
└──────────────┘  └──────────────┘
```

## 🔐 セキュリティ実装

### 認証フロー
1. GitHub Actions WorkflowがSecretから`LITELLM_MASTER_KEY`を取得
2. LLM Proxyに対してAPIリクエストを送信
3. LLM ProxyがマスターキーでWorkflowを認証
4. LLM Proxyが適切なクラウドプロバイダーのAPIキーを使用してLLM呼び出し

### セキュリティ対策
- ✅ APIキーはGitHub Secretsで管理（リポジトリコードに含まれない）
- ✅ セルフホストランナーは外部LLM APIに直接アクセス不可
- ✅ すべてのLLM呼び出しはログに記録
- ✅ ローカルネットワーク内通信のみ
- ✅ レート制限とコスト管理機能

## 📊 利用可能なモデル

| モデル名 | プロバイダー | 特徴 | 推奨用途 |
|---------|------------|------|---------|
| `claude-3-sonnet-fallback` | Bedrock→Vertex | 自動フォールオーバー | **通常使用（推奨）** |
| `claude-3-opus-fallback` | Bedrock→Vertex | 高性能、自動フォールオーバー | 複雑なタスク |
| `bedrock-claude-3-sonnet` | AWS Bedrock | バランス型 | 通常使用 |
| `bedrock-claude-3-opus` | AWS Bedrock | 最高性能 | 複雑な分析 |
| `bedrock-claude-3-haiku` | AWS Bedrock | 高速・低コスト | 簡単なタスク |
| `vertex-claude-3-sonnet` | GCP Vertex AI | バランス型 | フォールバック |
| `vertex-claude-3-opus` | GCP Vertex AI | 最高性能 | フォールバック |

## 🚀 使用方法

### 方法1: 手動実行

1. **GitHub Actions**タブを開く
2. **"Claude Code Integration"**を選択
3. **"Run workflow"**をクリック
4. タスクを入力（例：「このインフラコードのセキュリティをレビューして」）
5. 実行して結果を確認

### 方法2: Pull Request自動実行

1. Pull Requestを作成
2. ラベル**"claude-code"**を追加
3. 自動的にClaudeがコードをレビュー
4. 結果がPRコメントとして追加される

## 📈 モニタリングと監査

### ログ確認
```bash
# LLM Proxyログ
docker-compose -f service/llm-proxy/docker-compose.yml logs -f litellm

# データベースログ
docker-compose -f service/llm-proxy/docker-compose.yml exec db \
  psql -U llmproxy -d litellm -c \
  "SELECT * FROM litellm_request_log ORDER BY created_at DESC LIMIT 10;"
```

### メトリクス
```bash
# Prometheusメトリクス
curl http://llm-proxy.abe365.org:9090/metrics | grep litellm
```

### 使用量レポート
```bash
# 日次使用量
docker-compose -f service/llm-proxy/docker-compose.yml exec db \
  psql -U llmproxy -d litellm -c \
  "SELECT model, COUNT(*), SUM(total_tokens) 
   FROM litellm_request_log 
   WHERE created_at > CURRENT_DATE 
   GROUP BY model;"
```

## 🎓 次のステップ

### 本番環境デプロイ

1. **LLM Proxy準備**
   ```bash
   cd service/llm-proxy
   docker-compose up -d
   curl http://llm-proxy.abe365.org/health
   ```

2. **セルフホストランナーセットアップ**
   ```bash
   cd ansible
   ansible-playbook -i hosts_all.yml claude_code_setup.yml \
     --limit="monitoring.abe365.org"
   ```

3. **GitHub Secrets設定**
   - GitHub > Settings > Secrets and variables > Actions
   - `LITELLM_MASTER_KEY`を追加

4. **動作確認**
   ```bash
   LITELLM_MASTER_KEY=your-key python3 scripts/test_claude_integration.py
   ```

5. **Workflowテスト**
   - Actions タブで手動実行
   - テストPRで自動実行を確認

### 運用フェーズ

- **定期モニタリング**（週1回推奨）
  - 使用量の確認
  - エラー率の監視
  - コストの分析

- **定期メンテナンス**（月1回推奨）
  - APIキーのローテーション
  - 使用状況レビュー
  - 改善提案の検討

## 📚 ドキュメント構成

| ドキュメント | 対象読者 | 内容 |
|-------------|---------|------|
| [CLAUDE_CODE_SETUP.md](docs/CLAUDE_CODE_SETUP.md) | 管理者 | 詳細なセットアップ手順、トラブルシューティング |
| [CLAUDE_CODE_QUICKREF.md](docs/CLAUDE_CODE_QUICKREF.md) | 全員 | クイックリファレンス、よく使うコマンド |
| [CLAUDE_CODE_DEPLOYMENT_CHECKLIST.md](docs/CLAUDE_CODE_DEPLOYMENT_CHECKLIST.md) | デプロイ担当者 | デプロイ手順チェックリスト |
| [CLAUDE_CODE_README.md](.github/CLAUDE_CODE_README.md) | 開発者 | 統合概要、使用方法 |

## ✅ 検証項目

### 実装完了
- ✅ GitHub Actions Workflow作成
- ✅ Ansible Playbook作成
- ✅ テストスクリプト作成
- ✅ 包括的なドキュメント作成
- ✅ セキュリティ設計完了
- ✅ アーキテクチャ設計完了

### 要実環境テスト
- ⏳ LLM Proxy経由でのClaude API呼び出し
- ⏳ セルフホストランナーでのWorkflow実行
- ⏳ Pull Request自動レビュー
- ⏳ フォールオーバー動作確認
- ⏳ 使用量モニタリング
- ⏳ エラーハンドリング

## 🎉 成果物まとめ

### コード
- GitHub Actions Workflow（1ファイル）
- Ansible Playbook（1ファイル）
- Pythonテストスクリプト（1ファイル）

### ドキュメント
- セットアップガイド（7,765文字）
- クイックリファレンス（5,022文字）
- デプロイチェックリスト（5,407文字）
- 統合README（5,068文字）
- 環境変数設定例

### 合計
- **7ファイル作成**
- **2ファイル更新**（AGENTS.md, README.md）
- **約26KBのドキュメント**

## 🔍 技術的ハイライト

1. **OpenAI互換API**: LiteLLMによりOpenAI SDKでClaudeを利用可能
2. **マルチクラウド**: AWS BedrockとGCP Vertex AIの両方に対応
3. **自動フォールオーバー**: クォータ制限時の自動切り替え
4. **完全なログ記録**: PostgreSQLでの使用履歴管理
5. **Prometheusメトリクス**: リアルタイム監視
6. **Infrastructure as Code**: すべてコードで管理

## 📝 今後の拡張可能性

- VS Code拡張機能のセルフホスト対応
- Claude Code CLIツールの統合
- より詳細な使用量レポート
- コスト最適化の自動化
- 複数セルフホストランナー間での負荷分散
- カスタムプロンプトテンプレート
- チーム別使用量管理

---

**実装日**: 2026-01-08  
**実装者**: GitHub Copilot  
**バージョン**: 1.0.0  
**ステータス**: ✅ 実装完了、実環境テスト待ち

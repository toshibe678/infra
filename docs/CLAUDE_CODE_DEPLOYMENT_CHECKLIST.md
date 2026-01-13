# Claude Code 統合デプロイチェックリスト

このチェックリストは、Claude Code統合を本番環境にデプロイする際の手順を示します。

## Phase 1: 事前準備

### LLM Proxy準備

- [ ] LLM Proxyが稼働していることを確認
  ```bash
  curl http://llm-proxy.abe365.org/health
  ```

- [ ] 必要なモデルが設定されていることを確認
  ```bash
  curl http://llm-proxy.abe365.org/models \
    -H "Authorization: Bearer ${LITELLM_MASTER_KEY}" | jq -r '.data[].id'
  ```
  
  必須モデル:
  - [ ] `claude-3-sonnet-fallback`
  - [ ] `bedrock-claude-3-sonnet`
  - [ ] `vertex-claude-3-sonnet`

- [ ] AWS Bedrock認証情報が正しく設定されている
  ```bash
  docker-compose -f service/llm-proxy/docker-compose.yml exec litellm env | grep AWS
  ```

- [ ] GCP Vertex AI認証情報が正しく設定されている
  ```bash
  docker-compose -f service/llm-proxy/docker-compose.yml exec litellm env | grep GCP
  ```

### セルフホストランナー準備

- [ ] 対象のセルフホストランナーが稼働している
  - GitHub > Settings > Actions > Runners で確認

- [ ] Ansible inventoryに対象ホストが含まれている
  ```bash
  cat ansible/hosts_all.yml | grep -A5 "monitoring.abe365.org"
  ```

## Phase 2: デプロイ

### セルフホストランナーへのインストール

- [ ] Ansible playbookを実行
  ```bash
  cd ansible
  ansible-playbook -i hosts_all.yml claude_code_setup.yml \
    --limit="monitoring.abe365.org" \
    --vault-password-file ~/.ssh/.ansible_vault_pass
  ```

- [ ] インストール結果を確認
  - [ ] Python 3.11がインストールされた
  - [ ] openai, anthropic パッケージがインストールされた
  - [ ] 設定ファイルが作成された

- [ ] ランナーからLLM Proxyへの接続を確認
  ```bash
  ssh runner@monitoring.abe365.org
  curl http://llm-proxy.abe365.org/health
  ```

### GitHub Secrets設定

- [ ] Organization SecretsまたはRepository Secretsに`LITELLM_MASTER_KEY`を追加
  - GitHub > Settings > Secrets and variables > Actions
  - Name: `LITELLM_MASTER_KEY`
  - Value: (service/llm-proxy/.envから取得)

- [ ] Secretが正しく設定されたことを確認
  - テストworkflowを実行して確認

### Workflow設定

- [ ] `.github/workflows/claude-code.yml`がリポジトリに存在
  ```bash
  ls -la .github/workflows/claude-code.yml
  ```

- [ ] Workflowの設定を確認
  - [ ] `runs-on: self-hosted`が設定されている
  - [ ] 環境変数が正しく設定されている
  - [ ] タイムアウトが適切（デフォルト30分）

## Phase 3: 動作確認

### 基本動作テスト

- [ ] テストスクリプトでLLM Proxy接続を確認
  ```bash
  LITELLM_MASTER_KEY=your-key python3 scripts/test_claude_integration.py
  ```

- [ ] 手動でWorkflowを実行
  1. Actions タブ > "Claude Code Integration"
  2. "Run workflow" をクリック
  3. タスク: "Hello! Test message in Japanese."
  4. 実行結果を確認

- [ ] Pull Requestでの自動実行をテスト
  1. テスト用のPRを作成
  2. ラベル "claude-code" を追加
  3. Workflowが自動実行されることを確認
  4. コメントが追加されることを確認

### パフォーマンステスト

- [ ] 通常のタスク（500トークン程度）の実行時間を計測
  - 目標: 30秒以内

- [ ] 複雑なタスク（2000トークン程度）の実行時間を計測
  - 目標: 2分以内

### エラーハンドリングテスト

- [ ] 不正なAPIキーでの動作確認
  - 期待: 401 Unauthorizedエラーが適切に処理される

- [ ] LLM Proxy停止時の動作確認
  - 期待: Connection Errorが適切に処理される

- [ ] 存在しないモデル指定時の動作確認
  - 期待: Model Not Foundエラーが適切に処理される

## Phase 4: モニタリング設定

### ログ確認

- [ ] LLM Proxyのログ出力を確認
  ```bash
  docker-compose -f service/llm-proxy/docker-compose.yml logs -f litellm
  ```

- [ ] GitHub Actionsのログを確認
  - Actions タブ > 実行したworkflow > ログ

### メトリクス確認

- [ ] Prometheusメトリクスが収集されている
  ```bash
  curl http://llm-proxy.abe365.org:9090/metrics | grep litellm
  ```

- [ ] データベースにリクエストログが記録されている
  ```bash
  docker-compose -f service/llm-proxy/docker-compose.yml exec db \
    psql -U llmproxy -d litellm -c \
    "SELECT COUNT(*) FROM litellm_request_log WHERE created_at > NOW() - INTERVAL '1 hour';"
  ```

### アラート設定

- [ ] 使用量アラートの設定（オプション）
  - Prometheus/Grafanaでアラートルールを設定

- [ ] エラー率アラートの設定（オプション）
  - 5xx エラーが閾値を超えたら通知

## Phase 5: ドキュメント確認

- [ ] README.mdにClaude Code統合へのリンクが追加されている

- [ ] AGENTS.mdが更新されている
  - [ ] 完了セクションにClaude Code統合が記載
  - [ ] 今後の課題が更新されている

- [ ] セットアップドキュメントが最新
  - [ ] docs/CLAUDE_CODE_SETUP.md
  - [ ] docs/CLAUDE_CODE_QUICKREF.md
  - [ ] .github/CLAUDE_CODE_README.md

## Phase 6: セキュリティチェック

### 認証・認可

- [ ] LITELLM_MASTER_KEYが強固（32文字以上のランダム文字列）

- [ ] APIキーがGitHub Secretsに安全に保存されている
  - コードやログに露出していない

- [ ] LLM Proxyへのアクセスがローカルネットワークに制限されている

### ネットワークセキュリティ

- [ ] セルフホストランナーから外部LLM APIへの直接接続がない

- [ ] LLM Proxyのファイアウォール設定が適切
  - ローカルネットワークからのみアクセス可能

### 監査ログ

- [ ] すべてのLLM呼び出しがデータベースに記録される

- [ ] ログ保持期間が設定されている（推奨: 90日）

## Phase 7: 本番運用開始

### チーム通知

- [ ] チームメンバーにClaude Code統合の利用可能を通知

- [ ] 使用方法のドキュメント（CLAUDE_CODE_QUICKREF.md）を共有

- [ ] 推奨される使用例を共有

### モニタリング体制

- [ ] 担当者が決まっている
  - LLM Proxyの監視担当
  - 使用量・コストの監視担当

- [ ] 定期レビューのスケジュール（推奨: 週1回）
  - 使用量の確認
  - エラー率の確認
  - コストの確認

### バックアップ・災害復旧

- [ ] LLM Proxy設定のバックアップ手順が確立

- [ ] フォールオーバーシナリオのテスト
  - AWS Bedrock → GCP Vertex AIへの自動切り替え

## Phase 8: 継続的改善

### 使用状況の分析

- [ ] 週次レポートの作成
  - 使用回数
  - トークン消費量
  - エラー率
  - 平均応答時間

- [ ] コスト分析
  - AWS Bedrockのコスト
  - GCP Vertex AIのコスト
  - 月次コスト推移

### フィードバック収集

- [ ] ユーザーからのフィードバック収集方法の確立
  - Issue template
  - Slackチャンネル

- [ ] 改善提案の定期レビュー

## トラブル時の連絡先

| 役割 | 担当者 | 連絡方法 |
|------|--------|---------|
| LLM Proxy管理 | （記入） | （記入） |
| セルフホストランナー管理 | （記入） | （記入） |
| GitHub Actions管理 | （記入） | （記入） |
| セキュリティ | （記入） | （記入） |

## ロールバック手順

問題が発生した場合のロールバック：

1. **Workflowの無効化**
   ```bash
   # .github/workflows/claude-code.ymlをdisableに設定
   # または、ファイル名を変更
   git mv .github/workflows/claude-code.yml .github/workflows/claude-code.yml.disabled
   ```

2. **セルフホストランナーのクリーンアップ**
   ```bash
   # Pythonパッケージのアンインストール
   ansible-playbook -i hosts_all.yml claude_code_cleanup.yml
   ```

3. **GitHub Secretsの削除**
   - GitHub > Settings > Secrets and variables > Actions
   - LITELLM_MASTER_KEYを削除（必要に応じて）

---

**チェックリスト完了日**: ____/____/____  
**実施者**: __________________  
**レビュー者**: __________________

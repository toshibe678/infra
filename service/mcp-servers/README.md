# MCP Servers - Model Context Protocol 統合サービス

## 概要

複数のMCP (Model Context Protocol) サーバーを統合し、開発者が統一的なインターフェースを通じて利用できるようにするサービスです。個別の開発環境でMCPサーバーを起動するのではなく、集約して提供することでリソース消費を削減します。

## サービス構成

### 提供しているMCPサーバー

| サーバー名 | 用途 | エンドポイント |
|-----------|------|--------------|
| **Git MCP** | Gitリポジトリ操作 | `/git/` |
| **GitHub MCP** | GitHub API統合 | `/github/` |
| **Filesystem MCP** | ファイルシステムアクセス | `/filesystem/` |
| **PostgreSQL MCP** | PostgreSQLデータベース操作 | `/postgres/` |
| **Fetch MCP** | HTTP/HTTPS リクエスト | `/fetch/` |
| **Playwright MCP** | ブラウザ自動化 | `/playwright/` |
| **Gateway** | 統合エンドポイント | `/` |

### インフラ構成

- **Nginx**: リバースプロキシ、レート制限、SSL終端
- **PostgreSQL**: メタデータストレージ
- **Redis**: キャッシュ、セッション管理
- **Node Exporter**: Prometheusメトリクス収集

## セットアップ

### 1. 環境変数の設定

```bash
cd /home/toshi/git/infra/service/mcp-servers
cp .env.example .env
vim .env
```

必須の環境変数：
- `DB_PASSWORD`: PostgreSQLパスワード
- `REDIS_PASSWORD`: Redisパスワード
- `AUTH_TOKEN`: API認証トークン
- `GITHUB_TOKEN`: GitHub Personal Access Token

### 2. ディレクトリ構造の作成

```bash
mkdir -p data/postgres data/redis logs/nginx logs/gateway
mkdir -p repos workspace gateway mcp-servers/{git,github,filesystem,postgres,fetch,playwright}
```

### 3. サービス起動

```bash
docker-compose up -d
```

### 4. 動作確認

```bash
# ヘルスチェック
curl http://mcp.abe365.org/health

# 各MCPサーバーの確認
curl -H "Authorization: Bearer YOUR_AUTH_TOKEN" http://mcp.abe365.org/git/
curl -H "Authorization: Bearer YOUR_AUTH_TOKEN" http://mcp.abe365.org/github/
```

## 使用方法

### 統合ゲートウェイ経由のアクセス

```bash
# ゲートウェイ経由（推奨）
curl -X POST http://mcp.abe365.org/api/execute \
  -H "Authorization: Bearer YOUR_AUTH_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"server": "git", "command": "status", "params": {}}'
```

### 直接アクセス

```bash
# Git MCP直接アクセス
curl http://mcp.abe365.org/git/status \
  -H "Authorization: Bearer YOUR_AUTH_TOKEN"

# GitHub MCP直接アクセス
curl http://mcp.abe365.org/github/repos \
  -H "Authorization: Bearer YOUR_AUTH_TOKEN"
```

## Claude Desktopクライアント設定

### セットアップ手順

1. **設定ファイルのコピー**
   ```bash
   # リポジトリルートから
   cp claude_desktop_config.json.example ~/.config/Claude/claude_desktop_config.json
   ```
   - **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
   - **Windows**: `%APPDATA%/Claude/claude_desktop_config.json`
   - **Linux**: `~/.config/Claude/claude_desktop_config.json`

2. **認証トークンの設定**
   ```bash
   # .env から AUTH_TOKEN を確認
   grep AUTH_TOKEN /home/toshi/git/infra/service/mcp-servers/.env
   
   # claude_desktop_config.json の auth_token を編集
   sed -i 's/your-auth-token-here/<実際のトークン>/g' ~/.config/Claude/claude_desktop_config.json
   ```

3. **Claude Desktopの再起動**
   - Claude Desktopを完全に再起動
   - Discoverボタンでサーバー一覧を更新

### 設定ファイル例

```json
{
  "mcpServers": {
    "mcp-unified-gateway": {
      "url": "http://mcp.abe365.org",
      "env": {
        "AUTH_TOKEN": "your-actual-token-here"
      }
    }
  }
}
```

### 利用可能なエンドポイント

統合ゲートウェイ経由で以下のMCPサーバーにアクセス可能：

| エンドポイント | 説明 |
|-------------|------|
| `/git` | Gitリポジトリ操作 |
| `/github` | GitHub API統合 |
| `/filesystem` | ファイルシステムアクセス |
| `/postgres` | PostgreSQLデータベース操作 |
| `/fetch` | HTTP/HTTPS リクエスト |
| `/playwright` | ブラウザ自動化 |

### トラブルシューティング

**接続できない場合:**
1. ネットワーク接続確認: `ping mcp.abe365.org`
2. ゲートウェイの起動確認: `curl http://mcp.abe365.org/health`
3. トークンの確認: `echo $AUTH_TOKEN`
4. Claude Desktopの再起動

**認証エラー:**
1. `Authorization: Bearer` ヘッダーが正しく送信されているか確認
2. トークン値に前後の空白がないか確認
3. `.env` ファイルの `AUTH_TOKEN` を更新後、ゲートウェイを再起動

## セキュリティ

### 認証

- **トークン認証**: `AUTH_TOKEN`による認証が必要
- **レート制限**: 10req/s、バースト20まで許可
- **セキュリティヘッダー**: X-Frame-Options、X-XSS-Protection等を設定

### アクセス制御

- **Git MCP**: `/repos`配下のみアクセス可能
- **Filesystem MCP**: `/workspace`配下のみアクセス可能
- **PostgreSQL MCP**: 専用DBユーザーで分離

### 推奨事項

1. `.env`ファイルのパーミッション制限 (`chmod 600 .env`)
2. 強力なパスワード使用（最低20文字以上）
3. 定期的なトークンローテーション
4. 不要なMCPサーバーは無効化

## 監視

### Prometheus統合

```yaml
# prometheus.yml に追加
scrape_configs:
  - job_name: 'mcp-servers'
    static_configs:
      - targets: ['mcp.abe365.org:80']
        labels:
          service: 'mcp-servers'
```

### ログ確認

```bash
# Nginxログ
tail -f logs/nginx/access.log
tail -f logs/nginx/error.log

# Gatewayログ
tail -f logs/gateway/app.log

# コンテナログ
docker-compose logs -f mcp-gateway
docker-compose logs -f mcp-git
```

## トラブルシューティング

### コンテナが起動しない

```bash
# ログ確認
docker-compose logs

# 個別コンテナの確認
docker-compose logs mcp-gateway

# 再起動
docker-compose restart
```

### 接続できない

1. **ネットワーク確認**:
   ```bash
   ping mcp.abe365.org
   curl -I http://mcp.abe365.org/health
   ```

2. **認証トークン確認**:
   ```bash
   # .envファイルのAUTH_TOKENを確認
   grep AUTH_TOKEN .env
   ```

3. **ファイアウォール確認**:
   ```bash
   sudo iptables -L | grep 80
   ```

### パフォーマンス問題

1. **Redisキャッシュのクリア**:
   ```bash
   docker-compose exec redis redis-cli -a "$REDIS_PASSWORD" FLUSHALL
   ```

2. **リソース使用状況確認**:
   ```bash
   docker stats
   ```

3. **ログローテーション設定**:
   ```bash
   # logrotate設定を追加
   sudo vim /etc/logrotate.d/mcp-servers
   ```

## メンテナンス

### バックアップ

```bash
# データベースバックアップ
docker-compose exec db pg_dump -U mcpuser mcpdb > backup_$(date +%Y%m%d).sql

# 設定ファイルバックアップ
tar -czf mcp-servers-config-$(date +%Y%m%d).tar.gz \
  .env docker-compose.yml nginx/ gateway/
```

### アップデート

```bash
# イメージ更新
docker-compose pull

# サービス再起動
docker-compose down
docker-compose up -d

# 不要イメージ削除
docker image prune -a
```

## 開発者向け

### Gateway開発

Gateway（`/gateway`ディレクトリ）はNode.js/TypeScriptで実装されており、各MCPサーバーへのルーティングと認証を担当します。

```bash
cd gateway
npm install
npm run dev
```

### カスタムMCPサーバー追加

1. `docker-compose.yml`に新しいサービス追加
2. `nginx/nginx.conf`にupstreamとlocation追加
3. `.env.example`に必要な環境変数追加
4. READMEを更新

## 参考リンク

- [Model Context Protocol 公式](https://modelcontextprotocol.io/)
- [MCP Servers Repository](https://github.com/modelcontextprotocol/servers)
- [GitHub MCP Server](https://github.com/github/github-mcp-server)
- [Playwright MCP](https://github.com/microsoft/playwright-mcp)

## ライセンス

プロジェクトのライセンスに従います。

## サポート

問題や質問がある場合は、プロジェクトのIssueトラッカーを使用してください。

# MCP Servers - Model Context Protocol 統合サービス

## 概要

開発者が利用するMCPサーバーについて各開発環境のローカルリソースを利用するのではなく、統一的に提供して総リソース消費量を削減する目的でMCPサーバーを複数起動しそれを1つのインターフェースから提供することを目的としている

## ネットワーク構成と認証アーキテクチャ

### 通信フロー

```
[Claude Desktop / MCPクライアント]
    ↓ (Bearer Token認証)
[Nginx Reverse Proxy (:80)]
    ↓ (認証済みリクエスト)
[MCP Gateway (Express server.js)]
    ├→ /git → [mcp-git:3001]
    ├→ /github → [mcp-github:3002]
    ├→ /filesystem → [mcp-filesystem:3003]
    ├→ /postgres → [mcp-postgres:3004]
    ├→ /fetch → [mcp-fetch:3005]
    └→ /playwright → [mcp-playwright:3006]
```

### 認証機構

- **Layer 1**: Bearer Token認証（ `Authorization: Bearer ${AUTH_TOKEN}` ）
  - Nginx → Gateway で検証（gateway/server.js実装）
  - 無効なトークン: 401応答
  
- **Layer 2**: MCPサーバー障害対応
  - プロキシ先サーバーダウン時: Gateway から 503応答
  - エラーレスポンス例：
    ```json
    {
      "error": "Service Unavailable",
      "message": "Git MCP Server is unavailable",
      "details": "ECONNREFUSED"
    }
    ```

### VPN経由アクセス

VPN接続クライアント用に vpn-proxy 経由でのルーティングが利用可能：

```
[VPN Client (10.0.0.x)]
    ↓
[WireGuard VPN Tunnel]
    ↓ (VPN暗号化)
[vpn-proxy:80 (mcp-proxy.vpn.local)]
    ↓
[MCP Gateway]
    ↓
[MCPサーバー群]
```

## 実装詳細

### Gatewayサーバー

**ファイル**: `gateway/server.js` (Node.js Express)

**機能**:
- Bearer Token認証ミドルウェア
- 各MCPサーバーへのリバースプロキシ
- エラーハンドリング（503応答）
- ヘルスチェックエンドポイント（ `/health` ）
- リクエストログ出力

**環境変数**:
- `AUTH_TOKEN`: API認証トークン（必須）
- `PORT`: リスン先ポート（デフォルト: 3000）
- `MCP_*_URL`: 各MCPサーバーのURL（docker-composeで設定）

**起動**:
```bash
docker-compose up -d mcp-gateway
# または手動
cd service/mcp-servers/gateway
npm install
AUTH_TOKEN="your-token" npm start
```

### Nginxリバースプロキシ

**ファイル**: `nginx/nginx.conf`

**役割**:
- Gate way への リクエスト受け取り（ `:80` ）
- リクエスト転送（Gateway:3000）
- レート制限（10req/s、バースト20）
- ログ記録（access.log / error.log）
- WebSocket対応（upgrade handling）

## 運用ガイド

### 認証トークンの設定

```bash
# 強力なトークン生成（推奨）
openssl rand -hex 32 > /tmp/auth_token.txt

# .env に設定
AUTH_TOKEN=$(cat /tmp/auth_token.txt)
echo "AUTH_TOKEN=${AUTH_TOKEN}" >> .env

# トークン確認（docker-composeで使用時）
grep AUTH_TOKEN .env
```

### MCPクライアント設定

Claude Desktopでの設定は [リポジトリルート/claude_desktop_config.json.example](../../claude_desktop_config.json.example) を参照

## 将来の拡張計画

### 複数APIキー管理（段階的導入）

現在は単一の `AUTH_TOKEN` を環境変数で管理していますが、以下の段階で拡張予定：

**段階1（現在）**: 
- 環境変数による固定トークン
- 単一認証キー
- 全クライアント共有

**段階2（推奨）**:
- PostgreSQL での キー管理
- キー単位のレート制限
- 使用量追跡（ `track_cost_per_key` 対応）
- キーのローテーション機能

**段階3（長期）**:
- OAuth2 / OIDC 認証
- キーの有効期限管理
- 権限ベースアクセス制御（ABACキー別に利用可能なMCPサーバーを制限）
- 監査ログ統合

**実装ステップ**:
1. `gateway/auth-db.js` でPostgreSQL接続層を追加
2. `gateway/server.js` の認証ロジックを DB ルックアップ方式に変更
3. DB マイグレーション（FlywayまたはTypeORM）
4. 管理用エンドポイント追加（キー作成・削除・ローテーション）
5. Prometheus メトリクス追加（キー別使用量）

## 利用するMCPサーバー

実装済み：
* Git MCP
  * https://github.com/modelcontextprotocol/servers/tree/main/src/git
* GitHub MCP
  * https://github.com/github/github-mcp-server
* FileSystem MCP
  * https://github.com/modelcontextprotocol/servers/tree/main/src/filesystem
* PostgreSQL MCP
  * https://github.com/modelcontextprotocol/servers/tree/main/src/postgres
* Fetch MCP
  * https://github.com/modelcontextprotocol/servers/tree/main/src/fetch
* Playwright MCP
  * https://github.com/microsoft/playwright-mcp

計画中（今後追加予定）:
* Gmail MCP Server
* Slack MCP
* Notion MCP
* MySQL MCP
* AWS MCP Servers
* Context7
  * https://github.com/upstash/context7
* Chart
  * https://github.com/antvis/mcp-server-chart

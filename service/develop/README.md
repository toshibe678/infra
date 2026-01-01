# Development Environment

統合開発環境の構成

## 概要

開発作業に必要な各種ツールとサービスをDocker Composeで統合管理します。
ブラウザベースのIDE、データベース、キャッシュなどの開発に必要な環境を提供します。

## DNS設定

- **ドメイン**: develop.abe365.org
- **IPアドレス**: 192.168.100.55
- **DNS管理**: Cloudflare (cloudflere/records.tf)

## サービス構成

### コンポーネント

| サービス | ポート | 説明 |
|---------|--------|------|
| code-server | 8080 | VS Code（ブラウザ版） |
| jupyter | 8888 | JupyterLab |
| postgres | 5432 | PostgreSQL開発用DB |
| redis | 6379 | Redis開発用キャッシュ |
| mongo | 27017 | MongoDB開発用DB |
| adminer | 8081 | データベース管理ツール |
| portainer | 9000 | Docker管理UI |
| gitlab-runner | - | CI/CDランナー（オプション） |

## セットアップ手順

### 1. 環境変数の設定

```bash
cp .env.example .env
vim .env  # 必要な環境変数を設定
```

### 2. ディレクトリの作成

```bash
mkdir -p workspace notebooks data config
```

### 3. サービスの起動

```bash
# 全サービス起動
docker-compose up -d

# 特定サービスのみ起動
docker-compose up -d code-server jupyter postgres
```

## アクセス方法

サービス起動後、以下のURLでアクセス可能です：

| サービス | URL | 認証 |
|---------|-----|------|
| VS Code | http://develop.abe365.org:8080 | PASSWORD |
| JupyterLab | http://develop.abe365.org:8888 | TOKEN |
| Adminer | http://develop.abe365.org:8081 | DB認証 |
| Portainer | http://develop.abe365.org:9000 | 初回セットアップ |

## 環境変数

以下の環境変数を`.env`ファイルに設定してください：

| 変数名 | 説明 | 必須 |
|--------|------|------|
| CODE_SERVER_PASSWORD | VS Codeパスワード | ✓ |
| JUPYTER_TOKEN | JupyterLabトークン | ✓ |
| POSTGRES_PASSWORD | PostgreSQLパスワード | ✓ |
| REDIS_PASSWORD | Redisパスワード | ✓ |
| MONGO_PASSWORD | MongoDBパスワード | ✓ |
| SUDO_PASSWORD | sudo権限用パスワード | × |

## 使用例

### VS Codeでの開発

1. http://develop.abe365.org:8080 にアクセス
2. PASSWORDでログイン
3. `/home/coder/project` 配下で作業
4. 拡張機能のインストール可能

### JupyterLabでのデータ分析

1. http://develop.abe365.org:8888 にアクセス
2. TOKENでログイン
3. `/home/jovyan/work` 配下でノートブック作成

### データベース接続

#### PostgreSQL

```bash
# psqlクライアント
psql -h develop.abe365.org -U developer -d devdb

# Python
import psycopg2
conn = psycopg2.connect(
    host="develop.abe365.org",
    database="devdb",
    user="developer",
    password="your-password"
)
```

#### MongoDB

```bash
# mongo shell
mongosh mongodb://admin:your-password@develop.abe365.org:27017

# Python
from pymongo import MongoClient
client = MongoClient('mongodb://admin:your-password@develop.abe365.org:27017/')
```

## データ永続化

以下のディレクトリにデータが保存されます：

- `./workspace/`: VS Codeワークスペース
- `./notebooks/`: Jupyterノートブック
- `./data/postgres/`: PostgreSQLデータ
- `./data/redis/`: Redisデータ
- `./data/mongo/`: MongoDBデータ
- `./data/portainer/`: Portainer設定
- `./config/`: 各種設定ファイル

## カスタマイズ

### VS Code拡張機能のインストール

```bash
# コンテナ内で実行
docker-compose exec code-server code-server --install-extension <extension-id>
```

### Jupyter拡張機能の追加

```bash
# コンテナ内で実行
docker-compose exec jupyter pip install <package-name>
```

## トラブルシューティング

### VS Codeにアクセスできない

```bash
# コンテナの状態確認
docker-compose ps code-server

# ログの確認
docker-compose logs code-server
```

### データベース接続エラー

```bash
# PostgreSQL接続確認
docker-compose exec postgres pg_isready

# MongoDB接続確認
docker-compose exec mongo mongosh --eval "db.adminCommand('ping')"
```

## メンテナンス

### バックアップ

```bash
# PostgreSQLバックアップ
docker-compose exec postgres pg_dump -U developer devdb > backup_$(date +%Y%m%d).sql

# MongoDBバックアップ
docker-compose exec mongo mongodump --out=/data/backup_$(date +%Y%m%d)

# 全データディレクトリバックアップ
tar -czf develop_backup_$(date +%Y%m%d).tar.gz ./workspace ./notebooks ./data
```

### アップデート

```bash
docker-compose pull
docker-compose up -d
```

### リソース制限

本番環境では`docker-compose.yml`にリソース制限を追加することを推奨：

```yaml
services:
  code-server:
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G
```

## セキュリティ

- すべてのパスワードは強固なものを使用
- 外部公開する場合はHTTPS化とVPN経由アクセスを推奨
- 定期的なバックアップの実施
- 不要なサービスは停止

## 参考リンク

- [code-server Documentation](https://coder.com/docs/code-server)
- [JupyterLab Documentation](https://jupyterlab.readthedocs.io/)
- [Portainer Documentation](https://docs.portainer.io/)

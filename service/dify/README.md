# Dify AI Application Platform

AIアプリケーション開発プラットフォーム「Dify」のDocker Compose構成

## 概要

Difyは、LLMアプリケーション開発のためのオープンソースプラットフォームです。
このディレクトリには、ローカルネットワーク上でDifyを実行するための構成が含まれています。

## DNS設定

- **ドメイン**: dify.abe365.org
- **IPアドレス**: 192.168.100.52
- **DNS管理**: Cloudflare (cloudflere/records.tf)

## サービス構成

### コンポーネント

- **api**: Dify API サーバー
- **worker**: バックグラウンドタスク処理
- **web**: フロントエンドアプリケーション
- **db**: PostgreSQLデータベース
- **redis**: キャッシュ・メッセージブローカー
- **weaviate**: ベクトルデータベース
- **nginx**: リバースプロキシ

## セットアップ手順

### 1. 環境変数の設定

```bash
cp .env.example .env
vim .env  # 必要な環境変数を設定
```

### 2. Nginx設定の準備

```bash
mkdir -p nginx
# nginx.confを作成（必要に応じて）
```

### 3. 自己署名証明書の作成（HTTPS）

```bash
mkdir -p dify/docker/nginx/ssl && cd dify/docker/nginx/ssl
openssl req -x509 -nodes -newkey ec -pkeyopt ec_paramgen_curve:secp384r1 -days 825 \
	-keyout ./dify.key \
	-out ./dify.crt \
	-subj "/CN=dify.abe365.org" \
	-addext "subjectAltName=DNS:dify.abe365.org"

sed -i 's/^NGINX_HTTPS_ENABLED=.*/NGINX_HTTPS_ENABLED=true/' dify/docker/.env
```

### 4. サービスの起動

```bash
docker-compose up -d
```

### 4. ログの確認

```bash
docker-compose logs -f
```

## 環境変数

以下の環境変数を`.env`ファイルに設定してください：

| 変数名 | 説明 | 必須 |
|--------|------|------|
| SECRET_KEY | アプリケーションシークレットキー | ✓ |
| DB_PASSWORD | PostgreSQLパスワード | ✓ |
| REDIS_PASSWORD | Redisパスワード | ✓ |
| LOG_LEVEL | ログレベル (INFO/DEBUG/ERROR) | × |
| DB_USERNAME | データベースユーザー名 | × |
| DB_DATABASE | データベース名 | × |

## アクセス方法

サービス起動後、以下のURLでアクセス可能です：

- **Web UI**: https://dify.abe365.org
- **API**: https://dify.abe365.org/api

## データ永続化

以下のディレクトリにデータが保存されます：

- `./data/postgres/`: PostgreSQLデータ
- `./data/redis/`: Redisデータ
- `./data/weaviate/`: Weaviateベクトルデータ
- `./storage/`: アップロードファイル

## トラブルシューティング

### サービスが起動しない

```bash
# コンテナの状態確認
docker-compose ps

# ログの確認
docker-compose logs api
docker-compose logs db
```

### データベース初期化

```bash
# データベースをリセット
docker-compose down -v
rm -rf ./data/postgres
docker-compose up -d
```

## メンテナンス

### バックアップ

```bash
# データベースのバックアップ
docker-compose exec db pg_dump -U postgres dify > backup_$(date +%Y%m%d).sql

# データディレクトリのバックアップ
tar -czf dify_data_$(date +%Y%m%d).tar.gz ./data ./storage
```

### アップデート

```bash
docker-compose pull
docker-compose up -d
```

## セキュリティ

- SECRET_KEYは強固なランダム文字列を使用
- データベース・Redisパスワードは複雑なものを設定
- 本番環境では適切なファイアウォール設定を実施
- 定期的なバックアップの実施

## 参考リンク

- [Dify公式ドキュメント](https://docs.dify.ai/)
- [Dify GitHub](https://github.com/langgenius/dify)

# Dify初期起動時のコマンド
```bash
git submodule init
# .env.example から .env を作成し、SECRET_KEY を設定する
cp .env.example dify/docker/.env
sed -i "s|^SECRET_KEY=.*|SECRET_KEY=$(openssl rand -base64 42)|" dify/docker/.env
cd dify/docker
docker compose up -d
```

# サブモジュール系コマンド
| コマンド | 用途 |
|--------|------|
| git submodule init | .gitmodules の設定に基づきローカルの参照を初期化する |
| git submodule update | 指定されたコミットハッシュの内容を実際にチェックアウトする |
| git submodule update --init --recursive | 初期化と更新を同時に行い、dify内のサブモジュールも再帰的に取得する |


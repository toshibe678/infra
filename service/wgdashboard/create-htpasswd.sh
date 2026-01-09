#!/bin/bash

# Basic認証用のhtpasswdファイル作成スクリプト
# .envファイルから WG_DASHBOARD_USERNAME と WG_DASHBOARD_PASSWORD を読み込んで自動生成
# Usage: ./create-htpasswd.sh

set -e

# カラー出力
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# スクリプトディレクトリの取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${GREEN}=== Basic認証ファイル生成 ===${NC}"
echo ""

# .envファイルの確認
if [ ! -f "$SCRIPT_DIR/.env" ]; then
    echo -e "${RED}エラー: .envファイルが見つかりません ($SCRIPT_DIR/.env)${NC}"
    echo "先に .env.example をコピーして .env を作成してください:"
    echo "  cp .env.example .env"
    exit 1
fi

# .envファイルから環境変数を読み込む
set +e
source "$SCRIPT_DIR/.env"
set -e

# 環境変数の取得
USERNAME="${WG_DASHBOARD_USERNAME:-admin}"
PASSWORD="${WG_DASHBOARD_PASSWORD}"

# パスワードの確認
if [ -z "$PASSWORD" ]; then
    echo -e "${RED}エラー: .env内に WG_DASHBOARD_PASSWORD が設定されていません${NC}"
    echo "例:"
    echo "  WG_DASHBOARD_PASSWORD=your_secure_password"
    exit 1
fi

# htpasswdディレクトリの作成
mkdir -p "$SCRIPT_DIR/nginx"

echo -e "${GREEN}以下の認証情報を使用します:${NC}"
echo "  ユーザー名: $USERNAME"
echo "  パスワード: (****から始まります)"
echo ""

# htpasswdファイルが既に存在するか確認
if [ -f "$SCRIPT_DIR/nginx/htpasswd" ]; then
    echo -e "${YELLOW}既存のhtpasswdファイルが見つかりました${NC}"
    read -p "上書きしますか？ (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "中止しました"
        exit 0
    fi
fi

# Dockerでhtpasswdを生成（alpineイメージのapache2-utilsを使用）
# -b フラグでパスワードをコマンドライン引数として渡す（標準入力の問題を回避）
echo -e "${GREEN}htpasswdファイルを生成中...${NC}"
docker run --rm --entrypoint htpasswd httpd:2.4-alpine -c -b -B /dev/stdout "$USERNAME" "$PASSWORD" > "$SCRIPT_DIR/nginx/htpasswd.tmp"

if [ $? -eq 0 ]; then
    mv "$SCRIPT_DIR/nginx/htpasswd.tmp" "$SCRIPT_DIR/nginx/htpasswd"
    chmod 644 "$SCRIPT_DIR/nginx/htpasswd"
    echo ""
    echo -e "${GREEN}✓ htpasswdファイルを生成しました: ./nginx/htpasswd${NC}"
    echo ""
    echo "作成されたユーザー:"
    cat "$SCRIPT_DIR/nginx/htpasswd" | cut -d: -f1
    echo ""
    echo -e "${YELLOW}nginxを再起動して設定を反映してください:${NC}"
    echo "  docker-compose restart nginx"
else
    echo -e "${RED}エラーが発生しました${NC}"
    rm -f "$SCRIPT_DIR/nginx/htpasswd.tmp"
    exit 1
fi

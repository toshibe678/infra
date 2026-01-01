#!/bin/bash

# Basic認証用のhtpasswdファイル作成スクリプト
# Usage: ./create-htpasswd.sh

set -e

# カラー出力
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Basic認証ユーザー作成 ===${NC}"
echo ""

# htpasswdディレクトリの作成
mkdir -p ./nginx

# ユーザー名の入力
read -p "ユーザー名を入力してください: " USERNAME

if [ -z "$USERNAME" ]; then
    echo "ユーザー名が空です。終了します。"
    exit 1
fi

# htpasswdファイルが既に存在するか確認
if [ -f "./nginx/htpasswd" ]; then
    echo -e "${YELLOW}既存のhtpasswdファイルが見つかりました${NC}"
    read -p "ユーザーを追加しますか？ (既存ファイルは保持されます) (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "中止しました"
        exit 0
    fi
    APPEND_FLAG="-n"
else
    APPEND_FLAG="-c"
fi

# Dockerでhtpasswdを生成（alpineイメージのapache2-utilsを使用）
echo -e "${GREEN}パスワードを入力してください:${NC}"
docker run --rm -it --entrypoint htpasswd httpd:2.4-alpine $APPEND_FLAG -B /dev/stdout "$USERNAME" > ./nginx/htpasswd.tmp

if [ $? -eq 0 ]; then
    mv ./nginx/htpasswd.tmp ./nginx/htpasswd
    chmod 644 ./nginx/htpasswd
    echo ""
    echo -e "${GREEN}htpasswdファイルを作成しました: ./nginx/htpasswd${NC}"
    echo ""
    echo "作成されたユーザー一覧:"
    cat ./nginx/htpasswd | cut -d: -f1
    echo ""
    echo -e "${YELLOW}nginxを再起動して設定を反映してください:${NC}"
    echo "  docker-compose restart nginx"
else
    echo "エラーが発生しました"
    rm -f ./nginx/htpasswd.tmp
    exit 1
fi

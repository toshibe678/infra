#!/bin/bash

# SSL証明書初期セットアップスクリプト
# Usage: ./init-letsencrypt.sh

set -e

# 設定
DOMAIN="vpn-dev.abe365.org"
EMAIL="admin@abe365.org"  # 管理者メールアドレスを設定してください
STAGING=0  # テスト用には1、本番用には0

# カラー出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== Let's Encrypt SSL証明書セットアップ ===${NC}"
echo ""

# ドメイン名とメールアドレスの確認
echo -e "${YELLOW}ドメイン: ${DOMAIN}${NC}"
echo -e "${YELLOW}メールアドレス: ${EMAIL}${NC}"
echo ""
read -p "この設定で続行しますか？ (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}中止しました${NC}"
    exit 1
fi

# 既存の証明書データを確認
if [ -d "./data/certbot/conf/live/$DOMAIN" ]; then
    echo -e "${YELLOW}既存の証明書が見つかりました${NC}"
    read -p "削除して再作成しますか？ (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}既存の証明書を削除します...${NC}"
        sudo rm -rf ./data/certbot/conf/live/$DOMAIN
        sudo rm -rf ./data/certbot/conf/archive/$DOMAIN
        sudo rm -rf ./data/certbot/conf/renewal/$DOMAIN.conf
    else
        echo -e "${YELLOW}既存の証明書をそのまま使用します${NC}"
        exit 0
    fi
fi

# 必要なディレクトリを作成
echo -e "${GREEN}ディレクトリを作成しています...${NC}"
mkdir -p ./data/certbot/conf
mkdir -p ./data/certbot/www

# ダミー証明書の作成（初回起動用）
echo -e "${GREEN}ダミー証明書を作成しています...${NC}"
mkdir -p ./data/certbot/conf/live/$DOMAIN

docker-compose run --rm --entrypoint "\
  openssl req -x509 -nodes -newkey rsa:4096 -days 1 \
    -keyout '/etc/letsencrypt/live/$DOMAIN/privkey.pem' \
    -out '/etc/letsencrypt/live/$DOMAIN/fullchain.pem' \
    -subj '/CN=localhost'" certbot

echo -e "${GREEN}ダミーのchain.pemを作成...${NC}"
cp ./data/certbot/conf/live/$DOMAIN/fullchain.pem ./data/certbot/conf/live/$DOMAIN/chain.pem

# nginxを起動
echo -e "${GREEN}nginxを起動しています...${NC}"
docker-compose up -d nginx

# ダミー証明書を削除
echo -e "${GREEN}ダミー証明書を削除しています...${NC}"
sudo rm -rf ./data/certbot/conf/live/$DOMAIN

# 本物の証明書を取得
echo -e "${GREEN}Let's Encrypt証明書を取得しています...${NC}"

# ステージング環境かプロダクション環境か
STAGING_ARG=""
if [ $STAGING -eq 1 ]; then
    STAGING_ARG="--staging"
    echo -e "${YELLOW}テストモード（Staging）で証明書を取得します${NC}"
fi

docker-compose run --rm certbot certonly --webroot \
    -w /var/www/certbot \
    $STAGING_ARG \
    --email $EMAIL \
    --agree-tos \
    --no-eff-email \
    -d $DOMAIN

# nginxをリロード
echo -e "${GREEN}nginxをリロードしています...${NC}"
docker-compose exec nginx nginx -s reload

echo ""
echo -e "${GREEN}=== セットアップ完了 ===${NC}"
echo -e "${GREEN}HTTPS経由でアクセス可能です: https://$DOMAIN${NC}"
echo ""
echo -e "${YELLOW}注意: Basic認証を設定する必要があります${NC}"
echo -e "${YELLOW}次のコマンドを実行してください:${NC}"
echo -e "${YELLOW}  ./create-htpasswd.sh${NC}"

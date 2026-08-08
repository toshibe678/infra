#!/bin/bash
# Git Hooks セットアップスクリプト
# 
# このスクリプトは、リポジトリ内のhookファイルを.git/hooks/にインストールします。
# 別端末でリポジトリをcloneした後、このスクリプトを実行してください。

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
GIT_HOOKS_DIR="$REPO_ROOT/.git/hooks"
SOURCE_HOOKS_DIR="$SCRIPT_DIR/hooks"

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}🔧 Git Hooks セットアップ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Gitリポジトリの確認
if [ ! -d "$GIT_HOOKS_DIR" ]; then
    echo -e "${RED}エラー: .git/hooks ディレクトリが見つかりません${NC}"
    echo "このスクリプトはGitリポジトリのルートから実行してください"
    exit 1
fi

# hooks ディレクトリの確認
if [ ! -d "$SOURCE_HOOKS_DIR" ]; then
    echo -e "${RED}エラー: scripts/hooks/ ディレクトリが見つかりません${NC}"
    exit 1
fi

# インストールするhookファイルのリスト
HOOKS=$(ls "$SOURCE_HOOKS_DIR")

if [ -z "$HOOKS" ]; then
    echo -e "${YELLOW}インストールするhookファイルがありません${NC}"
    exit 0
fi

echo -e "${GREEN}以下のhookをインストールします:${NC}"
echo "$HOOKS" | while read -r hook; do
    echo "  - $hook"
done
echo ""

read -p "続行しますか？ (Y/n): " -r
echo ""
if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo -e "${YELLOW}キャンセルしました${NC}"
    exit 0
fi

# hookファイルをコピー
INSTALLED=0
SKIPPED=0

for hook in $HOOKS; do
    SOURCE="$SOURCE_HOOKS_DIR/$hook"
    TARGET="$GIT_HOOKS_DIR/$hook"
    
    # 既存ファイルの確認
    if [ -f "$TARGET" ]; then
        echo -e "${YELLOW}⚠ $hook は既に存在します${NC}"
        read -p "上書きしますか？ (y/N): " -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}  スキップしました${NC}"
            ((SKIPPED++))
            continue
        fi
        
        # バックアップを作成
        cp "$TARGET" "$TARGET.backup.$(date +%Y%m%d_%H%M%S)"
        echo -e "${BLUE}  バックアップを作成しました${NC}"
    fi
    
    # コピーして実行権限を付与
    cp "$SOURCE" "$TARGET"
    chmod +x "$TARGET"
    echo -e "${GREEN}✅ $hook をインストールしました${NC}"
    ((INSTALLED++))
done

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}完了${NC}"
echo -e "  インストール: $INSTALLED 個"
if [ $SKIPPED -gt 0 ]; then
    echo -e "  スキップ: $SKIPPED 個"
fi
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${GREEN}Git Hooksが有効になりました！${NC}"
echo "次回のgit commitから自動的に実行されます"

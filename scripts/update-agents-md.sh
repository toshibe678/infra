#!/bin/bash
# AGENTS.md自動更新スクリプト
# 
# 使い方:
#   ./scripts/update-agents-md.sh
#   または git commit時に自動実行（.git/hooks/prepare-commit-msg）

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
AGENTS_MD="$REPO_ROOT/AGENTS.md"

# 色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ヘッダー表示
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}📝 AGENTS.md 自動更新ツール${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Git変更内容を確認
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}エラー: Gitリポジトリではありません${NC}"
    exit 1
fi

# ステージングされた変更を取得
STAGED_FILES=$(git diff --cached --name-status 2>/dev/null || echo "")

if [ -z "$STAGED_FILES" ]; then
    echo -e "${YELLOW}ステージングされた変更がありません${NC}"
    echo "使い方: git add <files> してから実行してください"
    exit 0
fi

# 変更ファイルを表示
echo -e "${GREEN}ステージングされた変更:${NC}"
echo "$STAGED_FILES" | while read -r status file; do
    case $status in
        A) echo -e "  ${GREEN}[追加]${NC} $file" ;;
        M) echo -e "  ${YELLOW}[変更]${NC} $file" ;;
        D) echo -e "  ${RED}[削除]${NC} $file" ;;
        R*) echo -e "  ${BLUE}[移動]${NC} $file" ;;
        *) echo -e "  [$status] $file" ;;
    esac
done
echo ""

# 変更カテゴリを推測
CATEGORY=""
if echo "$STAGED_FILES" | grep -q "^[AM].*service/"; then
    CATEGORY="サービス定義"
elif echo "$STAGED_FILES" | grep -q "^[AM].*ansible/"; then
    CATEGORY="構成管理（Ansible）"
elif echo "$STAGED_FILES" | grep -q "^[AM].*terraform/"; then
    CATEGORY="インフラ管理（Terraform）"
elif echo "$STAGED_FILES" | grep -q "^[AM].*cdk/"; then
    CATEGORY="インフラ管理（CDK）"
elif echo "$STAGED_FILES" | grep -q "^[AM].*docker/"; then
    CATEGORY="コンテナ定義"
elif echo "$STAGED_FILES" | grep -q "^[AM].*\.md$"; then
    CATEGORY="ドキュメント"
fi

# ユーザー入力を促す
echo -e "${BLUE}変更内容をAGENTS.mdに記録します${NC}"
echo ""

if [ -n "$CATEGORY" ]; then
    echo -e "推測されたカテゴリ: ${GREEN}$CATEGORY${NC}"
    read -p "このカテゴリで良いですか？ (Y/n): " -r
    echo ""
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        CATEGORY=""
    fi
fi

if [ -z "$CATEGORY" ]; then
    echo "カテゴリを選択してください:"
    echo "  1) サービス定義"
    echo "  2) 構成管理（Ansible）"
    echo "  3) インフラ管理（Terraform/CDK）"
    echo "  4) コンテナ定義"
    echo "  5) セキュリティ"
    echo "  6) ドキュメント"
    echo "  7) その他"
    read -p "選択 (1-7): " -r
    
    case $REPLY in
        1) CATEGORY="サービス定義" ;;
        2) CATEGORY="構成管理（Ansible）" ;;
        3) CATEGORY="インフラ管理（Terraform/CDK）" ;;
        4) CATEGORY="コンテナ定義" ;;
        5) CATEGORY="セキュリティ" ;;
        6) CATEGORY="ドキュメント" ;;
        7) CATEGORY="その他" ;;
        *) CATEGORY="その他" ;;
    esac
fi

echo ""
echo -e "${GREEN}変更内容を入力してください:${NC}"
echo "（複数行可、Ctrl+Dで終了）"
echo ""

DESCRIPTION=$(cat)

if [ -z "$DESCRIPTION" ]; then
    echo -e "${RED}変更内容が入力されませんでした${NC}"
    exit 1
fi

# 日付を取得
DATE=$(date +"%Y-%m-%d")

# AGENTS.mdを更新
echo ""
echo -e "${YELLOW}AGENTS.mdを更新中...${NC}"

# バックアップを作成
cp "$AGENTS_MD" "$AGENTS_MD.bak"

# 「完了」セクションに追記（最新が上になるよう）
# ※簡易実装のため、手動で適切な位置に挿入することを推奨
TEMP_FILE=$(mktemp)

# 完了セクションを探して、その後に追記
awk -v date="$DATE" -v category="$CATEGORY" -v desc="$DESCRIPTION" '
/^## 完了$/ {
    print
    getline
    print
    print "* " date " - " category
    # 説明を複数行で追加
    split(desc, lines, "\n")
    for (i in lines) {
        if (lines[i] != "") {
            print "  - " lines[i]
        }
    }
    print
}
{ print }
' "$AGENTS_MD" > "$TEMP_FILE"

mv "$TEMP_FILE" "$AGENTS_MD"

echo -e "${GREEN}✅ AGENTS.mdを更新しました${NC}"
echo ""
echo -e "${BLUE}変更内容:${NC}"
echo -e "  カテゴリ: ${GREEN}$CATEGORY${NC}"
echo -e "  日付: ${GREEN}$DATE${NC}"
echo -e "  説明:"
echo "$DESCRIPTION" | sed 's/^/    /'
echo ""

# Git addを実行
read -p "AGENTS.mdをステージングに追加しますか？ (Y/n): " -r
echo ""
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    git add "$AGENTS_MD"
    echo -e "${GREEN}✅ AGENTS.mdをステージングに追加しました${NC}"
else
    echo -e "${YELLOW}スキップしました。手動でgit add AGENTS.mdを実行してください${NC}"
fi

echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}完了${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

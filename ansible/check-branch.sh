#!/bin/bash
# develop-setting の作業ブランチを取得した状態で、対象ホスト（既定: dev）に --check -D を実行する。
# 変更を develop-setting の main へ取り込む前の確認に使う（取り込み後は利用側が main の最新を取得するため遅い）。
# 使い方: ./check-branch.sh <develop-setting の作業ブランチ> [対象ホストまたはグループ]
# 一時的な requirements ファイルを使うため、リポジトリの requirements.yml は変更しない。
set -euo pipefail

BRANCH="${1:?作業ブランチ名を指定してください (例: ./check-branch.sh feature/x)}"
LIMIT="${2:-vpn-dev.abe365.org}"

# ブランチ名をそのまま sed に渡すため、使える文字を限定する
if [[ ! "${BRANCH}" =~ ^[A-Za-z0-9._/-]+$ ]]; then
  echo "ブランチ名に使えない文字が含まれています: ${BRANCH}" >&2
  exit 1
fi

cd "$(dirname "$0")"

REQ="$(mktemp)"
trap 'rm -f "${REQ}"' EXIT

# develop_setting の src の直後に version を足す
sed "s|^\(    src: https://github.com/toshibe678/develop-setting.git\)\$|\1\n    version: ${BRANCH}|" requirements.yml > "${REQ}"
grep -q "version: ${BRANCH}" "${REQ}" || { echo "requirements.yml に develop_setting の src が見つかりません" >&2; exit 1; }

ansible-galaxy install -r "${REQ}" -p roles --force
ansible-playbook -D -C -i hosts_all.yml -l "${LIMIT}" all.yml --vault-password-file ~/.ssh/.ansible_vault_pass

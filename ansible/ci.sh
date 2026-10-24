#!/bin/bash
# 取得（ansible-galaxy）の失敗を握りつぶさない。role が欠けたまま ansible-playbook を始めない
set -euo pipefail
# 作る鍵・パスワードのファイルは、作成の時点から自分だけが読める権限にする
umask 077

mkdir -p ~/.ssh
cat <<EOF > ~/.ssh/config
Host *
  ForwardAgent yes
  ServerAliveInterval 30
  ServerAliveCountMax 5
  GSSAPIAuthentication no
  StrictHostKeyChecking no
  UserKnownHostsFile=/dev/null
EOF
cd `dirname $0`

ansible-galaxy collection install -r requirements.yml --force-with-deps
ansible-galaxy install -r requirements.yml -p roles --force

echo -e "${TOSHI_KEY:-}" > ~/.ssh/id_ed25519
chmod 600 ~/.ssh/id_ed25519
echo -e "${VAULT_PASS:-}" > ~/.ssh/.ansible_vault_pass
chmod 600 ~/.ssh/.ansible_vault_pass

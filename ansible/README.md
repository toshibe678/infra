# ansible
```shell
ansible-galaxy install -r requirements.yml -p roles --force
ansible-galaxy collection install -r requirements.yml --force-with-deps
ansible-playbook -D -i hosts_all.yml --ask-vault-pass all.yml
```

動作を保証する ansible-core の最小の版は 2.16 です（`develop-setting` と同じ）。CI のコンテナは版を固定せず最新を使います。

### develop 関連の設定（develop-setting への集約）
開発言語・ツール・シェル設定などの develop 関連は `develop-setting`（`develop_setting` role）が唯一の定義元です。
`develop.yml` が `develop_setting_profile: server` で、**本番(prod)を除く** `linux` に適用します（`hosts: linux:!prod`）。
`ansible_os_family` などの fact を直接参照するため、`ansible.cfg` の `inject_facts_as_vars` は `True` のままにします（`False` にすると壊れます）。
本番(`vpn.toshi.click`)は第1段階では対象外で、第2段階で追加するときに再度の承認が要ります。

`develop-setting` の `main` が壊れていると、`ci.sh` の取得で止まります（本番の自動適用も止まり、Slack に通知されます）。
変更を `develop-setting` の `main` へ取り込む前に、作業ブランチを取得した状態で dev に `--check -D` を実行して確認してください。
```shell
make check-branch BRANCH=<develop-setting の作業ブランチ> [LIMIT=<対象ホストまたはグループ>]
# 既定の対象は vpn-dev.abe365.org。一時的な requirements ファイルを使うため、このリポジトリの requirements.yml は変わりません
```

CI は失敗時に Slack へ通知します（GitHub の secrets に `SLACK_WEBHOOK_URL` を登録）。鍵と vault パスワードは成否にかかわらず削除します。
静的検証（構文検査と ansible-lint）は `.github/workflows/ansible-lint.yml` と `make lint` です。

### test
```shell
ansible-playbook -D -l dev -i hosts_all.yml --ask-vault-pass all.yml
or
ansible-playbook -D -l dev -i hosts_all.yml  --vault-password-file ~/.ssh/.ansible_vault_pass all.yml
```

# shigure初期構築
```shell
ansible-playbook -D -l shigure -i hosts_all.yml all.yml --ask-vault-password -C
```
ansible-playbook -D -l vpn -i hosts_all.yml all.yml  --ask-vault-password

ansible-playbook -D -l raspi.test,rasdev.test -i hosts_all.yml all.yml --ask-become-pass --ask-vault-password


### 接続できない場合
1. 公開鍵を登録
   * `mkdir -p ~/.ssh && chmod 700 ~/.ssh`
   * `touch ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys && vi ~/.ssh/authorized_keys `
2. sudo設定
   * `sudo bash -c 'echo "toshi ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/toshi'`


### vpnサーバー作成（VPS）
```shell
ansible-playbook -D -l vpn -i hosts_all.yml all.yml -u root --ask-pass --ask-vault-password
```

```shell
ansible-vault encrypt /path/to/file
```

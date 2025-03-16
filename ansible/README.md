# ansible
```shell
ansible-galaxy install -r requirements.yml -p roles --force
ansible-galaxy collection install -r requirements.yml --force-with-deps
ansible-playbook -D -i hosts_all.yml --ask-vault-pass all.yml
```

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
ansible-playbook -D -l raspi -i hosts_all.yml all.yml  --ask-vault-password  --ask-become-pass  -t runner

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

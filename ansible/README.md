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
ansible-playbook -D -l shigure -i hosts_all.yml all.yml  --ask-pass --ask-become-pass --ask-vault-password -C
```

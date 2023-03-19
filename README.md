# infra
オンプレインフラ及びクラウドインフラの管理

下記については別リポジトリにて管理
* [WSLの構成管理(ubuntu)](https://github.com/toshi-click/ansible_for_wsl)
* [raspiなどのIoT機器の初期構築(ubuntu)](https://github.com/toshi-click/server-init)


### エラー対応
vagrant up時に下記のようなエラーが出る場合がある
```shell
VBoxManage.exe: error: Failed to create the host-only adapter
```
C:\Program Files\Oracle\VirtualBox\drivers\network\netadp6へ移動しVBoxNetAdp6.infを右クリック→インストールすると動く場合がある

vagrantで立ち上げたVMでテストすつ場合
```shell
ansible-playbook -D -l dev -i hosts_all.yml all.yml --ask-vault-password
```

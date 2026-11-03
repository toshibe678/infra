# Proxmox VM 初期設定

Proxmoxで作成したVMの初期設定を自動化するAnsibleプレイブック。

## 対象OS
- Ubuntu 22.04
- Ubuntu 24.04
- Ubuntu 26.04

## 前提条件
1. VMが起動済みでSSH接続可能
2. 一般ユーザー（toshi）でSSH鍵ログイン可能
3. 初回実行時はsudoパスワードが必要

## 実行するタスク
- sudoパスワード不要の設定
- Dockerのインストール（apt）
- GitHubリポジトリのクローン（scripts, infraなど）
- 基本的なシステム設定

## 使い方

### 初回セットアップ（sudoパスワードが必要な場合）
```bash
# ホスト追加
vi hosts_proxmox_vm.yml

# Vaultパスワードファイル準備（ansible/と同じものを使用）
# ~/.ssh/.ansible_vault_pass が存在することを確認

# 実行（初回はsudoパスワードを聞かれる）
ansible-playbook -i hosts_proxmox_vm.yml vm_init.yml --ask-become-pass --ask-vault-password

# またはDockerコンテナから
cd /path/to/infra
docker compose run --rm ansible bash
cd /ansible/proxmox-vm-init
ansible-playbook -i hosts_proxmox_vm.yml vm_init.yml --ask-become-pass --ask-vault-password
```

### 2回目以降（sudo NOPASSWD設定後）
```bash
ansible-playbook -i hosts_proxmox_vm.yml vm_init.yml
```

### チェックモード（変更を適用せずに確認）
```bash
ansible-playbook -i hosts_proxmox_vm.yml vm_init.yml -C
```

### 特定のホストのみ対象
```bash
ansible-playbook -i hosts_proxmox_vm.yml vm_init.yml -l vm01.example.com
```

## カスタマイズ

### クローンするリポジトリの追加
`group_vars/all.yml` の `git_repositories` に追加:

```yaml
git_repositories:
  - name: scripts
    repo: git@github.com:toshibe678/scripts.git
    dest: "/home/{{ manage_user_name }}/scripts"
  - name: your-repo
    repo: git@github.com:yourusername/your-repo.git
    dest: "/home/{{ manage_user_name }}/your-repo"
```

### 変数のカスタマイズ
`group_vars/all.yml` を編集して、ユーザー名や設定を変更できます。

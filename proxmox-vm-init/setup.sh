#!/bin/bash
# Proxmox VM初期設定のクイックセットアップスクリプト

set -e

echo "========================================="
echo "Proxmox VM Initial Setup"
echo "========================================="
echo ""

# 引数チェック
if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -c, --check     Dry-run mode (no changes)"
    echo "  -h, --help      Show this help message"
    echo ""
    echo "Before running:"
    echo "  1. Edit hosts_proxmox_vm.yml and add your VM hosts"
    echo "  2. Ensure ~/.ssh/.ansible_vault_pass exists"
    echo "  3. Ensure SSH key authentication is working"
    echo ""
    echo "Examples:"
    echo "  ./setup.sh          # Run initial setup"
    echo "  ./setup.sh --check  # Dry-run mode"
    exit 0
fi

# Docker Composeが利用可能か確認
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed or not in PATH"
    exit 1
fi

# hosts_proxmox_vm.ymlにホストが登録されているか確認
if ! grep -q "ansible_host:" hosts_proxmox_vm.yml; then
    echo "Warning: No hosts found in hosts_proxmox_vm.yml"
    echo "Please edit hosts_proxmox_vm.yml and add your VM hosts before running."
    echo ""
    read -p "Do you want to continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Vaultパスワードファイルの確認
if [ ! -f ~/.ssh/.ansible_vault_pass ]; then
    echo "Warning: ~/.ssh/.ansible_vault_pass not found"
    echo "You will be prompted for the vault password during execution."
fi

# 実行モード
if [ "$1" == "-c" ] || [ "$1" == "--check" ]; then
    echo "Running in CHECK mode (dry-run)..."
    cd .. && make vm-init-check
else
    echo "Running initial setup..."
    echo "You may be prompted for sudo password on first run."
    cd .. && make vm-init
fi

echo ""
echo "========================================="
echo "Setup completed!"
echo "========================================="

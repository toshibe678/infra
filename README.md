# infra
オンプレインフラ及びクラウドインフラの管理

下記については別リポジトリにて管理
* [WSLの構成管理(ubuntu)](https://github.com/toshi-click/ansible_for_wsl)

## 主要コンポーネント

### Ansible - 構成管理
- Linux サーバー、Raspberry Pi クラスターの自動構成
- WireGuard VPN の設定管理
- 詳細: [ansible/README.md](ansible/README.md)

### Terraform - クラウドインフラ
- AWS リソースの管理（S3, CloudFront, ACM）
- GCP の基本設定
- 詳細: [terraform/readme.md](terraform/readme.md)

### AWS CDK - 高度なAWS構成
- マルチアカウント管理 (sso-admin, sso-blog, sso-sandbox)
- 詳細: [cdk/README.md](cdk/README.md)

### Proxmox VM 初期設定
- 新規VM作成後の自動初期構成
- Docker インストール、GitHub リポジトリクローン
- 詳細: [proxmox-vm-init/README.md](proxmox-vm-init/README.md)

### Monitoring Stack
- Prometheus, Grafana, Alertmanager
- 詳細: [monitoring/README.md](monitoring/README.md)

## クイックスタート

```bash
# Terraform
make init && make plan

# Ansible デプロイ
make deploy

# Proxmox VM 初期設定
make vm-init

# Monitoring 起動
cd monitoring && docker-compose up -d
```

## ドキュメント
- **AI エージェント向け**: [AGENTS.md](AGENTS.md) - プロジェクト全体のコンテキスト
- **Claude Code 統合**: [docs/CLAUDE_CODE_SETUP.md](docs/CLAUDE_CODE_SETUP.md) - セルフホストランナーでのClaude Code利用ガイド
- **GitHub Copilot向け**: [.github/copilot-instructions.md](.github/copilot-instructions.md) - 開発ガイドライン

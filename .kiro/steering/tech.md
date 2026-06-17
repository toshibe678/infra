# Technology Stack

## Architecture

ツール実行はすべて Docker コンテナ内で行う（`compose.yml` の `terraform` / `ansible` サービス）。  
コマンドは `Makefile` 経由で統一し、ローカル環境への依存を持ち込まない。

## Core Technologies

| 分野 | 技術 | バージョン方針 |
|------|------|--------------|
| 構成管理 | Ansible | Docker コンテナ実行、Vault 暗号化 |
| IaC (クラウド) | Terraform | Docker コンテナ実行 |
| IaC (AWS高度) | AWS CDK | TypeScript、Node.js |
| コンテナ | Docker / Docker Compose | 各サービス独立 compose.yml |
| DNS | Cloudflare (records.tf) | Terraform 管理 |
| 監視 | Prometheus + Grafana + Node Exporter | 全サービスに統合 |
| LLM プロキシ | LiteLLM | 安定版 Docker イメージ |
| VPN | WireGuard + wgdashboard | ホスト直接動作 |
| セキュリティ | nginx / Let's Encrypt / Basic Auth | 各サービスに共通パターン |

## Development Standards

### Ansible
- ロールベース分割（`ansible/inner_roles/`・`ansible/dependency_roles/`）
- 変数は `group_vars/all/` に集約、ホスト固有は `host_vars/`
- シークレットは Ansible Vault（`~/.ssh/.ansible_vault_pass`）
- 冪等性必須：`-C` フラグでドライラン確認してから本番適用

### Terraform
- Root モジュール → 共通モジュール参照パターン
- `backend.tf` でリモートステート管理
- 適用前 `make check`（fmt + validate）必須

### Docker Compose（service/）
- `.env` で秘匿情報管理、`.env.example` でテンプレート提供
- nginx リバースプロキシ必須（SSL終端・レート制限・セキュリティヘッダー）
- Node Exporter 統合（Prometheus scrape 対応）

### Common Commands
```bash
# Terraform
make init && make plan && make apply

# Ansible（ドライラン → 本番）
make deploy

# Lint
make lint

# VM初期化
make vm-init
```

## Key Technical Decisions

- **ツール実行は Docker 内で完結**: ホスト環境への Terraform/Ansible 直インストールを避ける
- **Cloudflare DNS を IaC 管理**: `terraform/cloudfront_s3_acm/records.tf` で全 DNS レコードを管理
- **VPN ファースト設計**: 内部サービスは WireGuard VPN 越しにアクセス、外部公開は最小限
- **LiteLLM 安定版固定**: `latest` タグ禁止、安定版イメージを明示指定
- **npm / pip レジストリ**: 社内/プライベートレジストリ（flatt.tech）を優先設定

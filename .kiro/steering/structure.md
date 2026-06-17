# Project Structure

## Organization Philosophy

ツール種別ファーストで分割し、各ツールディレクトリ内でさらに用途・環境別に整理する。  
`service/` のみサービス名ファーストで独立 compose 構成をとる。

## Directory Patterns

### IaC ツール群（トップレベル）
**Location**: `ansible/`, `terraform/`, `cdk/`, `cloudformation/`  
**Purpose**: 各ツールの実行コンテキストを完全分離  
**Example**: Ansible は `compose.yml` の `ansible` サービスで実行、Terraform は `terraform` サービスで実行

### Ansible 構造
**Location**: `ansible/`  
**Purpose**: ロールベース構成管理  
```
ansible/
├── all.yml              # メインプレイブック
├── hosts_all.yml        # インベントリ（グループ階層）
├── group_vars/all/      # 全ホスト共通変数
├── host_vars/           # ホスト固有変数（FQDN 単位）
├── inner_roles/         # 独自ロール
└── dependency_roles/    # 外部依存ロール
```
インベントリはグループ階層（linux > vpn/monitoring/home_servers/k8s/raspi）で管理。

### Terraform 構造
**Location**: `terraform/`  
**Purpose**: AWS/GCP リソースの IaC  
```
terraform/
├── root/        # エントリーポイント
├── common/      # 共通モジュール
├── modules/     # 再利用モジュール（gcp/network/organization）
├── blog/        # ブログ用リソース
└── cloudfront_s3_acm/  # CDN + DNS（records.tf で Cloudflare DNS 管理）
```

### ローカルサービス群
**Location**: `service/`  
**Purpose**: ローカルネットワーク提供サービスの Docker Compose 定義  
各サービスは独立ディレクトリ、独立 `docker-compose.yml` を持つ。

```
service/<name>/
├── docker-compose.yml   # 必須
├── README.md            # 必須（セットアップ・環境変数・トラブルシュート）
├── .env.example         # 必須（秘匿情報テンプレート）
├── .gitignore           # .env を除外
└── nginx/               # nginx 設定（SSL終端・リバースプロキシ）
```

現在稼働中サービス: `monitoring`, `siem`, `dify`, `wgdashboard`, `llm-proxy`, `develop`, `ai-test`, `mcp-servers`, `vpn-proxy`

### Docker ビルド用コンテキスト
**Location**: `docker/`  
**Purpose**: `compose.yml` で使うツール実行コンテナの Dockerfile  
```
docker/ansible/   # Ansible 実行環境
docker/named/     # DNS（現在無効）
docker/proxy/     # プロキシ
```

## Naming Conventions

- **サービスディレクトリ**: `kebab-case`（`llm-proxy`, `mcp-servers`）
- **Ansible ホスト**: FQDN（`vpn-dev.abe365.org`, `monitoring.abe365.org`）
- **環境変数ファイル**: `.env`（git 除外）+ `.env.example`（git 管理）
- **Terraform ファイル**: `main.tf`, `output.tf`, `backend.tf`, `provider.tf`（用途別分割）

## Cloudflare DNS との対応

`service/` の各サービスは `terraform/cloudfront_s3_acm/records.tf` で定義された  
`*.abe365.org` サブドメインと対応する。新サービス追加時は DNS レコードも同時に追加する。

| サービス | ドメイン | IP |
|---------|---------|-----|
| monitoring | monitoring.abe365.org | 192.168.100.51 |
| llm-proxy | llm-proxy.abe365.org | 192.168.100.54 |
| mcp-servers | mcp.abe365.org | 192.168.100.57 |
| （以降同様のパターン） | | |

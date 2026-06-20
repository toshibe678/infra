# infra — Agent Teams ガイド

オンプレ及びクラウドのインフラを IaC で協調管理するリポジトリ。
AI エージェントがチームで作業するための運用ガイド。

## 目的とゴール

- 目的: オンプレ及びクラウドのインフラ管理を協調して行う。
- ゴール: 各種 IaC ツール（Ansible / Terraform / AWS CDK / CloudFormation）を駆使し、
  各種ハードウェアやクラウドを設定する。

## チーム構成と役割

コスト最適化のため、チームメイト（Teammates）のモデルにはすべて **sonnet** を指定してスポーンする。

| エージェント | 役割 | 担当エリア |
|---|---|---|
| **A: サーバーサービス担当** | 各サーバーで docker compose で定義する各種サービスを起動・連携 | `service/` |
| **B: 共通設定 / ドメイン / 通信担当** | Ansible でサーバー共通設定を定義、DNS・通信設定 | `ansible/`, `cloudflere/` |
| **C: クラウド担当** | クラウド環境の設定 | `cdk/`, `cloudformation/`, `terraform/` |

## デプロイ方針

- `service/` 配下の docker compose サービスは **Ansible 経由デプロイに統一**する。
  各サービスは `ansible/inner_roles/service_compose` 汎用 role を使い、per-service playbook
  `ansible/<service>.yml` で対象ホストへ冪等に展開する（手本: `ansible/inner_roles/vpn_proxy`）。
- クラウドリソースは Terraform / CDK / CloudFormation で管理する。
- CI/CD は self-hosted runner 上の Ansible/Terraform コンテナから実行する（`.github/workflows/`）。

### サービス → ホスト対応

| service | host |
|---|---|
| vpn-proxy | vpn-proxy.abe365.org |
| dify | dify.abe365.org |
| llm-proxy | llm-proxy.abe365.org |
| mcp-servers | mcp.abe365.org |
| monitoring | monitoring.abe365.org |
| siem | siem.abe365.org |
| wgdashboard | vpn.toshi.click（VPN prod に同居） |

## 業務ルール

- 各メンバーは「共有タスクリスト」を適切に更新・管理し、依存関係を意識して並列で進める。
- ファイルロック（競合）を避けるため、他メンバーのエリアを編集する場合は必ず事前にメッセージ機能で連携する。
- すべてのタスク完了後、全体のビルドとテストがパスすることを確認して最終報告をする。
- 秘密情報（`.env`, credentials 等）はコミットしない（`.gitignore` で管理、値は Ansible Vault へ）。

## 主要ディレクトリ

- `ansible/` — サーバー共通設定、WireGuard VPN、サービスデプロイ role
- `service/` — docker compose サービス群
- `terraform/` — AWS（S3/CloudFront/ACM）・GCP 基本設定
- `cdk/` — AWS マルチアカウント構成
- `cloudformation/` — StackSets 等
- `cloudflere/` — Cloudflare DNS（Terraform）
- `proxmox-vm-init/` — 新規 VM 初期構成

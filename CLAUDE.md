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
  汎用 role `ansible/inner_roles/service_compose` を、**単一の汎用 playbook `ansible/service-deploy.yml`**
  から使い回す。ホスト⇄サービスの対応は inventory の `compose_services` グループに `service_name` で
  持たせ、サービス定義（env / secret_files / healthcheck）は `ansible/vars/services/<service>.yml`
  に置く。新サービス追加は「vars ファイル追加 ＋ inventory に1行」だけで済み、playbook は増やさない。
  - **ファイル配布は `git.yml` に一元化**: `docker-compose.yml` と追跡済み config（nginx.conf 等）は
    各ホストの `~/infra` checkout（`git.yml` が clone/update）を直接使う。`service_compose` role は
    gitignore 対象（`.env` ＋ vault 由来 secret files ＋ 任意で自己署名 SSL 証明書）の生成と
    `docker compose up -d` のみ行い、追跡ファイルの再生成・コピーはしない。
    → デプロイ前に対象ホストで `git.yml`（`--tags git_checkout`）が走っている必要がある（CI も同様）。
  - **任意 SSL**: nginx で TLS 終端するサービス（vpn-proxy 等）は `service_compose_ssl_enabled: true` ＋
    `service_compose_ssl_cn` / `service_compose_ssl_sans` を vars に指定すると、role が初回のみ
    自己署名証明書を host 上に生成する（nginx の backend 設定自体は追跡済み静的ファイル）。
  - 全サービス一括: `ansible-playbook -i hosts_all.yml service-deploy.yml`
  - 個別: `ansible-playbook -i hosts_all.yml service-deploy.yml --limit <host>`
  - **例外**: `dify` のみ（公式サブモジュールの2段構成）個別 playbook `ansible/dify.yml` で管理する。
    vpn-proxy も `compose_services`（`vars/services/vpn-proxy.yml`、SSL 任意機能を使用）に統合済み。
- クラウドリソースは Terraform / CDK / CloudFormation で管理する。
- CI/CD は self-hosted runner 上の Ansible/Terraform コンテナから実行する（`.github/workflows/`）。
  - Ansible デプロイは **`all.yml` を単一エントリポイント**とし `-l <host/group>` で対象を絞る方式。
    `all.yml` が `git.yml`→各サービス（`service-deploy.yml` 等）まで含むため、per-service の変更検知
    ワークフローは作らない（冗長）。
    - `ansible-vpn-deploy.yml`: `ansible/**` push(develop) で `all.yml -l vpn.toshi.click` を自動実行
    - `ansible-manual-deploy.yml`: `workflow_dispatch` で target を選び `all.yml -l <target>` を手動実行
      （`compose_services` グループ選択で集約サービスを一括デプロイ可能）

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

### 秘密変数の規約（Ansible）

秘密値は **`crypt_` prefix** を付けた変数として **ansible-vault で暗号化**し、できるだけ `group_vars`
に定義する。playbook / role 側は **prefix を除去した変数**を参照し、その対応を平文 group_vars で
マップする。3層構成:

1. **暗号値（vault）**: `crypt_<name>: <secret>` を暗号化して保持
   - service 用: `ansible/group_vars/all/service_crypt_vars.yml`（雛形→ `ansible-vault encrypt`）
   - 既存共通: `ansible/group_vars/all/crypt_vars.yml`
2. **平文マッピング**: `ansible/group_vars/all/service_vars.yml` に `<name>: "{{ crypt_<name> }}"`
   （prefix を除去した変数名）
3. **参照**: playbook / `vars/services/<service>.yml` / role は prefix なし `{{ <name> }}` を参照

例: vault `crypt_mcp_servers_db_password` → `service_vars.yml` で
`mcp_servers_db_password: "{{ crypt_mcp_servers_db_password }}"` → `vars/services/mcp-servers.yml` で
`DB_PASSWORD: "{{ mcp_servers_db_password }}"`。
service の `.env` は `service_compose_env`（`vars/services/<service>.yml`）の各キーから生成されるため、
各サービスの `service_compose_env` は対応する `docker-compose.yml` の `${VAR}` 参照を漏れなく網羅すること。

## 主要ディレクトリ

- `ansible/` — サーバー共通設定、WireGuard VPN、サービスデプロイ role
- `service/` — docker compose サービス群
- `terraform/` — AWS（S3/CloudFront/ACM）・GCP 基本設定
- `cdk/` — AWS マルチアカウント構成
- `cloudformation/` — StackSets 等
- `cloudflere/` — Cloudflare DNS（Terraform）
- `proxmox-vm-init/` — 新規 VM 初期構成

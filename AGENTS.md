# 🧭 Project Overview
このリポジトリは、複数環境にまたがる Infrastructure as Code (IaC) の統合管理を目的として構築されています。
Ansible・Terraform・Docker・AWS CDK を中心に、構成管理・クラウドプロビジョニング・コンテナ化を一貫した形で自動化します。
プロジェクトの最終目標は、自動化された安全なインフラ運用基盤の確立です。

# 🎯 Core Objectives
* インフラ構成をコードで一元管理
* デプロイと設定の自動化
* 環境間の一貫性確保
* 明確で再現可能な構造の維持
* セキュアな構成とアクセス制御

## In Scope
* Infrastructure provisioning
* Server configuration management
* Container orchestration
* Network configuration
* Security & CI/CD infrastructure

## Out of Scope
* アプリケーションコード・ビジネスロジック
* プロダクトデータ管理・エンドユーザドキュメント

# 🧩 Active Context — 現在の開発フォーカス
## アクティブ領域
1. インフラコード管理：メモリーバンク構築、ドキュメント構造化
2. 構成管理：Ansible Playbook 構造整理、環境別設定
3. クラウドリソース：Terraform＋CDKハイブリッド運用
4. ローカルサービス管理：service/フォルダ構造の整備とDocker Compose定義
## 進行中の決定
* ドキュメント構造の統一化（Core/Component Docs分離）
* 開発・本番環境分離
* 環境変数ベース設定とセキュリティ分離
* IaCと自動化の更なる拡充
* ローカルネットワーク提供サービスのコンテナ化とDNS統合管理
## 改善目標
* 自動化範囲の拡張
* テストカバレッジ向上
* セキュリティ強化と監視体制の確立

# 🏗 Product Context — 目的と価値
## 解決する課題
| 課題           | 解決策                  | 効果        |
| ------------ | -------------------- | --------- |
| 手動構成の不整合     | Ansible自動化           | 一貫性維持     |
| AWSリソースの管理負荷 | Terraform/CDKによるIaC化 | 再現性・可搬性   |
| サービス分離と移植性   | Docker化              | 環境非依存運用   |
| ネットワーク複雑化    | コード化ネットワーク           | セキュア・再現可能 |

## ユーザー価値
* 管理者向け：明快なドキュメント・簡易セットアップ・迅速な復旧
* 開発者向け：統一環境・シンプルなデプロイ・容易なアクセス

## 成果物
1. 自動構築済みの環境
2. 標準化された構成管理
3. セキュアなIaC
4. 効率的なオペレーション


# 📊 Progress — 進行状況とマイルストーン
## 完了
* リポジトリ構造・Ansible/Terraform/Docker基盤整備
* ドキュメントテンプレート完成（Project Brief, System Patterns, Technical Context）
* service/フォルダの4サービス実装完了（dify, llm-proxy, develop, ai-test）
  - 各サービスのdocker-compose.yml、README.md、.env.example作成
  - llm-proxy: マルチクラウドLLM統合（AWS Bedrock、GCP VertexAI対応）
  - llm-proxy: 自動フォールオーバー機能実装（Bedrock→VertexAI）
  - develop: 統合開発環境（VS Code、JupyterLab、DB群）
  - ai-test: AI/ML実験環境（Ollama、MLflow、Qdrant）
  - dify: AIアプリケーション開発プラットフォーム
* wgdashboard: WireGuard管理ダッシュボード実装完了
  - ホストで動作中のWireGuardをDocker経由で管理
  - network_mode: hostでホストのWireGuard設定にアクセス
  - Let's Encrypt SSL自動更新実装（certbotコンテナ、init-letsencrypt.sh）
  - Basic認証による二段階認証（create-htpasswd.sh）
  - レート制限（10req/s、ログイン3req/分）
  - セキュリティヘッダー（HSTS、CSP、X-Frame-Options等）
  - HTTPS強制リダイレクト
  - グローバルアクセス対応（CONOHA VPS）
* 全サービスにnginxリバースプロキシ追加完了

## 進行中
* AWS CDKによる追加リソース管理
* CloudFront 最適化・コンテナ拡充
* 環境変数・シークレットの標準化

## 今後の課題
* service/配下のサービス本番デプロイ
* llm-proxyの使用量監視とコスト最適化
* CI/CD パイプライン強化
* スケーラビリティ・監視体制確立（既存monitoring/siemとの統合）
* バックアップとコスト最適化
* Fail2Ban導入（wgdashboard、他サービス）

## 学びと進化
* 早期ドキュメント化の重要性
* モジュール化による再利用性
* 自動化による人的負荷軽減

# 🧱 System Patterns — 構造・設計パターン
## 全体構造
``` graph TD
    A[Infrastructure as Code] --> B[Ansible / 構成管理]
    A --> C[Terraform / CDK]
    A --> D[Docker / コンテナ化]
```

## 構成要素
* Ansible：ロールベース分割 + group_vars/host_vars による変数管理
* Terraform：Root-Common-Network-Blog-CloudFront構成
* Docker：Proxy, n8n, Named, Terraform/Ansible実行環境
* Cloudflare：DNSレコード管理（ローカルネットワーク名前解決を含む）
* Service：ローカルネットワーク提供サービスのDocker Compose定義

## ローカルネットワーク提供サービス
`service/` フォルダには、Cloudflare DNS（records.tf）で定義されたabe365.orgサブドメインで名前解決可能な各サービスのインフラ定義を配置します。

### サービス一覧と構成
| サービス名 | サブドメイン | IPアドレス | 用途 |
|-----------|------------|-----------|------|
| Kubernetes Cluster | k8s1-3.abe365.org | 192.168.100.11-13 | k8sクラスタノード |
| Monitoring | monitoring.abe365.org | 192.168.100.51 | Grafana/Prometheus監視基盤 |
| Dify | dify.abe365.org | 192.168.100.52 | AIアプリケーション開発プラットフォーム |
| VPN Dev | vpn-dev.abe365.org | 192.168.100.53 | WireGuard管理ダッシュボード（WGDashboard） |
| LLM Proxy | llm-proxy.abe365.org | 192.168.100.54 | 統合LLM APIプロキシ（OpenAI/Anthropic/Azure/AWS Bedrock/GCP VertexAI対応、自動フォールオーバー機能付き） |
| Develop | develop.abe365.org | 192.168.100.55 | 開発環境 |
| AI Test | ai-test.abe365.org | 192.168.100.56 | AI実験環境 |

### サービスフォルダ構造
```
service/
├── monitoring/        # 既存：監視基盤（Grafana, Prometheus）
│   ├── docker-compose.yml
│   ├── README.md
│   └── config/
├── siem/             # 既存：セキュリティ情報・イベント管理
│   ├── docker-compose.yml
│   └── README.md
├── dify/             # ✓完成：AIアプリケーション開発（Dify Platform）
│   ├── docker-compose.yml
│   ├── README.md
│   ├── .env.example
│   └── nginx/
├── wgdashboard/      # ✓完成：WireGuard管理ダッシュボード
│   ├── docker-compose.yml
│   ├── README.md
│   ├── .env.example
│   ├── .gitignore
│   └── nginx/
├── llm-proxy/        # ✓完成：統合LLM APIプロキシ（LiteLLM）
│   ├── docker-compose.yml
│   ├── README.md
│   ├── .env.example
│   ├── .gitignore
│   └── config/
│       └── config.yaml.example
├── develop/          # ✓完成：統合開発環境
│   ├── docker-compose.yml
│   ├── README.md
│   └── .env.example
└── ai-test/          # ✓完成：AI/ML実験環境
    ├── docker-compose.yml
    ├── README.md
    └── .env.example
```

### サービス定義の原則
1. **各サービスは独立したdocker-compose.ymlを持つ**
   - サービス単位でのデプロイ・管理を可能にする
   - 環境変数は `.env` ファイルで管理
   - `.env.example` で環境変数テンプレートを提供
2. **DNS名前解決との連携**
   - Cloudflare records.tfで定義されたドメイン名を使用
   - ローカルネットワーク内で一貫した名前解決を実現
3. **ドキュメント必須**
   - 各サービスディレクトリにREADME.mdを配置
   - セットアップ手順、依存関係、環境変数を明記
   - トラブルシューティング・セキュリティガイドを含む
4. **マルチクラウド対応**（llm-proxyの場合）
   - AWS Bedrock、GCP VertexAI等、複数のクラウドプロバイダー対応
   - クォータ制限時の自動フォールオーバー機能
   - 使用量ベースのロードバランシング

## 設計指針
1. モジュール化：再利用性・責務分離・テスト容易化
2. 自動化：手動操作削減・一貫した実行・冪等性
3. セキュリティ：最小権限・暗号化・監査可能性

# ⚙️ Technical Context — 技術と開発環境
## 使用技術
| 分野   | 主技術                                  | 補足              |
| ---- | ------------------------------------ | --------------- |
| 構成管理 | Ansible                              | カスタムロール＋Vault対応 |
| インフラ | Terraform / AWS CDK / CloudFormation | IaCの多層管理        |
| コンテナ | Docker / Docker Compose              | マルチコンポーネント構成    |
| クラウド | AWS (Bedrock) / GCP (VertexAI)       | マルチクラウドLLM統合   |
| LLMプロキシ | LiteLLM                              | 統一API・フォールオーバー |
| セキュリティ | Let's Encrypt / nginx / Fail2Ban     | SSL自動更新・レート制限 |
| 開発言語 | Python / TypeScript                  | CLI + CDK実装     |

## 必須依存
* Docker / Docker Compose
* Terraform
* Ansible
* AWS CLI
* Node.js (CDK用)

## 実行フロー
``` bash
git clone <repo>
cd infra-repo
terraform init && terraform plan
ansible-playbook -i hosts playbook.yml
docker-compose up -d
```

## セキュリティと運用
* シークレット：Vault, 環境変数, AWS KMS
* アクセス制御：IAM・ネットワーク分離・最小権限原則
* 監査：CloudTrail・アクセスログ・監査ログ保持

# 🚀 Next Steps
| 期間 | 目標                                   |
| -- | ------------------------------------ |
| 短期 | メモリーバンク完成・自動化拡充・Ansible/Terraform最適化 |
| 中期 | モニタリング導入・スケーラビリティ改善・CI/CD強化          |
| 長期 | 運用効率最適化・コスト管理・継続的改善体制確立              |

# 🧠 Agent Summary
この agent.md は、インフラ自動化リポジトリの知識ベースとして機能し、Claude Code や他のLLMエージェントが「プロジェクト背景・技術文脈・進行状況」を理解した上で応答・修正提案を行うための コンテキスト統合ファイル です。



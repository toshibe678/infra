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
## 進行中の決定
* ドキュメント構造の統一化（Core/Component Docs分離）
* 開発・本番環境分離
* 環境変数ベース設定とセキュリティ分離
* IaCと自動化の更なる拡充
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

## 進行中
* AWS CDKによる追加リソース管理
* CloudFront 最適化・コンテナ拡充
* 環境変数・シークレットの標準化

## 今後の課題
* CI/CD パイプライン強化
* スケーラビリティ・監視体制確立
* バックアップとコスト最適化

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
| コンテナ | Docker                               | マルチコンポーネント構成    |
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



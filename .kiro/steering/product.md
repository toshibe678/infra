# Product Overview

オンプレミス・クラウド両環境にまたがるインフラを Infrastructure as Code で一元管理するプラットフォーム。  
Ansible・Terraform・Docker Compose を核に、構成管理・プロビジョニング・ローカルサービス運用を自動化する。

## Core Capabilities

- **構成管理の自動化**: Ansible によるロールベースのサーバー設定（Linux・Raspberry Pi・VPN・K8s）
- **クラウドIaC**: Terraform（AWS/GCP）と AWS CDK によるインフラプロビジョニング
- **ローカルサービス運用**: Docker Compose で定義したサービス群（AI・監視・開発環境）を DNS と統合して提供
- **LLM統合**: LiteLLM を介したマルチクラウド LLM プロキシ（AWS Bedrock / GCP VertexAI・自動フォールオーバー）
- **セキュリティ基盤**: WireGuard VPN・Let's Encrypt SSL・nginx リバースプロキシ・Prometheus/Grafana 監視

## Target Use Cases

- 自宅ホームサーバー群の一括構成管理（abe365.org サブドメイン）
- AWS/GCP クラウドリソースのコード管理・再現可能なデプロイ
- AI 実験・開発環境のセルフホスト（Dify・Ollama・JupyterLab・MCP サーバー）
- WireGuard VPN 越しの安全なアクセスと内部ルーティング

## Value Proposition

手動構成をなくし「コードが唯一の真実」とする。環境間の差異ゼロ・迅速な復旧・監査可能な変更履歴を実現する。

# Technical Context: Technologies & Development Setup

## 使用技術スタック

### 1. 構成管理
- **Ansible**
  - バージョン管理: requirements.yml
  - カスタムロール
  - 依存ロール
    - GitHub Actions Runner
    - WireGuard

### 2. クラウドインフラストラクチャ
- **Terraform**
  - AWS Provider
  - モジュール構成
  - ステート管理
- **AWS CDK**
  - TypeScript実装
  - CloudFormation生成
- **CloudFormation**
  - スタックセット管理
  - テンプレート

### 3. コンテナ化
- **Docker**
  - カスタムイメージ
  - コンポーネント
    - Ansible実行環境
    - n8n
    - Named
    - Proxy
    - Terraform実行環境

## 開発環境セットアップ

### 1. 必要な依存関係
```bash
# Required Tools
- Docker & Docker Compose
- Terraform
- Ansible
- AWS CLI
- Node.js (CDKのため)
```

### 2. 環境変数設定
```bash
# Core Environment Variables
- AWS credentials
- Terraform variables
- Ansible variables
```

### 3. 開発フロー
1. リポジトリクローン
2. 依存関係インストール
3. 環境変数設定
4. ローカル環境構築

## 技術的制約

### 1. バージョン要件
- Ansible: 2.x以上
- Terraform: 1.x以上
- Docker Compose: 2.x
- Node.js: 16.x以上

### 2. 実行環境要件
- Linux/Unix環境
- Python 3.x
- SSH接続性
- 適切な権限設定

### 3. ネットワーク要件
- AWS APIアクセス
- コンテナ間通信
- 外部サービス接続

## ツール使用パターン

### 1. Ansible実行
```bash
# プレイブック実行
ansible-playbook -i hosts playbook.yml

# 暗号化変数
ansible-vault edit group_vars/all/vault.yml
```

### 2. Terraform操作
```bash
# 初期化とプラン
terraform init
terraform plan

# 適用
terraform apply
```

### 3. Docker管理
```bash
# 環境構築
docker-compose up -d

# イメージビルド
docker build -t custom-image .
```

## 依存関係管理

### 1. Ansibleロール
- requirements.yml による管理
- Galaxy roles の利用
- カスタムロールの開発

### 2. パッケージ依存関係
- package.json (CDK)
- Dockerfile 依存関係
- Terraform providers

### 3. バージョン制御
- Git によるコード管理
- タグ付けとリリース管理
- 依存関係のバージョン固定

## セキュリティ考慮事項

### 1. シークレット管理
- Ansible Vault
- 環境変数
- AWS KMS

### 2. アクセス制御
- IAM ポリシー
- ネットワークセグメンテーション
- 最小権限原則

### 3. 監査とロギング
- AWS CloudTrail
- システムログ
- アクセスログ

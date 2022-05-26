# Terraform関連の読み物
## terraformの実行
#### AWSCLIインストール～設定
```bash
$ sudo apt install python3-pip
$ sudo apt install awscli
$ aws configure
AWS Access Key ID [None]: 自分が設定したもの
AWS Secret Access Key [None]: 自分が設定したもの
Default region name [None]: ap-northeast-1
Default output format [None]: text
```

#### dockerで実行
```bash
AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id)
AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key)
AWS_DEFAULT_REGION=$(aws configure get region)
docker pull hashicorp/terraform:0.15.3
cd this_repository
docker run -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION -v $(pwd):/terraform -w /terraform -it --entrypoint=ash hashicorp/terraform:0.15.4

# terraformの実行を事前準備のDockerfileを使用して行う場合
```bash
docker build -t terraform ./
docker run -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY -e AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION -v $(pwd)/terraform:/terraform -w /terraform -it terraform:latest

# tflintのローカル実行
tflint --config ./lint/.tflint.hcl;
```

# プロジェクトの初期化
terraform init -var "access_key=${AWS_ACCESS_KEY_ID}" -var "secret_key=$AWS_SECRET_ACCESS_KEY"

# terraformerで既存設定インポート
terraformer import aws --resources=*
terraformer import aws --resources=organization

# terraformのフォーマット
terraform fmt -recursive
# フォーマット済みかチェック
terraform fmt -recursive -check

# terraform syntax check
terraform validate
find . -type f -name '*. tf' -exec dirname {} \; | sort -u | xargs -I {} terraform validate {}

# オートコンプリートのインストール
terraform-install-autocomplete

# lint
tflint

# terraform 実行計画の確認
terraform plan -var "access_key=${AWS_ACCESS_KEY_ID}" -var "secret_key=$AWS_SECRET_ACCESS_KEY"

# terraformの適用
terraform apply -var "access_key=${AWS_ACCESS_KEY_ID}" -var "secret_key=$AWS_SECRET_ACCESS_KEY"
terraform apply -refresh-only -var "access_key=${AWS_ACCESS_KEY_ID}" -var "secret_key=$AWS_SECRET_ACCESS_KEY"

terraform import  -var "access_key=${AWS_ACCESS_KEY_ID}" -var "secret_key=$AWS_SECRET_ACCESS_KEY" aws_vpc.toshi-root-default-vpc vpc-d7658fb3


terraform import -var "access_key=${AWS_ACCESS_KEY_ID}" -var "secret_key=$AWS_SECRET_ACCESS_KEY"

# workspaces作成
terraform workspace new main

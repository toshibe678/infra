# 最新バージョン参照：https://hub.docker.com/r/hashicorp/terraform
FROM hashicorp/terraform:0.15.4

# tflintを使えるようにする
# 最新バージョン確認：https://github.com/terraform-linters/tflint/releases/
ENV TFLINT_VERSION=0.28.1
RUN wget https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip -O tflint.zip \
    && unzip tflint.zip -d /bin \
    && rm tflint.zip

# 既存環境からtfを生成出来るterraformaerを入れる
RUN apk --update add curl \
    && rm -rf /var/cache/apk/* \
    && curl -LO https://github.com/GoogleCloudPlatform/terraformer/releases/download/$(curl -s https://api.github.com/repos/GoogleCloudPlatform/terraformer/releases/latest | grep tag_name | cut -d '"' -f 4)/terraformer-all-linux-amd64 \
    && chmod +x terraformer-all-linux-amd64 \
    && mv terraformer-all-linux-amd64 /usr/local/bin/terraformer

ENTRYPOINT [ "ash" ]

# 最新バージョン参照：https://hub.docker.com/r/hashicorp/terraform
FROM hashicorp/terraform:0.15.4

# tflintを使えるようにする
# 最新バージョン確認：https://github.com/terraform-linters/tflint/releases/
ENV TFLINT_VERSION=0.28.1
RUN wget https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip -O tflint.zip \
    && unzip tflint.zip -d /bin \
    && rm tflint.zip

ENTRYPOINT [ "ash" ]

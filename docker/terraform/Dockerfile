FROM python:3.13

ARG TERRAFORM_VERSION="1.11.4"
# https://github.com/terraform-linters/tflint/releases
ARG TFLINT_VERSION="0.45.0"

# Debian set Locale
# tzdataのapt-get時にtimezoneの選択で止まってしまう対策でDEBIAN_FRONTENDを定義する
ENV DEBIAN_FRONTEND=noninteractive
# debian japanease
RUN apt-get update  \
    && apt-get install -y locales \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN sed -i -E 's/# (ja_JP.UTF-8)/\1/' /etc/locale.gen \
    && locale-gen

# install command.
RUN apt-get update \
    && apt-get install -y --no-install-recommends less vim wget unzip jq cmake libssl-dev gcc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# install aws-cli
RUN python3 -m pip install --upgrade pip \
    && python3 -m pip install awscli
#  && python3 -m pip install https://github.com/boto/botocore/archive/v2.tar.gz \
#  && python3 -m pip install https://github.com/aws/aws-cli/archive/v2.tar.gz

# terraform
# 最新バージョン確認：https://www.terraform.io/downloads.html
ARG terraform_version=1.11.4
ENV TERRAFORM_VERSION=${terraform_version}
RUN apt-get update \
    && apt-get -y install zip \
    && rm -rf /var/lib/apt/lists/* \
    && if [ $(uname -m) = "x86_64" ]; then \
          arch="amd64"; \
      else \
          arch="arm64"; \
      fi \
    && wget "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_${arch}.zip" \
    && unzip "terraform_${TERRAFORM_VERSION}_linux_${arch}.zip" \
    && mv terraform /bin \
    && rm "terraform_${TERRAFORM_VERSION}_linux_${arch}.zip"

# install tflint
RUN wget https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip -O tflint.zip \
    && unzip tflint.zip -d /usr/local/bin \
    && rm tflint.zip

# terraform graph
RUN apt-get update \
    && apt-get install -y --no-install-recommends graphviz graphviz-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

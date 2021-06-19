FROM ubuntu:devel
ARG tz=Asia/Tokyo
ENV TZ=${tz}
# Debian set Locale
# tzdataのapt-get時にtimezoneの選択で止まってしまう対策でDEBIAN_FRONTENDを定義する
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get -y install language-pack-ja-base language-pack-ja && \
    locale-gen ja_JP.UTF-8 && \
    rm -rf /var/lib/apt/lists/*
ENV LC_ALL=ja_JP.UTF-8 \
    LC_CTYPE=ja_JP.UTF-8 \
    LANGUAGE=ja_JP:jp
RUN localedef -f UTF-8 -i ja_JP ja_JP.utf8

# コンテナのデバッグ等で便利なソフト導入しておく
RUN apt-get update && \
    apt-get -y install vim && \
    apt-get -y install git && \
    apt-get -y install curl && \
    apt-get -y install wget && \
    apt-get -y install zip && \
    apt-get -y install unzip && \
    apt-get -y install net-tools && \
    apt-get -y install iproute2 && \
    apt-get -y install iputils-ping && \
    rm -rf /var/lib/apt/lists/*

# terraform
# 最新バージョン確認：https://www.terraform.io/downloads.html
ENV TERRAFORM_VERSION=0.15.5
RUN apt-get update \
    && apt-get -y install zip \
    && rm -rf /var/lib/apt/lists/* \
    && wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && mv terraform /bin \
    && rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# tflintを使えるようにする
# 最新バージョン確認：https://github.com/terraform-linters/tflint/releases/
ENV TFLINT_VERSION=0.28.1
RUN wget https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip -O tflint.zip \
    && unzip tflint.zip -d /bin \
    && rm tflint.zip

# 既存環境からtfを生成出来るterraformaerを入れる
RUN apt-get update \
    && apt-get -y install curl \
    && rm -rf /var/lib/apt/lists/* \
    && curl -LO https://github.com/GoogleCloudPlatform/terraformer/releases/download/$(curl -s https://api.github.com/repos/GoogleCloudPlatform/terraformer/releases/latest | grep tag_name | cut -d '"' -f 4)/terraformer-all-linux-amd64 \
    && chmod +x terraformer-all-linux-amd64 \
    && mv terraformer-all-linux-amd64 /bin/terraformer

## python & pip
RUN apt update \
    && apt -y -q install python3-distutils \
    && rm -rf /var/lib/apt/lists/* \
    && curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py \
    && python3 get-pip.py \
    && pip install -U pip

# aws cli
RUN pip install awscli

ENTRYPOINT [ "bash" ]

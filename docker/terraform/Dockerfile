FROM python:3.11

ARG TERRAFORM_VERSION="1.4.2"
# https://github.com/gruntwork-io/terragrunt/releases
ARG TERRAGRUNT_VERSION="0.45.0"
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

# install terraform
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && unzip ./terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/local/bin/ \
    && rm ./terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# install terargrunt
RUN wget https://github.com/gruntwork-io/terragrunt/releases/download/v${TERRAGRUNT_VERSION}/terragrunt_linux_amd64 \
    && chmod +x ./terragrunt_linux_amd64 \
    && mv ./terragrunt_linux_amd64 /usr/local/bin/terragrunt

# install tflint
RUN wget https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip -O tflint.zip \
    && unzip tflint.zip -d /usr/local/bin \
    && rm tflint.zip

# terraform graph
RUN apt-get update \
    && apt-get install -y --no-install-recommends graphviz graphviz-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY .terraformrc /root/.terraformrc
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]

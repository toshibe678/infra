FROM python:3.10

ARG TERRAFORM_VERSION="1.1.2"
ARG TERRAGRUNT_VERSION="0.35.16"
ARG TFLINT_VERSION="0.34.0"

# install command.
RUN apt-get update && apt-get install -y less vim wget unzip jq cmake libssl-dev gcc

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
RUN wget https://github.com/terraform-linters/tflint/releases/download/v${TFLINT_VERSION}/tflint_linux_amd64.zip -O tflint.zip
RUN unzip tflint.zip -d /usr/local/bin
RUN rm tflint.zip

COPY .terraformrc /root/.terraformrc
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]

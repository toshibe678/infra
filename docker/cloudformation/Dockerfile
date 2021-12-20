FROM python:3.10

# install command.
RUN apt-get update && apt-get install -y less vim wget unzip jq cmake libssl-dev gcc

# install aws-cli
RUN python3 -m pip install --upgrade pip \
    && python3 -m pip install awscli
#  && python3 -m pip install https://github.com/boto/botocore/archive/v2.tar.gz \
#  && python3 -m pip install https://github.com/aws/aws-cli/archive/v2.tar.gz



# install cfn-lint
RUN pip install cfn-lint

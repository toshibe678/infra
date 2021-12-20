FROM python:3.10

# install ansible
RUN python3 -m pip install --upgrade pip \
  && python3 -m pip install ansible ansible-lint

# install command.
RUN apt-get update && apt-get install -y less vim wget unzip jq


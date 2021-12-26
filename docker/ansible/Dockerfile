FROM python:3.10

# install command.
RUN apt-get update && apt-get install -y less vim wget unzip jq

# require paccage
RUN apt-get update && apt-get install -y sshpass

# install ansible
RUN python3 -m pip install --upgrade pip \
  && python3 -m pip install ansible ansible-lint

RUN ansible-galaxy collection install cisco.ios

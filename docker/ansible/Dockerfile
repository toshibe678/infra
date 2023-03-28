FROM python:3.11

# install command.
RUN apt-get update \
    && apt-get install -y less vim wget unzip jq \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# require paccage
RUN apt-get update \
    && apt-get install -y sshpass \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# install ansible
RUN python3 -m pip install --upgrade pip \
  && python3 -m pip install ansible paramiko ansible-lint

RUN ansible-galaxy collection install cisco.ios

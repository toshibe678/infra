FROM python:3.11

# Debian set Locale
# tzdataのapt-get時にtimezoneの選択で止まってしまう対策でDEBIAN_FRONTENDを定義する
ENV DEBIAN_FRONTEND=noninteractive
# debian japanease
RUN apt-get update && apt-get install -y locales \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN sed -i -E 's/# (ja_JP.UTF-8)/\1/' /etc/locale.gen \
    && locale-gen

# install command.
RUN apt-get update \
    && apt-get install -y less vim wget unzip jq cmake libssl-dev gcc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# install aws-cli cfn-lint
RUN python3 -m pip install --upgrade pip \
    && python3 -m pip install awscli cfn-lint

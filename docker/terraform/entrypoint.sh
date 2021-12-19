#!/bin/bash

if [[ -z "${terraform_token}" ]]; then
  echo "no terraform_token"
else
  sed -i -e "s/TOKEN_KEY/${terraform_token}/g" /root/.terraformrc
fi

exec "$@"

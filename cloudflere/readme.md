
docker run --env-file /home/toshi/git/infra/.env  --rm -v $PWD:/terraform -it ghcr.io/toshibe678/infra/terraform:latest /bin/bash

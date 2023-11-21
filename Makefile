.PHONY: build plan apply destroy init check exec_tf exec_ansible lint deploy

# makefile内のすべてのコマンドが単一のシェルスクリプトで実行されるようになるおまじない
.ONESHELL:

init:
	@docker compose run --rm terraform terraform init
# 	@docker compose run --rm ansible ansible-galaxy collection install -r requirements.yml --force-with-deps
	@docker compose run --rm nw-ansible ansible-galaxy collection install -r requirements.yml --force-with-deps
	@docker compose run --rm ansible ansible-galaxy install -p roles -r requirements.yml --force

plan:
# 	@docker compose run --rm terraform terragrund plan
	@docker compose run --rm terraform terraform plan

apply:
# 	@docker compose run --rm terraform terragrunt apply
	@docker compose run --rm terraform terraform apply

deploy:
	@docker compose run --rm ansible bash -c './ci.sh && ansible-playbook -D -i hosts_all.yml -l linux all.yml --vault-password-file ~/.ssh/.ansible_vault_pass -C'

nw-deploy:
	@docker compose run --rm ansible bash -c './ci.sh && ansible-playbook -D -i hosts_all.yml -l router all.yml --vault-password-file ~/.ssh/.ansible_vault_pass -C'

destroy: check
# 	@docker compose run --rm terraform terragrunt destroy
	@docker compose run --rm terraform terraform destroy

check:
	@docker compose run --rm terraform fmt
	@docker compose run --rm terraform validate

build:
	@docker compose build

exec_tf:
	@docker compose run --rm terraform bash

exec_ansible:
	@docker compose run --rm ansible bash

lint:
	@docker compose run --rm ansible ansible-lint all.yml -c .ansible-lint
	@docker compose run --rm terraform ./tflint.sh
	@docker compose run --rm cloudformation cfn-lint -t ./**/*.yml

raspi-up:
	@docker compose build -f compose-raspi.yml
	@docker compose up -d --foroe-recreate -f compose-raspi.yml

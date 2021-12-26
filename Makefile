.PHONY: build plan apply destroy init check exec_tf exec_ansible lint deploy

init:
# 	@docker-compose run --rm terraform terraform init
# 	@docker-compose run --rm ansible ansible-galaxy collection install cisco.ios
	@docker-compose run --rm ansible ansible-galaxy install -r requirements.yml

plan:
# 	@docker-compose run --rm terraform terragrund plan
	@docker-compose run --rm terraform terraform plan

apply:
# 	@docker-compose run --rm terraform terragrunt apply
	@docker-compose run --rm terraform terraform apply

deploy:
	@cd ansible && ansible-playbook -D -i hosts_all.yml -l linux all.yml --ask-vault-pass -C

nw-deploy:
	@docker-compose run --rm nw-ansible ansible-playbook -D -i hosts_all.yml -l cisco all.yml --ask-vault-pass -C

destroy: check
# 	@docker-compose run --rm terraform terragrunt destroy
	@docker-compose run --rm terraform terraform destroy

check:
	@docker-compose run --rm terraform fmt
	@docker-compose run --rm terraform validate

build:
	@docker-compose build

exec_tf:
	@docker-compose run --rm terraform bash

exec_ansible:
	@docker-compose run --rm ansible bash

lint:
	@docker-compose run --rm ansible ansible-lint all.yml -c .ansible-lint
	@docker-compose run --rm terraform ./tflint.sh
	@docker-compose run --rm cloudformation cfn-lint -t ./**/*.yml


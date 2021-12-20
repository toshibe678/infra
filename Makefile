.PHONY: build plan apply destroy init check exec lint

init:
	@docker-compose run --rm terraform terraform init

plan:
# 	@docker-compose run --rm terraform terragrund plan
	@docker-compose run --rm terraform terraform plan

apply:
# 	@docker-compose run --rm terraform terragrunt apply
	@docker-compose run --rm terraform terraform apply

destroy: check
# 	@docker-compose run --rm terraform terragrunt destroy
	@docker-compose run --rm terraform terraform destroy

check:
	@docker-compose run --rm terraform fmt
	@docker-compose run --rm terraform validate

build:
	@docker-compose build

exec:
	@docker-compose run --rm terraform bash

lint:
	@docker-compose run --rm ansible ansible-lint all.yml -c .ansible-lint
	@docker-compose run --rm terraform ./tflint.sh
	@docker-compose run --rm cloudformation cfn-lint -t ./**/*.yml

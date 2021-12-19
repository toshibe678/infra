.PHONY: build plan apply destroy init check

init: check
	@docker-compose run --rm terraform init

plan: check
	@docker-compose run --rm terraform terragrund plan

apply: check
	@docker-compose run --rm terraform terragrunt apply

destroy: check
	@docker-compose run --rm terraform terragrunt destroy

check:
	@docker-compose run --rm terraform fmt -recursive
	@docker-compose run --rm terraform fmt -check
	@docker-compose run --rm terraform validate

build:
	@docker-compose build

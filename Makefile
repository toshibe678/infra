export COMPOSE_HTTP_TIMEOUT := 500
.PHONY: build plan apply destroy init check exec_tf exec_ansible lint deploy check-branch

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

# 取り込み前の確認: develop-setting の作業ブランチを取得した状態で dev に --check -D を実行する
#   make check-branch BRANCH=<作業ブランチ> [LIMIT=<対象ホストまたはグループ>]
# 値はシェルの文字列に展開せず、環境変数（$$BRANCH、$$LIMIT）でコンテナへ渡す。ブランチ名の文字種は check-branch.sh が検査する
BRANCH ?=
LIMIT ?=
export BRANCH LIMIT

check-branch:
	@test -n "$$BRANCH" || { echo "BRANCH を指定してください (例: make check-branch BRANCH=feature/x)"; exit 1; }
	@docker compose run --rm -e BRANCH -e LIMIT ansible bash -c './ci.sh && ./check-branch.sh "$$BRANCH" $$LIMIT'

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
	@docker compose -f compose-raspi.yml build
	@docker compose -f compose-raspi.yml up -d

vm-init:
	@docker compose run --rm ansible bash -c 'cd /ansible/proxmox-vm-init && ansible-playbook -i hosts_proxmox_vm.yml vm_init.yml --vault-password-file ~/.ssh/.ansible_vault_pass --ask-become-pass'

vm-init-check:
	@docker compose run --rm ansible bash -c 'cd /ansible/proxmox-vm-init && ansible-playbook -i hosts_proxmox_vm.yml vm_init.yml --vault-password-file ~/.ssh/.ansible_vault_pass -C'

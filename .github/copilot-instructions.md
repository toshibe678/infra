# Copilot Instructions for Infrastructure Repository

## Project Overview
Multi-environment Infrastructure as Code (IaC) repository managing on-premises and cloud infrastructure through Ansible, Terraform, AWS CDK, and Docker. The goal is automated, secure, and reproducible infrastructure operations.

## Architecture & Key Components

### 1. Hybrid IaC Approach
- **Terraform** (`terraform/`): AWS resources via modules (blog, cloudfront_s3_acm, GCP modules)
- **AWS CDK** (`cdk/`): Profile-based multi-account deployment (sso-admin, sso-blog, sso-sandbox)
- **Cloudflare** (`cloudflere/`): DNS and CDN configuration
- **Ansible** (`ansible/`): Configuration management for Linux servers, Raspberry Pi clusters, and VPN

### 2. Environment Separation
Multi-account AWS strategy driven by `AWS_PROFILE`:
- `sso-admin` → Account 814229680634 (RootStack)
- `sso-blog` → Account 073855610728 (BlogStack)
- `sso-sandbox` → Account 570339075110 (SandboxStack)

CDK deployments automatically select stacks based on `AWS_PROFILE` (see `cdk/bin/cdk.ts`).

### 3. Ansible Structure
- **Inventory**: `hosts_all.yml` with hierarchical groups (linux → vpn/raspi → raspi_vpn/raspi_novpn)
- **Secrets**: Ansible Vault encrypted files in `group_vars/*/crypt_vars.yml`
- **Vault password**: Stored in `~/.ssh/.ansible_vault_pass` (gitignored, required for all playbook runs)
- **Key playbooks**: `all.yml`, `wireguard.yml`, `linux.yml`, `raspi.yml`

### 4. Containerized Execution
All IaC tools run in Docker containers via `compose.yml`:
- `terraform`: Terraform CLI with AWS credentials
- `ansible`: Ansible with vault password mounted
- `named`: DNS server with bind9
- Additional services: n8n workflow automation, monitoring stack

## Critical Workflows

### Running Terraform
```bash
# Via Makefile (recommended)
make init    # terraform init in container
make plan    # terraform plan in container
make apply   # terraform apply in container

# Direct execution
docker compose run --rm terraform terraform plan
```

### Running Ansible
```bash
# Via Makefile (recommended)
make deploy     # Deploy to Linux hosts (check mode)
make nw-deploy  # Deploy to network routers

# Direct execution with vault
docker compose run --rm ansible ansible-playbook -D -i hosts_all.yml \
  --vault-password-file ~/.ssh/.ansible_vault_pass all.yml

# Target specific hosts
ansible-playbook -D -l raspi -i hosts_all.yml all.yml --ask-vault-password
```

**Critical**: Always use `--vault-password-file ~/.ssh/.ansible_vault_pass` or `--ask-vault-password` when running playbooks.

### Proxmox VM Initial Setup
New VMs created in Proxmox can be automatically configured:

```bash
# Edit inventory first
vi proxmox-vm-init/hosts_proxmox_vm.yml

# Run initial setup (requires sudo password on first run)
make vm-init

# Dry-run to check what will change
make vm-init-check

# Or use the helper script
cd proxmox-vm-init
./setup.sh --check  # Dry-run
./setup.sh          # Full setup
```

Setup tasks include:
- Configure sudo NOPASSWD for user `toshi`
- Install Docker via apt
- Clone GitHub repositories (scripts, infra)
- Set up SSH keys for Git access
- Update system packages

### AWS CDK Deployment
```bash
cd cdk
npm install

# Profile-based deployment
aws sso login --profile sso-admin
export AWS_PROFILE=sso-admin
npx cdk deploy RootStack --profile sso-admin

# For blog account
export AWS_PROFILE=sso-blog
npx cdk deploy BlogStack --profile sso-blog
```

### Monitoring Stack
```bash
cd monitoring
docker-compose up -d

# Access UIs
# Prometheus: http://localhost:9090
# Grafana: http://localhost:3000
# Alertmanager: http://localhost:9093
```

## Project-Specific Conventions

### 1. State Management
- **Terraform**: Remote state in Terraform Cloud (organization: `toshibe-infra`, workspace tag: `main`)
- **Ansible**: No state - idempotent playbooks with fact caching disabled (`inject_fact_as_vars = False`)

### 2. Secret Handling
- **Never commit**: `.ansible_vault_pass`, AWS credentials, SSH keys
- **Ansible Vault**: Encrypt with `ansible-vault encrypt /path/to/file`
- **AWS**: Use SSO profiles, never hardcode credentials
- **Environment variables**: Stored in `.env` (gitignored) for Docker containers

### 3. Naming Patterns
- **Hosts**: FQDN format (`raspi.abe365.org`, `vpn.raspi.abe365.org`)
- **CDK Stacks**: `{Purpose}Stack` (RootStack, BlogStack, SandboxStack)
- **Terraform modules**: Lowercase with underscores (`cloudfront_s3_acm`, `gcp_common_settings`)
- **Ansible groups**: Hierarchical (`linux` → `raspi` → `raspi_vpn`)

### 4. Docker Development Pattern
- Use Makefile targets (`make deploy`, `make plan`) for consistency
- Shell access for debugging: `make exec_tf` or `make exec_ansible`
- All tools run in containers - no local installation needed except Docker

## Integration Points

### Ansible → AWS
- Manages EC2 instances provisioned by Terraform
- Configures VPN gateways and network services
- Uses `ansible_ssh_private_key_file: ~/.ssh/id_rsa` for access

### Terraform → CDK
- Terraform manages foundational resources (VPC, networking)
- CDK extends with higher-level constructs (CloudFront, Lambda)
- Both share account boundaries defined by AWS profiles

### Docker → Everything
- `compose.yml` provides execution environment for Terraform/Ansible
- `docker/*/Dockerfile` defines specialized containers (named, proxy, n8n)
- Monitoring stack (`monitoring/docker-compose.yml`) runs independently

## Testing & Validation

### Pre-deployment Checks
```bash
# Terraform
make check           # fmt + validate
make lint            # tflint on all .tf files

# Ansible
docker compose run --rm ansible ansible-lint all.yml -c .ansible-lint

# CloudFormation
docker compose run --rm cloudformation cfn-lint -t ./**/*.yml
```

### Dry-run Patterns
- **Ansible**: Use `-C` flag for check mode (no changes applied)
- **Terraform**: Always run `plan` before `apply`
- **CDK**: Use `cdk diff` to preview changes

## Common Gotchas

1. **Vault password required**: Ansible playbooks fail without vault password file or `--ask-vault-password`
2. **AWS Profile context**: CDK stack selection depends on `AWS_PROFILE` environment variable
3. **Docker timeout**: Set `COMPOSE_HTTP_TIMEOUT=500` for long-running containers
4. **Ansible SSH timeout**: Default 10s (`ansible.cfg`), may need adjustment for slow connections
5. **Terraform backend**: Always run `terraform init` when switching workspaces

## Key Files Reference
- `AGENTS.md`: Comprehensive project context for AI agents (read first)
- `Makefile`: Primary interface for Docker-based workflows
- `ansible/hosts_all.yml`: Complete infrastructure inventory
- `proxmox-vm-init/`: Proxmox VM initial setup playbooks
- `cdk/bin/cdk.ts`: Profile-to-stack routing logic
- `terraform/main.tf`: Root module composition
- `compose.yml`: Container orchestration for IaC tools

## Documentation Structure
- Core docs: `AGENTS.md` (this project uses AGENTS.md instead of Memory Bank)
- Component READMEs: `ansible/README.md`, `cdk/README.md`, `terraform/readme.md`
- Monitoring: `monitoring/README.md` for observability stack

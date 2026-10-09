# Deployment Guide

This document covers infrastructure provisioning (Terraform) and application deployment (Azure Static Web Apps) for all three environments.

---

## Prerequisites

| Tool | Version | Install |
|---|---|---|
| [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) | ≥ 2.60 | `curl -sL https://aka.ms/InstallAzureCLIDeb \| sudo bash` |
| [Terraform](https://developer.hashicorp.com/terraform/install) | ≥ 1.8 | `brew install terraform` |
| [SWA CLI](https://azure.github.io/static-web-apps-cli/) | ≥ 1.0 | `npm install -g @azure/static-web-apps-cli` |

Authenticate with Azure before running any scripts:

```bash
az login
az account set --subscription <YOUR_SUBSCRIPTION_ID>
```

---

## Environments

| Environment | tfvars File | Domain |
|---|---|---|
| `dev` | `terraform/envs/dev.tfvars` | `dev.example.dtig.us` |
| `staging` | `terraform/envs/staging.tfvars` | `staging.example.dtig.us` |
| `prod` | `terraform/envs/prod.tfvars` | `example.dtig.us` |

---

## CI/CD — Gitea Actions (Automated)

Pushes to `main` (or merged PRs) trigger `.gitea/workflows/deploy.yml`, which:

1. Checks out the repository **including all submodules** (`submodules: recursive`).
2. Sets up Node.js v22 with npm cache.
3. Builds and uploads to Azure SWA via `Azure/static-web-apps-deploy@v1`.

The `AZURE_STATIC_WEB_APPS_API_TOKEN` secret must be set in the Gitea repository settings.

---

## Manual Deployment

### 1. Provision Infrastructure (Terraform)

Use [`tools/www_terraform_deploy.sh`](../tools/www_terraform_deploy.sh) to provision or update Azure resources for a given environment:

```bash
# Provision dev environment
./tools/www_terraform_deploy.sh dev

# Provision staging
./tools/www_terraform_deploy.sh staging

# Provision production
./tools/www_terraform_deploy.sh prod
```

**What it does:**

1. Changes into `terraform/` and selects (or creates) the workspace for the env.
2. Runs `terraform apply -var-file="envs/<env>.tfvars" -auto-approve`.
3. Outputs `static_web_app_deployment_token`, `resource_group_name`, and `app_name`.

> [!IMPORTANT]
> Deploy environments **sequentially** — `dev` → `staging` → `prod`. Never provision production before validating staging.

> [!WARNING]
> The custom domain CNAME validation can take **3–5 minutes** after DNS propagation. If you see `extendedCode: 51021`, wait and re-run — do not abort.

### 2. Deploy Application to SWA

Use [`tools/www_swa_deploy.sh`](../tools/www_swa_deploy.sh) to build the Angular app and push the compiled output:

```bash
./tools/www_swa_deploy.sh dev
./tools/www_swa_deploy.sh staging
./tools/www_swa_deploy.sh prod
```

**What it does:**

1. Retrieves the SWA deployment token from Terraform outputs.
2. Runs `npm run build` in the repo root.
3. Deploys `dist/angular-project/browser` via the SWA CLI.

### 3. Destroy an Environment

```bash
./tools/www_terraform_destroy.sh dev
```

> [!CAUTION]
> Running destroy on `prod` is irreversible. Always take a backup of the SWA token and any Terraform state before destroying.

---

## Terraform Structure

```
terraform/
├── main.tf              # Resource group
├── providers.tf         # AzureRM provider config
├── variables.tf         # Input variables (environment name)
├── staticwebapp.tf      # SWA resource, custom domain, CNAME validation
└── envs/
    ├── dev.tfvars
    ├── staging.tfvars
    └── prod.tfvars
```

---

## Local SWA Testing

To test the production build locally against the SWA emulator (including routing rules from `staticwebapp.config.json`):

```bash
# Install Azurite (Azure Storage emulator) — already in devDependencies
# Terminal 1: start the emulator
npx azurite --silent &

# Terminal 2: build and serve
npm run build
npx swa start dist/angular-project/browser --config staticwebapp.config.json
```

The app will be available at `http://localhost:4280/`.

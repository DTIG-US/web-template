#!/bin/bash

# Usage: ./www_deploy.sh <env>
#   env: dev | staging | prod

ENV="${1:?Usage: $0 <dev|staging|prod>}"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TERRAFORM_DIR="$SCRIPT_DIR/../terraform"

cd "$TERRAFORM_DIR"

# 1. Select (or create) an isolated workspace for this environment
terraform workspace select "$ENV" 2>/dev/null || terraform workspace new "$ENV"

# 2. Provision the SWA resource
terraform apply -var-file="envs/${ENV}.tfvars" -auto-approve

# 2. Fetch the deployment token and resource identifiers
SWA_TOKEN=$(terraform output -raw static_web_app_deployment_token)
RESOURCE_GROUP=$(terraform output -raw resource_group_name)
APP_NAME=$(terraform output -raw app_name)

# 3. Build the Angular application
# npm run build

# 4. Deploy compiled output (dist/angular-project/browser)
# swa deploy dist/angular-project/browser \
#   --env production \
#   --resource-group "$RESOURCE_GROUP" \
#   --app-name "$APP_NAME" \
#   --deployment-token "$SWA_TOKEN"

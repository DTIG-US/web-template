#!/bin/bash
set -e

# Usage: ./tools/www_swa_deploy.sh <dev|staging|prod>
ENV="${1:?Usage: $0 <dev|staging|prod>}"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
ROOT_DIR="$SCRIPT_DIR/.."
TERRAFORM_DIR="$ROOT_DIR/terraform"

# 1. Fetch deployment credentials and target resource names from Terraform
echo "==> Retrieving Terraform outputs for workspace: ${ENV}..."
cd "$TERRAFORM_DIR"
terraform workspace select "$ENV" 2>/dev/null || terraform workspace new "$ENV"

SWA_TOKEN=$(terraform output -raw static_web_app_deployment_token)
RESOURCE_GROUP=$(terraform output -raw resource_group_name)
APP_NAME=$(terraform output -raw app_name)

# 2. Build the Angular application from the repository root
echo "==> Building Angular application in ${ROOT_DIR}..."
cd "$ROOT_DIR"
npm run build

# 3. Deploy compiled browser output to Azure Static Web Apps
echo "==> Deploying dist/angular-project/browser to Azure Static Web App (${APP_NAME})..."
swa deploy dist/angular-project/browser \
  --env production \
  --resource-group "$RESOURCE_GROUP" \
  --app-name "$APP_NAME" \
  --deployment-token "$SWA_TOKEN"

echo "==> Deployment completed successfully!"

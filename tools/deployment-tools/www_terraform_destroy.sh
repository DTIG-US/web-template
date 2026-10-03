#!/bin/bash

# Usage: ./www_deploy.sh <env>
#   env: dev | staging | prod
ENV="${1:?Usage: $0 <dev|staging|prod>}"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TERRAFORM_DIR="$SCRIPT_DIR/../terraform"

cd "$TERRAFORM_DIR"
terraform workspace select "$ENV"
terraform destroy -var-file="envs/${ENV}.tfvars" -auto-approve

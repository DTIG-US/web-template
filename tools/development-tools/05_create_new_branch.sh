#!/usr/bin/env bash

set -Eeuo pipefail

read -rp "Enter branch name: " BRANCH_NAME

if [[ -z "${BRANCH_NAME}" ]]; then
    echo "ERROR: Branch name cannot be empty."
    exit 1
fi

echo
echo "Creating and checking out branch '${BRANCH_NAME}' in all submodules..."

# Create/check out branch in every submodule
git submodule foreach --recursive '
    echo "----------------------------------------"
    echo "Submodule: $displaypath"

    if git show-ref --verify --quiet "refs/heads/'"${BRANCH_NAME}"'"; then
        echo "Branch already exists. Checking it out..."
        git checkout "'"${BRANCH_NAME}"'"
    else
        echo "Creating branch..."
        git checkout -b "'"${BRANCH_NAME}"'"
    fi
'

echo
echo "Processing parent repository..."
echo "----------------------------------------"

# Create/check out branch in parent repo
if git show-ref --verify --quiet "refs/heads/${BRANCH_NAME}"; then
    echo "Branch already exists. Checking it out..."
    git checkout "${BRANCH_NAME}"
else
    echo "Creating branch..."
    git checkout -b "${BRANCH_NAME}"
fi

echo
echo "Complete."
echo "Branch '${BRANCH_NAME}' is now checked out in the parent repository and all submodules."
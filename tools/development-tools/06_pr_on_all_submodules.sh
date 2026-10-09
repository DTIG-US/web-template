#!/usr/bin/env bash

set -e

# Default values if not provided as arguments
TITLE=${1:-"Automated Submodule Update"}
BODY=${2:-"This PR was generated automatically."}
BASE_BRANCH=${3:-"main"}

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is not installed. Please install it to create PRs."
    exit 1
fi

# Get list of submodule paths
if [ ! -f .gitmodules ]; then
    echo "Error: .gitmodules file not found."
    exit 1
fi

submodules=$(git config --file .gitmodules --get-regexp path | awk '{ print $2 }')

if [ -z "$submodules" ]; then
    echo "No submodules found."
    exit 0
fi

for sm in $submodules; do
    echo "======================================"
    echo "Processing submodule: $sm"
    
    if [ ! -d "$sm" ]; then
        echo "Directory $sm not found. Skipping."
        continue
    fi

    (
        cd "$sm"
        
        current_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "HEAD")
        
        if [ "$current_branch" = "HEAD" ]; then
            echo "Submodule $sm is in detached HEAD state. Cannot create PR. Skipping."
            exit 0
        fi
        
        echo "Current branch: $current_branch"
        
        # Push changes to the remote branch
        echo "Pushing changes to origin/$current_branch..."
        git push origin "$current_branch" || {
            echo "Failed to push $current_branch to origin. Skipping PR creation."
            exit 0
        }
        
        # Create PR using GitHub CLI
        echo "Creating PR for $sm..."
        gh pr create \
            --title "$TITLE" \
            --body "$BODY" \
            --base "$BASE_BRANCH" \
            --head "$current_branch" || echo "Failed to create PR for $sm (perhaps one already exists or there are no commits to merge?)"
    )
done

echo "======================================"
echo "Finished processing all submodules."

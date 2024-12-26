#!/bin/bash

# Source configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# Directory to store cloned repositories
OUTPUT_DIR="./github-repos"
mkdir -p "$OUTPUT_DIR"

# Function to update or clone repository
update_or_clone_repo() {
    local REPO_PATH="$1"
    local REPO_URL="$2"
    local REPO_NAME="$3"

    if [ -d "$REPO_PATH" ]; then
        echo "  Repository exists: $REPO_NAME, fetching updates..."
        (cd "$REPO_PATH" && git fetch --all)
    else
        echo "  Cloning repository: $REPO_NAME..."
        git clone "$REPO_URL" "$REPO_PATH"
    fi
}

# Function to check if account/organization exists and has repositories
check_github_account() {
    local ACCOUNT="$1"
    local IS_ORG="$2"
    
    if [ "$IS_ORG" = true ]; then
        echo "Fetching repositories for organization: $ACCOUNT..."
        if ! REPOS=$(gh repo list "$ACCOUNT" --limit 1000 --json name,sshUrl --jq '.[] | "\(.name) \(.sshUrl)"' 2>/dev/null); then
            echo "Error: Unable to access organization: $ACCOUNT"
            return 1
        fi
    else
        echo "Fetching repositories for user: $ACCOUNT..."
        if ! REPOS=$(gh repo list --limit 1000 --json name,sshUrl --jq '.[] | "\(.name) \(.sshUrl)"' 2>/dev/null); then
            echo "Error: Unable to access user account: $ACCOUNT"
            return 1
        fi
    fi
    
    if [ -z "$REPOS" ]; then
        echo "No repositories found for $ACCOUNT"
        return 1
    fi
    
    return 0
}

# Check if account exists and has repositories
if ! check_github_account "$GITHUB_ACCOUNT_NAME" "$GITHUB_IS_ORG"; then
    exit 1
fi

# Get repositories list
if [ "$GITHUB_IS_ORG" = true ]; then
    REPOS=$(gh repo list "$GITHUB_ACCOUNT_NAME" --limit 1000 --json name,sshUrl --jq '.[] | "\(.name) \(.sshUrl)"')
else
    REPOS=$(gh repo list --limit 1000 --json name,sshUrl --jq '.[] | "\(.name) \(.sshUrl)"')
fi

# Process each repository
while IFS= read -r REPO; do
    REPO_NAME=$(echo "$REPO" | awk '{print $1}')
    REPO_URL=$(echo "$REPO" | awk '{print $2}')
    REPO_PATH="$OUTPUT_DIR/$REPO_NAME"
    
    update_or_clone_repo "$REPO_PATH" "$REPO_URL" "$REPO_NAME"
done <<< "$REPOS"

echo "All repositories have been cloned or updated in $OUTPUT_DIR."
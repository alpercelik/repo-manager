#!/bin/bash

# Source configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/config.sh"

# Directory to store cloned repositories
OUTPUT_DIR="./azure-devops-repos"
mkdir -p "$OUTPUT_DIR"

# Function to update or clone repository
update_or_clone_repo() {
    local REPO_PATH="$1"
    local REPO_URL="$2"
    local REPO_NAME="$3"

    if [ -d "$REPO_PATH" ]; then
        echo "    Repository exists: $REPO_NAME, fetching updates..."
        (cd "$REPO_PATH" && git fetch --all)
    else
        echo "    Cloning repository: $REPO_NAME..."
        git clone "$REPO_URL" "$REPO_PATH"
    fi
}

# Function to check if organization exists and has projects
check_organization() {
    local ORG="$1"
    local ORG_URL="https://dev.azure.com/$ORG"
    
    # Try to access the organization and get projects
    if ! PROJECTS=$(az devops project list --organization "$ORG_URL" --query "value[].name" -o tsv 2>/dev/null); then
        echo "  Error: Unable to access organization: $ORG"
        return 1
    fi
    
    if [ -z "$PROJECTS" ]; then
        echo "  Skipping organization: $ORG (no projects found)"
        return 1
    fi
    
    return 0
}

# Iterate through each organization
for ORG in "${AZURE_DEVOPS_ORGANIZATIONS[@]}"; do
    ORG_URL="https://dev.azure.com/$ORG"
    echo "Processing organization: $ORG ($ORG_URL)..."
    
    # Check if organization exists and has projects
    if ! check_organization "$ORG"; then
        continue
    fi
    
    # Get all projects in the organization
    PROJECTS=$(az devops project list --organization "$ORG_URL" --query "value[].name" -o tsv)
    
    # Iterate through each project in the organization
    for PROJECT in $PROJECTS; do
        echo "  Processing project: $PROJECT..."
        
        # Get all repositories in the project
        REPOS=$(az repos list --organization "$ORG_URL" --project "$PROJECT" --query "[].name" -o tsv)
        
        if [ -z "$REPOS" ]; then
            echo "    No repositories found in project: $PROJECT"
            continue
        fi
        
        # Create a directory for the organization and project
        PROJECT_DIR="$OUTPUT_DIR/$ORG/$PROJECT"
        mkdir -p "$PROJECT_DIR"

        # Clone or update each repository
        for REPO in $REPOS; do
            REPO_URL="$ORG_URL/$PROJECT/_git/$REPO"
            REPO_PATH="$PROJECT_DIR/$REPO"
            update_or_clone_repo "$REPO_PATH" "$REPO_URL" "$REPO"
        done
    done
done

echo "All repositories have been cloned or updated in $OUTPUT_DIR."
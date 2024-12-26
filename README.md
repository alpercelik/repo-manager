# Repository Management Tools

A collection of shell scripts to manage repositories across GitHub and Azure DevOps platforms. These tools help with cloning repositories, cleaning build artifacts, and managing repository configurations.

## Features

- Bulk clone/update repositories from GitHub accounts/organizations
- Bulk clone/update repositories from Azure DevOps organizations
- Maintains organized directory structure for cloned repositories
- Automatic update of existing repositories
- Error handling and status reporting

## Prerequisites

- Git
- GitHub CLI (`gh`)
- Azure CLI with DevOps extension
- Bash shell environment
- Proper authentication setup for both GitHub and Azure DevOps

### Installing Prerequisites

1. **Git:**
   ```bash
   # Ubuntu/Debian
   sudo apt-get update
   sudo apt-get install git

   # macOS (using Homebrew)
   brew install git
   ```

2. **GitHub CLI:**
   ```bash
   # Ubuntu/Debian
   curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
   echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
   sudo apt update
   sudo apt install gh

   # macOS (using Homebrew)
   brew install gh
   ```

3. **Azure CLI:**
   ```bash
   # Ubuntu/Debian
   curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

   # macOS (using Homebrew)
   brew install azure-cli

   # Install Azure DevOps extension
   az extension add --name azure-devops
   ```

## Configuration

1. Create a `config.sh` file in the same directory as the scripts with the following content:
   ```bash
   # GitHub Configuration
   GITHUB_ACCOUNT_NAME="your-username-or-org"
   GITHUB_IS_ORG=false  # Set to true if using an organization

   # Azure DevOps Configuration
   AZURE_DEVOPS_ORGANIZATIONS=(
       "org1"
       "org2"
       # Add more organizations as needed
   )
   ```

2. Authenticate with GitHub:
   ```bash
   gh auth login
   ```

3. Authenticate with Azure DevOps:
   ```bash
   az login
   az devops login
   ```

## Usage

### Cloning GitHub Repositories

```bash
./sync-gh.sh
```

### Cloning Azure DevOps Repositories

```bash
./sync-ado.sh
```

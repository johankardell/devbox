# Azure Linux DevBox

This repository contains Azure Bicep templates to deploy an Ubuntu Linux VM in Azure.

## Resources Created

- Ubuntu 25.10 (Oracular) VM with Standard_B4as_v2 size (4 vCPUs, 16 GB RAM)
- Auto-shutdown scheduled for 20:00 (8 PM) Swedish time daily
- Virtual Network (10.0.0.0/16)
- Network Security Group (SSH access restricted to your IP)
- Public IP with DNS label
- Network Interface
- Premium SSD managed disk

**Location**: Sweden Central

> **Note**: VM size is `Standard_B4as_v2` (AMD-based B-series) as the Intel-based `Standard_B4ms_v2` is not available in Sweden Central region.

## Prerequisites

- Azure CLI installed and authenticated (`az login`)
- SSH key pair generated (or set `SSH_PUBLIC_KEY` environment variable)

## Deployment

### Option 1: Using the deployment script

```bash
./deploy.sh
```

The script will:
- Auto-detect your public IP address for SSH access (or read from `ALLOWED_SOURCE_IP` env var)
- Use `~/.ssh/id_rsa.pub` as the SSH public key (or read from `SSH_PUBLIC_KEY` env var)
- Create the resource group `rg-linux-devbox` in `swedencentral`
- Deploy the VM

### Option 2: Manual deployment

```bash
# Create resource group
az group create --name rg-linux-devbox --location swedencentral

# Deploy with parameters file
export SSH_PUBLIC_KEY=$(cat ~/.ssh/id_rsa.pub)
export ALLOWED_SOURCE_IP=$(curl -s https://api.ipify.org)
az deployment group create \
    --resource-group rg-linux-devbox \
    --template-file main.bicep \
    --parameters main.bicepparam

# Or deploy with inline parameters
az deployment group create \
    --resource-group rg-linux-devbox \
    --template-file main.bicep \
    --parameters adminUsername=azureuser \
                 sshPublicKey="$(cat ~/.ssh/id_rsa.pub)" \
                 allowedSourceIP="$(curl -s https://api.ipify.org)" \
                 location=swedencentral
```

## Connect to VM

After deployment completes, the output will include the SSH command:

```bash
ssh azureuser@<fqdn>
```

## Setup Development Environment

Once connected to the VM, run the setup script to install development tools:

```bash
# Copy the install script to the VM
scp install.sh azureuser@<fqdn>:~/

# SSH into the VM
ssh azureuser@<fqdn>

# Run the installation script
chmod +x install.sh
./install.sh
```

The script installs:
- **tmux**: Terminal multiplexer
- **git**: Version control
- **Azure CLI**: Azure management
- **GitHub CLI**: GitHub integration
- **GitHub Copilot CLI**: AI-powered CLI assistant
- **VS Code Insiders**: Latest VS Code editor

After installation, authenticate with:
```bash
gh auth login    # GitHub authentication
az login         # Azure authentication (use --use-device-code for remote)
```

## Clean Up

```bash
az group delete --name rg-linux-devbox --yes --no-wait
```

## Configuration

Edit `main.bicepparam` to customize:
- `adminUsername`: Default is `azureuser`
- VM size is set to `Standard_B4ms_v2` by default (can override in bicep file or parameters)

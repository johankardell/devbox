# Copilot Instructions

## Project Overview

Azure infrastructure-as-code project for deploying an Ubuntu Linux development VM. Uses Bicep for Azure resource definitions and shell scripts for deployment and provisioning.

## Architecture

- `main.bicep` - Azure resource definitions (VM, VNet, NSG, public IP, NIC)
- `main.bicepparam` - Bicep parameters, reads `SSH_PUBLIC_KEY` and `ALLOWED_SOURCE_IP` from environment
- `deploy.sh` - Deployment script that creates resource group and deploys Bicep template, then copies config files to VM
- `install.sh` - Runs on the VM to install dev tools (zsh, tmux, Azure CLI, GitHub CLI, kubectl, OpenTofu, VS Code Insiders)
- Dotfiles (`.zshrc`, `.p10k.zsh`, `.tmux.conf`) - Copied to VM during deployment

## Key Conventions

- Resource naming: `{resource-type}-{vmName}` (e.g., `vnet-vm-linux-devbox`, `nic-vm-linux-devbox`)
- Default location: `swedencentral`
- VM size: `Standard_B4as_v2` (AMD-based, 4 vCPUs, 16 GB RAM)
- SSH-only authentication (password auth disabled)
- NSG restricts SSH to deployer's IP address

## Deployment

```bash
# Deploy VM (auto-detects IP and SSH key)
./deploy.sh

# Or set manually
SSH_PUBLIC_KEY=$(cat ~/.ssh/id_rsa.pub) ALLOWED_SOURCE_IP=1.2.3.4 ./deploy.sh
```

## Cleanup

```bash
az group delete --name rg-linux-devbox --yes --no-wait
```

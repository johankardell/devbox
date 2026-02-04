# Azure Linux DevBox

Bicep templates to deploy an Ubuntu Linux development VM in Azure.

## What Gets Deployed

- Ubuntu 25.10 VM (`Standard_B4as_v2` - 4 vCPUs, 16 GB RAM)
- VNet, NSG (SSH restricted to your IP), public IP with DNS
- Premium SSD OS disk

## Prerequisites

- Azure CLI authenticated (`az login`)
- SSH key pair (`~/.ssh/id_rsa.pub`)

## Deploy

```bash
./deploy.sh
```

The script auto-detects your public IP and SSH key. Override with `ALLOWED_SOURCE_IP` and `SSH_PUBLIC_KEY` env vars.

## Setup Dev Environment

```bash
scp install.sh .zshrc .p10k.zsh .tmux.conf azureuser@<fqdn>:~/
ssh azureuser@<fqdn>
./install.sh
```

Installs: zsh + Oh My Zsh + Powerlevel10k, tmux, git, Azure CLI, GitHub CLI, VS Code Insiders.

Then authenticate:
```bash
gh auth login
az login --use-device-code
```

## VS Code Remote SSH

Add to `~/.ssh/config`:
```
Host devbox
    HostName <fqdn>
    User azureuser
```

In VS Code: Install "Remote - SSH" extension → Connect to `devbox`.

## Clean Up

```bash
az group delete --name rg-linux-devbox --yes --no-wait
```

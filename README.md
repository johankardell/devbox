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
# Copy the install script and zsh configs to the VM
scp install.sh .zshrc .p10k.zsh azureuser@<fqdn>:~/

# SSH into the VM
ssh azureuser@<fqdn>

# Run the installation script
chmod +x install.sh
./install.sh

# Logout and login again to start using zsh
exit
ssh azureuser@<fqdn>
```

The script installs:
- **zsh**: Modern shell with Oh My Zsh and Powerlevel10k theme
- **tmux**: Terminal multiplexer
- **git**: Version control
- **Azure CLI**: Azure management
- **GitHub CLI**: GitHub integration with built-in Copilot support
- **VS Code Insiders**: Latest VS Code editor

Your local zsh configuration (aliases, plugins, theme) will be replicated on the VM.

After installation, authenticate with:
```bash
gh auth login             # GitHub authentication (includes Copilot access)
az login --use-device-code # Azure authentication (use device code for remote)
```

## Using VM as VS Code Remote Backend

### Setup Remote SSH Connection

1. **Add VM to SSH config** (on your laptop):
   ```bash
   # Edit your SSH config
   nano ~/.ssh/config
   
   # Add the following entry:
   Host devbox
       HostName <FQDN from deployment>
       User azureuser
       IdentityFile ~/.ssh/id_rsa
   ```

2. **Install VS Code Remote - SSH extension** (on your laptop):
   - Open VS Code on your laptop
   - Install the "Remote - SSH" extension by Microsoft
   - Press `F1` and select "Remote-SSH: Connect to Host..."
   - Select `devbox` from the list
   - VS Code will connect to the VM and install the VS Code Server automatically

3. **Start coding**:
   - Once connected, VS Code runs on your laptop but executes code on the VM
   - Open folders on the remote VM: `File > Open Folder`
   - Install extensions on the remote VM as needed
   - Terminal in VS Code runs on the VM
   - All IntelliSense, debugging, and git operations run on the VM

### Tips for Remote Development

- **Port Forwarding**: VS Code automatically forwards ports from the VM to your laptop
- **Extensions**: Install extensions in the remote context (they'll show "Install in SSH: devbox")
- **Settings Sync**: Enable Settings Sync to keep your extensions and preferences across machines
- **Performance**: The VM processes everything; your laptop only handles UI rendering
- **Tunneling Alternative**: You can also use `code-insiders tunnel` on the VM for connection without SSH port forwarding

## Clean Up

```bash
az group delete --name rg-linux-devbox --yes --no-wait
```

## Configuration

Edit `main.bicepparam` to customize:
- `adminUsername`: Default is `azureuser`
- VM size is set to `Standard_B4ms_v2` by default (can override in bicep file or parameters)

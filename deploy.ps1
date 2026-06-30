$ErrorActionPreference = "Stop"

$RESOURCE_GROUP = "rg-linux-devbox"
$LOCATION = "swedencentral"
$SUBSCRIPTION_NAME = "two"

Write-Host "Setting subscription to '$SUBSCRIPTION_NAME'..."
az account set --subscription $SUBSCRIPTION_NAME

if (-not $env:SSH_PUBLIC_KEY) {
    $sshKeyPath = "$HOME\.ssh\id_rsa.pub"
    if (Test-Path $sshKeyPath) {
        $env:SSH_PUBLIC_KEY = Get-Content $sshKeyPath -Raw
    } else {
        Write-Error "Error: SSH_PUBLIC_KEY environment variable not set and $sshKeyPath not found`nPlease set SSH_PUBLIC_KEY or generate an SSH key pair"
        exit 1
    }
}

if (-not $env:ALLOWED_SOURCE_IP) {
    Write-Host "Detecting current public IP address..."
    $env:ALLOWED_SOURCE_IP = (Invoke-RestMethod -Uri "https://api.ipify.org")
    if (-not $env:ALLOWED_SOURCE_IP) {
        Write-Error "Error: Failed to detect public IP address`nPlease set ALLOWED_SOURCE_IP environment variable manually"
        exit 1
    }
    Write-Host "Detected IP: $env:ALLOWED_SOURCE_IP"
}

Write-Host "Creating resource group..."
az group create --name $RESOURCE_GROUP --location $LOCATION

Write-Host "Deploying Bicep template..."
az deployment group create `
    --resource-group $RESOURCE_GROUP `
    --template-file main.bicep `
    --parameters main.bicepparam `
    --output none

Write-Host ""
Write-Host "===================================="
Write-Host "Deployment complete!"
Write-Host "===================================="
Write-Host ""

Write-Host "Retrieving VM details..."
$DEPLOYMENT_OUTPUT = az deployment group show `
    --resource-group $RESOURCE_GROUP `
    --name main `
    --query properties.outputs `
    --output json | ConvertFrom-Json

$SSH_COMMAND = $DEPLOYMENT_OUTPUT.sshCommand.value
$PUBLIC_IP = $DEPLOYMENT_OUTPUT.publicIPAddress.value
$FQDN = $DEPLOYMENT_OUTPUT.fqdn.value

Write-Host "VM Details:"
Write-Host "  Public IP: $PUBLIC_IP"
Write-Host "  FQDN: $FQDN"
Write-Host ""
Write-Host "Connect to your VM:"
Write-Host "  $SSH_COMMAND"
Write-Host ""

Write-Host "Copying configuration files to VM..."
$VM_HOST = ($SSH_COMMAND -split " ")[-1]

# Copy SSH keys for GitHub authentication
$privateKeyPath = "$HOME\.ssh\id_rsa"
$publicKeyPath = "$HOME\.ssh\id_rsa.pub"
if ((Test-Path $privateKeyPath) -and (Test-Path $publicKeyPath)) {
    Write-Host "  - Copying SSH keys..."
    scp -P 9090 $privateKeyPath $publicKeyPath "${VM_HOST}:~/.ssh/"
    ssh -p 9090 $VM_HOST "chmod 600 ~/.ssh/id_rsa && chmod 644 ~/.ssh/id_rsa.pub"
} else {
    Write-Host "  - Warning: SSH keys not found, skipping..."
}

# Copy configuration files
Write-Host "  - Copying configuration files..."
scp -P 9090 install.sh .zshrc .p10k.zsh .tmux.conf "${VM_HOST}:~/"

# Copy Neovim configuration
Write-Host "  - Copying Neovim configuration..."
ssh -p 9090 $VM_HOST "mkdir -p ~/.config/nvim/lua/config ~/.config/nvim/lua/plugins"
scp -P 9090 -r nvim/* nvim/.neoconf.json "${VM_HOST}:~/.config/nvim/"

Write-Host ""
Write-Host "Files copied successfully!"
Write-Host ""

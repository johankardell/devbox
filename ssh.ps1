# Disable global secure access if you're having issues logging in from Windows

param(
    [switch]$Nsg,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$SshArgs
)

$ErrorActionPreference = "Stop"

$SUBSCRIPTION_NAME = "two"
$RESOURCE_GROUP = "rg-linux-devbox"
$VM_NAME = "vm-linux-devbox"
$PUBLIC_IP_NAME = "pip-$VM_NAME"
$USERNAME = "azureuser"

if ($Nsg) {
    # Update NSG rule to allow SSH from current IP
    $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    Write-Host "Updating NSG rule..."
    & "$ScriptDir\update_nsg.ps1"
} else {
    Write-Host "Skipping NSG update. Use -Nsg to update NSG before connecting."
}

Write-Host "Setting subscription to '$SUBSCRIPTION_NAME'..."
az account set --subscription $SUBSCRIPTION_NAME

Write-Host "Getting public IP for '$VM_NAME'..."
$PUBLIC_IP = az network public-ip show `
    --resource-group $RESOURCE_GROUP `
    --name $PUBLIC_IP_NAME `
    --query "ipAddress" -o tsv

if (-not $PUBLIC_IP) {
    Write-Error "Error: Could not get public IP for '$VM_NAME'"
    exit 1
}

Write-Host "Connecting to $USERNAME@$PUBLIC_IP..."
# On Windows, SSH may not auto-discover keys from ~/.ssh due to file permission requirements.
# Explicitly pass the first available private key as a workaround.
$SSH_KEY = @("id_ed25519", "id_rsa", "id_ecdsa", "id_dsa") |
    Where-Object { Test-Path "$HOME\.ssh\$_" } |
    Select-Object -First 1

if ($SSH_KEY) {
    ssh -p 9090 -i "$HOME\.ssh\$SSH_KEY" "$USERNAME@$PUBLIC_IP" @SshArgs
} else {
    ssh -p 9090 "$USERNAME@$PUBLIC_IP" @SshArgs
}

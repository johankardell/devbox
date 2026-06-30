$ErrorActionPreference = "Stop"

$SUBSCRIPTION_NAME = "two"

Write-Host "Setting subscription to '$SUBSCRIPTION_NAME'..."
az account set --subscription $SUBSCRIPTION_NAME

# Get the current public IP
$CURRENT_IP = (Invoke-RestMethod -Uri "https://api.ipify.org")

if (-not $CURRENT_IP) {
    Write-Error "Error: Could not detect current IP address"
    exit 1
}

# Extract the C-class network (first three octets)
$octets = $CURRENT_IP -split "\."
$CNET = "$($octets[0]).$($octets[1]).$($octets[2]).0/24"

Write-Host "Current IP: $CURRENT_IP"
Write-Host "Allowing C-net: $CNET"

# Resource names
$RESOURCE_GROUP = "rg-linux-devbox"
$NSG_NAME = "nsg-vm-linux-devbox"
$RULE_NAME = "AllowSSH"

# Check if the NSG rule exists
$ruleExists = $true
try {
    az network nsg rule show `
        --resource-group $RESOURCE_GROUP `
        --nsg-name $NSG_NAME `
        --name $RULE_NAME `
        --output none 2>$null
    if ($LASTEXITCODE -ne 0) { $ruleExists = $false }
} catch {
    $ruleExists = $false
}

if ($ruleExists) {
    # Update existing rule
    Write-Host "Updating NSG rule '$RULE_NAME' in '$NSG_NAME'..."
    az network nsg rule update `
        --resource-group $RESOURCE_GROUP `
        --nsg-name $NSG_NAME `
        --name $RULE_NAME `
        --source-address-prefixes $CNET
    Write-Host "NSG rule updated successfully. SSH access now allowed from $CNET"
} else {
    # Create new rule
    Write-Host "Creating NSG rule '$RULE_NAME' in '$NSG_NAME'..."
    az network nsg rule create `
        --resource-group $RESOURCE_GROUP `
        --nsg-name $NSG_NAME `
        --name $RULE_NAME `
        --priority 1000 `
        --source-address-prefixes $CNET `
        --destination-port-ranges 9090 `
        --access Allow `
        --protocol Tcp
    Write-Host "NSG rule created successfully. SSH access now allowed from $CNET"
}

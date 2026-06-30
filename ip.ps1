$ErrorActionPreference = "Stop"

$SUBSCRIPTION_NAME = "two"
$RESOURCE_GROUP = "rg-linux-devbox"
$VM_NAME = "vm-linux-devbox"
$PUBLIC_IP_NAME = "pip-$VM_NAME"

Write-Host "Setting subscription to '$SUBSCRIPTION_NAME'..."
az account set --subscription $SUBSCRIPTION_NAME

Write-Host "Getting public IP for '$VM_NAME'..."
$PUBLIC_IP = az network public-ip show `
    --resource-group $RESOURCE_GROUP `
    --name $PUBLIC_IP_NAME `
    --query "ipAddress" -o tsv

Write-Host $PUBLIC_IP

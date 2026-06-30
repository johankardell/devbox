$ErrorActionPreference = "Stop"

$SUBSCRIPTION_NAME = "two"
$RESOURCE_GROUP = "rg-linux-devbox"
$VM_NAME = "vm-linux-devbox"

Write-Host "Setting subscription to '$SUBSCRIPTION_NAME'..."
az account set --subscription $SUBSCRIPTION_NAME

Write-Host "Stopping and deallocating VM '$VM_NAME'..."
az vm deallocate `
    --resource-group $RESOURCE_GROUP `
    --name $VM_NAME

Write-Host "VM '$VM_NAME' stopped and deallocated successfully."

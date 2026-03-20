#!/bin/bash
set -e

SUBSCRIPTION_NAME="two"
RESOURCE_GROUP="rg-linux-devbox"
VM_NAME="vm-linux-devbox"
PUBLIC_IP_NAME="pip-${VM_NAME}"
USERNAME="azureuser"

# Update NSG rule to allow SSH from current IP
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Updating NSG rule..."
"$SCRIPT_DIR/update_nsg.sh"

echo "Getting subscription ID for '$SUBSCRIPTION_NAME'..."
SUBSCRIPTION_ID=$(az account list --query "[?name=='$SUBSCRIPTION_NAME'].id" -o tsv)
if [ -z "$SUBSCRIPTION_ID" ]; then
    echo "Error: Subscription '$SUBSCRIPTION_NAME' not found"
    exit 1
fi

echo "Getting public IP for '$VM_NAME'..."
PUBLIC_IP=$(az network public-ip show \
    --resource-group "$RESOURCE_GROUP" \
    --name "$PUBLIC_IP_NAME" \
    --subscription "$SUBSCRIPTION_ID" \
    --query "ipAddress" -o tsv)

if [ -z "$PUBLIC_IP" ]; then
    echo "Error: Could not get public IP for '$VM_NAME'"
    exit 1
fi

echo "Connecting to $USERNAME@$PUBLIC_IP..."
ssh -p 9090 "$USERNAME@$PUBLIC_IP" "$@"

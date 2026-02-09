#!/bin/bash
set -e

SUBSCRIPTION_NAME="two"
RESOURCE_GROUP="rg-linux-devbox"
VM_NAME="vm-linux-devbox"

echo "Getting subscription ID for '$SUBSCRIPTION_NAME'..."
SUBSCRIPTION_ID=$(az account list --query "[?name=='$SUBSCRIPTION_NAME'].id" -o tsv)
if [ -z "$SUBSCRIPTION_ID" ]; then
    echo "Error: Subscription '$SUBSCRIPTION_NAME' not found"
    exit 1
fi

echo "Starting VM '$VM_NAME'..."
az vm start \
    --resource-group "$RESOURCE_GROUP" \
    --name "$VM_NAME" \
    --subscription "$SUBSCRIPTION_ID"

echo "VM '$VM_NAME' started successfully."

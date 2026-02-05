#!/bin/bash
set -e

SUBSCRIPTION_NAME="two"

echo "Getting subscription ID for '$SUBSCRIPTION_NAME'..."
SUBSCRIPTION_ID=$(az account list --query "[?name=='$SUBSCRIPTION_NAME'].id" -o tsv)
if [ -z "$SUBSCRIPTION_ID" ]; then
    echo "Error: Subscription '$SUBSCRIPTION_NAME' not found"
    exit 1
fi

# Get the current public IP
CURRENT_IP=$(curl -s https://api.ipify.org)

if [ -z "$CURRENT_IP" ]; then
    echo "Error: Could not detect current IP address"
    exit 1
fi

# Extract the C-class network (first three octets)
CNET=$(echo "$CURRENT_IP" | awk -F. '{print $1"."$2"."$3".0/24"}')

echo "Current IP: $CURRENT_IP"
echo "Allowing C-net: $CNET"

# Resource names
RESOURCE_GROUP="rg-linux-devbox"
NSG_NAME="nsg-vm-linux-devbox"
RULE_NAME="AllowSSH"

# Check if the NSG rule exists
if az network nsg rule show \
    --resource-group "$RESOURCE_GROUP" \
    --nsg-name "$NSG_NAME" \
    --name "$RULE_NAME" \
    --subscription "$SUBSCRIPTION_ID" \
    --output none 2>/dev/null; then
    # Update existing rule
    echo "Updating NSG rule '$RULE_NAME' in '$NSG_NAME'..."
    az network nsg rule update \
        --resource-group "$RESOURCE_GROUP" \
        --nsg-name "$NSG_NAME" \
        --name "$RULE_NAME" \
        --source-address-prefixes "$CNET" \
        --subscription "$SUBSCRIPTION_ID"
    echo "NSG rule updated successfully. SSH access now allowed from $CNET"
else
    # Create new rule
    echo "Creating NSG rule '$RULE_NAME' in '$NSG_NAME'..."
    az network nsg rule create \
        --resource-group "$RESOURCE_GROUP" \
        --nsg-name "$NSG_NAME" \
        --name "$RULE_NAME" \
        --priority 1000 \
        --source-address-prefixes "$CNET" \
        --destination-port-ranges 22 \
        --access Allow \
        --protocol Tcp \
        --subscription "$SUBSCRIPTION_ID"
    echo "NSG rule created successfully. SSH access now allowed from $CNET"
fi

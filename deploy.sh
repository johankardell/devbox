#!/bin/bash
set -e

RESOURCE_GROUP="rg-linux-devbox"
LOCATION="swedencentral"

if [ -z "$SSH_PUBLIC_KEY" ]; then
    if [ -f ~/.ssh/id_rsa.pub ]; then
        export SSH_PUBLIC_KEY=$(cat ~/.ssh/id_rsa.pub)
    else
        echo "Error: SSH_PUBLIC_KEY environment variable not set and ~/.ssh/id_rsa.pub not found"
        echo "Please set SSH_PUBLIC_KEY or generate an SSH key pair"
        exit 1
    fi
fi

if [ -z "$ALLOWED_SOURCE_IP" ]; then
    echo "Detecting current public IP address..."
    ALLOWED_SOURCE_IP=$(curl -s https://api.ipify.org)
    if [ -z "$ALLOWED_SOURCE_IP" ]; then
        echo "Error: Failed to detect public IP address"
        echo "Please set ALLOWED_SOURCE_IP environment variable manually"
        exit 1
    fi
    export ALLOWED_SOURCE_IP
    echo "Detected IP: $ALLOWED_SOURCE_IP"
fi

echo "Creating resource group..."
az group create --name $RESOURCE_GROUP --location $LOCATION

echo "Deploying Bicep template..."
az deployment group create \
    --resource-group $RESOURCE_GROUP \
    --template-file main.bicep \
    --parameters main.bicepparam \
    --output none

echo ""
echo "===================================="
echo "Deployment complete!"
echo "===================================="
echo ""

echo "Retrieving VM details..."
DEPLOYMENT_OUTPUT=$(az deployment group show \
    --resource-group $RESOURCE_GROUP \
    --name main \
    --query properties.outputs \
    --output json)

SSH_COMMAND=$(echo $DEPLOYMENT_OUTPUT | jq -r '.sshCommand.value')
PUBLIC_IP=$(echo $DEPLOYMENT_OUTPUT | jq -r '.publicIPAddress.value')
FQDN=$(echo $DEPLOYMENT_OUTPUT | jq -r '.fqdn.value')

echo "VM Details:"
echo "  Public IP: $PUBLIC_IP"
echo "  FQDN: $FQDN"
echo ""
echo "Connect to your VM:"
echo "  $SSH_COMMAND"
echo ""
echo "Copy install script to VM:"
echo "  scp install.sh .zshrc .p10k.zsh ${SSH_COMMAND#ssh }:~/"
echo ""

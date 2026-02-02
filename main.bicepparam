using './main.bicep'

param location = 'swedencentral'
param adminUsername = 'azureuser'
param sshPublicKey = readEnvironmentVariable('SSH_PUBLIC_KEY')
param allowedSourceIP = readEnvironmentVariable('ALLOWED_SOURCE_IP')

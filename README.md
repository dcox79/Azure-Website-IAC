# Azure Infrastructure Deployment

## Prerequisites
- Azure CLI
- Azure subscription
- Resource Group created

## Setup

1. Login to Azure
```bash
az account list --refresh --output table
az login
```

2. Set your subscription
```bash
az account set --subscription <subscription-id>
```

3. Create a resource group (if not exists)
```bash
az group create --name <resource-group-name> --location eastus
```

## Parameters

Required parameters are defined in `main.bicepparam`:
```bicep:main.bicepparam
startLine: 1
endLine: 33
```

## Deployment

1. Test the deployment (What-if)
```bash
az deployment group what-if \
  --resource-group <resource-group-name> \
  --template-file main.bicep \
  --parameters main.bicepparam
```

2. Deploy the infrastructure
```bash
az deployment group create \
  --resource-group <resource-group-name> \
  --template-file main.bicep \
  --parameters main.bicepparam
```

## Resources Deployed
- Storage Accounts (Primary and Function)
- Function App (with staging slot)
- Front Door
- DNS Zone
- App Service Plan
- Cosmos DB Account

## Notes
- Ensure all parameter values in `main.bicepparam` are properly configured
- DNS records should be updated with your actual verification codes
- The deployment may take 15-20 minutes to complete
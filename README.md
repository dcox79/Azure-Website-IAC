# Azure Cloud Infrastructure as Code

This repository contains Infrastructure as Code (IaC) templates using Azure Bicep for deploying a complete cloud infrastructure. The infrastructure includes serverless functions, content delivery, database, and storage components configured for both production and non-production environments.

## Architecture Overview

![Architecture Diagram]
The infrastructure consists of the following components:

- **Azure Front Door**: Global load balancer and CDN
- **Azure Functions**: Serverless compute with staging slots
- **Azure Storage Accounts**: Blob storage for various purposes
- **Azure Cosmos DB**: NoSQL database with serverless configuration
- **Azure DNS**: Custom domain management
- **App Service Plan**: Hosting plan for Function Apps

## Prerequisites

- Azure CLI (version 2.50.0 or later)
- Azure subscription with Owner/Contributor access
- PowerShell 7+ or Azure Cloud Shell
- Visual Studio Code with Bicep extension (optional)

## Repository Structure

```
.
├── main.bicep              # Main deployment template
├── main.bicepparam        # Parameter file
├── modules/
│   ├── appServicePlan.bicep    # App Service Plan configuration
│   ├── cosmosDbAccount.bicep   # Cosmos DB configuration
│   ├── createContainer.bicep   # Storage container creation
│   ├── dnsZone.bicep          # DNS configuration
│   ├── frontDoor.bicep        # Front Door configuration
│   ├── functionAppProd.bicep   # Production function app
│   ├── functionAppStage.bicep  # Staging function app
│   └── storageAccount.bicep    # Storage account configuration
```

## Environment Setup

1. Install Azure CLI and login:
```bash
# Install Azure CLI (Windows)
winget install Microsoft.AzureCLI

# Login to Azure
az login
az account set --subscription "<subscription-id>"
```

2. Configure environment variables:
```powershell
$RG="your-resource-group"
$LOCATION="eastus"
$TEMPLATE="main.bicep"
$PARAMS="main.bicepparam"
```

3. Create Resource Group:
```bash
az group create --name $RG --location $LOCATION
```

## Parameter Configuration

Update `main.bicepparam` with your specific values:

- `environment`: 'prod' or 'nonprod'
- `location`: Azure region
- `zoneName`: Your custom domain
- `funcName`: Base name for function apps
- `profileName`: Front Door profile name
- `tags`: Resource tagging structure
- `dnsRecords`: DNS configuration including verification codes

## Deployment

1. Validate the deployment:
```bash
az deployment group what-if --resource-group $RG --template-file $TEMPLATE --parameters $PARAMS
```

2. Deploy the infrastructure:
```bash
az deployment group create --resource-group $RG --template-file $TEMPLATE --parameters $PARAMS
```

## Security Considerations

- All storage accounts are configured with:
  - HTTPS-only access
  - TLS 1.2 minimum version
  - Disabled public blob access
  - OAuth authentication enabled
  
- Function Apps include:
  - HTTPS-only access
  - Managed identity authentication
  - CORS configuration for specified domains
  - FTPS-only state

- Front Door provides:
  - WAF protection (optional)
  - TLS 1.2 minimum version
  - Managed certificates for custom domains

## Monitoring and Maintenance

1. Monitor deployments:
```bash
az deployment group list --resource-group $RG --query "[].{Name:name, ProvisioningState:properties.provisioningState}" -o table
```

2. Check resource health:
```bash
az resource list --resource-group $RG --query "[].{Name:name, Type:type, Status:properties.provisioningState}" -o table
```

## Troubleshooting

Common issues and solutions:

1. **Deployment Failures**
   - Verify parameter values in main.bicepparam
   - Check resource name availability
   - Verify subscription permissions

2. **DNS Configuration**
   - Ensure DNS verification codes are correct
   - Allow time for DNS propagation (up to 48 hours)
   - Verify domain ownership

3. **Function App Issues**
   - Check App Service Plan scaling
   - Verify storage account connections
   - Review application settings

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
## Support

For support and questions, please open an issue in the repository.

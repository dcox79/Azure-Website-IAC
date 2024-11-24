@description('The name of the App Service Plan')
param appServicePlanName string

@description('The location for the App Service Plan')
param location string

@description('The SKU name for the App Service Plan')
param skuName string

@description('The OS type for the App Service Plan')
@allowed([
  'Windows'
  'Linux'
])
param osType string = 'Linux'

@description('The SKU tier for the App Service Plan')
@allowed([
  'Free'
  'Shared'
  'Basic'
  'Standard'
  'Premium'
  'PremiumV2'
  'PremiumV3'
  'Isolated'
  'IsolatedV2'
])
param skuTier string

@description('Resource tags')
param tags object

resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  sku: {
    name: skuName
    tier: skuTier
  }
  kind: osType == 'Linux' ? 'linux' : 'app'
  properties: {
    reserved: osType == 'Linux'
  }
}

output appServicePlanId string = appServicePlan.id

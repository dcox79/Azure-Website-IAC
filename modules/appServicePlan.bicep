@description('The name of the App Service Plan')
param appServicePlanName string

@description('The location for the App Service Plan')
param location string = resourceGroup().location

@description('The SKU name for the App Service Plan')
@allowed([
  'Y1'  // Consumption
  'B1'  // Basic
  'S1'  // Standard
  'P1V2' // Premium V2
])
param skuName string = 'Y1'

@description('The SKU tier for the App Service Plan')
param skuTier string = 'Dynamic'

@description('The operating system type for the App Service Plan')
@allowed([
  'linux'
  'windows'
])
param osType string = 'linux'

var isPremiumTier = contains(skuName, 'P')
var isConsumptionTier = skuName == 'Y1'

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanName
  location: location
  kind: osType == 'linux' ? 'functionapp,linux' : 'functionapp'
  sku: {
    name: skuName
    tier: skuTier
    size: skuName
    family: take(skuName, 1)
    capacity: isConsumptionTier ? 0 : 1
  }
  properties: {
    perSiteScaling: false
    elasticScaleEnabled: isPremiumTier
    maximumElasticWorkerCount: isPremiumTier ? 20 : 1
    isSpot: false
    reserved: osType == 'linux'
    isXenon: false
    hyperV: false
    targetWorkerCount: 0
    targetWorkerSizeId: 0
    zoneRedundant: false
  }
}

// Outputs
output appServicePlanId string = appServicePlan.id
output appServicePlanName string = appServicePlan.name

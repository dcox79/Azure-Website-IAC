@description('The environment type for deployment (nonprod or prod)')
@allowed([
  'nonprod'
  'prod'
])
param environment string = 'prod'

@description('Azure region for resource deployment')
param location string = resourceGroup().location

@description('The domain name for DNS configuration')
param zoneName string

@description('Base name for the function app')
param funcName string

@description('Front Door profile name')
param profileName string

@description('DNS records configuration')
param dnsRecords object

@description('Resource tags')
param tags object

// Variables
var uniqueSuffix = uniqueString(subscription().subscriptionId, resourceGroup().id)
var storageAccountSkuName = (environment == 'prod') ? 'Standard_GRS' : 'Standard_LRS'
var appServicePlanSkuName = (environment == 'prod') ? 'P1V2' : 'B1'
var functionAppName = '${environment}-${funcName}-${uniqueSuffix}'
var primaryStorageAccountName = '${take(environment, 1)}stor${take(uniqueSuffix, 6)}'
var functionStorageAccountName = '${take(environment, 1)}func${take(uniqueSuffix, 6)}'

module primaryStorageAccountModule './modules/storageAccount.bicep' = {
  name: 'primaryStorageDeployment'
  params: {
    storageAccountName: primaryStorageAccountName
    location: location
    skuName: storageAccountSkuName
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    tags: tags
  }
}

module functionStorageAccountModule './modules/storageAccount.bicep' = {
  name: 'functionStorageDeployment'
  params: {
    storageAccountName: functionStorageAccountName
    location: location
    skuName: storageAccountSkuName
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
    tags: tags
  }
}

var functionContainers = [
  'azure-webjobs-hosts'
  'azure-webjobs-secrets'
  'function-releases'
  'scm-releases'
]

module functionContainerDeployments 'modules/createContainer.bicep' = [for container in functionContainers: {
  name: '${functionStorageAccountModule.name}-${container}-container'
  params: {
    storageAccountName: functionStorageAccountModule.outputs.storageAccountName
    containerName: container
  }
  dependsOn: [
    functionStorageAccountModule
  ]
}]

module frontDoorModule './modules/frontDoor.bicep' = {
  name: 'frontDoorDeployment'
  params: {
    profileName: profileName
    dnsZoneId: resourceId('Microsoft.Network/dnszones', zoneName)
    zoneName: zoneName
    tags: tags
  }
}

module dnsZoneModule './modules/dnsZone.bicep' = {
  name: 'dnsZoneDeployment'
  params: {
    zoneName: zoneName
    frontDoorEndpointId: frontDoorModule.outputs.endpointId
    dnsRecords: dnsRecords
  }
}

module appServicePlanModule './modules/appServicePlan.bicep' = {
  name: 'appServicePlanDeployment'
  params: {
    appServicePlanName: '${environment}-myproject-asp'
    location: location
    skuName: appServicePlanSkuName
    osType: 'Linux'
    skuTier: environment == 'prod' ? 'PremiumV2' : 'Basic'
    tags: tags
  }
}

module functionAppProdModule './modules/functionAppProd.bicep' = {
  name: 'functionAppProdDeployment'
  params: {
    functionAppName: functionAppName
    location: location
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    zoneName: zoneName
    runtimeStack: 'dotnet-isolated|8.0'
    tags: tags
  }
}

module cosmosDbModule './modules/cosmosDbAccount.bicep' = {
  name: 'cosmosDbDeployment'
  params: {
    accountName: '${take(environment, 1)}cosmos${take(uniqueSuffix, 6)}'
    location: location
    defaultConsistencyLevel: 'Session'
    enableFreeTier: environment != 'prod'
  }
}

output primaryStorageAccountId string = primaryStorageAccountModule.outputs.storageAccountId
output primaryStorageAccountName string = primaryStorageAccountModule.outputs.storageAccountName
output functionStorageAccountId string = functionStorageAccountModule.outputs.storageAccountId
output functionStorageAccountName string = functionStorageAccountModule.outputs.storageAccountName

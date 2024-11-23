param environment string
param location string = resourceGroup().location
param zoneName string
param funcName string
param dnsRecords object = {
  aRecords: [
    {
      name: '@'
      ttl: 3600
    }
  ]
  cnameRecords: [
    {
      name: 'www'
      ttl: 3600
    }
    {
      name: 'cdnverify.www'
      ttl: 3600
      cname: 'cdnverify.myhome.azureedge.net'
    }
  ]
  txtRecords: [
    {
      name: '@'
      ttl: 3600
      values: [
        'MS=ms12345678' // Replace with your actual verification code
      ]
    }
  ]
}

var namePrefix = toLower('${environment}myproject')

module primaryStorageAccountModule './modules/storageAccount.bicep' = {
  name: 'primaryStorageDeployment'
  params: {
    storageAccountName: '${namePrefix}stor'
    location: location
    skuName: 'Standard_LRS'
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
  }
}

module functionStorageAccountModule './modules/storageAccount.bicep' = {
  name: 'functionStorageDeployment'
  params: {
    storageAccountName: '${namePrefix}func'
    location: location
    skuName: 'Standard_LRS'
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    allowSharedKeyAccess: true
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
    profiles_myhomepage_name: 'myhomepage'
    dnszones_davidjcox_com_externalid: resourceId('Microsoft.Network/dnszones', zoneName)
    storageAccountName: primaryStorageAccountModule.outputs.storageAccountName
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
    appServicePlanName: '${namePrefix}-asp'
    location: location
  }
}

var functionAppName = '${funcName}-${uniqueString(resourceGroup().id)}'

module functionAppStageModule './modules/functionAppStage.bicep' = {
  name: 'functionAppStageDeployment'
  params: {
    sites_name: functionAppName
    location: location
    serverfarms_ASP_externalid: appServicePlanModule.outputs.appServicePlanId
    zoneName: zoneName
  }
}

module functionAppProdModule './modules/functionAppProd.bicep' = {
  name: 'functionAppProdDeployment'
  params: {
    functionAppName: functionAppName
    location: location
    appServicePlanId: appServicePlanModule.outputs.appServicePlanId
    zoneName: zoneName
  }
}

output primaryStorageAccountId string = primaryStorageAccountModule.outputs.storageAccountId
output primaryStorageAccountName string = primaryStorageAccountModule.outputs.storageAccountName
output functionStorageAccountId string = functionStorageAccountModule.outputs.storageAccountId
output functionStorageAccountName string = functionStorageAccountModule.outputs.storageAccountName

@description('The name of the function app')
param functionAppName string

@description('The location for all resources')
param location string

@description('The App Service Plan ID')
param appServicePlanId string

@description('The runtime stack for the function app')
param runtimeStack string = 'DOTNET-ISOLATED|8.0'

@description('The zone name for CORS settings')
param zoneName string

resource functionApp 'Microsoft.Web/sites@2023-12-01' = {
  name: functionAppName
  location: location
  kind: 'functionapp,linux'
  properties: {
    serverFarmId: appServicePlanId
    reserved: true
    siteConfig: {
      linuxFxVersion: runtimeStack
      cors: {
        allowedOrigins: [
          'https://${zoneName}'
          'https://www.${zoneName}'
        ]
        supportCredentials: true
      }
      http20Enabled: true
      minTlsVersion: '1.2'
      ftpsState: 'FtpsOnly'
      use32BitWorkerProcess: false
    }
    httpsOnly: true
  }
}

resource functionAppStaging 'Microsoft.Web/sites/slots@2023-12-01' = {
  parent: functionApp
  name: 'staging'
  location: location
  kind: 'functionapp,linux'
  properties: {
    serverFarmId: appServicePlanId
    reserved: true
    siteConfig: {
      linuxFxVersion: runtimeStack
      cors: {
        allowedOrigins: [
          'https://${zoneName}'
          'https://www.${zoneName}'
        ]
        supportCredentials: true
      }
      http20Enabled: true
      minTlsVersion: '1.2'
      ftpsState: 'FtpsOnly'
      use32BitWorkerProcess: false
    }
    httpsOnly: true
  }
}

output functionAppName string = functionApp.name
output functionAppId string = functionApp.id
output defaultHostName string = functionApp.properties.defaultHostName

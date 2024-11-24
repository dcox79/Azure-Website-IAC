@description('The name of the function app')
param functionAppName string

@description('The location for the function app')
param location string

@description('The App Service Plan ID')
param appServicePlanId string

@description('The zone name for CORS settings')
param zoneName string

@description('The runtime stack for the function app')
param runtimeStack string

@description('Resource tags')
param tags object

resource functionApp 'Microsoft.Web/sites@2023-01-01' = {
  name: functionAppName
  location: location
  tags: tags
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

output functionAppId string = functionApp.id
output functionAppName string = functionApp.name

@description('The name of the function app')
param sites_name string

@description('The location for all resources')
param location string

@description('The App Service Plan ID')
param serverfarms_ASP_externalid string

@description('The zone name for CORS settings')
param zoneName string

@description('Resource tags')
param tags object

resource functionAppStage 'Microsoft.Web/sites@2023-12-01' = {
  name: sites_name
  location: location
  tags: tags
  kind: 'functionapp,linux'
  properties: {
    serverFarmId: serverfarms_ASP_externalid
    reserved: true
    siteConfig: {
      linuxFxVersion: 'DOTNET-ISOLATED|8.0'
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

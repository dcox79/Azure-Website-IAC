@description('The name of the Front Door profile')
param profileName string

@description('The DNS Zone resource ID')
param dnsZoneId string

@description('The primary storage account name')
param primaryStorageAccountName string

@description('The zone name for the custom domain')
param zoneName string

@description('Resource tags')
param tags object

@description('The location for the Front Door profile')
param location string = 'Global'

var uniqueSuffix = uniqueString(subscription().subscriptionId, resourceGroup().id)
var endpointName = 'endpoint-${uniqueSuffix}'
var customDomainName = '${zoneName}-domain-${uniqueSuffix}'

resource profiles_resource 'Microsoft.Cdn/profiles@2023-05-01' = {
  name: profileName
  location: location
  tags: tags
  sku: {
    name: 'Standard_AzureFrontDoor'
  }
  kind: 'frontdoor'
  properties: {
    originResponseTimeoutSeconds: 60
  }
}

resource endpoint 'Microsoft.Cdn/profiles/afdendpoints@2023-05-01' = {
  parent: profiles_resource
  name: endpointName
  location: location
  properties: {
    enabledState: 'Enabled'
  }
}

resource customDomain 'Microsoft.Cdn/profiles/customdomains@2023-05-01' = {
  parent: profiles_resource
  name: customDomainName
  properties: {
    hostName: zoneName
    tlsSettings: {
      certificateType: 'ManagedCertificate'
      minimumTlsVersion: 'TLS12'
      cipherSuiteSetType: 'TLS12_2022'
    }
    azureDnsZone: {
      id: dnsZoneId
    }
  }
}

// Reference existing storage account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' existing = {
  name: primaryStorageAccountName
}

output endpointId string = resourceId('Microsoft.Cdn/profiles/afdendpoints', profileName, endpoint.name)

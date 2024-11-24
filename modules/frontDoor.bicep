@description('The name of the Front Door profile')
param profileName string

@description('The DNS Zone resource ID')
param dnsZoneId string

@description('The zone name for the custom domain')
param zoneName string

@description('Resource tags')
param tags object

@description('The location for the Front Door profile')
param location string = 'Global'

var uniqueSuffix = take(uniqueString(subscription().subscriptionId, resourceGroup().id), 8)
var endpointName = 'endpoint-${uniqueSuffix}'
var customDomainName = replace(zoneName, '.', '-')

resource profiles_resource 'Microsoft.Cdn/profiles@2023-05-01' = {
  name: profileName
  location: location
  tags: tags
  sku: {
    name: 'Standard_AzureFrontDoor'
  }
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
    }
    azureDnsZone: {
      id: dnsZoneId
    }
  }
}

output endpointId string = resourceId('Microsoft.Cdn/profiles/afdendpoints', profileName, endpoint.name)

param profiles_myhomepage_name string = 'myhomepage'
param dnszones_davidjcox_com_externalid string = '/subscriptions/95f43086-5c7c-4125-b86e-870651585413/resourceGroups/MyResume-rg/providers/Microsoft.Network/dnszones/davidjcox.com'
param storageAccountName string

resource profiles_myhomepage_name_resource 'Microsoft.Cdn/profiles@2024-06-01-preview' = {
  name: profiles_myhomepage_name
  location: 'Global'
  sku: {
    name: 'Standard_AzureFrontDoor'
  }
  kind: 'frontdoor'
  properties: {
    originResponseTimeoutSeconds: 60
  }
}

resource profiles_myhomepage_name_myhome 'Microsoft.Cdn/profiles/afdendpoints@2024-06-01-preview' = {
  parent: profiles_myhomepage_name_resource
  name: 'myhome'
  location: 'Global'
  properties: {
    enabledState: 'Enabled'
  }
}

resource profiles_myhomepage_name_default_origin_group_2a56a917 'Microsoft.Cdn/profiles/origingroups@2024-06-01-preview' = {
  parent: profiles_myhomepage_name_resource
  name: 'default-origin-group-2a56a917'
  properties: {
    loadBalancingSettings: {
      sampleSize: 4
      successfulSamplesRequired: 3
      additionalLatencyInMilliseconds: 50
    }
    sessionAffinityState: 'Disabled'
  }
}

resource profiles_myhomepage_name_0_1bdcb501_76e5_44d7_877c_36d8d96c3ba3_davidjcox_com 'Microsoft.Cdn/profiles/secrets@2024-06-01-preview' = {
  parent: profiles_myhomepage_name_resource
  name: '0--1bdcb501-76e5-44d7-877c-36d8d96c3ba3-davidjcox-com'
  properties: {
    parameters: {
      type: 'ManagedCertificate'
    }
  }
}

resource profiles_myhomepage_name_0_b3a38306_8079_4854_9ae4_b969fe9130fe_www_davidjcox_com 'Microsoft.Cdn/profiles/secrets@2024-06-01-preview' = {
  parent: profiles_myhomepage_name_resource
  name: '0--b3a38306-8079-4854-9ae4-b969fe9130fe-www-davidjcox-com'
  properties: {
    parameters: {
      type: 'ManagedCertificate'
    }
  }
}

resource profiles_myhomepage_name_davidjcox_com_b7e3 'Microsoft.Cdn/profiles/customdomains@2024-06-01-preview' = {
  parent: profiles_myhomepage_name_resource
  name: 'davidjcox-com-b7e3'
  properties: {
    hostName: 'davidjcox.com'
    tlsSettings: {
      certificateType: 'ManagedCertificate'
      minimumTlsVersion: 'TLS12'
      cipherSuiteSetType: 'TLS12_2022'
      secret: {
        id: profiles_myhomepage_name_0_1bdcb501_76e5_44d7_877c_36d8d96c3ba3_davidjcox_com.id
      }
    }
    azureDnsZone: {
      id: dnszones_davidjcox_com_externalid
    }
  }
}

resource profiles_myhomepage_name_www_davidjcox_com_6f17 'Microsoft.Cdn/profiles/customdomains@2024-06-01-preview' = {
  parent: profiles_myhomepage_name_resource
  name: 'www-davidjcox-com-6f17'
  properties: {
    hostName: 'www.davidjcox.com'
    tlsSettings: {
      certificateType: 'ManagedCertificate'
      minimumTlsVersion: 'TLS12'
      cipherSuiteSetType: 'TLS12_2022'
      secret: {
        id: profiles_myhomepage_name_0_b3a38306_8079_4854_9ae4_b969fe9130fe_www_davidjcox_com.id
      }
    }
    azureDnsZone: {
      id: dnszones_davidjcox_com_externalid
    }
  }
}

resource profiles_myhomepage_name_default_origin_group_2a56a917_default_origin 'Microsoft.Cdn/profiles/origingroups/origins@2024-06-01-preview' = {
  parent: profiles_myhomepage_name_default_origin_group_2a56a917
  name: 'default-origin'
  properties: {
    hostName: storageAccount.properties.primaryEndpoints.web
    httpPort: 80
    httpsPort: 443
    originHostHeader: storageAccount.properties.primaryEndpoints.web
    priority: 1
    weight: 1000
    enabledState: 'Enabled'
    enforceCertificateNameCheck: true
  }
}

resource profiles_myhomepage_name_myhome_default_route 'Microsoft.Cdn/profiles/afdendpoints/routes@2024-06-01-preview' = {
  parent: profiles_myhomepage_name_myhome
  name: 'default-route'
  properties: {
    customDomains: [
      {
        id: profiles_myhomepage_name_davidjcox_com_b7e3.id
      }
      {
        id: profiles_myhomepage_name_www_davidjcox_com_6f17.id
      }
    ]
    grpcState: 'Disabled'
    originGroup: {
      id: profiles_myhomepage_name_default_origin_group_2a56a917.id
    }
    ruleSets: []
    supportedProtocols: [
      'Http'
      'Https'
    ]
    patternsToMatch: [
      '/*'
    ]
    forwardingProtocol: 'MatchRequest'
    linkToDefaultDomain: 'Enabled'
    httpsRedirect: 'Enabled'
    enabledState: 'Enabled'
  }
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

output endpointId string = resourceId('Microsoft.Cdn/profiles/afdendpoints', profiles_myhomepage_name, 'myhome')

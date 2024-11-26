/*
  Storage Account Module
  
  This module deploys a storage account with comprehensive security settings and
  necessary containers for Function Apps. It includes:
  - Blob, File, Queue, and Table services
  - Function-specific containers
  - OAuth authentication
  - TLS 1.2 enforcement
  - HTTPS-only access
*/

@description('The name of the storage account')
param storageAccountName string

@description('The location for the storage account')
param location string = resourceGroup().location

@description('The SKU for the storage account')
@allowed([
  'Standard_LRS'
  'Standard_GRS'
  'Standard_RAGRS'
  'Standard_ZRS'
  'Premium_LRS'
  'Premium_ZRS'
])
param skuName string = 'Standard_LRS'

@description('The access tier for the storage account')
@allowed([
  'Hot'
  'Cool'
])
param accessTier string = 'Hot'

@description('Enable public blob access')
param allowBlobPublicAccess bool = false

@description('Enable shared key access')
param allowSharedKeyAccess bool = true

@description('Custom domain name for the storage account')
param customDomain string = ''

@description('Resource tags')
param tags object

var storageAccountProperties = {
  defaultToOAuthAuthentication: true
  allowCrossTenantReplication: false
  minimumTlsVersion: 'TLS1_2'
  allowBlobPublicAccess: allowBlobPublicAccess
  allowSharedKeyAccess: allowSharedKeyAccess
  networkAcls: {
    bypass: 'AzureServices'
    virtualNetworkRules: []
    ipRules: []
    defaultAction: 'Allow'
  }
  supportsHttpsTrafficOnly: true
  encryption: {
    services: {
      file: {
        keyType: 'Account'
        enabled: true
      }
      blob: {
        keyType: 'Account'
        enabled: true
      }
    }
    keySource: 'Microsoft.Storage'
  }
  accessTier: accessTier
  customDomain: !empty(customDomain) ? {
    name: customDomain
    useSubDomainName: true
  } : null
}

// Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  name: storageAccountName
  location: location
  tags: tags
  sku: {
    name: skuName
  }
  kind: 'StorageV2'
  properties: storageAccountProperties
}

// Blob Service
resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      enabled: false
    }
  }
}

// Function App Containers
resource functionContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobService
  name: 'azure-webjobs-hosts'
  properties: {
    publicAccess: 'None'
    metadata: {}
  }
}

resource secretsContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobService
  name: 'azure-webjobs-secrets'
  properties: {
    publicAccess: 'None'
    metadata: {}
  }
}

// Queue Service
resource queueService 'Microsoft.Storage/storageAccounts/queueServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

// Table Service
resource tableService 'Microsoft.Storage/storageAccounts/tableServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
  }
}

// File Service
resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
    shareDeleteRetentionPolicy: {
      enabled: false
    }
  }
}

// Outputs
output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
output primaryEndpoints object = storageAccount.properties.primaryEndpoints

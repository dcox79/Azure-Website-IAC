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
      allowPermanentDelete: false
      enabled: false
    }
  }
}

// File Service
resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    protocolSettings: {
      smb: {}
    }
    cors: {
      corsRules: []
    }
    shareDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
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

// Function-specific containers
var functionContainers = [
  'azure-webjobs-hosts'
  'azure-webjobs-secrets'
  'function-releases'
  'scm-releases'
]

resource functionContainerResources 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = [for container in functionContainers: {
  parent: blobService
  name: container
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
}]

// Outputs
output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
output blobEndpoint string = storageAccount.properties.primaryEndpoints.blob
output fileEndpoint string = storageAccount.properties.primaryEndpoints.file
output queueEndpoint string = storageAccount.properties.primaryEndpoints.queue
output tableEndpoint string = storageAccount.properties.primaryEndpoints.table

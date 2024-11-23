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

var storageAccountProperties = {
  defaultToOAuthAuthentication: true
  allowCrossTenantReplication: false
  minimumTlsVersion: 'TLS1_2'
  allowBlobPublicAccess: false
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

// Web Container
resource webContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2023-05-01' = {
  parent: blobService
  name: '$web'
  properties: {
    immutableStorageWithVersioning: {
      enabled: false
    }
    defaultEncryptionScope: '$account-encryption-key'
    denyEncryptionScopeOverride: false
    publicAccess: 'None'
  }
}

// Outputs
output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
output primaryEndpoints object = storageAccount.properties.primaryEndpoints

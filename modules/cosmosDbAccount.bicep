@description('The name of the Cosmos DB account')
param accountName string

@description('The location for the Cosmos DB account')
param location string = resourceGroup().location

@description('The consistency level for the Cosmos DB account')
@allowed([
  'Eventual'
  'Session'
  'BoundedStaleness'
  'Strong'
  'ConsistentPrefix'
])
param defaultConsistencyLevel string = 'Session'

@description('Enable free tier for the Cosmos DB account')
param enableFreeTier bool = false

resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2024-05-15' = {
  name: accountName
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    consistencyPolicy: {
      defaultConsistencyLevel: defaultConsistencyLevel
      maxIntervalInSeconds: 5
      maxStalenessPrefix: 100
    }
    enableFreeTier: enableFreeTier
    capabilities: [
      {
        name: 'EnableServerless'
      }
    ]
    backupPolicy: {
      type: 'Periodic'
      periodicModeProperties: {
        backupIntervalInMinutes: 240
        backupRetentionIntervalInHours: 8
        backupStorageRedundancy: 'Geo'
      }
    }
  }
}

resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2024-05-15' = {
  parent: cosmosDbAccount
  name: 'CloudResume'
  properties: {
    resource: {
      id: 'CloudResume'
    }
  }
}

resource container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2024-05-15' = {
  parent: database
  name: 'Counter'
  properties: {
    resource: {
      id: 'Counter'
      partitionKey: {
        paths: [
          '/id'
        ]
        kind: 'Hash'
        version: 2
      }
    }
  }
}

output accountName string = cosmosDbAccount.name
output accountId string = cosmosDbAccount.id
output databaseName string = database.name
output containerName string = container.name

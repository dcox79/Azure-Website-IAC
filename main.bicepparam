using './main.bicep'

// Basic deployment parameters
param environment = 'prod'
param location = 'centralus'
param zoneName = 'davidjcox.online'
param funcName = 'djcJSONResume'
param profileName = 'djcJSONResPro'

// Resource tags
param tags = {
  Application: 'CloudResume'
  Environment: environment
  Owner: 'CloudTeam'
  CostCenter: 'CloudOps'
  ManagedBy: 'Bicep'
}

// DNS Configuration
param dnsRecords = {
  aRecords: [
    {
      name: '@'
      ttl: 3600
    }
  ]
  cnameRecords: [
    {
      name: 'www'
      ttl: 3600
    }
  ]
  txtRecords: []
}

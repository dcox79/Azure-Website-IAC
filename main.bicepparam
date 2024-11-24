using './main.bicep'

// Basic deployment parameters
param environment = 'prod'
param location = 'centralus'
param zoneName = '<ChangeME>'
param funcName = '<ChangeME>'
param profileName = '<ChangeME>'

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
  txtRecords: [
    {
      name: '@'
      ttl: 3600
      values: [
        'MS=ms12345678' // Replace with your actual verification code
      ]
    }
  ]
}

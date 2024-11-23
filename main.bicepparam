using './main.bicep'
param environment = 'prod'
param location = 'eastus'
param zoneName = 'davidjcox.com'
param funcName = 'getresumevisitors'
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
    {
      name: 'cdnverify.www'
      ttl: 3600
      cname: 'cdnverify.myhome.azureedge.net'
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

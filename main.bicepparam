using './main.bicep'
param environment = 'prod'
param location = 'centralus'
param zoneName = 'davidjcox.online'
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

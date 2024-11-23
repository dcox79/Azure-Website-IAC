@description('The DNS zone name')
param zoneName string

@description('The Front Door profile endpoint ID')
param frontDoorEndpointId string

@description('DNS record configuration')
param dnsRecords object = {
  aRecords: []
  cnameRecords: []
  txtRecords: []
}

resource dnsZone 'Microsoft.Network/dnszones@2023-07-01-preview' = {
  name: zoneName
  location: 'global'
  properties: {
    zoneType: 'Public'
  }
}

resource aRecords 'Microsoft.Network/dnszones/A@2023-07-01-preview' = [for record in dnsRecords.aRecords: {
  parent: dnsZone
  name: record.name
  properties: {
    TTL: record.ttl
    targetResource: {
      id: frontDoorEndpointId
    }
  }
}]

resource cnameRecords 'Microsoft.Network/dnszones/CNAME@2023-07-01-preview' = [for record in dnsRecords.cnameRecords: {
  parent: dnsZone
  name: record.name
  properties: {
    TTL: record.ttl
    CNAMERecord: contains(record, 'cname') ? {
      cname: record.cname
    } : null
    targetResource: !contains(record, 'cname') ? {
      id: frontDoorEndpointId
    } : null
  }
}]

resource txtRecords 'Microsoft.Network/dnszones/TXT@2023-07-01-preview' = [for record in dnsRecords.txtRecords: {
  parent: dnsZone
  name: record.name
  properties: {
    TTL: record.ttl
    TXTRecords: [for value in record.values: {
      value: [
        value
      ]
    }]
  }
}]

output zoneId string = dnsZone.id
output zoneName string = dnsZone.name

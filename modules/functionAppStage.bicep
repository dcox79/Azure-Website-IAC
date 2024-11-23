@description('The name of the function app')
param sites_name string

@description('The location for all resources')
param location string

@description('The App Service Plan ID')
param serverfarms_ASP_externalid string

@description('The zone name for CORS settings')
param zoneName string

resource sites_name_staging 'Microsoft.Web/sites/slots@2023-12-01' = {
  name: '${sites_name}/staging'
  location: location
  kind: 'functionapp,linux'
  properties: {
    enabled: true
    hostNameSslStates: [
      {
        name: '${sites_name}-staging.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${sites_name}-staging.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Repository'
      }
    ]
    serverFarmId: serverfarms_ASP_externalid
    reserved: true
    isXenon: false
    hyperV: false
    dnsConfiguration: {}
    vnetRouteAllEnabled: false
    vnetImagePullEnabled: false
    vnetContentShareEnabled: false
    siteConfig: {
      numberOfWorkers: 1
      linuxFxVersion: 'DOTNET-ISOLATED|8.0'
      acrUseManagedIdentityCreds: false
      alwaysOn: false
      http20Enabled: false
      functionAppScaleLimit: 200
      minimumElasticInstanceCount: 1
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientCertEnabled: false
    clientCertMode: 'Required'
    hostNamesDisabled: false
    vnetBackupRestoreEnabled: false
    customDomainVerificationId: 'EFB48EABFE3384BFD712EBD972F2857D4B0882E8DB9707565A8EF46952AE6070'
    containerSize: 1536
    dailyMemoryTimeQuota: 0
    httpsOnly: false
    redundancyMode: 'None'
    storageAccountRequired: false
    keyVaultReferenceIdentity: 'SystemAssigned'
  }
}

resource sites_name_staging_ftp 'Microsoft.Web/sites/slots/basicPublishingCredentialsPolicies@2023-12-01' = {
  parent: sites_name_staging
  name: 'ftp'
  location: location
  properties: {
    allow: true
  }
}

resource sites_name_staging_scm 'Microsoft.Web/sites/slots/basicPublishingCredentialsPolicies@2023-12-01' = {
  parent: sites_name_staging
  name: 'scm'
  location: location
  properties: {
    allow: true
  }
}

resource sites_name_staging_web 'Microsoft.Web/sites/slots/config@2023-12-01' = {
  parent: sites_name_staging
  name: 'web'
  location: location
  properties: {
    numberOfWorkers: 1
    defaultDocuments: [
      'Default.htm'
      'Default.html'
      'Default.asp'
      'index.htm'
      'index.html'
      'iisstart.htm'
      'default.aspx'
      'index.php'
      'hostingstart.html'
    ]
    netFrameworkVersion: 'v4.0'
    linuxFxVersion: 'DOTNET-ISOLATED|8.0'
    requestTracingEnabled: false
    remoteDebuggingEnabled: false
    remoteDebuggingVersion: 'VS2022'
    httpLoggingEnabled: false
    acrUseManagedIdentityCreds: false
    logsDirectorySizeLimit: 35
    detailedErrorLoggingEnabled: false
    publishingUsername: '$getresumevisitors__staging'
    scmType: 'None'
    use32BitWorkerProcess: false
    webSocketsEnabled: false
    alwaysOn: false
    managedPipelineMode: 'Integrated'
    virtualApplications: [
      {
        virtualPath: '/'
        physicalPath: 'site\\wwwroot'
        preloadEnabled: false
      }
    ]
    loadBalancing: 'LeastRequests'
    experiments: {
      rampUpRules: []
    }
    autoHealEnabled: false
    vnetRouteAllEnabled: false
    vnetPrivatePortsCount: 0
    cors: {
      allowedOrigins: [
        'https://${zoneName}'
        'https://www.${zoneName}'
      ]
      supportCredentials: true
    }
    localMySqlEnabled: false
    ipSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictions: [
      {
        ipAddress: 'Any'
        action: 'Allow'
        priority: 2147483647
        name: 'Allow all'
        description: 'Allow all access'
      }
    ]
    scmIpSecurityRestrictionsUseMain: false
    http20Enabled: false
    minTlsVersion: '1.2'
    scmMinTlsVersion: '1.2'
    ftpsState: 'FtpsOnly'
    preWarmedInstanceCount: 0
    functionAppScaleLimit: 200
    functionsRuntimeScaleMonitoringEnabled: false
    minimumElasticInstanceCount: 1
    azureStorageAccounts: {}
  }
}

resource sites_name_staging_GetVisitorCounter 'Microsoft.Web/sites/slots/functions@2023-12-01' = {
  parent: sites_name_staging
  name: 'GetVisitorCounter'
  location: location
  properties: {
    script_href: 'https://getresumevisitors-staging.azurewebsites.net/admin/vfs/home/site/wwwroot/api.dll'
    test_data_href: 'https://getresumevisitors-staging.azurewebsites.net/admin/vfs/tmp/FunctionsData/GetVisitorCounter.dat'
    href: 'https://getresumevisitors-staging.azurewebsites.net/admin/functions/GetVisitorCounter'
    config: {
      name: 'GetVisitorCounter'
      entryPoint: 'Api.Function.GetVisitorCounter.Run'
      scriptFile: 'api.dll'
      language: 'dotnet-isolated'
      bindings: [
        {
          name: 'req'
          direction: 'In'
          type: 'httpTrigger'
          authLevel: 'Anonymous'
          methods: [
            'get'
            'post'
          ]
          properties: {}
        }
        {
          name: 'counter'
          direction: 'In'
          type: 'cosmosDB'
          databaseName: 'CloudResume'
          containerName: 'Counter'
          connection: 'CosmosDbConnectionString'
          id: 'index'
          partitionKey: 'index'
          properties: {
            supportsDeferredBinding: 'True'
          }
        }
        {
          name: 'NewCounter'
          direction: 'Out'
          type: 'cosmosDB'
          databaseName: 'CloudResume'
          containerName: 'Counter'
          connection: 'CosmosDbConnectionString'
          properties: {}
        }
        {
          name: 'HttpResponse'
          type: 'http'
          direction: 'Out'
        }
      ]
    }
    invoke_url_template: 'https://getresumevisitors-staging.azurewebsites.net/api/getvisitorcounter'
    language: 'dotnet-isolated'
    isDisabled: false
  }
}

resource sites_name_staging_sites_getresumevisitors_name_staging_azurewebsites_net 'Microsoft.Web/sites/slots/hostNameBindings@2023-12-01' = {
  parent: sites_name_staging
  name: '${sites_name}-staging.azurewebsites.net'
  location: location
  properties: {
    siteName: 'getresumevisitors(staging)'
    hostNameType: 'Verified'
  }
}

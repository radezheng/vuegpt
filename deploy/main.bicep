param repoUrl string = 'https://github.com/radezheng/vuegpt'
param appName string
param location string = resourceGroup().location
param sku string = 'FREE'

resource appServicePlan 'Microsoft.Web/serverfarms@2021-01-01' = {
  name: appName
  location: location
  properties: {
    reserved: false
  }
  sku: {
    name: sku
  }
}

resource webApp 'Microsoft.Web/sites@2021-01-01' = {
  name: appName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '14'
        }
      ]
    }
  }
}

resource sourceControl 'Microsoft.Web/sites/sourcecontrols@2021-01-01' = {
  parent: webApp
  name: 'web'
  properties: {
    repoUrl: repoUrl
    branch: 'master'
    isManualIntegration: true
    deploymentRollbackEnabled: false
    isMercurial: false
  }
}

param resourceName string
param location string
param tags object

resource registry 'Microsoft.ContainerRegistry/registries@2026-01-01-preview' = {
  name: resourceName
  location: location
  tags: tags
  properties: {
    adminUserEnabled: false
    anonymousPullEnabled: false
    dataEndpointEnabled: false
    encryption: {
      status: 'disabled'
    }
    networkRuleBypassOptions: 'AzureServices'
    policies: {
      exportPolicy: {
        status: 'enabled'
      }
      quarantinePolicy: {
        status: 'disabled'
      }
      retentionPolicy: {
        status: 'disabled'
      }
      trustPolicy: {
        status: 'disabled'
      }
    }
    publicNetworkAccess: 'Enabled' // TODO this should be disabled ideally
    zoneRedundancy: 'Disabled'
  }
  sku: {
    name: 'Premium'
  }
}

output id string = registry.id
output name string = registry.name
output loginServer string = registry.properties.loginServer

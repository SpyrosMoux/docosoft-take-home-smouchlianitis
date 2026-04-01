param location string
param pipelineIdentityName string
param tags object

resource pipelineIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: pipelineIdentityName
  location: location
  tags: tags
}

output id string = pipelineIdentity.id
output clientId string = pipelineIdentity.properties.clientId
output principalId string = pipelineIdentity.properties.principalId

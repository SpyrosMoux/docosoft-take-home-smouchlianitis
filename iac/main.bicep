targetScope = 'resourceGroup'

param acrName string
param acrLocation string
param appServicePlanName string
param webAppName string
param appInsightsName string
param userAssignedIdentityName string
param pipelineIdentityName string
param logAnalyticsWorkspaceName string
param actionGroupName string
param alertEmailAddress string
param commonTags object
param dockerRepository string = 'counterapi'
param dockerTag string = 'latest'
param configureContainerImage bool = false

module acr './modules/acr.bicep' = {
  name: 'docosoft'
  params: {
    location: acrLocation
    resourceName: acrName
    tags: commonTags
  }
}

module appservice './modules/appservice.bicep' = {
  name: 'docosoft-appservice'
  params: {
    location: resourceGroup().location
    appServicePlanName: appServicePlanName
    webAppName: webAppName
    appInsightsName: appInsightsName
    userAssignedIdentityName: userAssignedIdentityName
    acrName: acr.outputs.name
    acrLoginServer: acr.outputs.loginServer
    tags: commonTags
    dockerRepository: dockerRepository
    dockerTag: dockerTag
    configureContainerImage: configureContainerImage
  }
}

module observability './modules/observability.bicep' = {
  name: 'docosoft-observability'
  params: {
    location: resourceGroup().location
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    webAppName: webAppName
    acrName: acr.outputs.name
    actionGroupName: actionGroupName
    alertEmailAddress: alertEmailAddress
    tags: commonTags
  }
}

module pipelineIdentity './modules/pipeline-identity.bicep' = {
  name: 'docosoft-pipeline-identity'
  params: {
    location: resourceGroup().location
    pipelineIdentityName: pipelineIdentityName
    tags: commonTags
  }
}

resource acrExisting 'Microsoft.ContainerRegistry/registries@2026-01-01-preview' existing = {
  name: acrName
}

resource pipelineContributorAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, pipelineIdentityName, 'Contributor')
  scope: resourceGroup()
  properties: {
    principalId: pipelineIdentity.outputs.principalId
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      'b24988ac-6180-42a0-ab88-20f7382dd24c'
    )
    principalType: 'ServicePrincipal'
  }
}

resource pipelineUaaAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, pipelineIdentityName, 'UserAccessAdministrator')
  scope: resourceGroup()
  properties: {
    principalId: pipelineIdentity.outputs.principalId
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '18d7d88d-d35e-4fb5-a5c3-7773c20a72d9'
    )
    principalType: 'ServicePrincipal'
  }
}

resource pipelineAcrPushAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(acrExisting.id, pipelineIdentityName, 'AcrPush')
  scope: acrExisting
  properties: {
    principalId: pipelineIdentity.outputs.principalId
    roleDefinitionId: subscriptionResourceId(
      'Microsoft.Authorization/roleDefinitions',
      '8311e382-0749-4cb8-b61a-304f252e45ec'
    )
    principalType: 'ServicePrincipal'
  }
}

output pipelineIdentityClientId string = pipelineIdentity.outputs.clientId
output pipelineIdentityPrincipalId string = pipelineIdentity.outputs.principalId

targetScope = 'subscription'

param resourceGroupName string
param resourceGroupLocation string
param acrName string
param acrLocation string
param appServicePlanName string
param webAppName string
param appInsightsName string
param userAssignedIdentityName string
param commonTags object
param dockerRepository string = 'counterapi'
param dockerTag string = 'latest'

resource newRG 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceGroupName
  location: resourceGroupLocation
  tags: commonTags
}

module acr './modules/acr.bicep' = {
  name: 'docosoft'
  scope: newRG
  params: {
    location: acrLocation
    resourceName: acrName
    tags: commonTags
  }
}

module appservice './modules/appservice.bicep' = {
  name: 'docosoft-appservice'
  scope: newRG
  params: {
    location: resourceGroupLocation
    appServicePlanName: appServicePlanName
    webAppName: webAppName
    appInsightsName: appInsightsName
    userAssignedIdentityName: userAssignedIdentityName
    acrName: acr.outputs.name
    acrLoginServer: acr.outputs.loginServer
    tags: commonTags
    dockerRepository: dockerRepository
    dockerTag: dockerTag
  }
}

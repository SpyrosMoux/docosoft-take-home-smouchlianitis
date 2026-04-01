targetScope = 'resourceGroup'

param acrName string
param acrLocation string
param appServicePlanName string
param webAppName string
param appInsightsName string
param userAssignedIdentityName string
param logAnalyticsWorkspaceName string
param actionGroupName string
param alertEmailAddress string
param commonTags object
param dockerRepository string = 'counterapi'
param dockerTag string = 'latest'

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

using '../main.bicep'

param acrName = 'docosoftspyrosmoux'
param acrLocation = 'westeurope'
param appServicePlanName = 'docosoft-plan-b1'
param webAppName = 'docosoft-counterapi-we'
param appInsightsName = 'docosoft-ai'
param userAssignedIdentityName = 'docosoft-counterapi-uami'
param pipelineIdentityName = 'docosoft-pipeline-uami'
param logAnalyticsWorkspaceName = 'docosoft-law'
param actionGroupName = 'docosoft-ag'
param alertEmailAddress = 'spirosgsaaa@gmail.com'
param commonTags = {
  environment: 'production'
  owner: 'smouchlianitis'
  project: 'docosoft'
}
param dockerRepository = 'counterapi'
param dockerTag = 'latest'

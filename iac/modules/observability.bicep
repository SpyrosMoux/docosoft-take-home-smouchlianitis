param location string
param logAnalyticsWorkspaceName string
param webAppName string
param acrName string
param actionGroupName string
param alertEmailAddress string
param http5xxThreshold int = 5
param averageResponseTimeThresholdSeconds int = 2
param tags object

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  tags: tags
  properties: {
    retentionInDays: 30
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource webApp 'Microsoft.Web/sites@2024-11-01' existing = {
  name: webAppName
}

resource acr 'Microsoft.ContainerRegistry/registries@2026-01-01-preview' existing = {
  name: acrName
}

resource actionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: actionGroupName
  location: 'Global'
  properties: {
    enabled: true
    groupShortName: 'docosoft'
    emailReceivers: [
      {
        name: 'primary-email'
        emailAddress: alertEmailAddress
        useCommonAlertSchema: true
      }
    ]
  }
}

resource webAppDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${webApp.name}-diagnostics'
  scope: webApp
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

resource acrDiagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${acr.name}-diagnostics'
  scope: acr
  properties: {
    workspaceId: logAnalyticsWorkspace.id
    logs: [
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
      }
    ]
  }
}

resource webAppHttp5xxAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: '${webApp.name}-http5xx-alert'
  location: 'global'
  tags: tags
  properties: {
    description: 'Alert when App Service returns elevated HTTP 5xx responses.'
    severity: 2
    enabled: true
    scopes: [
      webApp.id
    ]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          criterionType: 'StaticThresholdCriterion'
          name: 'Http5xxThreshold'
          metricNamespace: 'Microsoft.Web/sites'
          metricName: 'Http5xx'
          operator: 'GreaterThan'
          threshold: http5xxThreshold
          timeAggregation: 'Total'
        }
      ]
    }
    autoMitigate: true
    targetResourceType: 'Microsoft.Web/sites'
    actions: [
      {
        actionGroupId: actionGroup.id
      }
    ]
  }
}

resource webAppLatencyAlert 'Microsoft.Insights/metricAlerts@2018-03-01' = {
  name: '${webApp.name}-latency-alert'
  location: 'global'
  tags: tags
  properties: {
    description: 'Alert when App Service average response time is elevated.'
    severity: 3
    enabled: true
    scopes: [
      webApp.id
    ]
    evaluationFrequency: 'PT1M'
    windowSize: 'PT5M'
    criteria: {
      'odata.type': 'Microsoft.Azure.Monitor.SingleResourceMultipleMetricCriteria'
      allOf: [
        {
          criterionType: 'StaticThresholdCriterion'
          name: 'AverageResponseTimeThreshold'
          metricNamespace: 'Microsoft.Web/sites'
          metricName: 'AverageResponseTime'
          operator: 'GreaterThan'
          threshold: averageResponseTimeThresholdSeconds
          timeAggregation: 'Average'
        }
      ]
    }
    autoMitigate: true
    targetResourceType: 'Microsoft.Web/sites'
    actions: [
      {
        actionGroupId: actionGroup.id
      }
    ]
  }
}

output logAnalyticsWorkspaceId string = logAnalyticsWorkspace.id

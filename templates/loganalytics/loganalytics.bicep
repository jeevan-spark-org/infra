targetScope = 'subscription'

@description('Azure region for all regional resources.')
param location string

@description('Daily ingestion quota in GB for Log Analytics workspace (for example: 0.5 or -1 for unlimited).')
param logAnalyticsDailyQuotaGb string

@description('Log Analytics interactive retention in days.')
param logAnalyticsRetentionInDays string

@description('Log Analytics workspace SKU name (for example: PerGB2018).')
param logAnalyticsSkuName string

@description('Log Analytics workspace name.')
param logAnalyticsWorkspaceName string

@description('Resource group name for shared platform resources.')
param resourceGroupName string

@description('Tags applied to all taggable resources.')
param tags string

var tagsObject = json(tags)
var logAnalyticsDailyQuotaGbValue = json(logAnalyticsDailyQuotaGb)
var logAnalyticsRetentionInDaysInt = int(logAnalyticsRetentionInDays)

resource rg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceGroupName
  location: location
  tags: tagsObject
}

module logAnalytics 'br/public:avm/res/operational-insights/workspace:0.15.0' = {
  name: 'law-${uniqueString(subscription().id, resourceGroupName, logAnalyticsWorkspaceName)}'
  scope: rg
  params: {
    dailyQuotaGb: logAnalyticsDailyQuotaGbValue
    dataRetention: logAnalyticsRetentionInDaysInt
    name: logAnalyticsWorkspaceName
    skuName: logAnalyticsSkuName
    location: location
    tags: tagsObject
  }
}

output logAnalyticsWorkspaceResourceId string = logAnalytics.outputs.resourceId

targetScope = 'subscription'

@description('Azure region for all regional resources.')
param location string

@description('Resource group name for shared platform resources.')
param resourceGroupName string

@description('Log Analytics workspace name.')
param logAnalyticsWorkspaceName string

@description('Tags applied to all taggable resources.')
param tags string

var tagsObject = json(tags)

resource rg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceGroupName
  location: location
  tags: tagsObject
}

module logAnalytics 'br/public:avm/res/operational-insights/workspace:0.15.0' = {
  name: 'law-${uniqueString(subscription().id, resourceGroupName, logAnalyticsWorkspaceName)}'
  scope: rg
  params: {
    name: logAnalyticsWorkspaceName
    location: location
    tags: tagsObject
  }
}

output logAnalyticsWorkspaceResourceId string = logAnalytics.outputs.resourceId

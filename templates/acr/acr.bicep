targetScope = 'subscription'

@description('Azure region for all regional resources.')
param location string

@description('Resource group name for ACR resources.')
param resourceGroupName string

@description('Azure Container Registry name (5-50 alphanumeric).')
param acrName string

@description('SKU for Azure Container Registry.')
param acrSku string

@description('Virtual network name used for shared platform networking.')
param virtualNetworkName string

@description('Subnet name used for ACR private endpoint integration.')
param privateEndpointSubnetName string

@description('ACR public IP allowlist rules as JSON array string (for example: [{"action":"Allow","value":"203.0.113.10/32"}]).')
param acrAllowedIpRules string

@description('Tags applied to all taggable resources.')
param tags string

var tagsObject = json(tags)
var acrAllowedIpRulesArray = json(acrAllowedIpRules)

resource rg 'Microsoft.Resources/resourceGroups@2025-04-01' existing = {
  name: resourceGroupName
}

resource vnet 'Microsoft.Network/virtualNetworks@2024-07-01' existing = {
  scope: rg
  name: virtualNetworkName
}

resource privateEndpointSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' existing = {
  parent: vnet
  name: privateEndpointSubnetName
}

module acr 'br/public:avm/res/container-registry/registry:0.10.0' = {
  name: 'acr-${uniqueString(subscription().id, resourceGroupName, acrName)}'
  scope: rg
  params: {
    location: location
    name: acrName
    acrSku: acrSku
    tags: tagsObject
    acrAdminUserEnabled: false
    publicNetworkAccess: 'Enabled'
    networkRuleSetDefaultAction: 'Deny'
    networkRuleSetIpRules: acrAllowedIpRulesArray
    privateEndpoints: [
      {
        service: 'registry'
        subnetResourceId: privateEndpointSubnet.id
      }
    ]
  }
}

output acrName string = acr.outputs.name
output acrLoginServer string = acr.outputs.loginServer

targetScope = 'subscription'

@description('Subnet CIDR for AKS node pools.')
param aksSubnetAddressPrefix string

@description('Subnet name for AKS node pools.')
param aksSubnetName string

@description('Azure region for all regional resources.')
param location string

@description('Subnet CIDR for private endpoints subnet.')
param privateEndpointSubnetAddressPrefix string

@description('Subnet name for private endpoints (for example ACR private endpoint).')
param privateEndpointSubnetName string

@description('Resource group name for shared platform resources.')
param resourceGroupName string

@description('Tags applied to all taggable resources.')
param tags string

@description('Virtual network name for shared platform resources.')
param virtualNetworkName string

@description('Address space for shared virtual network.')
param vnetAddressPrefixes string

var vnetAddressPrefixesArray = [for addressPrefix in split(replace(replace(replace(vnetAddressPrefixes, '[', ''), ']', ''), '"', ''), ','): trim(addressPrefix)]
var tagsObject = json(tags)

resource rg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceGroupName
  location: location
  tags: tagsObject
}

module vnet 'br/public:avm/res/network/virtual-network:0.7.2' = {
  name: 'vnet-${uniqueString(subscription().id, resourceGroupName, virtualNetworkName)}'
  scope: rg
  params: {
    name: virtualNetworkName
    location: location
    addressPrefixes: vnetAddressPrefixesArray
    subnets: [
      {
        name: aksSubnetName
        addressPrefix: aksSubnetAddressPrefix
      }
      {
        name: privateEndpointSubnetName
        addressPrefix: privateEndpointSubnetAddressPrefix
        privateEndpointNetworkPolicies: 'Disabled'
      }
    ]
    tags: tagsObject
  }
}

output virtualNetworkResourceId string = vnet.outputs.resourceId
output aksSubnetResourceId string = vnet.outputs.subnetResourceIds[0]
output privateEndpointSubnetResourceId string = vnet.outputs.subnetResourceIds[1]

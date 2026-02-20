targetScope = 'subscription'

@description('Azure region for all regional resources.')
param location string = deployment().location

@description('Environment short name. Example: dev, test, prod.')
param environmentName string = 'dev'

@description('Resource group name for AKS platform resources.')
param resourceGroupName string = 'rg-aks-${environmentName}'

@description('AKS cluster resource name.')
param aksClusterName string = 'aks-${environmentName}'

@description('Log Analytics workspace name.')
param logAnalyticsWorkspaceName string = 'law-aks-${environmentName}'

@description('Virtual network name for AKS.')
param virtualNetworkName string = 'vnet-aks-${environmentName}'

@description('Address space for AKS VNet.')
param vnetAddressPrefixes string = '["10.40.0.0/16"]'

@description('Subnet name for AKS node pools.')
param aksSubnetName string = 'snet-aks-nodes'

@description('Subnet CIDR for AKS node pools.')
param aksSubnetAddressPrefix string = '10.40.0.0/20'

@description('System node pool VM size.')
param systemNodePoolVmSize string = 'Standard_D4ds_v5'

@description('Initial node count for system node pool.')
param systemNodeCount string = '3'

@description('User node pool VM size.')
param userNodePoolVmSize string = 'Standard_D4ds_v5'

@description('Minimum nodes for user pool autoscaling.')
param userNodePoolMinCount string = '2'

@description('Maximum nodes for user pool autoscaling.')
param userNodePoolMaxCount string = '5'

@description('Name of the AKS Flux extension.')
param fluxExtensionName string = 'flux'

@description('Namespace where Flux extension release is installed.')
param fluxReleaseNamespace string = 'flux-system'

@description('Tags applied to all taggable resources.')
param tags string = '{"environment":"dev","workload":"platform","managedBy":"azure-pipelines"}'

var vnetAddressPrefixesArray = json(vnetAddressPrefixes)
var systemNodeCountInt = int(systemNodeCount)
var userNodePoolMinCountInt = int(userNodePoolMinCount)
var userNodePoolMaxCountInt = int(userNodePoolMaxCount)
var tagsObject = json(tags)

resource rg 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceGroupName
  location: location
  tags: tagsObject
}

@description('Deploy a virtual network through AVM.')
module vnet 'br/public:avm/res/network/virtual-network:0.7.2' = {
  name: 'vnet-${uniqueString(subscription().id, resourceGroupName)}'
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
    ]
    tags: tagsObject
  }
}

@description('Deploy a Log Analytics workspace through AVM for AKS monitoring.')
module logAnalytics 'br/public:avm/res/operational-insights/workspace:0.15.0' = {
  name: 'law-${uniqueString(subscription().id, resourceGroupName)}'
  scope: rg
  params: {
    name: logAnalyticsWorkspaceName
    location: location
    tags: tagsObject
  }
}

@description('Deploy AKS through AVM managed-cluster module.')
module aks 'br/public:avm/res/container-service/managed-cluster:0.12.0' = {
  name: 'aks-${uniqueString(subscription().id, resourceGroupName)}'
  scope: rg
  params: {
    name: aksClusterName
    location: location
    tags: tagsObject
    managedIdentities: {
      systemAssigned: true
    }
    aadProfile: {
      managed: true
      enableAzureRBAC: true
    }
    azurePolicyEnabled: true
    disableLocalAccounts: true
    enableOidcIssuerProfile: true
    enableRBAC: true
    networkPlugin: 'azure'
    networkPluginMode: 'overlay'
    networkPolicy: 'azure'
    omsAgentEnabled: true
    monitoringWorkspaceResourceId: logAnalytics.outputs.resourceId
    publicNetworkAccess: 'Enabled'
    fluxExtension: {
      name: fluxExtensionName
      releaseNamespace: fluxReleaseNamespace
    }
    primaryAgentPoolProfiles: [
      {
        name: 'systempool'
        mode: 'System'
        type: 'VirtualMachineScaleSets'
        vmSize: systemNodePoolVmSize
        count: systemNodeCountInt
        maxPods: 50
        osType: 'Linux'
        vnetSubnetResourceId: vnet.outputs.subnetResourceIds[0]
      }
    ]
    agentPools: [
      {
        name: 'userpool1'
        mode: 'User'
        type: 'VirtualMachineScaleSets'
        vmSize: userNodePoolVmSize
        enableAutoScaling: true
        minCount: userNodePoolMinCountInt
        maxCount: userNodePoolMaxCountInt
        maxPods: 50
        osType: 'Linux'
        vnetSubnetResourceId: vnet.outputs.subnetResourceIds[0]
      }
    ]
  }
}

output resourceGroupName string = resourceGroupName
output aksClusterResourceId string = aks.outputs.resourceId
output aksClusterName string = aks.outputs.name

targetScope = 'subscription'

@description('AKS cluster resource name.')
param aksClusterName string

@description('AKS cluster SKU tier. Supported values include Free and Standard.')
param aksSkuTier string

@description('Subnet name for AKS node pools.')
param aksSubnetName string

@description('Authorized IP ranges for AKS API server as a JSON array string (for example: ["203.0.113.10/32"]).')
param apiServerAuthorizedIpRanges string

@description('Flux configurations as a JSON array string that defines Git source and kustomization reconciliation.')
param fluxConfigurations string

@description('Flux extension configuration settings as a JSON object string (for example: {"setKubeServiceHostFqdn":"true"}).')
param fluxExtensionConfigurationSettings string

@description('Name of the AKS Flux extension.')
param fluxExtensionName string

@description('Namespace where Flux extension release is installed.')
param fluxReleaseNamespace string

@description('Azure region for all regional resources.')
param location string

@description('Log Analytics workspace name.')
param logAnalyticsWorkspaceName string

@description('Resource group name for AKS platform resources.')
param resourceGroupName string

@description('Whether autoscaling is enabled for the system node pool (true/false).')
param systemNodePoolEnableAutoScaling string

@description('Maximum nodes for system node pool autoscaling.')
param systemNodePoolMaxCount string

@description('Minimum nodes for system node pool autoscaling.')
param systemNodePoolMinCount string

@description('System node pool VM size.')
param systemNodePoolVmSize string

@description('Tags applied to all taggable resources.')
param tags string

@description('Whether autoscaling is enabled for the user node pool (true/false).')
param userNodePoolEnableAutoScaling string

@description('Maximum nodes for user pool autoscaling.')
param userNodePoolMaxCount string

@description('Minimum nodes for user pool autoscaling.')
param userNodePoolMinCount string

@description('User node pool VM size.')
param userNodePoolVmSize string

@description('Virtual network name for AKS.')
param virtualNetworkName string

var systemNodePoolMinCountInt = int(systemNodePoolMinCount)
var systemNodePoolMaxCountInt = int(systemNodePoolMaxCount)
var systemNodePoolEnableAutoScalingBool = toLower(systemNodePoolEnableAutoScaling) == 'true'
var userNodePoolMinCountInt = int(userNodePoolMinCount)
var userNodePoolMaxCountInt = int(userNodePoolMaxCount)
var userNodePoolEnableAutoScalingBool = toLower(userNodePoolEnableAutoScaling) == 'true'
var tagsObject = json(tags)
var fluxExtensionConfigurationSettingsObject = json(fluxExtensionConfigurationSettings)
var fluxConfigurationsArray = json(fluxConfigurations)
var apiServerAuthorizedIpRangesArray = json(apiServerAuthorizedIpRanges)

resource rg 'Microsoft.Resources/resourceGroups@2025-04-01' existing = {
  name: resourceGroupName
}

resource vnet 'Microsoft.Network/virtualNetworks@2024-07-01' existing = {
  scope: rg
  name: virtualNetworkName
}

resource aksSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-07-01' existing = {
  parent: vnet
  name: aksSubnetName
}

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  scope: rg
  name: logAnalyticsWorkspaceName
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
    monitoringWorkspaceResourceId: logAnalyticsWorkspace.id
    publicNetworkAccess: 'Enabled'
    apiServerAccessProfile: {
      authorizedIPRanges: apiServerAuthorizedIpRangesArray
    }
    skuTier: aksSkuTier
    fluxExtension: {
      name: fluxExtensionName
      releaseNamespace: fluxReleaseNamespace
      configurationSettings: fluxExtensionConfigurationSettingsObject
      fluxConfigurations: fluxConfigurationsArray
    }
    primaryAgentPoolProfiles: [
      {
        name: 'systempool'
        mode: 'System'
        type: 'VirtualMachineScaleSets'
        vmSize: systemNodePoolVmSize
        enableAutoScaling: systemNodePoolEnableAutoScalingBool
        ...(systemNodePoolEnableAutoScalingBool
          ? {
              minCount: systemNodePoolMinCountInt
              maxCount: systemNodePoolMaxCountInt
            }
          : {
              count: systemNodePoolMinCountInt
            })
        maxPods: 50
        osType: 'Linux'
        vnetSubnetResourceId: aksSubnet.id
      }
    ]
    agentPools: [
      {
        name: 'userpool1'
        mode: 'User'
        type: 'VirtualMachineScaleSets'
        vmSize: userNodePoolVmSize
        enableAutoScaling: userNodePoolEnableAutoScalingBool
        ...(userNodePoolEnableAutoScalingBool
          ? {
              minCount: userNodePoolMinCountInt
              maxCount: userNodePoolMaxCountInt
            }
          : {
              count: userNodePoolMinCountInt
            })
        maxPods: 50
        osType: 'Linux'
        vnetSubnetResourceId: aksSubnet.id
      }
    ]
  }
}

output resourceGroupName string = resourceGroupName
output aksClusterResourceId string = aks.outputs.resourceId
output aksClusterName string = aks.outputs.name

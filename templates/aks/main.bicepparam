using 'main.bicep'

param location = '#{{ location }}'
param environmentName = '#{{ environmentNameValue }}'
param resourceGroupName = '#{{ resourceGroupName }}'
param aksClusterName = '#{{ aksClusterName }}'
param logAnalyticsWorkspaceName = '#{{ logAnalyticsWorkspaceName }}'
param virtualNetworkName = '#{{ virtualNetworkName }}'
param vnetAddressPrefixes = '#{{ vnetAddressPrefixes }}'
param aksSubnetName = '#{{ aksSubnetName }}'
param aksSubnetAddressPrefix = '#{{ aksSubnetAddressPrefix }}'

param systemNodePoolVmSize = '#{{ systemNodePoolVmSize }}'
param systemNodeCount = '#{{ systemNodeCount }}'
param userNodePoolVmSize = '#{{ userNodePoolVmSize }}'
param userNodePoolMinCount = '#{{ userNodePoolMinCount }}'
param userNodePoolMaxCount = '#{{ userNodePoolMaxCount }}'

param fluxExtensionName = '#{{ fluxExtensionName }}'
param fluxReleaseNamespace = '#{{ fluxReleaseNamespace }}'

param tags = '#{{ tags }}'

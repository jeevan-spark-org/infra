using 'main.bicep'

param location = '#{{ location }}'
param resourceGroupName = '#{{ resourceGroupName }}'
param aksClusterName = '#{{ aksClusterName }}'
param logAnalyticsWorkspaceName = '#{{ logAnalyticsWorkspaceName }}'
param virtualNetworkName = '#{{ virtualNetworkName }}'
param aksSubnetName = '#{{ aksSubnetName }}'
param apiServerAuthorizedIpRanges = '#{{ apiServerAuthorizedIpRanges }}'

param systemNodePoolVmSize = '#{{ systemNodePoolVmSize }}'
param systemNodeCount = '#{{ systemNodeCount }}'
param userNodePoolVmSize = '#{{ userNodePoolVmSize }}'
param userNodePoolMinCount = '#{{ userNodePoolMinCount }}'
param userNodePoolMaxCount = '#{{ userNodePoolMaxCount }}'

param fluxExtensionName = '#{{ fluxExtensionName }}'
param fluxReleaseNamespace = '#{{ fluxReleaseNamespace }}'
param fluxExtensionConfigurationSettings = '#{{ fluxExtensionConfigurationSettings }}'
param fluxConfigurations = '#{{ fluxConfigurations }}'

param tags = '#{{ tags }}'

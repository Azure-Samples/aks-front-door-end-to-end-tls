@description('Specifies the prefix for all the Azure resources.')
param prefix string = uniqueString(resourceGroup().id)

@description('Specifies the object id of an Azure Active Directory user. In general, this the object id of the system administrator who deploys the Azure resources.')
param userId string = ''

@description('Specifies whether name resources are in CamelCase, UpperCamelCase, or KebabCase.')
@allowed([
  'CamelCase'
  'UpperCamelCase'
  'KebabCase'
])
param letterCaseType string = 'UpperCamelCase'

@description('Specifies the location of the AKS cluster.')
param location string = resourceGroup().location

@description('Specifies the name of the AKS cluster.')
param aksClusterName string = letterCaseType == 'UpperCamelCase'
  ? '${toUpper(first(prefix))}${toLower(substring(prefix, 1, length(prefix) - 1))}Aks'
  : letterCaseType == 'CamelCase' ? '${toLower(prefix)}Aks' : '${toLower(prefix)}-aks'

@description('Specifies whether creating metric alerts or not.')
param createMetricAlerts bool = true

@description('Specifies whether metric alerts as either enabled or disabled.')
param metricAlertsEnabled bool = true

@description('Specifies metric alerts eval frequency.')
param metricAlertsEvalFrequency string = 'PT1M'

@description('Specifies metric alerts window size.')
param metricAlertsWindowsSize string = 'PT1H'

@description('Specifies the DNS prefix specified when creating the managed cluster.')
param aksClusterDnsPrefix string = aksClusterName

@description('Specifies the network plugin used for building Kubernetes network. - azure or kubenet.')
@allowed([
  'azure'
  'kubenet'
])
param aksClusterNetworkPlugin string = 'azure'

@description('Specifies the Network plugin mode used for building the Kubernetes network.')
@allowed([
  ''
  'overlay'
])
param aksClusterNetworkPluginMode string = ''

@description('Specifies the network policy used for building Kubernetes network. - calico or azure')
@allowed([
  'azure'
  'calico'
  'cilium'
  'none'
])
param aksClusterNetworkPolicy string = 'azure'

@description('Specifies the network dataplane used in the Kubernetes cluster..')
@allowed([
  'azure'
  'cilium'
])
param aksClusterNetworkDataplane string = 'azure'

@description('Specifies the network mode. This cannot be specified if networkPlugin is anything other than azure.')
@allowed([
  'bridge'
  'transparent'
])
param aksClusterNetworkMode string = 'transparent'

@description('Specifies the CIDR notation IP range from which to assign pod IPs when kubenet is used.')
param aksClusterPodCidr string = '192.168.0.0/16'

@description('A CIDR notation IP range from which to assign service cluster IPs. It must not overlap with any Subnet IP ranges.')
param aksClusterServiceCidr string = '172.16.0.0/16'

@description('Specifies the IP address assigned to the Kubernetes DNS service. It must be within the Kubernetes service address range specified in serviceCidr.')
param aksClusterDnsServiceIP string = '172.16.0.10'

@description('Specifies the sku of the load balancer used by the virtual machine scale sets used by nodepools.')
@allowed([
  'basic'
  'standard'
])
param aksClusterLoadBalancerSku string = 'standard'

@description('Specifies the type of the managed inbound Load Balancer BackendPool.')
@allowed([
  'nodeIP'
  'nodeIPConfiguration'
])
param loadBalancerBackendPoolType string = 'nodeIPConfiguration'

@description('Specifies whether Advanced Container Networking Services is enabled or not. When enabled, network monitoring generates metrics in Prometheus format.')
param aksClusterAcnsEnabled bool = false

@description('Specifies the IP families are used to determine single-stack or dual-stack clusters. For single-stack, the expected value is IPv4. For dual-stack, the expected values are IPv4 and IPv6.')
param aksClusterIpFamilies array = ['IPv4']

@description('Specifies outbound (egress) routing method. - loadBalancer or userDefinedRouting.')
@allowed([
  'loadBalancer'
  'managedNATGateway'
  'userAssignedNATGateway'
  'userDefinedRouting'
])
param aksClusterOutboundType string = 'loadBalancer'

@description('Specifies the tier of a managed cluster SKU: Paid or Free')
@allowed([
  'Free'
  'Standard'
  'Premium'
])
param aksClusterSkuTier string = 'Standard'

@description('Specifies the version of Kubernetes specified when creating the managed cluster.')
param aksClusterKubernetesVersion string = '1.18.8'

@description('Specifies the administrator username of Linux virtual machines.')
param aksClusterAdminUsername string = 'azureuser'

@description('Specifies the SSH RSA public key string for the Linux nodes.')
param aksClusterSshPublicKey string

@description('Specifies the tenant id of the Azure Active Directory used by the AKS cluster for authentication.')
param aadProfileTenantId string = subscription().tenantId

@description('Specifies the AAD group object IDs that will have admin role of the cluster.')
param aadProfileAdminGroupObjectIDs array = []

@description('Specifies the node OS upgrade channel. The default is Unmanaged, but may change to either NodeImage or SecurityPatch at GA.	.')
@allowed([
  'NodeImage'
  'None'
  'SecurityPatch'
  'Unmanaged'
])
param aksClusterNodeOSUpgradeChannel string = 'Unmanaged'

@description('Specifies the upgrade channel for auto upgrade. Allowed values include rapid, stable, patch, node-image, none.')
@allowed([
  'rapid'
  'stable'
  'patch'
  'node-image'
  'none'
])
param aksClusterUpgradeChannel string = 'stable'

@description('Specifies whether to create the cluster as a private cluster or not.')
param aksClusterEnablePrivateCluster bool = true

@description('Specifies whether the managed NGINX Ingress Controller application routing addon is enabled.')
param aksClusterWebAppRoutingEnabled bool = true

@description('Specifies the Private DNS Zone mode for private cluster. When the value is equal to None, a Public DNS Zone is used in place of a Private DNS Zone')
param aksPrivateDNSZone string = 'none'

@description('Specifies whether to create additional public FQDN for private cluster or not.')
param aksEnablePrivateClusterPublicFQDN bool = true

@description('Specifies whether to enable managed AAD integration.')
param aadProfileManaged bool = true

@description('Specifies whether to  to enable Azure RBAC for Kubernetes authorization.')
param aadProfileEnableAzureRBAC bool = true

@description('Specifies the unique name of of the system node pool profile in the context of the subscription and resource group.')
param systemAgentPoolName string = 'nodepool1'

@description('Specifies the vm size of nodes in the system node pool.')
param systemAgentPoolVmSize string = 'Standard_DS5_v2'

@description('Specifies the OS Disk Size in GB to be used to specify the disk size for every machine in the system agent pool. If you specify 0, it will apply the default osDisk size according to the vmSize specified.')
param systemAgentPoolOsDiskSizeGB int = 100

@description('Specifies the OS disk type to be used for machines in a given agent pool. Allowed values are \'Ephemeral\' and \'Managed\'. If unspecified, defaults to \'Ephemeral\' when the VM supports ephemeral OS and has a cache disk larger than the requested OSDiskSizeGB. Otherwise, defaults to \'Managed\'. May not be changed after creation. - Managed or Ephemeral')
@allowed([
  'Ephemeral'
  'Managed'
])
param systemAgentPoolOsDiskType string = 'Ephemeral'

@description('Specifies the number of agents (VMs) to host docker containers in the system node pool. Allowed values must be in the range of 1 to 100 (inclusive). The default value is 1.')
param systemAgentPoolAgentCount int = 3

@description('Specifies the OS type for the vms in the system node pool. Choose from Linux and Windows. Default to Linux.')
@allowed([
  'Linux'
  'Windows'
])
param systemAgentPoolOsType string = 'Linux'

@description('Specifies the OS SKU used by the system agent pool. If not specified, the default is Ubuntu if OSType=Linux or Windows2019 if OSType=Windows. And the default Windows OSSKU will be changed to Windows2022 after Windows2019 is deprecated.')
@allowed([
  'Ubuntu'
  'Windows2019'
  'Windows2022'
  'AzureLinux'
])
param systemAgentPoolOsSKU string = 'Ubuntu'

@description('Specifies the maximum number of pods that can run on a node in the system node pool. The maximum number of pods per node in an AKS cluster is 250. The default maximum number of pods per node varies between kubenet and Azure CNI networking, and the method of cluster deployment.')
param systemAgentPoolMaxPods int = 30

@description('Specifies the maximum number of nodes for auto-scaling for the system node pool.')
param systemAgentPoolMaxCount int = 5

@description('Specifies the minimum number of nodes for auto-scaling for the system node pool.')
param systemAgentPoolMinCount int = 3

@description('Specifies whether to enable auto-scaling for the system node pool.')
param systemAgentPoolEnableAutoScaling bool = true

@description('Specifies the virtual machine scale set priority in the system node pool: Spot or Regular.')
@allowed([
  'Spot'
  'Regular'
])
param systemAgentPoolScaleSetPriority string = 'Regular'

@description('Specifies the ScaleSetEvictionPolicy to be used to specify eviction policy for spot virtual machine scale set. Default to Delete. Allowed values are Delete or Deallocate.')
@allowed([
  'Delete'
  'Deallocate'
])
param systemAgentPoolScaleSetEvictionPolicy string = 'Delete'

@description('Specifies the Agent pool node labels to be persisted across all nodes in the system node pool.')
param systemAgentPoolNodeLabels object = {}

@description('Specifies the taints added to new nodes during node pool create and scale. For example, key=value:NoSchedule.')
param systemAgentPoolNodeTaints array = []

@description('Determines the placement of emptyDir volumes, container runtime data root, and Kubelet ephemeral storage.')
@allowed([
  'OS'
  'Temporary'
])
param systemAgentPoolKubeletDiskType string = 'OS'

@description('Specifies the type for the system node pool: VirtualMachineScaleSets or AvailabilitySet')
@allowed([
  'VirtualMachineScaleSets'
  'AvailabilitySet'
])
param systemAgentPoolType string = 'VirtualMachineScaleSets'

@description('Specifies the availability zones for the agent nodes in the system node pool. Requirese the use of VirtualMachineScaleSets as node pool type.')
param systemAgentPoolAvailabilityZones array = [
  '1'
  '2'
  '3'
]

@description('Specifies the unique name of of the user node pool profile in the context of the subscription and resource group.')
param userAgentPoolName string = 'nodepool1'

@description('Specifies the vm size of nodes in the user node pool.')
param userAgentPoolVmSize string = 'Standard_DS5_v2'

@description('Specifies the OS Disk Size in GB to be used to specify the disk size for every machine in the system agent pool. If you specify 0, it will apply the default osDisk size according to the vmSize specified..')
param userAgentPoolOsDiskSizeGB int = 100

@description('Specifies the OS disk type to be used for machines in a given agent pool. Allowed values are \'Ephemeral\' and \'Managed\'. If unspecified, defaults to \'Ephemeral\' when the VM supports ephemeral OS and has a cache disk larger than the requested OSDiskSizeGB. Otherwise, defaults to \'Managed\'. May not be changed after creation. - Managed or Ephemeral')
@allowed([
  'Ephemeral'
  'Managed'
])
param userAgentPoolOsDiskType string = 'Ephemeral'

@description('Specifies the number of agents (VMs) to host docker containers in the user node pool. Allowed values must be in the range of 1 to 100 (inclusive). The default value is 1.')
param userAgentPoolAgentCount int = 3

@description('Specifies the OS type for the vms in the user node pool. Choose from Linux and Windows. Default to Linux.')
@allowed([
  'Linux'
  'Windows'
])
param userAgentPoolOsType string = 'Linux'

@description('Specifies the OS SKU used by the system agent pool. If not specified, the default is Ubuntu if OSType=Linux or Windows2019 if OSType=Windows. And the default Windows OSSKU will be changed to Windows2022 after Windows2019 is deprecated.')
@allowed([
  'Ubuntu'
  'Windows2019'
  'Windows2022'
  'AzureLinux'
])
param userAgentPoolOsSKU string = 'Ubuntu'

@description('Specifies the maximum number of pods that can run on a node in the user node pool. The maximum number of pods per node in an AKS cluster is 250. The default maximum number of pods per node varies between kubenet and Azure CNI networking, and the method of cluster deployment.')
param userAgentPoolMaxPods int = 30

@description('Specifies the maximum number of nodes for auto-scaling for the user node pool.')
param userAgentPoolMaxCount int = 5

@description('Specifies the minimum number of nodes for auto-scaling for the user node pool.')
param userAgentPoolMinCount int = 3

@description('Specifies whether to enable auto-scaling for the user node pool.')
param userAgentPoolEnableAutoScaling bool = true

@description('Specifies the virtual machine scale set priority in the user node pool: Spot or Regular.')
@allowed([
  'Spot'
  'Regular'
])
param userAgentPoolScaleSetPriority string = 'Regular'

@description('Specifies the ScaleSetEvictionPolicy to be used to specify eviction policy for spot virtual machine scale set. Default to Delete. Allowed values are Delete or Deallocate.')
@allowed([
  'Delete'
  'Deallocate'
])
param userAgentPoolScaleSetEvictionPolicy string = 'Delete'

@description('Specifies the Agent pool node labels to be persisted across all nodes in the user node pool.')
param userAgentPoolNodeLabels object = {}

@description('Specifies the taints added to new nodes during node pool create and scale. For example, key=value:NoSchedule.')
param userAgentPoolNodeTaints array = []

@description('Determines the placement of emptyDir volumes, container runtime data root, and Kubelet ephemeral storage.')
@allowed([
  'OS'
  'Temporary'
])
param userAgentPoolKubeletDiskType string = 'OS'

@description('Specifies the type for the user node pool: VirtualMachineScaleSets or AvailabilitySet')
@allowed([
  'VirtualMachineScaleSets'
  'AvailabilitySet'
])
param userAgentPoolType string = 'VirtualMachineScaleSets'

@description('Specifies the availability zones for the agent nodes in the user node pool. Requirese the use of VirtualMachineScaleSets as node pool type.')
param userAgentPoolAvailabilityZones array = [
  '1'
  '2'
  '3'
]

@description('Specifies whether the httpApplicationRouting add-on is enabled or not.')
param httpApplicationRoutingEnabled bool = false

@description('Specifies whether the Istio Service Mesh add-on is enabled or not.')
param istioServiceMeshEnabled bool = false

@description('Specifies whether the Istio Ingress Gateway is enabled or not.')
param istioIngressGatewayEnabled bool = false

@description('Specifies the type of the Istio Ingress Gateway.')
@allowed([
  'Internal'
  'External'
])
param istioIngressGatewayType string = 'External'

@description('Specifies whether the Kubernetes Event-Driven Autoscaler (KEDA) add-on is enabled or not.')
param kedaEnabled bool = false

@description('Specifies whether the Dapr extension is enabled or not.')
param daprEnabled bool = false

@description('Enable high availability (HA) mode for the Dapr control plane')
param daprHaEnabled bool = false

@description('Specifies whether the Flux V2 extension is enabled or not.')
param fluxGitOpsEnabled bool = false

@description('Specifies whether the Vertical Pod Autoscaler is enabled or not.')
param verticalPodAutoscalerEnabled bool = false

@description('Specifies whether the aciConnectorLinux add-on is enabled or not.')
param aciConnectorLinuxEnabled bool = false

@description('Specifies whether the azurepolicy add-on is enabled or not.')
param azurePolicyEnabled bool = true

@description('Specifies whether the Azure Key Vault Provider for Secrets Store CSI Driver addon is enabled or not.')
param azureKeyvaultSecretsProviderEnabled bool = true

@description('Specifies whether the kubeDashboard add-on is enabled or not.')
param kubeDashboardEnabled bool = false

@description('Specifies whether the pod identity addon is enabled..')
param podIdentityProfileEnabled bool = false

@description('Specifies the scan interval of the auto-scaler of the AKS cluster.')
param autoScalerProfileScanInterval string = '10s'

@description('Specifies the scale down delay after add of the auto-scaler of the AKS cluster.')
param autoScalerProfileScaleDownDelayAfterAdd string = '10m'

@description('Specifies the scale down delay after delete of the auto-scaler of the AKS cluster.')
param autoScalerProfileScaleDownDelayAfterDelete string = '20s'

@description('Specifies scale down delay after failure of the auto-scaler of the AKS cluster.')
param autoScalerProfileScaleDownDelayAfterFailure string = '3m'

@description('Specifies the scale down unneeded time of the auto-scaler of the AKS cluster.')
param autoScalerProfileScaleDownUnneededTime string = '10m'

@description('Specifies the scale down unready time of the auto-scaler of the AKS cluster.')
param autoScalerProfileScaleDownUnreadyTime string = '20m'

@description('Specifies the utilization threshold of the auto-scaler of the AKS cluster.')
param autoScalerProfileUtilizationThreshold string = '0.5'

@description('Specifies the max graceful termination time interval in seconds for the auto-scaler of the AKS cluster.')
param autoScalerProfileMaxGracefulTerminationSec string = '600'

@description('Specifies whether to enable API server VNET integration for the cluster or not.')
param enableVnetIntegration bool = true

@description('Specifies the name of the virtual network.')
param virtualNetworkName string = letterCaseType == 'UpperCamelCase'
  ? '${toUpper(first(prefix))}${toLower(substring(prefix, 1, length(prefix) - 1))}Vnet'
  : letterCaseType == 'CamelCase' ? '${toLower(prefix)}Vnet' : '${toLower(prefix)}-vnet'

@description('Specifies the address prefixes of the virtual network.')
param virtualNetworkAddressPrefixes string = '10.0.0.0/8'

@description('Specifies the name of the subnet hosting the worker nodes of the default system agent pool of the AKS cluster.')
param systemAgentPoolSubnetName string = 'SystemSubnet'

@description('Specifies the address prefix of the subnet hosting the worker nodes of the default system agent pool of the AKS cluster.')
param systemAgentPoolSubnetAddressPrefix string = '10.0.0.0/16'

@description('Specifies the name of the subnet hosting the worker nodes of the user agent pool of the AKS cluster.')
param userAgentPoolSubnetName string = 'UserSubnet'

@description('Specifies the address prefix of the subnet hosting the worker nodes of the user agent pool of the AKS cluster.')
param userAgentPoolSubnetAddressPrefix string = '10.1.0.0/16'

@description('Specifies whether to enable the Azure Blob CSI Driver. The default value is false.')
param blobCSIDriverEnabled bool = false

@description('Specifies whether to enable the Azure Disk CSI Driver. The default value is true.')
param diskCSIDriverEnabled bool = true

@description('Specifies whether to enable the Azure File CSI Driver. The default value is true.')
param fileCSIDriverEnabled bool = true

@description('Specifies whether to enable the Snapshot Controller. The default value is true.')
param snapshotControllerEnabled bool = true

@description('Specifies whether to enable Defender threat detection. The default value is false.')
param defenderSecurityMonitoringEnabled bool = false

@description('Specifies whether to enable ImageCleaner on AKS cluster. The default value is false.')
param imageCleanerEnabled bool = false

@description('Specifies whether ImageCleaner scanning interval in hours.')
param imageCleanerIntervalHours int = 24

@description('Specifies whether to enable Node Restriction. The default value is false.')
param nodeRestrictionEnabled bool = false

@description('Specifies whether to enable Workload Identity. The default value is false.')
param workloadIdentityEnabled bool = true

@description('Specifies whether the OIDC issuer is enabled.')
param oidcIssuerProfileEnabled bool = true

@description('Specifies the name of the subnet hosting the pods running in the AKS cluster.')
param podSubnetName string = letterCaseType == 'UpperCamelCase'
  ? 'PodSubnet'
  : letterCaseType == 'CamelCase' ? 'podSubnet' : 'pod-subnet'

@description('Specifies the address prefix of the subnet hosting the pods running in the AKS cluster.')
param podSubnetAddressPrefix string = '10.2.0.0/16'

@description('Specifies the name of the subnet delegated to the API server when configuring the AKS cluster to use API server VNET integration.')
param apiServerSubnetName string = letterCaseType == 'UpperCamelCase'
  ? 'ApiServerSubnet'
  : letterCaseType == 'CamelCase' ? 'apiServerSubnet' : 'api-server-subnet'

@description('Specifies the address prefix of the subnet delegated to the API server when configuring the AKS cluster to use API server VNET integration.')
param apiServerSubnetAddressPrefix string = '10.3.0.0/28'

@description('Specifies the name of the subnet which contains the virtual machine.')
param vmSubnetName string = letterCaseType == 'UpperCamelCase'
  ? 'VmSubnet'
  : letterCaseType == 'CamelCase' ? 'vmSubnet' : 'vm-subnet'

@description('Specifies the address prefix of the subnet which contains the virtual machine.')
param vmSubnetAddressPrefix string = '10.3.1.0/24'

@description('Specifies the Bastion subnet IP prefix. This prefix must be within vnet IP prefix address space.')
param bastionSubnetAddressPrefix string = '10.3.2.0/24'

@description('Specifies the name of the Log Analytics Workspace.')
param logAnalyticsWorkspaceName string = letterCaseType == 'UpperCamelCase'
  ? '${toUpper(first(prefix))}${toLower(substring(prefix, 1, length(prefix) - 1))}Workspace'
  : letterCaseType == 'CamelCase' ? '${toLower(prefix)}Workspace' : '${toLower(prefix)}-workspace'

@description('Specifies the service tier of the workspace: Free, Standalone, PerNode, Per-GB.')
@allowed([
  'Free'
  'Standalone'
  'PerNode'
  'PerGB2018'
])
param logAnalyticsSku string = 'PerNode'

@description('Specifies the workspace data retention in days. -1 means Unlimited retention for the Unlimited Sku. 730 days is the maximum allowed for all other Skus.')
param logAnalyticsRetentionInDays int = 60

@description('Specifies whether creating or not a jumpbox virtual machine in the AKS cluster virtual network.')
param vmEnabled bool = true

@description('Specifies the name of the virtual machine.')
param vmName string = 'TestVm'

@description('Specifies the size of the virtual machine.')
param vmSize string = 'Standard_DS3_v2'

@description('Specifies the image publisher of the disk image used to create the virtual machine.')
param imagePublisher string = 'Canonical'

@description('Specifies the offer of the platform image or marketplace image used to create the virtual machine.')
param imageOffer string = '0001-com-ubuntu-server-jammy'

@description('Specifies the Ubuntu version for the VM. This will pick a fully patched image of this given Ubuntu version.')
param imageSku string = '22_04-lts-gen2'

@description('Specifies the type of authentication when accessing the Virtual Machine. SSH key is recommended.')
@allowed([
  'sshPublicKey'
  'password'
])
param authenticationType string = 'password'

@description('Specifies the name of the administrator account of the virtual machine.')
param vmAdminUsername string

@description('Specifies the SSH Key or password for the virtual machine. SSH key is recommended.')
@secure()
param vmAdminPasswordOrKey string

@description('Specifies the storage account type for OS and data disk.')
@allowed([
  'Premium_LRS'
  'StandardSSD_LRS'
  'Standard_LRS'
  'UltraSSD_LRS'
])
param diskStorageAccountType string = 'Premium_LRS'

@description('Specifies the number of data disks of the virtual machine.')
@minValue(0)
@maxValue(64)
param numDataDisks int = 1

@description('Specifies the size in GB of the OS disk of the VM.')
param osDiskSize int = 50

@description('Specifies the size in GB of the OS disk of the virtual machine.')
param dataDiskSize int = 50

@description('Specifies the caching requirements for the data disks.')
param dataDiskCaching string = 'ReadWrite'

@description('Specifies the globally unique name for the storage account used to store the boot diagnostics logs of the virtual machine.')
param blobStorageAccountName string = '${toLower(prefix)}${uniqueString(resourceGroup().id)}'

@description('Specifies the name of the private link to the boot diagnostics storage account.')
param blobStorageAccountPrivateEndpointName string = letterCaseType == 'UpperCamelCase'
  ? 'BlobStorageAccountPrivateEndpoint'
  : letterCaseType == 'CamelCase' ? 'blobStorageAccountPrivateEndpoint' : 'blob-storage-account-private-endpoint'

@description('Specifies the name of the private link to the Azure Container Registry.')
param acrPrivateEndpointName string = letterCaseType == 'UpperCamelCase'
  ? 'AcrPrivateEndpoint'
  : letterCaseType == 'CamelCase' ? 'acrPrivateEndpoint' : 'acr-private-endpoint'

@description('Name of your Azure Container Registry')
@minLength(5)
@maxLength(50)
param acrName string = letterCaseType == 'UpperCamelCase'
  ? '${toUpper(first(prefix))}${toLower(substring(prefix, 1, length(prefix) - 1))}Registry'
  : letterCaseType == 'CamelCase' ? '${toLower(prefix)}Registry' : '${toLower(prefix)}-Registry'

@description('Enable admin user that have push / pull permission to the registry.')
param acrAdminUserEnabled bool = false

@description('Tier of your Azure Container Registry.')
@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param acrSku string = 'Premium'

@description('Specifies whether Azure Bastion should be created.')
param bastionHostEnabled bool = true

@description('Specifies the name of the Azure Bastion resource.')
param bastionHostName string = letterCaseType == 'UpperCamelCase'
  ? '${toUpper(first(prefix))}${toLower(substring(prefix, 1, length(prefix) - 1))}Bastion'
  : letterCaseType == 'CamelCase' ? '${toLower(prefix)}Bastion' : '${toLower(prefix)}-bastion'

@description('Specifies the name of the Azure NAT Gateway.')
param natGatewayName string = letterCaseType == 'UpperCamelCase'
  ? '${toUpper(first(prefix))}${toLower(substring(prefix, 1, length(prefix) - 1))}NatGateway'
  : letterCaseType == 'CamelCase' ? '${toLower(prefix)}NatGateway' : '${toLower(prefix)}-nat-gateway'

@description('Specifies a list of availability zones denoting the zone in which Nat Gateway should be deployed.')
param natGatewayZones array = []

@description('Specifies the number of Public IPs to create for the Azure NAT Gateway.')
param natGatewayPublicIps int = 1

@description('Specifies the idle timeout in minutes for the Azure NAT Gateway.')
param natGatewayIdleTimeoutMins int = 30

@description('Specifies the name of the private link to the Key Vault.')
param keyVaultPrivateEndpointName string = letterCaseType == 'UpperCamelCase'
  ? 'KeyVaultPrivateEndpoint'
  : letterCaseType == 'CamelCase' ? 'keyVaultPrivateEndpoint' : 'key-vault-private-endpoint'

@description('Specifies the name of an existing Key Vault resource holding the TLS certificate.')
param keyVaultName string

@description('Specifies the name of the resource group that contains the existing Key Vault resource.')
param keyVaultResourceGroupName string

@description('Specifies the name of the existing TLS certificate.')
param keyVaultCertificateName string

@description('Specifies the version of the Key Vault secret that contains the custom domain certificate. Set the value to an empty string to use the latest version.')
param keyVaultCertificateVersion string = ''

@description('Specifies the name of the Azure Front Door.')
param frontDoorName string = letterCaseType == 'UpperCamelCase'
  ? '${toUpper(first(prefix))}${toLower(substring(prefix, 1, length(prefix) - 1))}FrontDoor'
  : letterCaseType == 'CamelCase' ? '${toLower(prefix)}FrontDoor' : '${toLower(prefix)}-front-door'

@description('The name of the SKU to use when creating the Front Door profile.')
@allowed([
  'Standard_AzureFrontDoor'
  'Premium_AzureFrontDoor'
])
param frontDoorSkuName string = 'Premium_AzureFrontDoor'

@description('Specifies the send and receive timeout on forwarding request to the origin. When timeout is reached, the request fails and returns.')
param originResponseTimeoutSeconds int = 30

@description('Specifies the name of the Azure Front Door Origin Group for the web application.')
param originGroupName string = letterCaseType == 'UpperCamelCase'
  ? '${frontDoorName}OriginGroup'
  : letterCaseType == 'CamelCase' ? '${frontDoorName}OriginGroup' : '${toLower(prefix)}-origin-group'

@description('Specifies the name of the Azure Front Door Origin for the web application.')
param originName string = letterCaseType == 'UpperCamelCase'
  ? '${frontDoorName}Origin'
  : letterCaseType == 'CamelCase' ? '${frontDoorName}Origin' : '${toLower(prefix)}-origin'

@description('Specifies the value of the HTTP port. Must be between 1 and 65535.')
param httpPort int = 80

@description('Specifies the value of the HTTPS port. Must be between 1 and 65535.')
param httpsPort int = 443

@description('Specifies the priority of origin in given origin group for load balancing. Higher priorities will not be used for load balancing if any lower priority origin is healthy.Must be between 1 and 5.')
@minValue(1)
@maxValue(5)
param priority int = 1

@description('Specifies the weight of the origin in a given origin group for load balancing. Must be between 1 and 1000.')
@minValue(1)
@maxValue(1000)
param weight int = 1000

@description('Specifies whether to enable health probes to be made against backends defined under backendPools. Health probes can only be disabled if there is a single enabled backend in single enabled backend pool.')
@allowed([
  'Enabled'
  'Disabled'
])
param originEnabledState string = 'Enabled'

@description('Specifies the number of samples to consider for load balancing decisions.')
param sampleSize int = 4

@description('Specifies the number of samples within the sample period that must succeed.')
param successfulSamplesRequired int = 3

@description('Specifies the additional latency in milliseconds for probes to fall into the lowest latency bucket.')
param additionalLatencyInMilliseconds int = 50

@description('Specifies path relative to the origin that is used to determine the health of the origin.')
param probePath string = '/'

@description('Specifies the health probe request type.')
@allowed([
  'GET'
  'HEAD'
  'NotSet'
])
param probeRequestType string = 'GET'

@description('Specifies the health probe protocol.')
@allowed([
  'Http'
  'Https'
  'NotSet'
])
param probeProtocol string = 'Http'

@description('Specifies the number of seconds between health probes.Default is 240 seconds.')
param probeIntervalInSeconds int = 60

@description('Specifies whether to allow session affinity on this host. Valid options are Enabled or Disabled.')
@allowed([
  'Enabled'
  'Disabled'
])
param sessionAffinityState string = 'Disabled'

@description('Specifies the endpoint name reuse scope. The default value is TenantReuse.')
@allowed([
  'NoReuse'
  'ResourceGroupReuse'
  'SubscriptionReuse'
  'TenantReuse'
])
param autoGeneratedDomainNameLabelScope string = 'TenantReuse'

@description('Specifies the name of the Azure Front Door Route for the web application.')
param routeName string = letterCaseType == 'UpperCamelCase'
  ? '${frontDoorName}Route'
  : letterCaseType == 'CamelCase' ? '${frontDoorName}Route' : '${toLower(prefix)}-route'

@description('Specifies a directory path on the origin that Azure Front Door can use to retrieve content from, e.g. contoso.cloudapp.net/originpath.')
param originPath string = '/'

@description('Specifies the rule sets referenced by this endpoint.')
param ruleSets array = []

@description('Specifies the list of supported protocols for this route')
param supportedProtocols array = [
  'Http'
  'Https'
]

@description('Specifies the route patterns of the rule.')
param routePatternsToMatch array = ['/*']

@description('Specifies the protocol this rule will use when forwarding traffic to backends.')
@allowed([
  'HttpOnly'
  'HttpsOnly'
  'MatchRequest'
])
param forwardingProtocol string = 'HttpsOnly'

@description('Specifies whether this route will be linked to the default endpoint domain.')
@allowed([
  'Enabled'
  'Disabled'
])
param linkToDefaultDomain string = 'Enabled'

@description('Specifies whether to automatically redirect HTTP traffic to HTTPS traffic. Note that this is a easy way to set up this rule and it will be the first rule that gets executed.')
@allowed([
  'Enabled'
  'Disabled'
])
param httpsRedirect string = 'Enabled'

@description('Specifies the name of the Azure Front Door Endpoint for the web application.')
param endpointName string = letterCaseType == 'UpperCamelCase'
  ? '${frontDoorName}Endpoint'
  : letterCaseType == 'CamelCase' ? '${frontDoorName}Endpoint' : '${toLower(prefix)}-endpoint'

@description('Specifies whether to enable use of this rule. Permitted values are Enabled or Disabled')
@allowed([
  'Enabled'
  'Disabled'
])
param endpointEnabledState string = 'Enabled'

@description('Specifies the name of the Azure Front Door WAF policy.')
param wafPolicyName string = letterCaseType == 'UpperCamelCase'
  ? '${frontDoorName}WafPolicy'
  : letterCaseType == 'CamelCase' ? '${frontDoorName}WafPolicy' : '${toLower(prefix)}-waf-policy'

@description('Specifies the WAF policy is in detection mode or prevention mode.')
@allowed([
  'Detection'
  'Prevention'
])
param wafPolicyMode string = 'Prevention'

@description('Specifies if the policy is in enabled or disabled state. Defaults to Enabled if not specified.')
param wafPolicyEnabledState string = 'Enabled'

@description('Specifies the list of managed rule sets to configure on the WAF.')
param wafManagedRuleSets array = [
  {
    ruleSetType: 'Microsoft_DefaultRuleSet'
    ruleSetVersion: '1.1'
  }
  {
    ruleSetType: 'Microsoft_BotManagerRuleSet'
    ruleSetVersion: '1.0'
  }
]

@description('Specifies the list of custom rulesto configure on the WAF.')
param wafCustomRules array = [
  {
    name: 'BlockTrafficFromIPRanges'
    priority: 100
    enabledState: 'Enabled'
    ruleType: 'MatchRule'
    action: 'Block'
    matchConditions: [
      {
        matchVariable: 'RemoteAddr'
        operator: 'IPMatch'
        matchValue: [
          '198.0.100.100'
          '203.0.0.0/24'
        ]
      }
    ]
  }
  {
    name: 'Blockme'
    enabledState: 'Enabled'
    priority: 200
    ruleType: 'MatchRule'
    rateLimitDurationInMinutes: 1
    rateLimitThreshold: 100
    matchConditions: [
      {
        matchVariable: 'QueryString'
        operator: 'Contains'
        negateCondition: false
        matchValue: [
          'blockme'
        ]
        transforms: [
          'Lowercase'
        ]
      }
    ]
    action: 'Block'
  }
  {
    name: 'RateLimitRule'
    enabledState: 'Enabled'
    priority: 1
    ruleType: 'RateLimitRule'
    rateLimitDurationInMinutes: 1
    rateLimitThreshold: 1000
    matchConditions: [
      {
        matchVariable: 'RemoteAddr'
        operator: 'IPMatch'
        negateCondition: true
        matchValue: [
          '0.0.0.0'
        ]
        transforms: []
      }
    ]
    action: 'Block'
  }
]

@description('Specifies if the WAF policy managed rules will inspect the request body content.')
@allowed([
  'Enabled'
  'Disabled'
])
param wafPolicyRequestBodyCheck string = 'Enabled'

@description('Specifies name of the security policy.')
param securityPolicyName string = letterCaseType == 'UpperCamelCase'
  ? '${frontDoorName}SecurityPolicy'
  : letterCaseType == 'CamelCase' ? '${frontDoorName}SecurityPolicy' : '${toLower(prefix)}-security-policy'

@description('Specifies the list of patterns to match by the security policy.')
param securityPolicyPatternsToMatch array = ['/*']

@description('Specifies the name of the Azure Private Link Service.')
param privateLinkServiceName string = empty(prefix)
  ? '${uniqueString(resourceGroup().id)}-private-link-service'
  : '${prefix}PrivateLinkService'

@description('Specifies the resource tags.')
param tags object = {
  IaC: 'Bicep'
}

@description('Specifies the resource tags.')
param clusterTags object = {
  IaC: 'Bicep'
  ApiServerVnetIntegration: true
}

@description('Specifies the name of the Action Group.')
param actionGroupName string = letterCaseType == 'UpperCamelCase'
  ? '${toUpper(first(prefix))}${toLower(substring(prefix, 1, length(prefix) - 1))}ActionGroup'
  : letterCaseType == 'CamelCase' ? '${toLower(prefix)}ActionGroup' : '${toLower(prefix)}-action-group'

@description('Specifies the short name of the action group. This will be used in SMS messages..')
param actionGroupShortName string = 'AksAlerts'

@description('Specifies whether this action group is enabled. If an action group is not enabled, then none of its receivers will receive communications.')
param actionGroupEnabled bool = true

@description('Specifies the email address of the receiver.')
param actionGroupEmailAddress string

@description('Specifies whether to use common alert schema..')
param actionGroupUseCommonAlertSchema bool = false

@description('Specifies the country code of the SMS receiver.')
param actionGroupCountryCode string = '39'

@description('Specifies the phone number of the SMS receiver.')
param actionGroupPhoneNumber string = ''

@description('Specifies a comma-separated list of additional Kubernetes label keys that will be used in the resource labels metric.')
param metricAnnotationsAllowList string = ''

@description('Specifies a comma-separated list of Kubernetes annotations keys that will be used in the resource labels metric.')
param metricLabelsAllowlist string = ''

@description('Specifies the name of the Azure Monitor managed service for Prometheus resource.')
param prometheusName string = letterCaseType == 'UpperCamelCase'
  ? '${toUpper(first(prefix))}${toLower(substring(prefix, 1, length(prefix) - 1))}Prometheus'
  : letterCaseType == 'CamelCase' ? '${toLower(prefix)}Prometheus' : '${toLower(prefix)}-prometheus'

@description('Specifies whether or not public endpoint access is allowed for the Azure Monitor managed service for Prometheus resource.')
@allowed([
  'Enabled'
  'Disabled'
])
param prometheusPublicNetworkAccess string = 'Enabled'

@description('Specifies the name of the Azure Managed Grafana resource.')
param grafanaName string = letterCaseType == 'UpperCamelCase'
  ? '${toUpper(first(prefix))}${toLower(substring(prefix, 1, length(prefix) - 1))}Grafana'
  : letterCaseType == 'CamelCase' ? '${toLower(prefix)}Grafana' : '${toLower(prefix)}-grafana'

@description('Specifies the sku of the Azure Managed Grafana resource.')
param grafanaSkuName string = 'Standard'

@description('Specifies the api key setting of the Azure Managed Grafana resource.')
@allowed([
  'Disabled'
  'Enabled'
])
param grafanaApiKey string = 'Enabled'

@description('Specifies the scope for dns deterministic name hash calculation.')
@allowed([
  'TenantReuse'
])
param grafanaAutoGeneratedDomainNameLabelScope string = 'TenantReuse'

@description('Specifies whether the Azure Managed Grafana resource uses deterministic outbound IPs.')
@allowed([
  'Disabled'
  'Enabled'
])
param grafanaDeterministicOutboundIP string = 'Disabled'

@description('Specifies the the state for enable or disable traffic over the public interface for the the Azure Managed Grafana resource.')
@allowed([
  'Disabled'
  'Enabled'
])
param grafanaPublicNetworkAccess string = 'Enabled'

@description('The zone redundancy setting of the Azure Managed Grafana resource.')
@allowed([
  'Disabled'
  'Enabled'
])
param grafanaZoneRedundancy string = 'Disabled'

@description('Specifies the secret provider class name that reads the certificate from key vault and creates a TLS secret in the Kubernetes cluster.')
#disable-next-line secure-secrets-in-params
param secretProviderClassName string = 'azure-tls'

@description('Specifies the name of the Kubernetes secret containing the TLS certificate.')
param secretName string = 'ingress-tls-csi'

@description('Specifies the namespace of the application.')
param namespace string = 'httpbin-tls'

@description('Specifies the tenant id.')
param tenantId string = subscription().tenantId

@description('Specifies the email address for the cert-manager cluster issuer.')
param email string = 'admin@contoso.com'

@description('Specifies the name of the deployment script uri.')
param deploymentScripName string = letterCaseType == 'UpperCamelCase'
  ? '${toUpper(first(prefix))}${toLower(substring(prefix, 1, length(prefix) - 1))}BashScript'
  : letterCaseType == 'CamelCase' ? '${toLower(prefix)}BashScript' : '${toLower(prefix)}-bash-script'

@description('Specifies the uri of the deployment script.')
param deploymentScriptUri string

@description('Specifies the subdomain of the workload.')
param subdomain string

@description('Specifies the name of an existing public DNS zone.')
param dnsZoneName string

@description('Specifies the name of the resource group which contains the public DNS zone.')
param dnsZoneResourceGroupName string

@description('''Specifies the the kind of NGINX ingress controller to use. You can assign two values: 
- Managed: is the managed NGINX ingress controller installed by the Azure Kubernetes Service (AKS) team.
- Unmanaged: is the NGINX ingress controller installed via Helm.
''')
@allowed([
  'Managed'
  'Unmanaged'
])
param nginxIngressControllerType string = aksClusterWebAppRoutingEnabled ? 'Managed' : 'Unmanaged'

@description('Specifies whether deploying Prometheus and Grafana using Helm.')
param installPrometheusAndGrafana bool = false

@description('Specifies whether deploying cert-manager using Helm.')
param installCertManager bool = false

@description('Specifies whether deploying NGINX ingress controller using Helm.')
param installNginxIngressController bool = false

@description('Specifies the time-to-live (TTL) value for the CNAME record.')
param cnameRecordTtl int = 3600

// Variables
var loadBalancerName = 'kubernetes-internal'
var hostName = '${subdomain}.${dnsZoneName}'

// Modules
module keyVault 'keyVault.bicep' = {
  name: 'keyVault'
  scope: resourceGroup(keyVaultResourceGroupName)
  params: {
    name: keyVaultName
    keyVaultCsiDriverManagedIdentityObjectId: aksCluster.outputs.azureKeyvaultSecretsProviderIdentity.objectId
    frontDoorManagedIdentityObjectId: frontDoorManagedIdentity.outputs.principalId
    azureKeyvaultSecretsProviderEnabled: azureKeyvaultSecretsProviderEnabled
  }
}

module workspace 'logAnalytics.bicep' = {
  name: 'workspace'
  params: {
    name: logAnalyticsWorkspaceName
    location: location
    sku: logAnalyticsSku
    retentionInDays: logAnalyticsRetentionInDays
    tags: tags
  }
}

module containerRegistry 'containerRegistry.bicep' = {
  name: 'containerRegistry'
  params: {
    name: acrName
    sku: acrSku
    adminUserEnabled: acrAdminUserEnabled
    workspaceId: workspace.outputs.id
    location: location
    tags: tags
  }
}

module storageAccount 'storageAccount.bicep' = {
  name: 'storageAccount'
  params: {
    name: blobStorageAccountName
    createContainers: false
    containerNames: []
    workspaceId: workspace.outputs.id
    location: location
    tags: tags
  }
}
resource existingKeyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: keyVaultName
  scope: resourceGroup(keyVaultResourceGroupName)
}

module network 'network.bicep' = {
  name: 'network'
  params: {
    podSubnetEnabled: aksClusterNetworkPluginMode != 'overlay' && podSubnetName != '' && podSubnetAddressPrefix != ''
    enableVnetIntegration: enableVnetIntegration
    bastionHostEnabled: bastionHostEnabled
    virtualNetworkName: virtualNetworkName
    virtualNetworkAddressPrefixes: virtualNetworkAddressPrefixes
    systemAgentPoolSubnetName: systemAgentPoolSubnetName
    systemAgentPoolSubnetAddressPrefix: systemAgentPoolSubnetAddressPrefix
    userAgentPoolSubnetName: userAgentPoolSubnetName
    userAgentPoolSubnetAddressPrefix: userAgentPoolSubnetAddressPrefix
    podSubnetName: podSubnetName
    podSubnetAddressPrefix: podSubnetAddressPrefix
    apiServerSubnetName: apiServerSubnetName
    apiServerSubnetAddressPrefix: apiServerSubnetAddressPrefix
    vmSubnetName: vmSubnetName
    vmSubnetAddressPrefix: vmSubnetAddressPrefix
    vmSubnetNsgName: '${vmSubnetName}Nsg'
    bastionSubnetAddressPrefix: bastionSubnetAddressPrefix
    bastionSubnetNsgName: 'AzureBastionSubnetNsg'
    bastionHostName: bastionHostName
    natGatewayName: natGatewayName
    natGatewayEnabled: aksClusterOutboundType == 'userAssignedNATGateway'
    natGatewayZones: natGatewayZones
    natGatewayPublicIps: natGatewayPublicIps
    natGatewayIdleTimeoutMins: natGatewayIdleTimeoutMins
    createAcrPrivateEndpoint: acrSku == 'Premium'
    storageAccountPrivateEndpointName: blobStorageAccountPrivateEndpointName
    storageAccountId: storageAccount.outputs.id
    keyVaultPrivateEndpointName: keyVaultPrivateEndpointName
    keyVaultId: existingKeyVault.id
    acrPrivateEndpointName: acrPrivateEndpointName
    acrId: containerRegistry.outputs.id
    workspaceId: workspace.outputs.id
    location: location
    tags: tags
  }
}

module jumpboxVirtualMachine 'virtualMachine.bicep' = if (vmEnabled) {
  name: 'jumpboxVirtualMachine'
  params: {
    vmName: vmName
    vmSize: vmSize
    vmSubnetId: network.outputs.vmSubnetId
    storageAccountName: vmEnabled ? storageAccount.outputs.name : ''
    imagePublisher: imagePublisher
    imageOffer: imageOffer
    imageSku: imageSku
    authenticationType: authenticationType
    vmAdminUsername: vmAdminUsername
    vmAdminPasswordOrKey: vmAdminPasswordOrKey
    diskStorageAccountType: diskStorageAccountType
    numDataDisks: numDataDisks
    osDiskSize: osDiskSize
    dataDiskSize: dataDiskSize
    dataDiskCaching: dataDiskCaching
    managedIdentityName: letterCaseType == 'UpperCamelCase'
      ? '${toUpper(first(prefix))}${toLower(substring(prefix, 1, length(prefix) - 1))}AzureMonitorAgentManagedIdentity'
      : letterCaseType == 'CamelCase'
          ? '${toLower(prefix)}AzureMonitorAgentManagedIdentity'
          : '${toLower(prefix)}-azure-monitor-agent-managed-identity'
    location: location
    tags: tags
  }
}

module aksManagedIdentity 'aksManagedIdentity.bicep' = {
  name: 'aksManagedIdentity'
  params: {
    name: letterCaseType == 'UpperCamelCase'
    ? '${aksClusterName}Identity'
    : letterCaseType == 'CamelCase'
        ? '${aksClusterName}Identity'
        : '${aksClusterName}-identity'
    virtualNetworkName: network.outputs.virtualNetworkName
    location: location
    tags: tags
  }
}

module certManagerManagedIdentity 'managedIdentity.bicep' = {
  name: 'certManagerManagedIdentity'
  params: {
    name: letterCaseType == 'UpperCamelCase'
    ? 'CertManagerIdentity'
    : letterCaseType == 'CamelCase'
        ? 'certManagerIdentity'
        : 'cert-manager-identity'
    location: location
    tags: tags
  }
}

module frontDoorManagedIdentity 'managedIdentity.bicep' = {
  name: 'frontDoorManagedIdentity'
  params: {
    name: letterCaseType == 'UpperCamelCase'
    ? '${frontDoorName}Identity'
    : letterCaseType == 'CamelCase'
        ? '${frontDoorName}Identity'
        : '${frontDoorName}-identity'
    location: location
    tags: tags
  }
}

module kubeletManageIdentity 'kubeletManagedIdentity.bicep' = {
  name: 'kubeletManageIdentity'
  params: {
    aksClusterName: aksCluster.outputs.name
    acrName: containerRegistry.outputs.name
  }
}

module aksCluster 'aksCluster.bicep' = {
  name: 'aksCluster'
  params: {
    name: aksClusterName
    enableVnetIntegration: enableVnetIntegration
    virtualNetworkName: network.outputs.virtualNetworkName
    systemAgentPoolSubnetName: systemAgentPoolSubnetName
    userAgentPoolSubnetName: userAgentPoolSubnetName
    podSubnetName: podSubnetName
    apiServerSubnetName: apiServerSubnetName
    managedIdentityName: aksManagedIdentity.outputs.name
    dnsPrefix: aksClusterDnsPrefix
    networkDataplane: aksClusterNetworkDataplane
    networkMode: aksClusterNetworkMode
    networkPlugin: aksClusterNetworkPlugin
    networkPluginMode: aksClusterNetworkPluginMode
    networkPolicy: aksClusterNetworkPolicy
    webAppRoutingEnabled: nginxIngressControllerType == 'Managed' || aksClusterWebAppRoutingEnabled
    podCidr: aksClusterPodCidr
    serviceCidr: aksClusterServiceCidr
    dnsServiceIP: aksClusterDnsServiceIP
    loadBalancerSku: aksClusterLoadBalancerSku
    loadBalancerBackendPoolType: loadBalancerBackendPoolType
    acnsEnabled: aksClusterAcnsEnabled
    ipFamilies: aksClusterIpFamilies
    outboundType: aksClusterOutboundType
    skuTier: aksClusterSkuTier
    kubernetesVersion: aksClusterKubernetesVersion
    adminUsername: aksClusterAdminUsername
    sshPublicKey: aksClusterSshPublicKey
    aadProfileTenantId: aadProfileTenantId
    aadProfileAdminGroupObjectIDs: aadProfileAdminGroupObjectIDs
    aadProfileManaged: aadProfileManaged
    aadProfileEnableAzureRBAC: aadProfileEnableAzureRBAC
    nodeOSUpgradeChannel: aksClusterNodeOSUpgradeChannel
    upgradeChannel: aksClusterUpgradeChannel
    enablePrivateCluster: aksClusterEnablePrivateCluster
    privateDNSZone: aksPrivateDNSZone
    enablePrivateClusterPublicFQDN: aksEnablePrivateClusterPublicFQDN
    systemAgentPoolName: systemAgentPoolName
    systemAgentPoolVmSize: systemAgentPoolVmSize
    systemAgentPoolOsDiskSizeGB: systemAgentPoolOsDiskSizeGB
    systemAgentPoolOsDiskType: systemAgentPoolOsDiskType
    systemAgentPoolAgentCount: systemAgentPoolAgentCount
    systemAgentPoolOsSKU: systemAgentPoolOsSKU
    systemAgentPoolOsType: systemAgentPoolOsType
    systemAgentPoolMaxPods: systemAgentPoolMaxPods
    systemAgentPoolMaxCount: systemAgentPoolMaxCount
    systemAgentPoolMinCount: systemAgentPoolMinCount
    systemAgentPoolEnableAutoScaling: systemAgentPoolEnableAutoScaling
    systemAgentPoolScaleSetPriority: systemAgentPoolScaleSetPriority
    systemAgentPoolScaleSetEvictionPolicy: systemAgentPoolScaleSetEvictionPolicy
    systemAgentPoolNodeLabels: systemAgentPoolNodeLabels
    systemAgentPoolNodeTaints: systemAgentPoolNodeTaints
    systemAgentPoolType: systemAgentPoolType
    systemAgentPoolAvailabilityZones: systemAgentPoolAvailabilityZones
    systemAgentPoolKubeletDiskType: systemAgentPoolKubeletDiskType
    userAgentPoolName: userAgentPoolName
    userAgentPoolVmSize: userAgentPoolVmSize
    userAgentPoolOsDiskSizeGB: userAgentPoolOsDiskSizeGB
    userAgentPoolOsDiskType: userAgentPoolOsDiskType
    userAgentPoolAgentCount: userAgentPoolAgentCount
    userAgentPoolOsSKU: userAgentPoolOsSKU
    userAgentPoolOsType: userAgentPoolOsType
    userAgentPoolMaxPods: userAgentPoolMaxPods
    userAgentPoolMaxCount: userAgentPoolMaxCount
    userAgentPoolMinCount: userAgentPoolMinCount
    userAgentPoolEnableAutoScaling: userAgentPoolEnableAutoScaling
    userAgentPoolScaleSetPriority: userAgentPoolScaleSetPriority
    userAgentPoolScaleSetEvictionPolicy: userAgentPoolScaleSetEvictionPolicy
    userAgentPoolNodeLabels: userAgentPoolNodeLabels
    userAgentPoolNodeTaints: userAgentPoolNodeTaints
    userAgentPoolType: userAgentPoolType
    userAgentPoolAvailabilityZones: userAgentPoolAvailabilityZones
    userAgentPoolKubeletDiskType: userAgentPoolKubeletDiskType
    httpApplicationRoutingEnabled: httpApplicationRoutingEnabled
    istioServiceMeshEnabled: istioServiceMeshEnabled
    istioIngressGatewayEnabled: istioIngressGatewayEnabled
    istioIngressGatewayType: istioIngressGatewayType
    kedaEnabled: kedaEnabled
    daprEnabled: daprEnabled
    daprHaEnabled: daprHaEnabled
    fluxGitOpsEnabled: fluxGitOpsEnabled
    verticalPodAutoscalerEnabled: verticalPodAutoscalerEnabled
    aciConnectorLinuxEnabled: aciConnectorLinuxEnabled
    azurePolicyEnabled: azurePolicyEnabled
    azureKeyvaultSecretsProviderEnabled: azureKeyvaultSecretsProviderEnabled
    kubeDashboardEnabled: kubeDashboardEnabled
    autoScalerProfileScanInterval: autoScalerProfileScanInterval
    autoScalerProfileScaleDownDelayAfterAdd: autoScalerProfileScaleDownDelayAfterAdd
    autoScalerProfileScaleDownDelayAfterDelete: autoScalerProfileScaleDownDelayAfterDelete
    autoScalerProfileScaleDownDelayAfterFailure: autoScalerProfileScaleDownDelayAfterFailure
    autoScalerProfileScaleDownUnneededTime: autoScalerProfileScaleDownUnneededTime
    autoScalerProfileScaleDownUnreadyTime: autoScalerProfileScaleDownUnreadyTime
    autoScalerProfileUtilizationThreshold: autoScalerProfileUtilizationThreshold
    autoScalerProfileMaxGracefulTerminationSec: autoScalerProfileMaxGracefulTerminationSec
    blobCSIDriverEnabled: blobCSIDriverEnabled
    diskCSIDriverEnabled: diskCSIDriverEnabled
    fileCSIDriverEnabled: fileCSIDriverEnabled
    snapshotControllerEnabled: snapshotControllerEnabled
    defenderSecurityMonitoringEnabled: defenderSecurityMonitoringEnabled
    imageCleanerEnabled: imageCleanerEnabled
    imageCleanerIntervalHours: imageCleanerIntervalHours
    nodeRestrictionEnabled: nodeRestrictionEnabled
    workloadIdentityEnabled: workloadIdentityEnabled
    oidcIssuerProfileEnabled: oidcIssuerProfileEnabled
    podIdentityProfileEnabled: podIdentityProfileEnabled
    prometheusAndGrafanaEnabled: true
    metricAnnotationsAllowList: metricAnnotationsAllowList
    metricLabelsAllowlist: metricLabelsAllowlist
    dnsZoneName: dnsZoneName
    dnsZoneResourceGroupName: dnsZoneResourceGroupName
    workspaceId: workspace.outputs.id
    location: location
    tags: clusterTags
  }
}

module actionGroup 'actionGroup.bicep' = if (actionGroupEnabled) {
  name: 'actionGroup'
  params: {
    name: actionGroupName
    enabled: actionGroupEnabled
    groupShortName: actionGroupShortName
    emailAddress: actionGroupEmailAddress
    useCommonAlertSchema: actionGroupUseCommonAlertSchema
    countryCode: actionGroupCountryCode
    phoneNumber: actionGroupPhoneNumber
    tags: tags
  }
}

module prometheus 'managedPrometheus.bicep' = {
  name: 'managedPrometheus'
  params: {
    name: prometheusName
    publicNetworkAccess: prometheusPublicNetworkAccess
    location: location
    tags: tags
    clusterName: aksCluster.outputs.name
    actionGroupId: actionGroupEnabled ? actionGroup.outputs.id : ''
  }
}

module grafana 'managedGrafana.bicep' = {
  name: 'managedGrafana'
  params: {
    name: grafanaName
    skuName: grafanaSkuName
    apiKey: grafanaApiKey
    autoGeneratedDomainNameLabelScope: grafanaAutoGeneratedDomainNameLabelScope
    deterministicOutboundIP: grafanaDeterministicOutboundIP
    publicNetworkAccess: grafanaPublicNetworkAccess
    zoneRedundancy: grafanaZoneRedundancy
    prometheusName: prometheus.outputs.name
    userId: userId
    location: location
    tags: tags
  }
}

module privateLinkService 'privateLinkService.bicep' = {
  name: 'privateLinkService'
  params: {
    name: privateLinkServiceName
    loadBalancerName: loadBalancerName
    loadBalancerResourceGroupName: aksCluster.outputs.nodeResourceGroup
    subnetId: network.outputs.vmSubnetId
    location: location
    tags: tags
  }
  dependsOn: [
    deploymentScript
  ]
}

module frontDoor 'frontDoor.bicep' = {
  name: 'frontDoor'
  params: {
    frontDoorName: frontDoorName
    frontDoorSkuName: frontDoorSkuName
    managedIdentityName: frontDoorManagedIdentity.outputs.name
    originResponseTimeoutSeconds: originResponseTimeoutSeconds
    originGroupName: originGroupName
    originName: originName
    originEnabledState: originEnabledState
    originPath: originPath
    hostName: hostName
    httpPort: httpPort
    httpsPort: httpsPort
    originHostHeader: hostName
    priority: priority
    weight: weight
    privateLinkResourceId: privateLinkService.outputs.id
    sampleSize: sampleSize
    successfulSamplesRequired: successfulSamplesRequired
    additionalLatencyInMilliseconds: additionalLatencyInMilliseconds
    probePath: probePath
    probeRequestType: probeRequestType
    probeProtocol: probeProtocol
    probeIntervalInSeconds: probeIntervalInSeconds
    sessionAffinityState: sessionAffinityState
    autoGeneratedDomainNameLabelScope: autoGeneratedDomainNameLabelScope
    routeName: routeName
    ruleSets: ruleSets
    supportedProtocols: supportedProtocols
    routePatternsToMatch: routePatternsToMatch
    forwardingProtocol: forwardingProtocol
    linkToDefaultDomain: linkToDefaultDomain
    httpsRedirect: httpsRedirect
    endpointName: endpointName
    endpointEnabledState: endpointEnabledState
    wafPolicyName: wafPolicyName
    wafPolicyMode: wafPolicyMode
    wafPolicyEnabledState: wafPolicyEnabledState
    wafManagedRuleSets: wafManagedRuleSets
    wafCustomRules: wafCustomRules
    wafPolicyRequestBodyCheck: wafPolicyRequestBodyCheck
    securityPolicyName: securityPolicyName
    securityPolicyPatternsToMatch: securityPolicyPatternsToMatch
    keyVaultName: keyVaultName
    keyVaultResourceGroupName: keyVaultResourceGroupName
    keyVaultCertificateName: keyVaultCertificateName
    keyVaultCertificateVersion: keyVaultCertificateVersion
    customDomainName: hostName
    workspaceId: workspace.outputs.id
    location: location
    tags: tags
  }
  dependsOn: [
    keyVault
  ]
}

module aksmetricalerts 'metricAlerts.bicep' = if (createMetricAlerts) {
  name: 'aksmetricalerts'
  scope: resourceGroup()
  params: {
    aksClusterName: aksCluster.outputs.name
    metricAlertsEnabled: metricAlertsEnabled
    evalFrequency: metricAlertsEvalFrequency
    windowSize: metricAlertsWindowsSize
    alertSeverity: 'Informational'
    tags: tags
  }
}

module deploymentScript 'deploymentScript.bicep' = {
  name: 'deploymentScript'
  params: {
    name: deploymentScripName
    managedIdentityName: letterCaseType == 'UpperCamelCase'
    ? 'DeploymentScriptIdentity'
    : letterCaseType == 'CamelCase'
        ? 'deploymentScriptIdentity'
        : 'deployment-script-identity'
    clusterName: aksCluster.outputs.name
    hostName: hostName
    nginxIngressControllerType: nginxIngressControllerType
    webAppRoutingEnabled: aksClusterWebAppRoutingEnabled
    installPrometheusAndGrafana: installPrometheusAndGrafana
    installCertManager: installCertManager
    installNginxIngressController: installNginxIngressController
    secretProviderClassName: secretProviderClassName
    secretName: secretName
    namespace: namespace
    keyVaultCertificateName: keyVaultCertificateName
    keyVaultName: keyVaultName
    dnsZoneName: dnsZoneName
    dnsZoneResourceGroupName: dnsZoneResourceGroupName
    certManagerClientId: certManagerManagedIdentity.outputs.clientId
    csiDriverClientId: aksCluster.outputs.azureKeyvaultSecretsProviderIdentity.clientId
    tenantId: tenantId
    email: email
    primaryScriptUri: deploymentScriptUri
    resourceGroupName: resourceGroup().name
    subscriptionId: subscription().subscriptionId
    location: location
    tags: tags
  }
  dependsOn: [
    keyVault
  ]
}

module dnsZone 'dnsZone.bicep' = {
  name: 'dnsZone'
  scope: resourceGroup(dnsZoneResourceGroupName)
  params: {
    name: dnsZoneName
    cnameRecordName: subdomain
    ttl: cnameRecordTtl
    hostName: frontDoor.outputs.frontDoorEndpointFqdn
    validationToken: frontDoor.outputs.customDomainValidationDnsTxtRecordValue
    domainValidationState: frontDoor.outputs.customDomainValidationState
    certManagerManagedIdentityObjectId: certManagerManagedIdentity.outputs.principalId
    webAppRoutingManagedIdentityObjectId: aksCluster.outputs.webAppRoutingManagedIdentity.objectId
  }
}

// Outputs
output aksClusterName string = aksCluster.outputs.name
output aksClusterFqdn string = aksCluster.outputs.fqdn
output acrName string = containerRegistry.outputs.name
output keyVaultName string = keyVault.outputs.name
output logAnalyticsWorkspaceName string = workspace.outputs.name
output frontDoorName string = frontDoor.outputs.name
output frontDoorEndpointFqdn string = frontDoor.outputs.frontDoorEndpointFqdn
output privateLinkServiceName string = privateLinkService.outputs.name
output customDomainValidationDnsTxtRecordValue string = frontDoor.outputs.customDomainValidationDnsTxtRecordValue
output customDomainValidationExpiry string = frontDoor.outputs.customDomainValidationExpiry

// Parameters
@description('Specifies the name of the private link service.')
param name string

@description('Specifies the location of the private link service.')
param location string

@description('Specifies the name of the load balancer.')
param loadBalancerName string

@description('Specifies the name of the resource group containing the load balancer.')
param loadBalancerResourceGroupName string

@description('Specifies the resource Id of the subnet where the private link service will be created.')
param subnetId string

@description('Specifies the private IP address allocation method. Possible values are Static or Dynamic. Default is Dynamic.')
@allowed([
  'Static'
  'Dynamic'
])
param privateIPAllocationMethod string = 'Dynamic'

@description('Specifies the private IP address version to use. Possible values are IPv4 or IPv6. Default is IPv4.')
@allowed([
  'IPv4'
  'IPv6'
])
param privateIPAddressVersion string = 'IPv4'

@description('Specifies the resource tags.')
param tags object

// Resources
resource loadBalancer 'Microsoft.Network/loadBalancers@2023-04-01' existing = {
  name: loadBalancerName
  scope: resourceGroup(loadBalancerResourceGroupName)
}

resource privateLinkService 'Microsoft.Network/privateLinkServices@2023-04-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    autoApproval: {
      subscriptions: [
        subscription().subscriptionId
      ]
    }
    visibility: {
      subscriptions: [
        subscription().subscriptionId
      ]
    }
    fqdns: []
    enableProxyProtocol: false
    loadBalancerFrontendIpConfigurations: [
      {
        id: loadBalancer.properties.frontendIPConfigurations[0].id
      }
    ]
    ipConfigurations: [
      {
        name: 'Default'
        properties: {
          privateIPAllocationMethod: privateIPAllocationMethod
          subnet: {
            id: subnetId
          }
          primary: true
          privateIPAddressVersion: privateIPAddressVersion
        }
      }
    ]
  }
}

// Outputs
output id string = privateLinkService.id
output name string = privateLinkService.name

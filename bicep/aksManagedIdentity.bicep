// Parameters
@description('Specifies the name of the user-defined managed identity.')
param name string

@description('Specifies the name of the existing virtual network.')
param virtualNetworkName string

@description('Specifies the location.')
param location string = resourceGroup().location

@description('Specifies the resource tags.')
param tags object

// Resources
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: name
  location: location
  tags: tags
}

resource networkContributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '4d97b98b-1d4f-4787-a291-c67834d212e7'
  scope: subscription()
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-08-01' existing =  {
  name: virtualNetworkName
}

resource virtualNetworkContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name:  guid(managedIdentity.id, virtualNetwork.id, networkContributorRoleDefinition.id)
  scope: virtualNetwork
  properties: {
    roleDefinitionId: networkContributorRoleDefinition.id
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// Outputs
output id string = managedIdentity.id
output name string = managedIdentity.name

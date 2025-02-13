// Parameters
@description('Specifies the name of the user-defined managed identity.')
param name string

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

// Outputs
output id string = managedIdentity.id
output name string = managedIdentity.name
output principalId string = managedIdentity.properties.principalId
output clientId string = managedIdentity.properties.clientId

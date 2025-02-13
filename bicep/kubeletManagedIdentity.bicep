// Parameters
@description('Specifies the name of the existing AKS cluster.')
param aksClusterName string

@description('Specifies the name of the existing container registry.')
param acrName string

// Resources
resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-09-02-preview' existing = {
  name: aksClusterName
}

resource acrPullRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '7f951dda-4ed3-4680-a7ca-43fe172d538d'
  scope: subscription()
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-12-01-preview' existing = {
  name: acrName
}

resource acrPullRoleAssignmentName 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(aksCluster.name, containerRegistry.id, acrPullRoleDefinition.id)
  scope: containerRegistry
  properties: {
    roleDefinitionId: acrPullRoleDefinition.id
    principalId: any(aksCluster.properties.identityProfile.kubeletidentity).objectId
    principalType: 'ServicePrincipal'
  }
}

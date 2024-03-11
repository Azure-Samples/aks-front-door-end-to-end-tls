// Parameters
@description('Specifies the name of an existing Key Vault resource holding the TLS certificate.')
param name string

@description('Specifies the object id of the Key Vault CSI Driver user-assigned managed identity.')
param objectId string

@description('Specifies whether the Azure Key Vault Provider for Secrets Store CSI Driver addon is enabled or not.')
param azureKeyvaultSecretsProviderEnabled bool = true

// Resources
resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: name
}

resource keyVaultAdministratorRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '00482a5a-887f-4fb3-b363-3b7fe8e74483'
  scope: subscription()
}

// Role Assignments
resource keyVaultCSIdriverSecretsUserRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (azureKeyvaultSecretsProviderEnabled) {
  name: guid(keyVault.id, 'CSIDriver', keyVaultAdministratorRole.id, objectId)
  scope: keyVault
  properties: {
    roleDefinitionId: keyVaultAdministratorRole.id
    principalType: 'ServicePrincipal'
    principalId: objectId
  }
}

// Outputs
output id string = keyVault.id
output name string = keyVault.name

// Parameters
@description('Specifies the name of an existing Key Vault resource holding the TLS certificate.')
param name string

@description('Specifies the object id of the Key Vault Secret Store CSI Driver user-assigned managed identity.')
param keyVaultCsiDriverManagedIdentityObjectId string

@description('Specifies the object id of the Front Door user-assigned managed identity.')
param frontDoorManagedIdentityObjectId string

@description('Specifies whether the Azure Key Vault Provider for Secrets Store CSI Driver addon is enabled or not.')
param azureKeyvaultSecretsProviderEnabled bool = true

// Resources
resource keyVault 'Microsoft.KeyVault/vaults@2022-07-01' existing = {
  name: name
}

resource keyVaultAdministratorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '00482a5a-887f-4fb3-b363-3b7fe8e74483'
  scope: subscription()
}

// Role Assignments
resource keyVaultCsiDriverManagedIdentityKeyVaultAdmnistratorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (azureKeyvaultSecretsProviderEnabled) {
  name: guid(keyVault.id, 'CSIDriver', keyVaultAdministratorRoleDefinition.id, keyVaultCsiDriverManagedIdentityObjectId)
  scope: keyVault
  properties: {
    roleDefinitionId: keyVaultAdministratorRoleDefinition.id
    principalType: 'ServicePrincipal'
    principalId: keyVaultCsiDriverManagedIdentityObjectId
  }
}

resource frontDoorManagedIdentityKeyVaultAdmnistratorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (azureKeyvaultSecretsProviderEnabled) {
  name: guid(keyVault.id, 'CSIDriver', keyVaultAdministratorRoleDefinition.id, frontDoorManagedIdentityObjectId)
  scope: keyVault
  properties: {
    roleDefinitionId: keyVaultAdministratorRoleDefinition.id
    principalType: 'ServicePrincipal'
    principalId: frontDoorManagedIdentityObjectId
  }
}

// Outputs
output id string = keyVault.id
output name string = keyVault.name

// For more information, see https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/deployment-script-bicep
@description('Specifies the name of the deployment script uri.')
param name string = 'BashScript' 

@description('Specifies the primary script URI.')
param primaryScriptUri string

@description('Specifies the name of the AKS cluster.')
param clusterName string

@description('Specifies the resource group name')
param resourceGroupName string = resourceGroup().name

@description('Specifies the subscription id.')
param subscriptionId string = subscription().subscriptionId

@description('Specifies the hostname of the application.')
param hostName string

@description('Specifies the secret provider class name that reads the certificate from key vault and creates a TLS secret in the Kubernetes cluster.')
#disable-next-line secure-secrets-in-params
param secretProviderClassName string

@description('Specifies the secret name containing the TLS certificate.')
param secretName string

@description('Specifies the namespace of the application.')
param namespace string

@description('Specifies the name of the existing Key Vault resource holding the TLS certificate.')
param keyVaultName string

@description('Specifies the name of the existing TLS certificate.')
param keyVaultCertificateName string

@description('Specifies the client id of the Key Vault CSI Driver user-assigned managed identity.')
param clientId string

@description('Specifies the tenantId.')
param tenantId string

@description('Specifies the email address for the cert-manager cluster issuer.')
param email string = 'admin@contoso.com'

@description('Specifies the current datetime')
param utcValue string = utcNow()

@description('Specifies the location.')
param location string = resourceGroup().location

@description('Specifies the resource tags.')
param tags object

// Variables
var clusterAdminRoleDefinitionId = resourceId('Microsoft.Authorization/roleDefinitions', '0ab0b1a8-8aac-4efd-b8c2-3ee1fb270be8')

// Resources
resource aksCluster 'Microsoft.ContainerService/managedClusters@2022-11-02-preview' existing = {
  name: clusterName
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2021-09-30-preview' = {
  name: 'scriptManagedIdentity'
  location: location
  tags: tags
}

resource clusterAdminContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2020-10-01-preview' = {
  name:  guid(managedIdentity.id, aksCluster.id, clusterAdminRoleDefinitionId)
  scope: aksCluster
  properties: {
    roleDefinitionId: clusterAdminRoleDefinitionId
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

// Script
resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: name
  location: location
  kind: 'AzureCLI'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    forceUpdateTag: utcValue
    azCliVersion: '2.42.0'
    timeout: 'PT30M'
    environmentVariables: [
      {
        name: 'clusterName'
        value: clusterName
      }
      {
        name: 'resourceGroupName'
        value: resourceGroupName
      }
      {
        name: 'subscriptionId'
        value: subscriptionId
      }
      {
        name: 'hostname'
        value: hostName
      }
      {
        name: 'secretProviderClassName'
        value: secretProviderClassName
      }
      {
        name: 'secretName'
        value: secretName
      }
      {
        name: 'namespace'
        value: namespace
      }
      {
        name: 'keyVaultName'
        value: keyVaultName
      }
      {
        name: 'keyVaultCertificateName'
        value: keyVaultCertificateName
      }
      {
        name: 'clientId'
        value: clientId
      }
      {
        name: 'tenantId'
        value: tenantId
      }
      {
        name: 'email'
        value: email
      }
    ]
    primaryScriptUri: primaryScriptUri
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}

/*
  resource log 'Microsoft.Resources/deploymentScripts/logs@2020-10-01' existing = {
  parent: deploymentScript
  name: 'default'
}
*/

// output log string = log.properties.log
output result object = deploymentScript.properties.outputs
output certManager string = deploymentScript.properties.outputs.certManager
output nginxIngressController string = deploymentScript.properties.outputs.nginxIngressController

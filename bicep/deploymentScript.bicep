// For more information, see https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/deployment-script-bicep
@description('Specifies the name of the deployment script uri.')
param name string = 'BashScript' 

@description('Specifies the primary script URI.')
param primaryScriptUri string

@description('Specifies the name of the deployment script user-defined managed identity.')
param managedIdentityName string

@description('''Specifies the the kind of NGINX ingress controller to use. You can assign two values: 
- Managed: is the managed NGINX ingress controller installed by the Azure Kubernetes Service (AKS) team.
- Unmanaged: is the NGINX ingress controller installed via Helm.
''')
@allowed([
  'Managed'
  'Unmanaged'
])
param nginxIngressControllerType string

@description('Specifies whether the managed NGINX Ingress Controller application routing addon is enabled.')
param webAppRoutingEnabled bool

@description('Specifies whether deploying Prometheus and Grafana using Helm.')
param installPrometheusAndGrafana bool = false

@description('Specifies whether deploying cert-manager using Helm.')
param installCertManager bool = false

@description('Specifies whether deploying NGINX ingress controller using Helm.')
param installNginxIngressController bool = false

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

@description('Specifies the name of the public DNS zone used by the managed NGINX Ingress Controller, when enabled.')
param dnsZoneName string

@description('Specifies the resource group name of the public DNS zone used by the managed NGINX Ingress Controller, when enabled.')
param dnsZoneResourceGroupName string

@description('Specifies the client id of the cert-manager user-assigned managed identity.')
param certManagerClientId string

@description('Specifies the client id of the Key Vault CSI Driver user-assigned managed identity.')
param csiDriverClientId string

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

// Resources
resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-09-02-preview' existing = {
  name: clusterName
}

resource clusterAdminRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '0ab0b1a8-8aac-4efd-b8c2-3ee1fb270be8'
  scope: subscription()
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-07-31-preview' = {
  name: managedIdentityName
  location: location
  tags: tags
}

resource clusterAdminContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name:  guid(managedIdentity.id, aksCluster.id, clusterAdminRoleDefinition.id)
  scope: aksCluster
  properties: {
    roleDefinitionId: clusterAdminRoleDefinition.id
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
        name: 'nginxIngressControllerType'
        value: nginxIngressControllerType
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
        name: 'dnsZoneName'
        value: dnsZoneName
      }
      {
        name: 'dnsZoneResourceGroupName'
        value: dnsZoneResourceGroupName
      }
      {
        name: 'certManagerClientId'
        value: certManagerClientId
      }
      {
        name: 'csiDriverClientId'
        value: csiDriverClientId
      }
      {
        name: 'tenantId'
        value: tenantId
      }
      {
        name: 'email'
        value: email
      }
      {
        name: 'webAppRoutingEnabled'
        value: webAppRoutingEnabled ? 'true' : 'false'
      }
      {
        name: 'installPrometheusAndGrafana'
        value: installPrometheusAndGrafana ? 'true' : 'false'
      }
      {
        name: 'installCertManager'
        value: installCertManager ? 'true' : 'false'
      }
      {
        name: 'installNginxIngressController'
        value: installNginxIngressController ? 'true' : 'false'
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

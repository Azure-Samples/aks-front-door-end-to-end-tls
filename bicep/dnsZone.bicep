// Parameters
@description('Specifies the name of an existing public DNS zone.')
param name string

@description('Specifies the name of the CNAME record to create within the DNS zone. The record will be an alias to your Front Door endpoint.')
param cnameRecordName string

@description('Specifies the time-to-live (TTL) value for the CNAME record.')
param ttl int = 3600

@description('Specifies the Front Door endpoint to which the CNAME record will point.')
param hostName string

@description('Specifies the validation state of the custom domain.')
param domainValidationState string 

@description('Specifies the validation token of the custom domain.')
param validationToken string

@description('Specifies the object id of the cert-manager user-assigned managed identity.')
param certManagerManagedIdentityObjectId string

@description('Specifies the object id of application routing add-on user-assigned managed identity.')
param webAppRoutingManagedIdentityObjectId string

// Resources
resource dnsZone 'Microsoft.Network/dnsZones@2018-05-01' existing = {
  name: name
}

resource dnsZoneContributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: 'befefa01-2a29-4197-83a8-272ff33ce314'
  scope: subscription()
}

resource cnameRecord 'Microsoft.Network/dnsZones/CNAME@2018-05-01' = {
  parent: dnsZone
  name: cnameRecordName
  properties: {
    TTL: ttl
    CNAMERecord: {
      cname: hostName
    }
  }
}

resource validationTxtRecord 'Microsoft.Network/dnsZones/TXT@2018-05-01' = if (domainValidationState != 'Approved') {
  parent: dnsZone
  name: '_dnsauth.${cnameRecordName}'
  properties: {
    TTL: ttl
    TXTRecords: [
      {
        value: [
          validationToken
        ]
      }
    ]
  }
}

resource certManagerManagedIdentityDnsZoneContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name:  guid(certManagerManagedIdentityObjectId, dnsZone.id, dnsZoneContributorRoleDefinition.id)
  scope: dnsZone
  properties: {
    roleDefinitionId: dnsZoneContributorRoleDefinition.id
    principalId: certManagerManagedIdentityObjectId
    principalType: 'ServicePrincipal'
  }
}

resource webAppRoutingManagedIdentityDnsZoneContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name:  guid(webAppRoutingManagedIdentityObjectId, dnsZone.id, dnsZoneContributorRoleDefinition.id)
  scope: dnsZone
  properties: {
    roleDefinitionId: dnsZoneContributorRoleDefinition.id
    principalId: webAppRoutingManagedIdentityObjectId
    principalType: 'ServicePrincipal'
  }
}

// Outputs
output dnsZoneId string = dnsZone.id

New-AzADServicePrincipal -ApplicationId "2565bd9d-da50-47d4-8b85-4c97f669dc36"

New-AzResourceGroup -Name 'WVD-DEPLOY' -location 'eastus'

New-AzUserAssignedIdentity -ResourceGroupName 'WVD-DEPLOY' -Name 'bpdeploy'

Id                : /subscriptions/312ed374-43f0-4c49-b519-27e3e30c17f2/resourcegroups/WVD-DEPLOY/providers/Microsoft.ManagedIdentity/userAssignedIdentities/bpdeploy
ResourceGroupName : WVD-DEPLOY
Name              : bpdeploy
Location          : eastus
TenantId          : 974cccba-8d13-48e4-94c6-23390a798f42
PrincipalId       : dcdbbed7-de32-4774-b9ec-4f80b28ece04
ClientId          : f45fe12b-288a-4b69-b01c-3aeb673e855c
ClientSecretUrl   : https://control-eastus.identity.azure.net/subscriptions/312ed374-43f0-4c49-b519-27e3e30c17f2/resourcegroups/WVD-DEPLOY/providers/Microsoft.ManagedIdentity/userAssignedIdentities/bpdeploy/credentials?tid=974cccba-8d13 
                    -48e4-94c6-23390a798f42&oid=dcdbbed7-de32-4774-b9ec-4f80b28ece04&aid=f45fe12b-288a-4b69-b01c-3aeb673e855c
Type              : Microsoft.ManagedIdentity/userAssignedIdentities


New-AzRoleAssignment -ObjectId 0cca72bd-8791-47a3-9b37-8dde407b3c41 -RoleDefinitionName Owner





# The following parameter values are examples, which you can change to suit your environment
# The Azure location (ex. needs to be filled in at or near run-time).

$SubscriptionID = (Get-AzSubscription).Id
$ResourceGroupName = 'AVD Global RG'
$UserAssignedIdentity = 'UAI1'
$NetworkSecurityGroupName = 'Blueprint Operators'
$AzureLocation = '<location name>' # To get a current location list, run this command: 'Get-AzLocation | Select-Object Location'

##### DO NOT MODIFY CODE BELOW THIS LINE #####

# Create user assigned managed identity
New-AzUserAssignedIdentity -ResourceGroup $ResourceGroupName -Name $UserAssignedIdentity

# Create Azure security group
New-AzNetworkSecurityGroup -Name $NetworkSecurityGroupName -ResourceGroupName $ResourceGroupName -Location $AzureLocation

# Assign Azure Blueprint roles to the security group just created
$BlueprintOperatorRoleID = (Get-AzADGroup -DisplayName $NetworkSecurityGroupName).Id
$BlueprintOperatorRoleName = (Get-AzADGroup -DisplayName $NetworkSecurityGroupName).DisplayName

New-AzRoleAssignment -ObjectId $BlueprintOperatorRoleID -RoleDefinitionName $BlueprintOperatorRoleName  -Scope /subscriptions/$SubscriptionID/resourcegroups/$ResourceGroupName/providers/<providerName>/<resourceType>/<resourceSubType>/<resourceName>

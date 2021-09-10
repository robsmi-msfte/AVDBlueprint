[CmdletBinding()]
param(
    [Parameter()]
    [string]$AVDBPParamFile = ".\AVDBPParameters.json"
)

If ($AVDBPParamFile -ne '.\AVDBPParameters.json') {
    Write-Host "The current value of parameter AVDBPParamFile is '$AVDBPParamFile'"
    Write-Host "The parameter 'AVDBPParamFile' is not set correctly"
    Write-Host "Please check the path and try again"
    Return
}

$BPScriptParams = Get-Content $AVDBPParamFile | ConvertFrom-Json
$BPScriptParams.PSObject.Properties | ForEach-Object {
     New-Variable -Name $_.Name -Value $_.Value -Force -ErrorAction SilentlyContinue
    }
$BPScriptParams

<#####################################################################################################################################
    This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.  
    THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, 
    INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.  We grant 
    You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object code form 
    of the Sample Code, provided that You agree: (i) to not use Our name, logo, or trademarks to market Your software product in 
    which the Sample Code is embedded; (ii) to include a valid copyright notice on Your software product in which the Sample Code 
    is embedded; and (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, 
    including attorneys’ fees, that arise or result from the use or distribution of the Sample Code.
    Microsoft provides programming examples for illustration only, without warranty either expressed or
    implied, including, but not limited to, the implied warranties of merchantability and/or fitness 
    for a particular purpose. 
 
    This sample assumes that you are familiar with the programming language being demonstrated and the 
    tools used to create and debug procedures. Microsoft support professionals can help explain the 
    functionality of a particular procedure, but they will not modify these examples to provide added 
    functionality or construct procedures to meet your specific needs. if you have limited programming 
    experience, you may want to contact a Microsoft Certified Partner or the Microsoft fee-based consulting 
    line at (800) 936-5200. 
    For more information about Microsoft Certified Partners, please visit the following Microsoft Web site:
    https://partner.microsoft.com/global/30000104 
######################################################################################################################################>

<#####################################################################################################################################
- TITLE:          AVD Blueprint Configuration and Deployment script
- AUTHORED BY:    Robert M. Smith
- AUTHORED DATE:  01 September 2021
- CONTRIBUTORS:   Tim Muessig
- LAST UPDATED:   10 September 2021
- PURPOSE:        A single PowerShell script to perform everything necessary to deploy Azure Virtual Desktop (AVD)
                  into an Azure Subscription

- IMPORTANT:      This script is currently intended to be deployed in an environment without user Active Directory
                  or Azure Active Directory Domain Services (AAD DS).  This script currently creates a new instance of AAD DS.
                  A future version will add the ability to install to an environment with existing AD or AAD DS.

- DEPENDENCIES    1. An Azure tenant
                  2. An Azure subscription
                  3. An Azure account in the Azure tenant with the following roles:
                     - 'Global Administrator' at the Azure AD scope
                     - 'Owner' at the Azure subscription scope
                  4. A copy of the Blueprint files (Blueprint.json and all .JSON files in the \Artifacts folder)
                  5. This script and accompanying .JSON file, which can be found in 'Examples and Samples' folder
                  6. The Blueprint "collateral" files (all files in \Scripts folder)
                     The files in the \Scripts folder can be used directly from the Azure Github repository URI
                     Or, a copy can be made available from an alternate location, such as an Azure Storage container,
                     an internal web server, etc. If using an alternate location, that location should allow for anonymous access.


- PARAMETERS      This script only has one parameter '-File'.  This is set to look for a file called "AVDBPParameters.json"
                  in the current folder

- USAGE           'AssignAVDBlueprint.ps1 -file .\AVDBPParameters.json

- USAGE EXAMPLE   'AssignAVDBlueprint.ps1 -AzureLocation 'centralus'

- LINK            
######################################################################################################################################>


 #region Checking for the first two required parameters, and if not set, exit script
if (-not($AzureLocation)) {
    Write-Host "`n    Azure location is null
    Azure Location must be specified in the file 'AVDBPParameters.json'
    for a list of Azure locations available in your subscription run 'Get-AzLocation | Select-Object Location'
    This script will now exit." -ForegroundColor Cyan
    Return
}

if (-not($AADDSDomainName)) {
    Write-Host "`n    Azure Active Directory Domain Services name is null
    AAD DS name must be specified in the parameter file 'AVDBPParameters.json'
    Your AAD DS prefix name must be 15 characters or less in the format 'domain.contoso.com'
    This script will now exit." -ForegroundColor Cyan
    Return
}
#endregion

#region Checking for and setting up environment
Write-Host "The next action will prompt you to login to your Azure portal using a Global Admin account" -ForegroundColor Cyan
Read-Host -Prompt "Press any key to continue"
Connect-AzAccount
$CurrentAzureEnvironment = Get-AzContext
$AzureSubscriptionID = $CurrentAzureEnvironment.Subscription.Id
$AzureTenantID = $CurrentAzureEnvironment.Tenant.Id
$AzureEnvironmentName = $CurrentAzureEnvironment.Environment.Name
$AzureStorageEnvironment = $CurrentAzureEnvironment.Environment.StorageEndpointSuffix
$AzureStorageFileEnv = 'file.' + $AzureStorageEnvironment

Write-Host "The next action will prompt you to login to connect to Azure AD" -ForegroundColor Cyan
Write-Host "If the prompt does not appear in the foregroun, try minimizing your current app" -ForegroundColor Cyan
Read-Host -Prompt "Press any key to continue"
Connect-AzureAD -TenantId $AzureTenantID

# Parameters set at script run-time, based on current context
[String]$ScriptExecutionUserObjectID = az ad signed-in-user show --query objectId
# Had to remove the quotation marks from the previous output
$ScriptExecutionUserObjectID2 = $ScriptExecutionUserObjectID -Replace '"', ""

#endregion

#region Make sure required Az modules are installed
# Including the "import-module" line in case the modules were installed by xcopy method, but not yet imported
# Also including a test for the PSGallery

# This script requires Az modules:
    #  - Az.Blueprint
    #  - Az.ManagedServiceIdentity
    #  - Az.Resources
    #  - AzureAD

    $AzModuleGalleryMessage = "You may be prompted to install from the PowerShell Gallery`n
    If the Az PowerShell modules were not previously installed you may be prompted to install 'Nuget'.`n
    If your policies allow those items to be installed, press 'Y' when prompted."
            
    if (-not(Get-PSRepository -Name 'PSGallery')) {
    Write-Host "    PowerShell Gallery 'PSGallery' not available.  Now resetting local repository to default,`n
    to allow access to the PSGallery (PowerShell Gallery),`n
    so subsequent Az modules needed for this script can be installed."
    Register-PSRepository -Default
    }
    
    Import-Module -Name Az.ManagedServiceIdentity
    if (-not(Get-Module Az.ManagedServiceIdentity)) {
    Write-Host "PowerShell module 'Az.ManagedServiceIdentity' not found. Now installing..."
    Write-Host $AzModuleGalleryMessage
    Install-Module Az.ManagedServiceIdentity
    }

    Import-Module -Name Az.Resources
    if (-not(Get-Module Az.Resources)) {
    Write-Host "PowerShell module 'Az.Resources' not found. Now installing..."
    Write-Host $AzModuleGalleryMessage
    Install-Module Az.Resources
    }

    Import-Module -Name Az.Blueprint
    if (-not(Get-Module Az.Blueprint)) {
    Write-Host "PowerShell module 'Az.Blueprint' not found. Now installing..."
    Write-Host $AzModuleGalleryMessage
    Install-Module Az.Blueprint
    }

    Import-Module -Name AzureAD
    if (-not(Get-InstalledModule | Where-Object Name -EQ 'AzureAD')) {
    Write-Host "PowerShell module 'AzureAD' not found. Now installing..."
    Write-Host $AzModuleGalleryMessage
    Install-Module AzureAD -Scope CurrentUser
    }
#endregion

#region Create a "global" resource group for AVD resources...
# which should not be the same resource group that the AVD Blueprint is later assigned to

    Write-Host "Creating AVD resource group for persistent objects such as user-assigned identity"
    If (-not(Get-AzResourceGroup -Name $BlueprintGlobalResourceGroupName -ErrorAction SilentlyContinue)){
        Write-Host "Resource Group $BlueprintGlobalResourceGroupName does not currently exist. Now creating Resource Group"
        New-AzResourceGroup -ResourceGroupName $BlueprintGlobalResourceGroupName -Location $AzureLocation
        } else {
        Write-Output "Resource Group '$BlueprintGlobalResourceGroupName' already exists."
    }
#endregion

#region Check to see if there is a user assigned managed identity with name 'UAI1', and if not, create one
    Write-Host "Creating user-assigned managed identity account, that will be the context of the AVD assignment"
    If (-not(Get-AzUserAssignedIdentity -Name $UserAssignedIdentityName -ResourceGroupName $BlueprintGlobalResourceGroupName -ErrorAction SilentlyContinue)){
        Write-Host "        Managed identity '$UserAssignedIdentityName' does not currently exist.`n
        Now creating '$UserAssignedIdentityName' in resource group '$BlueprintGlobalResourceGroupName'"
        $UserAssignedIdentity = New-AzUserAssignedIdentity -ResourceGroupName $BlueprintGlobalResourceGroupName -Name $UserAssignedIdentityName -Location $AzureLocation
        } else {
        Write-Output "User Assigned Identity '$UserAssignedIdentityName' already exists"
        $UserAssignedIdentity = Get-AzUserAssignedIdentity -ResourceGroupName $BlueprintGlobalResourceGroupName -Name $UserAssignedIdentityName
    }
    $UserAssignedIdentityId = $UserAssignedIdentity.Id
    $UserAssignedObjectID = $UserAssignedIdentity.PrincipalId
#endregion    

#region Grant the 'Owner' subscription level role to the managed identity
Write-Host "Now checking if user assigned identity '$UserAssignedIdentityName' has 'Owner' subscription level role assignment"
if (-not(Get-AzRoleAssignment -ResourceGroupName $BlueprintGlobalResourceGroupName -ObjectID $UserAssignedObjectID)) {
    Write-Host "User assigned identity '$UserAssignedIdentityName' does not currently have 'Owner' subscription level role assignment"
    Write-Host "Now assigning 'Owner' role to '$UserAssignedIdentityName'"
    New-AzRoleAssignment -ObjectId $UserAssignedIdentity.PrincipalId -RoleDefinitionName "Owner" -Scope "/subscriptions/$AzureSubscriptionID"
} else {
    Write-Host "User assigned identity '$UserAssignedIdentityName' already has 'Owner' role assigned at the subscription level"
    Get-AzRoleAssignment -ResourceGroupName $BlueprintGlobalResourceGroupName -ObjectID $UserAssignedObjectID
}
#endregion

#region Assign the required 'Global Administrator' Azure AD role assignment to the user-assigned managed identity
Write-Host "Now assigning 'Owner' role to managed identity, at the subscription level"
if (-not(Get-AzRoleAssignment -ObjectId $UserAssignedObjectID)){
    Write-Host "'Owner subscription role not currently assigned to managed identity. Now assigning..." 
    New-AzRoleAssignment -ObjectId $UserAssignedIdentity.PrincipalId -RoleDefinitionName "Owner" -Scope "/subscriptions/$AzureSubscriptionID" -ErrorAction SilentlyContinue
} else {
    Write-Host "'Owner' subscription role already assigned to managed identity."
    Get-AzRoleAssignment -ObjectId $UserAssignedObjectID
}
#endregion

#region Assign Azure AD role 'Global Administrator' to the managed identity, to allow creation of AD objects during assignment, if not already assigned
$AADGlobalAdminRoleInfo = Get-AzureADMSRoleDefinition -Filter "displayName eq 'Global Administrator'"
$AADGlobalAdminRoleInfoId = $AADGlobalAdminRoleInfo.Id
$AADGlobalAdminRoleDisplayName = $AADGlobalAdminRoleInfo.displayName
Write-Host "Assigning Azure AD role 'Global Administrator' to the managed identity"
if (-not(Get-AzureADMSRoleAssignment -Filter "principalID eq '$UserAssignedObjectID' and roleDefinitionId eq '$AADGlobalAdminRoleInfoId'")){
    Write-Host "User assigned identity"$UserAssignedIdentity.name"does not have the"$AADGlobalAdminRoleInfo.displayName"role currently assigned.`n"
    Write-Host "Now assigning role to managed identity."
    New-AzureADMSRoleAssignment -RoleDefinitionId $AADGlobalAdminRoleInfo.Id -PrincipalId $UserAssignedIdentity.PrincipalId -DirectoryScopeId '/'    
} else {
    Write-Host "User assigned identity '$UserAssignedIdentityName' already has the '$AADGlobalAdminRoleDisplayName' role assigned.`n"
    Get-AzureADMSRoleAssignment -Filter "principalID eq '$UserAssignedObjectID' and roleDefinitionId eq '$AADGlobalAdminRoleInfoId'"
}
#endregion

#region Register the Azure Blueprint provider to the subscription, if not already registered
Write-Host "Now checking the 'Microsoft.Blueprint' provider, and registering if needed"
if (-not(Get-AzResourceProvider -ListAvailable | Where-Object {($_.ProviderNamespace -EQ "Microsoft.Blueprint" -and $_.RegistrationState -EQ "Registered")})) {
    Write-Host "The 'Microsoft.Blueprint' provider is not currently registered. Now registering..."
    Register-AzResourceProvider -ProviderNamespace 'Microsoft.Blueprint'
    Get-AzResourceProvider -ListAvailable | Where-Object {($_.ProviderNamespace -EQ "Microsoft.Blueprint" -and $_.RegistrationState -EQ "Registered")}
} else {
    Write-Host "The 'Microsoft.Blueprint' provider is already registered"
    Get-AzResourceProvider -ListAvailable | Where-Object {($_.ProviderNamespace -EQ "Microsoft.Blueprint" -and $_.RegistrationState -EQ "Registered")}
}
#endregion

#region Register the Azure AD provider to the subscription, if not already registered
Write-Host "Now checking the 'Microsoft.AAD' provider, and registering if needed"
if (-not(Get-AzResourceProvider -ListAvailable | Where-Object {($_.ProviderNamespace -EQ "Microsoft.AAD" -and $_.RegistrationState -EQ "Registered")})) {
    Write-Host "The 'Microsoft.AAD' provider is not currently registered. Now registering..."
    Register-AzResourceProvider -ProviderNamespace 'Microsoft.AAD'
    Get-AzResourceProvider -ListAvailable | Where-Object {($_.ProviderNamespace -EQ "Microsoft.AAD" -and $_.RegistrationState -EQ "Registered")}
} else {
    Write-Host "The 'Microsoft.AAD' provider is already registered"
    Get-AzResourceProvider -ListAvailable | Where-Object {($_.ProviderNamespace -EQ "Microsoft.AAD" -and $_.RegistrationState -EQ "Registered")}
}
#endregion

#region Register the Azure Active Directory enterprise application to the subscription if not already registered
Write-Host "Now checking registration for the AAD DS enterprise application, and registering if needed"
if (-not (Get-AzureADServicePrincipal | Where-Object AppID -like "6ba9a5d4-8456-4118-b521-9c5ca10cdf84")) {
    Write-Host "The AAD DS enterprise application is not currently registered. Now registering"
    New-AzureADServicePrincipal -AppId "6ba9a5d4-8456-4118-b521-9c5ca10cdf84"
} else {
    Write-Host "The AAD DS enterprise application is already registered"
    Get-AzureADServicePrincipal | Where-Object AppID -like "6ba9a5d4-8456-4118-b521-9c5ca10cdf84"
}
#endregion

#region Register the Domain Controller Services service principal to the subscription if not already registered
Write-Host "Now checking registration for Domain Controller Services service principal, and registering if needed"
if (-not (Get-AzureADServicePrincipal | Where-Object AppID -like "2565bd9d-da50-47d4-8b85-4c97f669dc36")) {
    Write-Host "The Domain Controller Services service principal is not currently registered. Now registering"
    New-AzureADServicePrincipal -AppId "2565bd9d-da50-47d4-8b85-4c97f669dc36"
} else {
    Write-Host "The Domain Controller Services service principal is already registered"
    Get-AzureADServicePrincipal | Where-Object AppID -like "2565bd9d-da50-47d4-8b85-4c97f669dc36"
}
#endregion

# Import Blueprint section
Write-Host "    Now importing Blueprint to subscription.`n    If prompted to overwrite a previous Blueprint, press 'Y' and then press 'Enter'" -ForegroundColor Cyan
Import-AzBlueprintWithArtifact -Name $BlueprintName -InputPath $BlueprintPath -SubscriptionId $AzureSubscriptionID

# Publish Blueprint section
$BlueprintDefinition = Get-AzBlueprint -SubscriptionId $AzureSubscriptionID -Name $BlueprintName
$BlueprintVersion = (Get-Date -Format "yyyyMMddHHmmss").ToString()
Publish-AzBlueprint -Blueprint $BlueprintDefinition -Version $BlueprintVersion

# Create the hash table for Parameters
$bpParameters = @{
    adds_domainName                     =   $AADDSDomainName
    adds_emailNotifications             =   $adds_emailNotifications
    script_executionUserResourceID      =   $UserAssignedIdentityId
    scriptExecutionUserObjectID         =   $ScriptExecutionUserObjectID2
    keyvault_ownerUserObjectID          =   $UserAssignedObjectID
    AzureEnvironmentName                =   $AzureEnvironmentName
    AzureStorageFQDN                    =   $AzureStorageFileEnv
    scriptURI                           =   $ScriptURI
    resourcePrefix                      =   $BlueprintResourcePrefix
    avdHostPool_CreateAvailabilitySet   =   $avdHostPool_CreateAvailabilitySet
    vnetEnableDdosProtection            =   $vnetEnableDdosProtection
    managementVMOSSku                   =   $managementVMOSSku
    avdHostPool_vmSize                  =   $avdHostPool_vmSize
    avdHostPool_vmNumberOfInstances     =   $avdHostPool_vmNumberOfInstances
    avdHostPool_maxSessionLimit         =   $avdHostPool_maxSessionLimit
    avdHostPool_loadBalancerType        =   $avdHostPool_loadBalancerType
    avdHostPool_HostPoolType            =   $avdHostPool_HostPoolType
    avdUsers_userCount                  =   $avdUsers_userCount
    logsRetentionInDays                 =   $logsRetentionInDays
 }

# Create the hash table for ResourceGroupParameters
# Hash table for "-ResourceGroupParameter" values
$bpRGParameters = @{ResourceGroup=@{location=$AzureLocation}}

$version =(Get-Date -Format "yyyyMMddHHmmss").ToString()
$BlueprintAssignmentName = $BlueprintName + '_' + $version

# Create the new blueprint assignment
$BlueprintParams = @{
    Name                        = $BlueprintAssignmentName
    Blueprint                   = $BlueprintDefinition
    SubscriptionId              = $AzureSubscriptionID
    Location                    = $AzureLocation
    UserAssignedIdentity        = $UserAssignedIdentityId
    Parameter                   = $bpParameters
    ResourceGroupParameter      = $bpRGParameters
}
$BlueprintAssignment = New-AzBlueprintAssignment @BlueprintParams

Write-Output $BlueprintAssignment
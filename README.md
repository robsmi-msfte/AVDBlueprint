# Instructions for customizing and deploying Azure Virtual Desktop to your environment, utilizing Azure Blueprints  

## Overview

[Azure Blueprints](https://docs.microsoft.com/en-us/azure/governance/blueprints/overview) provide a structured approach to standing up new environments, while adhering to environment requirements.  Microsoft has created a set of Azure Virtual Desktop (AVD) Blueprint objects that help automate the creation of an entire environment, ready to run.  
Azure Blueprints utilize ["artifacts"](https://docs.microsoft.com/en-us/azure/governance/blueprints/overview#blueprint-definition), such as:

* Role Assignments
* Policy Assignments
* Azure Resource Manager (ARM) templates
* Resource Groups

The AVD Blueprints are meant to deploy an entire environment, including Azure Active Directory Domain Services (AAD DS), a management virtual machine (VM), networking, AVD infrastructure, and related resources, in a turn-key fashion.   The following is a guide to help accomplish customizing to your environment.  

## Getting Started with the AVD Blueprint

* **Download Blueprint files locally** to a folder on your device.  
* **Extract the downloaded .zip file** to any folder on your device (Example. 'C:\AVDBlueprint')  

> [!NOTE]
> If you extract the files to a folder other than **'C:\AVDBlueprint'**, edit the file **'\Examples and Samples\AVDBPParameters.json'** to be equal to the path where the files are extracted to.  Example:  
`"BlueprintPath": "D:\\Downloads\\AVDBlueprint\\Blueprint",`

* **Edit the included sample file 'AVDBPParameters.json** to customize to your environment. There are several required values that need to be edited:

    `"AzureSubscriptionID": "",`  
    `"AzureTenantID": "",`  
    `"AzureCloudInstance": "",`  
    `"AADDSDomainName": "",`  
    `"aadds_emailNotifications": "",`  

    **Example:**  

    `"AzureSubscriptionID": "00000000-0000-0000-0000-000000000000",`  
    `"AzureTenantID": "00000000-0000-0000-0000-000000000000",`  
    `"AzureCloudInstance": "AzureCloud",`  
    `"AADDSDomainName": "avd.contoso.com",`  
    `"aadds_emailNotifications": "avdadmin@contoso.com",`  

    The remaining parameter values can be used as they are, or you can customize to suit your environment.  The values most likely to be modified first, are in the second "paragraph" of the file 'AVDBPParameters.json'.  In this section you can change the OS version to be deployed, you can change the AVD Azure VM size, number of VMs to create, and more.  Please note that as this file is in JSON format, some formatting rules must be followed:  

      - String values (text) must be surrounded by quotation marks
      - Integer values (numbers) must NOT be surrounded by quotation marks
      - Boolean values (True/False) must NOT be surrounded by quotation marks

* **Once parameters file editing is complete, save and close the file 'AVDBPParameters.json'**.

* **Start your preferred PowerShell tool (PowerShell, PowerShell ISE, etc) *elevated (Run As Administrator)***

* **Set the PowerShell 'Execution Policy', temporarily, to "Remote Signed" for scope "current user"**  by running the following command:

    `Set-ExecutionPolicy -ExecutionPolicy Remote-Signed -Scope CurrentUser

* **When ready, open and run, or just run the PowerShell script 'AssignAVDBlueprint.json** If you are running on a device that does not have some of the required PowerShell modules, such as AzureAD, Identity, etc., you may be prompted to install those from the [PowerShell Gallery](https://docs.microsoft.com/en-us/powershell/scripting/gallery/overview?view=powershell-7.1).  The PowerShell Gallery a community effort, hosting content from Microsoft, as well as the PowerShell community.

### More information about required and optional parameters

Azure Virtual Desktop can be customized in a wide variety of ways. The purpose of this Blueprint is to provide a framework for repeatable and consistent AVD deployments.  The following table lists some of choices for customization available.  If a parameter is listed below as "not required (No), then that value has a default in the Blueprint itself, or has a value defined in the included parameter file.

| Parameter | Type | Value | Required |
|-|-|-|-|  
|AzureSubscriptionID|string|The 'Subscription ID' obtained from Azure Portal or other tools for the destination deployment|Yes|
|AzureTenantID|string|The 'Tenant ID' obtained from Azure Portal or other tools for the destination deployment|Yes|
|AzureCloudInstance|string|'AzureCloud'<br/>'AzureUSGovernment'|Yes|
|AADDSDomainName|string|the name of the AAD DS domain to be created|Yes|
|aadds_emailNotifications|string|e-mail address to send messages regarding AAD DS issues|Yes|
|avdHostPool_vmGalleryImageSKU|string|'19h2-evd-o365pp'<br/>'19h2-evd-o365pp-g2''<br/>'20h1-evd-o365pp'<br/>'20h1-evd-o365pp-g2'<br/>''20h2-evd-o365pp'<br/>'20h2-evd-o365pp-g2'<br/>**'21h1-evd-o365pp'**<br/>'21h1-evd-o365pp-g2'<br/>'19h2-evd'<br/>'19h2-evd-g2'<br/>'20h1-evd'<br/>'20h1-evd-g2'<br/>'20h2-evd'<br/>'20h2-evd-g2'<br/>'21h1-evd'<br/>'21h1-evd-g2'|No (default currently 21H1 with M365)
|avdHostPool_vmSize|string|[Azure virtual machine size of your choice](https://docs.microsoft.com/en-us/azure/virtual-machines/sizes?WT.mc_id=Portal-fx)|No (default is 'Standard_B4ms')
|avdHostPool_vmNumberOfInstances|integer|number of AVD VMs to be created by this blueprint|No|
|avdHostPool_maxSessionLimit|integer|The maximum number of simultaneous sessions allowed per session host in a host pool|No|
|avdUsers_userCount|integer|number of test users to be created in AAD DS by this blueprint|No|
|BlueprintResourcePrefix|string|The prefix that most objects created by this blueprint will be given|No|
|BlueprintGlobalResourceGroupName|string|the resource group that contains the user-assigned managed identity and is most often not the same as the deployment resource group|No|
|UserAssignedIdentityName|string|the name of the user-assigned managed identity utilized by this blueprint|No|
|BlueprintName|string|the name of this blueprint, as it appears in the Azure portal|No|
|BlueprintPath|string|the local folder where 'Blueprint.json' can be found|No|
|BlueprintParameterFilePath|string|the name of the parameter file 'AVDBPParameters.json'|No|

## Prerequisites

* **An [Azure tenant](https://docs.microsoft.com/en-us/microsoft-365/education/deploy/intro-azure-active-directory#what-is-an-azure-ad-tenant)**. Though you can create a long tenant domain name prefix, you cannot in AAD DS.  Therefore it is recommended to have your domain name prefix 15 characters or less.  
If you don't already have a tenant for this deployment, here are some instructions on [setting up an Azure tenant](https://docs.microsoft.com/en-us/azure/active-directory/develop/quickstart-create-new-tenant).

> [!IMPORTANT]
> It is not currently possible to create a managed domain name with a prefix that exceeds 15 characters.  More information can be found on this topic, in this article:  
<https://docs.microsoft.com/en-us/azure/active-directory-domain-services/tutorial-create-instance>

* **An [Azure subscription](https://azure.microsoft.com/en-us/free/) with sufficient credits to deploy the environment, and keep it running at the desired levels**  
If you do not already have an Azure subscription, or wish to create a new Azure subscription, here is documentation on [creating an additional Azure subscription](https://docs.microsoft.com/en-us/azure/cost-management-billing/manage/create-subscription).

* **An [Azure Global Administrator](https://docs.microsoft.com/en-us/azure/active-directory/roles/permissions-reference) account**  
  * An Azure account with Azure Active Directory Global administrator role assigned.
  * This same Azure account needs the **'Owner' role** assigned at the Azure subscription level.

* **An [Azure Managed Identity](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview)**  
The Azure Managed Identity exists within Azure and can securely store and retrieve credentials from Azure Key Vault during the deployment.  This AVD Blueprint utilizes type 'User Assigned Managed Identity'.  The instructions for creating a managed identity are here: **[Create a user-assigned managed identity](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/how-to-manage-ua-identity-portal#create-a-user-assigned-managed-identity)**

> [!TIP]
> The managed identity is something that you can use for any number of Blueprint assignments. When you create the managed identity, you will have to specify a resource group. (Ex. '**AVD_Blueprint_Global_RG**'). This resource group can persist as long as you are performing Blueprint assignments.  That way you don't have to go through the process of creating a managed identity each time...just reuse the existing managed identity.

> [!NOTE]
> In the case of deploying to an otherwise empty subscription, the level of assignment for the managed identity will need to be the Azure subscription.  The AVD Blueprint, by default, creates objects at the subscription level during the blueprint deployment such as Azure AD DS.

* **Managed identity assigned the Owner role at the subscription level**  
The reason is that the managed identity needs full access during the deployment, for example to initiate the creation of an instance of Azure AD DS.  

    **MORE INFO:** [Add or change Azure subscription administrators](https://docs.microsoft.com/en-us/azure/cost-management-billing/manage/add-change-subscription-administrator)

* **Managed identity assigned the "Global Administrator" role in Azure Active Director**  
The managed identity account will be creating objects in Azure Active Directory during the Blueprint assignment, as well as domain join operations during the deployment.  Instructions on how to add a role to a user (including user assigned managed identities) can be found [here](https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-users-assign-role-azure-portal).

* **Azure Blueprint resource provider registered to your subscription** through Azure PowerShell with this PowerShell command:  

    ```powershell
    Register-AzResourceProvider -ProviderNamespace Microsoft.Blueprint
    ```

    You should receive this output from the Register-AzResourceProvider command:  

    ```powershell
    ProviderNamespace   Microsoft.Blueprint
    RegistrationState : Registering
    ResourceTypes     : {blueprints, blueprints/artifacts, blueprints/versions, blueprints/versions/artifacts…}
    Locations         : {}
    ```

* **Azure Active Directory provider registered to your subscription** (if not already registered):  
Check the current provider registration status in your subscription:  

    ```powershell
    Get-AzResourceProvider -ListAvailable | Select-Object ProviderNamespace, RegistrationState
    ```

    If necessary, register the Azure AD resource provider:

    ```PowerShell
    Register-AzResourceProvider -ProviderNamespace Microsoft.AAD
    ```

* **Azure Active Directory Domain Services Enterprise application registered to your subscription**

    Documentation: [Create an Azure Active Directory Domain Services managed domain using an Azure Resource Manager template](https://docs.microsoft.com/en-us/azure/active-directory-domain-services/template-create-instance)

    Run the following PowerShell command:

    ```PowerShell
    New-AzureADServicePrincipal -AppId "6ba9a5d4-8456-4118-b521-9c5ca10cdf84"
    ```

* **[Domain Controller Services service principal](https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal)** (if it does not already exist), with this PowerShell command

    ```PowerShell
    New-AzureADServicePrincipal -AppId "2565bd9d-da50-47d4-8b85-4c97f669dc36"
    ```  

> [!NOTE]
> Any roles assigned to the user assigned managed identity can safely be removed after the blueprint assignment has completed.  The only downside is that if subsequent blueprint assignments are needed, those roles would need to be granted to the user assigned managed identity again.

* **The Blueprint main file (Blueprint.json), and related artifact objects**  
These objects are publicly available on Github.com. Once the Blueprint objects have been acquired, they need to be customized to each respective environment.

## Managing and Assigning/Deploying the AVD Blueprint

> [!NOTE]
> The following sub-sections are example methods available to assign the AVD Blueprint.  There are sample assignment files in the Github repository in the 'Examples & Samples' folder.

### Manage and Deploy the AVD Blueprint using a local repository of Blueprint files and customized files to import and assign using PowerShell (Windows device)

This method performs all activities on the local machine.  This example uses Visual Studio Code as the tool to edit, save, connect to Azure, and deploy.  Several extensions make working with ARM templates a little easier:

* Install Visual Studio Code (the following extensions are recommended):
  * GitLens--Git supercharged
  * PowerShell
  * Azure CLI Tools
  * Azure Resource Manager (ARM) Tools

* Go the [AVD Blueprint Github repository main folder](https://github.com/Azure/AVDBlueprint) in your favorite web browser

* Click or tap the down arrow on the green button called **'Code'**, then tap or click the option 'Download Zip'.

    ![Image for Github Download Zip option](./images/GitDownloadZip2.png)

* Once the .zip file is downloaded to your local device, you can expand the contents to any location of your choosing, by double-clicking the downloaded .zip file, and then copying the main folder within the zip to any location.
The example files in this repository use this path:

    > C:\VSCode\AVDBlueprint  
    > C:\VSCode\AVDBlueprint\Blueprint  
    > C:\VSCode\AVDBlueprint\Blueprint\Artifacts  
    > C:\VSCode\AVDBlueprint\Blueprint\Examples and Samples  
    > C:\VSCode\AVDBlueprint\Blueprint\images  
    > C:\VSCode\AVDBlueprint\Blueprint\scripts  
    > C:\VSCode\AVDBlueprint_CustomizedFiles <-- This folder at same level of Blueprint repository in case you want to delete and unzip new or Git clone.

  > [!TIP]
  > If you use the folder structure above, copy the files from folder **'Examples and Scripts'** to the folder **'AVDBlueprint_CustomizedFiles'**.  Then customize your files so you won't have to customize them again, or at least maybe not all the way from scratch.

* Customize the following files from the **'Examples and Samples'** folder.

  1. Create a folder, for example 'C:\VSCode\AVDBlueprint_CustomizedFiles'.
  1. Copy the files from 'C:\VSCode\AVDBlueprint\Blueprint\Examples and Samples' to 'C:\VSCode\AVDBlueprint_CustomizedFiles'
  1. Edit the file **'run.config.json'**
      1. Change the **'TenantID'** value to your [Azure Tenant ID](https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-how-to-find-tenant)
      1. Change the **'subscriptionID'** value to your [Azure Subscription ID](https://docs.microsoft.com/en-us/azure/media-services/latest/setup-azure-subscription-how-to?tabs=portal)
      1. If desired, change the **'blueprintName'** value (you can use the sample name)
      1. If desired, change the **'blueprintPath'** path value (you can use the sample directory names and structure)
      1. If desired, change the **'assignmentFile'** path value (you can use the sample directory names and structure)
  1. Edit the file **'import-bp.json'** to point to file *'run.config.json'*.
      1. If you are using the sample folder structure, this file does not need to be edited.
      1. If you are using a folder structure with different paths and names, edit line 1 argument, so the path resolves to the file 'run.config.json'.
  1. Edit the file **'assign-bp.json'** to point to file *'run.config.json'*.
      1. If you are using the sample folder structure, this file does not need to be edited.
      1. If you are using a folder structure with different paths and names, edit line 1 argument, so the path resolves to the file 'run.config.json'.
  1. Edit the file **'assign_default.json'**
      1. Change the two **'Location'** parameters to point to the Azure location you are deploying to.  You can log in to your Azure tenant using PowerShell, or Azure Cloud Shell, and run the command **'Get-AzLocation | ft location'**.
      1. Change the parameter value **'userAssignedIdentities'** to the path to your user-assigned managed identity.  The easiest way to get this value is the following:
          1. In the Azure portal, start typing 'Managed Identities', and in the results list, click **'Managed Identities'**
          1. Click the name of your managed identity
          1. In the **'Settings'** section/blade, click **'Properties'**
          1. Copy the value of **'Resource ID'**, then paste that into the **'userAssignedIdentities'** parameter value
      1. In the **'Properties'** section of the 'assign_default.json':
          1. Edit the value of the **'BlueprintID'**, and replace the sample Azure subscription ID (between the second and third '/' characters from the left) with your subscription ID.
          1. Edit the value of the **'scope'**, and replace the sample Azure subscription ID  (between the second and third '/' characters from the left) with your subscription ID.
      1. The following parameter values are in the  **'Parameters'** section of the **'assign_default.json'**
          1. The following parameter values are ***required*** to be changed, to your Azure environment values.
              1. **'ADDS_domainName'**: The name of the Azure Active Directory Directory Services instance that will be created and synced to your Azure AD tenant.
              1. **'aadds_emailNotifications'**: Not currently implemented, but should be changed to a local admin e-mail account.
              1. **'script_executionUserResourceID'**: ARM path to the managed identity by name.  Get this in the Azure portal, Managed Identities, Identity, Properties, **'Resource ID'**.
              1. **'scriptExecutionUserObjectID'**: The GUID/object ID of the Azure global administrator account used to initiate the Blueprint assignment.  You can get this in Azure AD, Users, username, then **'Object ID'** (under Identities)
              1. **'keyvault_ownerUserObjectID'**: The GUID/object ID of the managed identity used during the Blueprint assignment.  You can get this in Azure Portal, Managed Identities, click identity name, the copy the 'Object ID' in the 'Essentials' section.
          1. The following parameter values are not required, though you may want to edit some of the default values to your environment and/or requirements.
              1. **'scriptURI'**: You can leave this to the current default, or if you fork the main repository to a new repository and wish to use that URI, you can.
              1. **'AzureEnvironmentName'**: The current default is 'Azure Cloud' (Azure Commercial).  You can change this value in case you are deploying to *Azure Gov*.
              1. **'AzureStorageFQDN'**: The current default is 'Azure Cloud' (Azure Commercial).  You can change this value in case you are deploying to *Azure Gov*.
              1. **'avdHostPool_vmGalleryImageSKU'**: The version of Windows 10 EVD being deployed.  The 'Allowed Values' list are other available Windows versions from the Azure Gallery.
              1. **'avdHostPool_vmSize'**: The Azure VM size.  You can change this value to any AVD supported VM size in the region you are assigning/deploying to.
              1. **'avdHostPool_vmNumberOfInstances'**: The number of EVD VMs that this Blueprint assignment will create.
              1. **'avdHostPool_maxSessionLimit'**: The maximum number of users that can log in to a Windows EVD session host, in the host pool created by this Blueprint assignment.
              1. **'avdUsers_userCount'**: The number of test users created by this Blueprint assignment.
              1. **'vvnetEnableDdosProtection'**: Controls whether this Blueprint creates an [Azure DDoS plan](https://docs.microsoft.com/en-us/azure/ddos-protection/ddos-protection-overview) or not.
  1. Open a PowerShell prompt and connect to your Azure subscription, using **'Connect-AzAccount'**
  1. **Change directory** to where you have your customized import and assignment files (import-bp.ps1 and assign-bp.ps1).
  1. To import and publish the Blueprint to your subscription, run the PowerShell file **'import-bp.ps1'**.
  1. To assign, and thus start the Blueprint deployment in your subscription, run the PowerShell file **'assign-bp.ps1'**

## Deconstruction

If an environment built by this blueprint is no longer needed, a script is provided in the **'Examples and Samples'** folder that can deconstruct a Blueprint assignment initiated by this Blueprint.  In addition, this script can export logs found in an AVD Blueprint deployment's Log Analytics Workspace to a csv file stored in the directory specified at runtime.  And a capability to purge a previous key vault has been added (**-PurgeKeyVault**), so that a previously deleted key vault won't conflict with an attempt to create a new key vault of the same name.

The script finds and removes the following items that were previously deployed via AVD Blueprint:

* All SessionHosts and HostPools in a ResourceGroup based on resource prefix
* All users discovered in 'AVD Users' group
* 'AVD Users' group itself
* 'AAD DC Admins' group
* All VMs created by the previous Blueprint assignment
* All VM collateral including Availability Set
* Previous instance of Azure AD DS
* (optionally) delete AND purge the previous key vault. By default the key vault is "soft deleted", which is the behavior if running this script without the '-PurgeKeyVault' switch.
* Everything else in the Resource Group
* Finally, the resource group itself

Use of `-verbose`, `-whatif` or `-confirm` ARE supported. Also, the script will create one Powershell Job for each Resource Group being removed. Teardowns typically take quite some time, so this will allow you to return to prompt and keep working while the job runs in the background.  

**Example:**

```powershell
#Exports logs of a AVD Blueprint deployment that used the prefix "ABC" followed by a removal:
.\Remove-AzAvdBpDeployment.ps1 -Verbose -Prefix "ABC" -LogPath "C:\projects"

#Use help for more details or examples:  
help .\Remove-AzAvdBpDeployment.ps1
```

## Tips

### **Deploying AVD Blueprint to Sovereign Clouds**

If you are deploying to AzureUSGovernment, and using an assignment file, you can now change several values in the assignment file and then utilize this Blueprint without having to edit the Blueprint files or Blueprint scripts.

1. Edit the file **'run.config.json'**, changing the **'SubscriptionID'** and **'TenantID'** to the new cloud being deployed to
1. Edit the assignment file **"assign_default.json"**
    1. Change **Location** values at the top and bottom of the assignment file to the new location being deployed to (ex. **'usgovarizona'**)
    1. Change the parameter **'AzureEnvironmentName'** value to 'AzureUSGovernment'
    1. Change the parameter **'AzureStorageFQDN'** value to 'file.core.usgovcloudapi.net'
1. Open a PowerShell console:
    1. Change directory to your customized files
    1. Connect to your account using PowerShell **'Connect-AzAccount -Environment AzureUSGovernment'**
1. If you have not yet imported the Blueprint to the new cloud, run the **'import-bp.ps1'** script
1. Assign the Blueprint with your customized **"assign_default.json"**.

> [!TIP]
> If you plan to deploy in both Azure Commercial and AzureGov, it might be easier to create two folders for your customized files (import-bp.ps1, assign-bp.ps1, run.config.json, and assign_default.json).  Example:  
>
> * C:\VSCode\CustomizedFiles\AzCloud
> * C:\VSCode\CustomizedFiles\AzGov  
>
> You change a few values in your "run.config.json" file (SubID, TenantID, path) and you can easily pivot from one cloud to the other.  
> The path to the Blueprint files themselves can be the same in both sets of files, if you choose this method.

### **Pre-existing Active Directory**

If there is already an active Active Directory environment in the target environment, it is possible to have this blueprint integrate with that rather than deploy a new one. Two actions need to be taken to support this:

1. Delete the adds.json artifact from the Artifacts folder
2. Remove all "adds" entries from the "dependsOn" section of the following artifacts:
    * addsDAUser.json
    * avdDeploy.json
    * DNSsharedSvcs.json
    * mgmtvm.json

### **Group Policy Settings**

Regarding Group Policy settings that are applied to the AVD session host computers, during the Blueprint deployment. There are two
sections of Group Policy settings applied to the AVD session hosts:  

* **FSLogix settings**
* **Remote Desktop Session Host redirection settings**  

#### FSLogix Settings

The FSLogix Windows policy settings are the mechanism used to enable the FSLogix profile management solution.  This Blueprint currently utilizes Azure Files as the FSLogix profile container storage location.  These settings are documented in [this article](https://docs.microsoft.com/en-us/fslogix/configure-profile-container-tutorial).

During Blueprint deployment, some of the parameters are evaluated and used to create a variable for the FSLogix profile share UNC path, as it exits in each unique deployment.  The parameter is then written to a new Group Policy Object that is applied to the Active Directory Organizational Unit that is created by the script run from the management VM, for the AVD session host VMs.  Here is the complete list of FSLogix settings applied by this Blueprint:

> VHDLocation == {unique UNC path for each deployment}  
> Enabled == Yes  
> DeleteLocalProfileWhenVHDShouldApply == Enabled  
> FlipFlopProfileDirectoryName == Enabled  

#### Remote Desktop Session Host redirection settings

This Blueprint adds as a default, one RDP redirection setting:

> "fEnableTimeZoneRedirection"  

There are several Windows policy settings that control certain aspects of the user experience while connected to a session host. The **"Remote Desktop Session Host redirection"** settings are set in the script,  **'CreateAADDSFileShare_ConfigureGP.ps1'**.  This script is run from the "management VM" in the "MGMTVM" artifact.  If you wish to add additional redirection settings, the best way may be through current or planned management methods such as Group Policy.

### **Development Tools**

[Visual Studio Code](https://code.visualstudio.com/) is a Microsoft provided suite available for editing, importing, and assigning the Blueprints. If using VS Code, the following extensions will greatly assist the efforts:|

* Azure Resource Manager Tools  
* XML Formatter  
* PowerShell extension (so that all work can be performed within one tool)  

There may be other extensions available that perform the same or similar functionality.

### **Accessing the Blueprint files and scripts**

In most cases you don't have to change anything to access the current Blueprint files, and scripts used during Blueprint runtime, so long as there is Internet connection available from your Azure subscription.  You can use the main public Github script URI for access to the Blueprint script files.  The reason for this is that the Blueprint core files (Blueprint.json and artifact files) are all uploaded to Azure by the import process, and are thus available within Azure throughout runtime.

The AVD Blueprint in its current form, has several external dependencies during runtime.

* PowerShell scripts to perform various tasks such as create users, add users to AD group, create an OU, create a GPO, and more
* A GPO backup contained in a .zip file, which restores a startup script to the newly created GPO startup scripts.  This is the current method that the AVD session host computers are able to run the Virtual Desktop Optimization toolkit
* The Virtual Desktop Optimization tool which is available publicly at <https://github.com/The-Virtual-Desktop-Team/Virtual-Desktop-Optimization-Tool>

### Deployment Considerations

* **Resource Prefix naming considerations**  
The value assigned for "Resource Prefix" will be used when naming many objects created by the blueprint.  Therefore, you may want to keep that prefix as short as possible.  Something like "AVD001" for example.
One reason for this is in case you need to deconstruct one installation, then run another.  If a previously created key vault exists in any form (normal or "soft delete"), and has the same name as the new resource prefix, then the Blueprint will fail at that point, not being able to create a new key vault.
To prevent this name collision with key vault, use the "PurgeKeyVault" switch with the "Teardown" script **"Remove-AzAvdBpDeployment.ps1"**.  In nearly all cases, this script will delete AND purge the previous key vault created by this Blueprint.

* **Create a separate Resource Group for your permanent Blueprint resources**
During the Blueprint deployment process, you will be creating some resources that you may want to retain after the blueprint has been deployed.
Depending on various factors, you may create a managed identity, a storage blob, etc. To that end, you could create a resource group, and in that resource group you only create items that are related to your Blueprint work. Another reason for this is that you can build and deconstruct a Blueprint, over and over, yet retain some of the core objects necessary, which will save time and effort.  

    Example: AVDBlueprint-RG

## Recommended Reading

1) [Azure Blueprints](<https://docs.microsoft.com/en-us/azure/governance/blueprints/overview>)
2) [Azure Virtual Desktop](<https://docs.microsoft.com/en-us/azure/virtual-desktop/>)
3) [Import the Blueprint](<https://docs.microsoft.com/en-us/azure/governance/blueprints/how-to/import-export-ps>)
4) [Publish the Blueprint](<https://docs.microsoft.com/en-us/azure/governance/blueprints/create-blueprint-portal>)
5) [Assign the Blueprint](<https://docs.microsoft.com/en-us/azure/governance/blueprints/create-blueprint-portal>)

## Change List

* Added a folder called **'Examples and Samples'**. Recent updates to the AVD Blueprint mean that the Blueprint files themselves, no longer need any manual edits. And you can use the same Blueprint files for Azure Commercial or Azure US Government.  For your unique values, such as SubscriptionID and so on, you can customize the included sample file **'run.config.json'**.

* Edited the two sample PowerShell scripts that perform the Import, Publish, and Assignment tasks.  The script named "assign-bp.ps1" performs the import and publish functions.  The file "assign-bp.ps1" performs the Blueprint assignment.  Of the remaining two files; "run.config.json" and "assign_default.json" samples, the "run.config.json" would most likely only be edited once, to include your unique values of TenantID, SubscriptionID, BlueprintPath, etc.  The remaining file "assign_default.json" is the only file you need edit afterward to customize the Blueprint experience.  There is a new section in the section of this Readme called **Manage the Blueprint using a local repository of Blueprint files and customized files to import and assign using PowerShell (Windows device)**.

* 08/10/2021: Streamlined Log Analytics by removing log collection for components not in use by this Blueprint.  Also, updated the API version for several resources with the Log Analytics artifact, for compatibility across several clouds.

* 08/10/2021: Updated the list of Azure VM sizes in the "AllowedValues" list in the "avdHostPool_vmGalleryImageSKU" parameter.  Based on what is available as of 08/18/21, from "19h2" to "21h1", with and without Office 365.

* 08/10/2021: Edited Blueprint parameter "AzureEnvironmentName" to included allowed values for AzureCloud and AzureUSGovernment.  The default value is AzureCloud.  You can override that value with an Assignment file.

* 08/10/2021: Edited Blueprint parameter "AzureStorageFQDN" to include the storage endpoints for both Azure Commercial and Azure Government.  The default value is Azure Commercial (file.core.windows.net)

* 08/24/2021: Changed Blueprint settings for Key Vault creation. Previously the settings were "Soft Delete" "true", and "Purge Protection" "enabled.  The change was to remove both of those settings, resulting in the current defaults being applied.  Purge protection can be enabled after the fact if desired.  But with purge protection enabled, and no way to change it, a soft deleted key vault name could collide with a new key vault name.

* 08/25/2021: Changed the script that creates AVD test users and assigns them to an 'AVD Users' AD group.

* 08/25/2021: Changed the method used to assign users to the AVD Application Group created by this Blueprint.  The new method is to assign the 'AVD Users' AD group to the AVD Application Group.

## Blueprint objects, purpose, and parameter documentation

### Blueprint Objects and Purpose

| Type | Object | Purpose |
|-|-|-|  
|Assignment file|assign_default.json|Hard-code and pass to the Blueprint, the environment specific items such as subscription, UserAssignedIdentity, etc.|  
|Blueprint file|Blueprint.json|The is the central file of an Azure Blueprint definition|
|Artifact|adds.json|directs the creation of Azure Active Directory Domain Services resources|
|Artifact|addsDAUser.json|directs the creation of domain administrator account|
|Artifact|DNSsharedsvcs.json|directs the creation of domain name services (DNS) resources|
|Artifact|keyvault.json|directs the creation of Azure Key Vault resources, used to store and retrieve credentials used at various points during the Blueprint assignment|
|Artifact|log-analytics.json|Sets up logging of various components to Azure storage|
|Artifact|MGMTVM.json|Sets up logging of various components to Azure storage|
|Artifact|net.json|Sets up networking and various subnets|
|Artifact|nsg.json|Sets up network security groups|
|Artifact|avdDeploy.json|Deploys AVD session hosts, created the AVD host pool and application group, and adds the session hosts to the application group|
|Artifact|avdTestUsers.json|Creates users in AAD DS, that are available to log in after the deployment is complete|

### Blueprint Parameters

Blueprint parameters, located in blueprint.json, allow to configure the deployment and customize the environment.

### Required Parameters

The blueprint includes the following required parameters.  

| Parameter | Example Value | Purpose |  
|-|-|-|  
|**adds_domainName**|avdbp.contoso.com|The domain name for the Azure ADDS domain that will be created|
|**script_executionUserResourceID**|Resource ID Path|Resource ID for the Managed Identity that will execute embedded deployment scripts.|
|**scriptExecutionUserObjectID**|xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx|Object ID for the Managed Identity that will execute embedded deployment scripts.|
|**keyvault_ownerUserObjectID**|xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx|Object ID of the user that will get access to the Key Vault. To retrieve this value go to Microsoft Azure Portal > Azure Active Directory > Users > (user) and copy the User’s Object ID.|

### Optional Parameters  

These optional parameters either have default values or, by default, do not have values. You can override them during the blueprint assignment process.  

| Parameter | Default Value | Purpose |
|-|-|-|
|**resourcePrefix**|AVD|A text string prefixed to the beginning of each resource name.|
|**aadds_emailNotifications**|avdbpadmin@contoso.com|An email account that will receive ADDS notifications|
|**scriptURI**|<https://raw.githubusercontent.com/Azure/AVDBlueprint/main/scripts>|URI where Powershell scripts executed by the blueprint are located.|
|**log-analytics_service-tier**|PerNode|Log Analytics Service tier: Free, Standalone, PerNode or PerGB2018.|
|**log-analytics_data-retention**|365|Number of days data will be retained.|
|**vnet_vnet-address-prefix**|10.0.0.0/16|Address prefix of the vNet created by the AVD Blueprint.|
|**vnetEnableDdosProtection**|true|Determines whether or not DDoS Protection is enabled in the Virtual Network.|
|**vnet_sharedsvcs-subnet-address-prefix**|10.0.0.0/24|Shared services subnet address prefix.|
|**vnet_adds-subnet-address-prefix**|10.0.6.0/24|Subnet for Azure ADDS.|
|**daUser_AdminUser**|domainadmin@{adds_domainName}|This account will be a member of AAD DC Administrators and local admin on deployed VMs.|
|**avdHostpool_hostpoolname**|{resourcePrefix}-avd-hp||
|**avdHostpool_workspaceName**|{resourcePrefix}-avd-ws||
|**avdHostpool_hostpoolDescription**|||
|**avdHostpool_vmNamePrefix**|{resourcePrefix}vm|Prefix added to each AVD session host name.|
|**avdHostpool_vmGalleryImageOffer**|office-365||
|**avdHostpool_vmGalleryImagePublisher**|MicrosoftWindowsDesktop||
|**avdHostpool_vmGalleryImageSKU**|21h1-evd-o365pp||
|**avdHostpool_vmImageType**|Gallery||
|**avdHostpool_vmDiskType**|StandardSSD_LRS||
|**avdHostpool_vmUseManagedDisks**|true||
|**avdHostpool_allApplicationGroupReferences**|||
|**avdHostpool_vmImageVhdUri**||(Required when vmImageType = CustomVHD) URI of the sysprepped image vhd file to be used to create the session host VMs.|
|**avdHostpool_vmCustomImageSourceId**||(Required when vmImageType = CustomImage) Resource ID of the image.|
|**avdHostpool_networkSecurityGroupId**||The resource id of an existing network security group.|
|**avdHostpool_personalDesktopAssignmentType**|||
|**avdHostpool_customRdpProperty**||Hostpool rdp properties.|
|**avdHostpool_deploymentId**|||
|**avdHostpool_ouPath**|||
|**avdUsers_userPrefix**|user|Username prefix. A number will be added to the end of this value.|
|**avdUsers_userCount**|10|Total Number of AVD users to create.|

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft trademarks or logos is subject to and must follow  [Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general) . Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship. Any use of third-party trademarks or logos are subject to those third-party's policies.

## Disclaimer

This Sample Code is provided for the purpose of illustration only and is not intended to be used in a production environment.
THIS SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE. We grant You a nonexclusive, royalty-free right to use and modify the Sample Code and to reproduce and distribute the object code form of the Sample Code, provided that You agree: (i) to not use Our name, logo, or trademarks to market Your software product in which the Sample Code is embedded; (ii) to include a valid copyright notice on Your software product in which the Sample Code is embedded; and (iii) to indemnify, hold harmless, and defend Us and Our suppliers from and against any claims or lawsuits, including attorneys’ fees, that arise or result from the use or distribution of the Sample Code.

Microsoft provides programming examples for illustration only, without warranty either expressed or implied, including, but not limited to, the implied warranties of merchantability and/or fitness for a particular purpose.

This sample assumes that you are familiar with the programming language being demonstrated and the tools used to create and debug procedures. Microsoft support professionals can help explain the functionality of a particular procedure, but they will not modify these examples to provide added functionality or construct procedures to meet your specific needs. if you have limited programming experience, you may want to contact a Microsoft Certified Partner or the Microsoft fee-based consulting line at (800) 936-5200

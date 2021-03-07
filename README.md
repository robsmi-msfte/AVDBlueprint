# Instructions for customizing Azure Windows Virtual Desktop to your environment, utilizing Azure Blueprints  

[Azure Blueprints](https://docs.microsoft.com/en-us/azure/governance/blueprints/overview) provide a structured approach to standing up new environments, while adhering to environment requirements.  Microsoft has created a set of Windows Virtual Desktop (WVD) Blueprint objects that help automate the creation of an entire environment, ready to run.  
  
Azure Blueprints utilize ["artifacts"](https://docs.microsoft.com/en-us/azure/governance/blueprints/overview#blueprint-definition), such as:

* Role Assignments
* Policy Assignments
* Azure Resource Manager (ARM) templates
* Resource Groups

The WVD Blueprints are meant to deploy an entire environment, including Azure Active Directory Domain Services (AAD DS), a management virtual machine (VM), networking, WVD infrastructure, and related resources, in a turn-key fashion.   The following is a guide to help accomplish customizing to your environment.

## Recommended Reading

1) [Azure Blueprints] (<https://docs.microsoft.com/en-us/azure/governance/blueprints/overview>)
2) [Windows Virtual Desktop] (<https://docs.microsoft.com/en-us/azure/virtual-desktop/>)

## Prerequisites

1. Two “identities” are required to successfully assign (deploy) the Azure WVD Blueprints:  
    * An [Azure Global Administrator](https://docs.microsoft.com/en-us/azure/active-directory/roles/permissions-reference).  
    > The Azure Global Administrator is a person that has complete permission to an Azure subscription. This is required because modifications will be made at the directory and subscription levels.

    * An [Azure Managed Identity](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview)  
    > The Azure Managed Identity exists within Azure and can securely store and retrieve credentials from Azure Key Vault during the deployment.  

2. An [Azure subscription](https://azure.microsoft.com/en-us/free/) with sufficient credits to deploy the environment, and keep it running at the desired levels.  

3. A development environment can be used to help work with the Blueprint code, as well as [“import”](https://docs.microsoft.com/en-us/azure/governance/blueprints/how-to/import-export-ps) and [“assign”](https://docs.microsoft.com/en-us/azure/governance/blueprints/how-to/manage-assignments-ps) the Blueprints.  
   PowerShell can be utilized with the [Az.Blueprint module](https://docs.microsoft.com/en-us/azure/governance/blueprints/how-to/manage-assignments-ps#add-the-azblueprint-module) for PowerShell.  

    If you've not used Azure Blueprints before, register the resource provider through Azure PowerShell with this PowerShell command:  

    `Register-AzResourceProvider -ProviderNamespace Microsoft.Blueprint`

4. Open an instance of PowerShell, connect to your Azure account, then register the Azure AD provider to your account (if not already registered):

    * `Connect-AzAccount`  
    * `Register-AzResourceProvider -ProviderNamespace Microsoft.AAD`

5. Create the Domain Controller Services service principal (if it does not already exist), with this PowerShell command

    `New-AzureADServicePrincipal -AppId "2565bd9d-da50-47d4-8b85-4c97f669dc36"`

    (more info on this topic) <https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal>

6. Create a user-assigned managed identity within Azure, which will later be used to execute the blueprint.  Note that in the case of “greenfield” deployments, the level of assignment will need to be the Azure subscription.  The Blueprint creates objects at the subscription level during the blueprint deployment.

    * Create an Azure security group (example: ‘Blueprint Operators’)  
    * Add the managed identity to the Azure security group created in the previous step  
    * Assign permissions to the group, to allow members to create objects at the subscription level  
    * At the subscription level, assign roles to the group previously created, by going to the following location in the Azure Portal  
       > **Azure Portal** -> **Home** -> **Subscriptions** -> (***your subscription***) -> **Access Control (IAM)**

7. Click **Add Role Assignments**, then add the following role assignments to the group you created earlier (step 6):

    * [Blueprint Contributor](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#blueprint-contributor)
    * [Blueprint Operator](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#blueprint-operator)
    * [Managed Identity Operator](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#managed-identity-operator)

8. The managed identity must be assigned the **Owner** role at the subscription level.  The reason is that the managed identity needs full access during the deployment, for example to initiate the creation of an instance of Azure AD DS.  

        **MORE INFO:** https://docs.microsoft.com/en-us/azure/cost-management-billing/manage/add-change-subscription-administrator  

9. Add the managed identity to the Global Administrators group in Azure AD.  The managed identity is going to be initiating the creation of users and virtual machines during the blueprint process.

        **MORE INFO:** https://docs.microsoft.com/en-us/azure/governance/blueprints/how-to/configure-for-blueprint-operator  

10. The Blueprint main file, and related artifact objects. These objects are publically available on Github.com. Once the Blueprint objects have been acquired, they need to be customized to each respective environment. The necessary customizations can be applied in a few different ways.

    * An "assignment" file can be customized with your Azure subscription, and related details. A sample assignment file (assign_default.json) is included with this Blueprint.
    * Code can be created to stand up an interface, that could be used to receive the specific information, and then pass that information to the Blueprint, as well as initiate the Blueprint assigment. The following table contains the environment specific information needed to assign (deploy) the Blueprint to each respective environment.  
    * Copy the assignment file to the 'Deploy/' folder, which has an entry in the .Gitignore file.  Files you customize in the 'Deploy' folder will not be included with subsequent pull requests.

| Type | Object | Purpose |
|-|-|-|  
|Assignment file|assign_default.json|Hard-code and pass to the Blueprint the environment specific items such as subscription, UserAssignedIdentity, etc.|  
|Blueprint file|Blueprint.json|The is the central file of an Azure Blueprint assignment|
|Artifact|adds.json|directs the creation of Azure Active Directory Domain Services resources|
|Artifact|addsDAUser.json|directs the creation of domain administrator account|
|Artifact|DNSsharedsvcs.json|directs the creation of domain name services (DNS) resources|
|Artifact|keyvault.json|directs the creation of Azure Key Vault resources, used to store and retrieve credentials used at various points during the Blueprint assignment|
|Artifact|log-analytics.json|Sets up logging of various components to Azure storage|
|Artifact|MGMTVM.json|Sets up logging of various components to Azure storage|
|Artifact|net.json|Sets up networking and various subnets|
|Artifact|nsg.json|Sets up network security groups|
|Artifact|wvdDeploy.json|Deploys WVD session hosts, created the WVD host pool and application group, and adds the session hosts to the application group|
|Artifact|wvdTestUsers.json|Creates users in AAD DS, that are available to log in after the deployment is complete|

## Customizing the Assignment (in preparation for deployment)

With the basic objects in place, a few updates will prepare the Blueprint for Assignment to your Azure subscription.  There are two objects that can be edited fairly easily to customize for each respective environment:

* assign_json
* run.config.json
* (optional) Blueprint.json

### Editing 'assign_default.json' file

The **'assign_default.json'** file is used to pass certain values to the Blueprint at assignment time, such as Azure subscription ID, managed identity name, and more. This file is in Javascript Notation (JSON) format, so is easily editable in a variety of methods.  
Some values will require a concatentation of values. The following are values that require a "path" value in Azure:

```json
userAssignedIdentities
```

> "/subscriptions/[**YOUR AZURE SUBSCRIPTION ID**]/resourceGroups/[**YOUR AZURE RESOURCE GROUP**]/providers/Microsoft.ManagedIdentity/userAssignedIdentities/[**YOUR MANAGED IDENTITY NAME]**"

```json
blueprintID
```

> "/subscriptions/[**YOUR AZURE SUBSCRIPTION ID**]/providers/Microsoft.Blueprint/blueprints/[**YOUR BLUEPRINT NAME**]"  

```json
scope
```

> "/subscriptions/[**YOUR AZURE SUBSCRIPTION ID**]"  

```json
script_executionUserResourceID
```

> "/subscriptions/[**YOUR AZURE SUBSCRIPTION ID**]/resourceGroups/[**YOUR AZURE RESOURCE GROUP**]/providers/Microsoft.ManagedIdentity/userAssignedIdentities/[**YOUR MANAGED IDENTITY NAME]"  

The following values are needed to customize the **'assign_default.json'** file to respective environments:  

| Parameter | Value | Purpose |
|-|-|-|  
|**Location**|ex. '**eastus**'|The Azure region the assignment will be created in|  
|**userAssignedIdentities**|ex. '**UAI1**'|The name, in path format, of the managed identity created from the prerequisite steps earlier|
|**blueprintId**|ex. **'wvd_full'**|a name that you provide, that is the Blueprint name assigned in your subscription|
|**scope**|[**YOUR AZURE SUBSCRIPTION ID**]<br/>ex. **'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX'**|The ID of your Azure subscription|
|**resourcePrefix**|ex. **'WVD'**|a value you determine, which will be used to prefix the name of most objects created during Blueprint assignment.<br/>**NOTE:** This prefix will be used to name WVD session host computers, so should be kept as short as possible, due to the 15 character [name limitation for WVD session hosts in Azure WVD as of 2/2/2021](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules#microsoftcompute)|
|**aDDS_domainName**|ex. **'wvdbp.contoso.com'**|the name of your Azure Active Directory instance, this Blueprint will be assigned to|
|**ADDS_emailNotifications** (optional)|ex. **'wvdbpadmin@contoso.com'**|an optional account for e-mail notifications|
|**script_executionUserResourceID**|ex. **'UAI1'**|the name and path of your Azure Managed Identity|
|**script_executionUserObjectID**|[**AZURE AD USER OBJECT ID**]<br/>ex. **'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX'**|the 'Object ID' of the Azure Active Directory account that will be used to execute the Blueprint|
|**keyvault_ownerUserObjectID**|[**MANAGED IDENTITY OBJECT ID**]<br/>ex. **'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX'**|the object ID of your Azure Managed Identity|
|**Location**|ex. '**eastus**'|The geographic region that Azure Resoource Group will be created in|

### Editing 'run.config.json'

The file 'run.config.json' in the 'Scripts' folder, contains several values that are passed in to the Blueprint. The values must be edited to the specific values for your environment.

| Parameter | Value | Purpose |
|-|-|-|  
|**tenantID**|ex. **'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX'**|Your Azure AD 'Tenant ID' value|
|**subscriptionID**|ex. **'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX'**|Your Azure AD 'Subscription ID' value|  
|**blueprintPath**|ex. **C:\\Code\\WVDBP\\AZBluePrints-WVD\\Blueprint"**|The local folder on the device where the Blueprint objects are stored' value|  
|**assignmentFile**|ex. **C:\\Code\\WVDBP\\AZBluePrints-WVD\\Assignments\\assign_default.json"**|The local folder on the device where the Blueprint objects are stored' value|  

## Import, Publish and Assign the Blueprint

1. Import the Blueprint - <https://docs.microsoft.com/en-us/azure/governance/blueprints/how-to/import-export-ps>\
2. Publish the Blueprint - <https://docs.microsoft.com/en-us/azure/governance/blueprints/create-blueprint-portal>
3. Assign the Blueprint - <https://docs.microsoft.com/en-us/azure/governance/blueprints/create-blueprint-portal>

## Teardown

If an environment built by this blueprint is no longer needed, a script is provided in the Resources folder that will export logs found in a WVD Blueprint deployment's Log Analytics Workspace to a csv file stored in the directory specified at runtime.  

The script finds and removes the following items that were previously deployed via WVD Blueprint:

* All SessionHosts and HostPools in a ResourceGroup based on resource prefix
* All users discovered in 'WVD Users' group
* 'WVD Users' group itself
* 'AAD DC Admins' group

>[!NOTE]
Use of `-verbose`, `-whatif` or `-comfirm` ARE supported. Also, the script will create one Powershell Job for each Resource Group being removed. Teardowns typically take quite some time, so this will allow you to return to prompt and keep working while the job runs in the background.  

**Example:**

```powershell
#Exports logs of a WVD Blueprint deployment that used the prefix "ABC" followed by a removal:
.\Remove-AzWvdBpDeployment.ps1 -Verbose -Prefix "ABC" -LogPath "C:\projects"

#Use help for more details or examples:  
help .\Remove-AzWvdBpDeployment.ps1
```

## Tips

* [Visual Studio Code](https://code.visualstudio.com/) is a Microsoft provided suite available for editing, importing, and assigning the Blueprints. If using VS Code, the following extensions will greatly assist the efforts:|

  * Azure Resource Manager Tools  
  * XML Formatter  
  * PowerShell extension (so that all work can be performed within one tool)  

   There may be other extensions available that perform the same functionality

* To store scripts and any other objects needed during Blueprint assignment on Internet connected assigments, a publically web location can be used to store scripts and other objects needed during Blueprint assigment.  
[Azure Storage Blob](https://azure.microsoft.com/en-us/services/storage/blobs/) is one possible method to make the scripts and other objects available.
Whatever method chosed, the access method should be "public" and "anonymous" read-only access.

* If you need to delete a deployment with the intent of starting over with a new deployment, you will need to change the "Deployment Prefix" value in the "assign_default.json" file.
  This file is used to prefix most of the Azure resources created during the deployment, including an [Key Vault](https://azure.microsoft.com/en-us/services/key-vault/) object.
  Azure Key Vault is used to store and retrieve cryptogrphic keys used by cloud apps and services, and as such is treated with great care in Azure.
  When an Azure Key Vault is deleted, it transitions to a "soft delete" state for a period of time, before actually being deleted.
  While an Azure Key Vault is in soft delete state, another key vault cannot be created with the same name.  Therefore, if you do not change your
  Resource Prefix value for subsequent deployments, the subsequent deployments will fail with an error referencing Key Vault name.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft trademarks or logos is subject to and must follow  [Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general) . Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship. Any use of third-party trademarks or logos are subject to those third-party's policies.

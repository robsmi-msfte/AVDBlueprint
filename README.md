# Instructions for customizing Azure Windows Virtual Desktop to your environment, utilizing Azure Blueprints  

[Azure Blueprints](https://docs.microsoft.com/en-us/azure/governance/blueprints/overview) provide a structured approach to standing up new environments, while adhering to environment requirements.  Microsoft has created a set of Windows Virtual Desktop (WVD) Blueprint objects that help automate the creation of an entire environment, ready to run.  
  
Azure Blueprints utilize ["artifacts"](https://docs.microsoft.com/en-us/azure/governance/blueprints/overview#blueprint-definition), such as:

* Role Assignments
* Policy Assignments
* Azure Resource Manager (ARM) templates
* Resource Groups

The WVD Blueprints are meant to deploy an entire environment, including Azure Active Directory Domain Services (AAD DS), a management virtual machine (VM), networking, WVD infrastructure, and related resources, in a turn-key fashion.   The following is a guide to help accomplish customizing to your environment.  
## Prerequisites    
1.	Two “identities” are required to successfully deploy the Azure WVD Blueprints:  
    a).	An [Azure Global Administrator](https://docs.microsoft.com/en-us/azure/active-directory/roles/permissions-reference).  
    > The Azure Global Administrator is a person that has complete permission to an Azure subscription. This is required because modifications will be made at the directory and subscription levels.

    b).	An [Azure Managed Identity](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview)  
    > The Azure Managed Identity exists within Azure and can securely store and retrieve credentials from Azure Key Vault during the deployment.  

2.	An [Azure subscription](https://azure.microsoft.com/en-us/free/) with sufficient credits to deploy the environment, and keep it running at the desired levels.  

3.	A development environment can be used to help work with the Blueprint code, as well as [“import”](https://docs.microsoft.com/en-us/azure/governance/blueprints/how-to/import-export-ps) and [“assign”](https://docs.microsoft.com/en-us/azure/governance/blueprints/how-to/manage-assignments-ps) the Blueprints.  
   PowerShell can be utilized with the [Az.Blueprint module](https://docs.microsoft.com/en-us/azure/governance/blueprints/how-to/manage-assignments-ps#add-the-azblueprint-module) for PowerShell.  

    If you've not used Azure Blueprints before, register the resource provider through Azure PowerShell with this PowerShell command:  

    `Register-AzResourceProvider -ProviderNamespace Microsoft.Blueprint`

4.	Open an instance of PowerShell, connect to your Azure account, then register the Azure AD provider to your account (if not already registered):

    a).	`Connect-AzAccount`  
    b).	`Register-AzResourceProvider -ProviderNamespace Microsoft.AAD`

5.	Create the Domain Controller Services service principal (if it does not already exist), with this PowerShell command

    `New-AzureADServicePrincipal -AppId "2565bd9d-da50-47d4-8b85-4c97f669dc36"`

    (more info on this topic) https://docs.microsoft.com/en-us/azure/active-directory/develop/howto-create-service-principal-portal

6.	Create a user-assigned managed identity within Azure, which will later be used to execute the blueprint.  Note that in the case of “greenfield” deployments, the level of assignment will need to be the Azure subscription.  The Blueprint creates objects at the subscription level during the blueprint deployment.

    a) Create an Azure security group (example: ‘Blueprint Operators’)  
    b) Add the managed identity to the Azure security group created in the previous step  
    c) Assign permissions to the group, to allow members to create objects at the subscription level  
    d) At the subscription level, assign roles to the group previously created, by going to the following location in the Azure Portal  
       > **Azure Portal** -> **Home** -> **Subscriptions** -> (***your subscription***) -> **Access Control (IAM)**

7.	Click **Add Role Assignments**, then add the following role assignments to the group you created earlier in this step:

    a)	Blueprint Contributor  
    b)	Blueprint Operator  
    c)	Managed Identity Operator  
    d)	In addition, you have to grant the **Owner** role to the managed identity at the subscription level.  The reason is that the managed identity needs full access during the deployment, for example to initiate the creation of an instance of Azure AD DS.  

    **MORE INFO:** https://docs.microsoft.com/en-us/azure/cost-management-billing/manage/add-change-subscription-administrator  

    e)	Finally, add the managed identity to the Global Administrators group in Azure AD.  The managed identity is going to be initiating the creation of users and virtual machines during the blueprint process.

    MORE INFO: https://docs.microsoft.com/en-us/azure/governance/blueprints/how-to/configure-for-blueprint-operator  

8.  The Blueprint main file, and related artifact objects. These objects are publically available on Github.com. Once the Blueprint objects have been acquired, they need to be customized to each respective environment. The necessary customizations can be applied in a few different ways.

    - An "assignment" file can be customized with your Azure subscription, and related details.
    - Code can be created to stand up an interface, that could be used to receive the specific information, and then pass that information to the Blueprint, as well as initiate       the Blueprint assigment. The following table contains the environment specific information needed to assign (deploy) the Blueprint to each respective environment.  

    | Type | Object | Purpose |  
    |-|-|-|  
    |Assignment file|assign_default.json|Hard-code and pass to the Blueprint the environment specific items such as subscription, UserAssignedIdentity, etc. |  
    |Blueprint file|Blueprint.json|The is the central file of an Azure Blueprint assignment|
    |Artifact|adds.json|directs the creation of Azure Active Directory Domain Services resources|
    |Artifact|addsDAUser.json|directs the creation of domain administrator account|
    |Artifact|DNSsharedsvcs.json|directs the creation of domain name services (DNS) resources|
    |Artifact|keyvault.json|directs the creation of Azure Key Vault resources, used to store and retrieve credentials used at various points during the Blueprint assignment|
    |Artifact|log-analytics.json’|Sets up logging of various components to Azure storage|
    |Artifact|MGMTVM.json’|Sets up logging of various components to Azure storage|
    |Artifact|net.json’|Sets up networking and various subnets|
    |Artifact|nsg.json’|Sets up network security groups|

## Tips

- [Visual Studio Code](https://code.visualstudio.com/) is a Microsoft provided suite available for editing, importing, and assigning the Blueprints. If using VS Code, the following extensions will greatly assist the efforts:|
   
   - Azure Resource Manager Tools  
   - XML Formatter  
   - PowerShell extension (so that all work can be performed within one tool)  

   There may be other extensions available that perform the same functionality

- To store scripts and any other objects needed during Blueprint assignment on Internet connected assigments, a publically web location can be used to store scripts and other objects needed during Blueprint assigment.  
[Azure Storage Blob](https://azure.microsoft.com/en-us/services/storage/blobs/) is one possible method to make the scripts and other objects available.
Whatever method chosed, the access method should be "public" and "anonymous" read-only access.



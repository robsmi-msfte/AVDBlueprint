# Instructions for customizing Azure Windows Virtual Desktop to your environment, utilizing Azure Blueprints  

Azure Blueprints provide a structured approach to standing up new environments, while adhering to environment requirements.  Microsoft has created a set of Windows Virtual Desktop (WVD) Blueprint objects that help automate the creation of an entire environment, ready to run.  
The WVD Blueprints are meant to deploy an entire environment, including Azure Active Directory Domain Services (AAD DS), a management virtual machine (VM), networking, WVD infrastructure, and related resources, in a turn-key fashion.   The following is a guide to help accomplish customizing to your environment.  
## Prerequisites    
1.	Two “identities” are required to successfully deploy the Azure WVD Blueprints:  
    a).	An [Azure Global Administrator](https://docs.microsoft.com/en-us/azure/active-directory/roles/permissions-reference).  
    > The Azure Global Administrator is a person that has complete permission to an Azure subscription. This is required because modifications will be made at the directory and subscription levels.

    b).	An [Azure Managed Identity](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview)  
    > The Azure Managed Identity exists within Azure and can securely store and retrieve credentials from Azure Key Vault during the deployment.  
2.	An [Azure subscription](https://azure.microsoft.com/en-us/free/) with sufficient credits to deploy the environment, and keep it running at the desired levels.  
3.	A develop environment can be used to help work with the Blueprint code, as well as [“import”](https://docs.microsoft.com/en-us/azure/governance/blueprints/how-to/import-export-ps) and [“assign”](https://docs.microsoft.com/en-us/azure/governance/blueprints/how-to/manage-assignments-ps) the Blueprints.  
    a).	PowerShell with the [Az.Blueprint module](https://docs.microsoft.com/en-us/azure/governance/blueprints/how-to/manage-assignments-ps#add-the-azblueprint-module) for PowerShell  
    > If you've not used Azure Blueprints before, register the resource provider through Azure PowerShell with this PowerShell command:  
    `Register-AzResourceProvider -ProviderNamespace Microsoft.Blueprint`

    b). [Visual Studio Code](https://code.visualstudio.com/) is a Microsoft provided suite available for editing, importing, and assigning the Blueprints.  If using VS Code, the following extensions will greatly assist the efforts:

        i) Azure Resource Manager Tools  
        ii) XML Formatter  
        iii) PowerShell extension (so that all work can be performed within one tool)

        There may be other extensions available that perform the same functionality  

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

    **MORE INFO:** https://docs.microsoft.com/en-us/azure/governance/blueprints/how-to/configure-for-blueprint-operator  

8.	Lastly, an [Azure Storage Blob](https://azure.microsoft.com/en-us/services/storage/blobs/) needs to be created with anonymous access permissions granted.  This will be the network location containing scripts and other objects needed during the blueprint deployment.


Quickest way to currently deploy everything:

1) Update Utils\Import-bp.ps1 to match your tenant values.
2) Execute Import-bp.ps1
3) Edit assignments\assign_default.json to match your environment
4) Execute assign-bp.ps1

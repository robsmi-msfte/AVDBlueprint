# Instructions for customizing and deploying Azure Virtual Desktop to your environment, utilizing Azure Blueprints

## Prerequisites

* **An [Azure tenant](https://docs.microsoft.com/en-us/microsoft-365/education/deploy/intro-azure-active-directory#what-is-an-azure-ad-tenant)**. Though you can create a long tenant domain name prefix, you cannot in AAD DS.  Therefore it is recommended to have your domain name prefix 15 characters or less.  

> [!IMPORTANT]
> It is not currently possible to create a managed domain name with a prefix that exceeds 15 characters.  More information can be found on this topic, in this article:  
<https://docs.microsoft.com/en-us/azure/active-directory-domain-services/tutorial-create-instance>

* **An [Azure subscription](https://azure.microsoft.com/en-us/free/) with sufficient credits to deploy the environment, and keep it running at the desired levels**

* **An [Azure Global Administrator](https://docs.microsoft.com/en-us/azure/active-directory/roles/permissions-reference) account**  
  * An Azure account with Azure Active Directory Global administrator role assigned.
  * This same Azure account needs the **'Owner' role** assigned at the Azure subscription level.

* **An [Azure Managed Identity](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview)**  
The Azure Managed Identity exists within Azure and can securely store and retrieve credentials from Azure Key Vault during the deployment.  This AVD Blueprint utilizes type 'User Assigned Managed Identity'.  The instructions for creating a managed identity are here: **[Create a user-assigned managed identity](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/how-to-manage-ua-identity-portal#create-a-user-assigned-managed-identity)**

> [!NOTE]
> In the case of deploying to an otherwise empty subscription, the level of assignment will need to be the Azure subscription.  The AVD Blueprint, by default, creates objects at the subscription level during the blueprint deployment such as Azure AD DS.

* **Security configuration in the environment for a Blueprint Operator**  
The management of Blueprint definitions and Blueprint assignments are two different roles, thus the need for two different identities (Azure administrator and managed identity). The security group being granted the **Blueprint Operator** role needs to also be granted the **Managed Identity Operator** role. Without this permission, blueprint assignments fail because of lack of permissions.  One method is to add the two identities to the one security group (example *Blueprint Operators*), and then you only need add the required roles to the security group.

    The steps to create a security group and assign the roles are as follows (documentation [here](https://docs.microsoft.com/en-us/azure/governance/blueprints/how-to/configure-for-blueprint-operator)):  

  * [Create an Azure security group](https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-groups-create-azure-portal) (example: **Blueprint Operators**)  
  * At the subscription level, assign roles to the group previously created, by going to the following location in the Azure Portal  
  > **Azure Portal** -> **Home** -> **Subscriptions** -> (***your subscription***) -> **Access Control (IAM)**  
  * [Add the managed identity created earlier in this section, and the Global Administrator accounts to the Azure security group](https://docs.microsoft.com/en-us/azure/active-directory/fundamentals/active-directory-groups-create-azure-portal#create-a-basic-group-and-add-members)  
  * Assign permissions to the group , to allow members to create objects at the subscription level:

    * [Blueprint Contributor](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#blueprint-contributor)
    * [Blueprint Operator](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#blueprint-operator)
    * [Managed Identity Operator](https://docs.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#managed-identity-operator)  

    When correctly configured, the Role assignments for your Azure AD group, should look like this:  

    ![Blueprint Group Access Control Depiction](https://github.com/Azure/AVDBlueprint/blob/main/images/BluePrint_GroupAccessControlDepiction.PNG)

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

* **Managed identity assigned the Owner role at the subscription level**  
The reason is that the managed identity needs full access during the deployment, for example to initiate the creation of an instance of Azure AD DS.  

    **MORE INFO:** [Add or change Azure subscription administrators](https://docs.microsoft.com/en-us/azure/cost-management-billing/manage/add-change-subscription-administrator)  

* **The account used to assign the Blueprint, granted "User Access Administrator" at the subscription level**  
The account used to manage the subscription and later assign the Blueprint, should be assigned the "User Access Administrator". During Blueprint assignment users are going to be created and assigned to a AVD group. The "User Access Administrator" permission ensures the requisite permission in Azure AD to perform this function.  

    **MORE INFO:** [Assign a user as an administrator of an Azure subscription](https://docs.microsoft.com/en-us/azure/role-based-access-control/role-assignments-portal-subscription-admin)  

* **The Blueprint main file (Blueprint.json), and related artifact objects**  
These objects are publicly available on Github.com. Once the Blueprint objects have been acquired, they need to be customized to each respective environment. The necessary customizations can be applied in a few different ways.  

[Back to main Readme.md file](Prerequisities.md)
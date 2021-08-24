### Manage the Blueprint using local storage on a device and publish in Azure portal (Windows instructions)  

You can manage the AVD Blueprint using a device that has a small amount of local storage available.

1. Go the [AVD Blueprint Github repository main folder](https://github.com/Azure/AVDBlueprint).  

1. Click or tap the down arrow on the green button called 'Code', then tap or click the option 'Download Zip'.  

      ![Image for Github Download Zip option](./images/GitDownloadZip2.png)  

1. Once the .zip file is downloaded to your local device, you can expand the contents to any location of your choosing,
by double-clicking the downloaded .zip file, and then copying the main folder within the zip to any location, such as 'C:\AVDBlueprint-main'.  

1. The next step is to import the Blueprint to your Azure subscription. These are the high-level steps to import the Blueprint:

    * Start PowerShell.
    * Run the following PowerShell commands to import the required modules needed to import the blueprint (if not previously installed)

    ```PowerShell
    Install-Module -Name Az.Blueprint
    Import-Module Az.Blueprint
    ```  

    **NOTE:** Installing the PowerShell 'Az' modules does not include the Az.Blueprint modules. If you have installed the 'Az' modules, you will still need to install the Az.Blueprint modules.  

1. Authenticate to your subscription by using the following PowerShell command

    ```powershell
    Connect-AzAccount
    ```

1. Run the following command to import the Blueprint to your Azure subscription:  

    ```powershell
    Import-AzBlueprintWithArtifact -Name "YourBlueprintName" -SubscriptionId "00000000-1111-0000-1111-000000000000" -InputPath 'C:\AVDBlueprint-main\Blueprint'
    ```

1. From the Azure Portal, browse to [Azure Blueprint service tab](https://portal.azure.com/#blade/Microsoft_Azure_Policy/BlueprintsMenuBlade/GetStarted) and select "**Blueprint definitions**".  
You can review newly imported Blueprint definitions and follow instructions to edit, publish and assign blueprint. ([More information](https://docs.microsoft.com/en-us/azure/governance/blueprints/create-blueprint-portal#edit-a-blueprint))  

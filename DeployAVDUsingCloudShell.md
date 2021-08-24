### Method 2: Manage the Blueprint using Azure Cloud Shell

Azure hosts Azure Cloud Shell, an interactive shell environment that can be used through a web browser.
You can use either Bash or PowerShell with Cloud Shell to work with Azure services.
You can use the Cloud Shell preinstalled commands to import and assign the AVD Blueprint without having to install anything on your local environment.  
There are several ways to get started with Azure Cloud Shell:  

1. Start Azure CloudShell:  

    * **Direct link**: Open a browser to [https://shell.azure.com](https://shell.azure.com).

    * **Azure portal**: Select the Cloud Shell icon on the [Azure portal](https://portal.azure.com):

      ![Icon to launch the Cloud Shell from the Azure portal](./images/portal-launch-icon.png)

1. Start PowerShell in Azure CloudShell ([more information here](https://docs.microsoft.com/en-us/azure/cloud-shell/overview#choice-of-preferred-shell-experience))

1. Run the following command to clone the Azure AVDBlueprint repository to CloudDrive.  

    ```dos
    git clone https://github.com/Azure/AVDBlueprint.git $HOME/clouddrive/AVDBlueprint
    ```

    **TIP:**  Run ```dir $HOME/clouddrive``` to verify the repository was successfully cloned to your CloudDrive  

1. Run the following commands to import the required PowerShell modules needed to import the blueprint (if not previously installed)

    ```PowerShell
    Install-Module -Name Az.Blueprint
    Import-Module Az.Blueprint
    ```

1. Run the following command to import the AVD Blueprint definition, and save it within the specified subscription or management group.  

    ```powershell
    Import-AzBlueprintWithArtifact -Name "YourBlueprintName" -SubscriptionId "00000000-1111-0000-1111-000000000000" -InputPath "$HOME/clouddrive/AVDBlueprint/blueprint"
    ```  

    **NOTE:** The '-InputPath' argument must point to the folder where blueprint.json file is placed.

1. From the Azure Portal, browse to [Azure Blueprint service tab](https://portal.azure.com/#blade/Microsoft_Azure_Policy/BlueprintsMenuBlade/GetStarted) and select "**Blueprint definitions**".  
You can review newly imported Blueprint definitions and follow instructions to edit, publish and assign blueprint. ([More information](https://docs.microsoft.com/en-us/azure/governance/blueprints/create-blueprint-portal#edit-a-blueprint))  

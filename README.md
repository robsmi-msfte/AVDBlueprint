# AZBluePrints-WVD

This Azure Blueprint will deploy and configure Azure ADDS and WVD (domain join is failing)

Current steps that must be completed before publishing:

Register the provider: Register-AzResourceProvider -ProviderNamespace Microsoft.AAD (TODO: Confirm this is required)

Create the Domain Controller Services service principal New-AzADServicePrincipal -ApplicationId "2565bd9d-da50-47d4-8b85-4c97f669dc36"

Create a user-assigned identity to execute the BP. YOU MUST USE A MANAGED IDENTITY FOR THIS BP: <https://docs.microsoft.com/en-us/azure/governance/blueprints/how-to/configure-for-blueprint-operator>

Give the managed identity Tenant admin.

Assign the managed identity to the Blueprint contributor role and also a contributor to the Domain Controller Services app.

Quickest way to currently deploy everything:

1) Update Utils\Import-bp.ps1 to match your tenant values.
2) Execute Import-bp.ps1
3) Edit assignments\assign_default.json to match your environment
4) Execute assign-bp.ps1

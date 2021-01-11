$tenantID = 'f9eca388-26c6-4cf9-980d-4966eacc2c08'
$subID = '3c09cfd5-3ea6-48c8-a9ac-3f997816d723'
$bpName = 'ADDS'

Connect-AzAccount -Tenant $tenantID -Subscription $subID

$bpDef = Get-AzBlueprint -SubscriptionId $subID -Name $bpName

$dateFolderName ='C:\temp\Blueprints\' + (Get-Date -Format "yyyyMMddHHmmss").ToString()
Export-AzBlueprintWithArtifact -Blueprint $bpDef  -OutputPath $dateFolderName

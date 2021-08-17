$jConfig = Get-Content "C:\VSCode\CustomizedFiles\run.config.json" | ConvertFrom-Json
$tenantID = $jConfig.args.tenantID
$subID = $jConfig.args.subscriptionID
$bpName = $jConfig.args.blueprintName
$assignFile = $jConfig.args.assignmentFile

$version =(Get-Date -Format "yyyyMMddHHmmss").ToString()
$assignmentName = $bpName + '_' + $version

If (!(Get-AzContext)) {
    Write-Host "Please login to your Azure account"
    Connect-AzAccount -Tenant $tenantID -Subscription $subID
}

$bpAssignment = New-AzBlueprintAssignment -Name $assignmentName -SubscriptionId $subscriptionID -AssignmentFile $assignFile

Write-Output $bpAssignment
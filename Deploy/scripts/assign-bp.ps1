$jConfig = Get-Content "./run.config.json" | ConvertFrom-Json
$tenantID = $jConfig.args.tenantID
$subID = $jConfig.args.subscriptionID
$assignment = $jConfig.args.assignmentFile
.\assign-bp.ps1 -tenantID $tenantID -subscriptionID $subID -assignFile $assignment
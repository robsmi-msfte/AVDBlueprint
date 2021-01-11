# Input bindings are passed in via param block.
param([byte[]] $InputBlob, $TriggerMetadata)

$resourceGroupName = 'vditechdeploydemo' #$env:DEPLOY_uploadResourceGroupName
$storageAccountName = 'vditechdeploydemo' #$env:DEPLOY_storageAccountName
$blobContainer = 'uploads' #$env:DEPLOY_uploadContainer
#$assignmentName = $env:DEPLOY_blueprintName + '_' + (Get-Date -Format 'yyyyMMddHHmmss').ToString()
$assignmentName = 'WVD_E2E_' + (Get-Date -Format 'yyyyMMddHHmmss').ToString()

# Write out the blob name and size to the information log.
Write-Host "PowerShell Blob trigger function Processed blob! Name: $($TriggerMetadata.Name) Size: $($InputBlob.Length) bytes"

Write-Host "Trigger Metadata:" 
$TriggerMetadata

Write-Host "Assignment File: $($TriggerMetadata.Uri)"
$tempFile = "$($env:temp)\$((New-Guid).Guid).json"

try {
    $storageAccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -name $storageAccountName
    $storageContext = $storageAccount.context
}
catch {
    Write-Host $_
    Write-Host "Failed to connect to Storage Account ($storageAccountName) in $resourceGroupName."
}

try {
    $blob = $TriggerMetadata.name #TODO File validation
    Get-AzStorageBlobContent -Context $storageContext -Container $blobContainer -blob $blob -Destination "$tempFile" -Force
}
catch {
    Write-Host "ResourceGroup: $resourceGroupName. Storage Account: $storageAccountName AssignmentName: $assignmentName"
    Write-Host "Failed to retrieve $tempFile from $($TriggerMetadata.name) in $storageAccountName - $blobContainer."
    Write-Error "Failed to get file."
}

Write-Host "Deploying $assignmentName from $tempFile."
try {
    New-AzBlueprintAssignment -Name $assignmentName -AssignmentFile $tempFile
}
catch {
    Write-Host $_
    Write-Host "Failed to deploy blueprint - $assignmentName from $tempFile."
}

Remove-Item $tempFile
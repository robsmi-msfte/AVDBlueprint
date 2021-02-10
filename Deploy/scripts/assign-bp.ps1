[CmdletBinding(SupportsShouldProcess=$true)]
Param(
    [Parameter(Mandatory=$true)]
    [string] $tenantID,

    [Parameter(Mandatory=$true)]
    [string] $subscriptionID,

    [Parameter(Mandatory=$true)]
    [string] $bpName,

    [Parameter(Mandatory=$false)]
    [string] $assignFile = '..\assignments\assign_default.json'
)

$version =(Get-Date -Format "yyyyMMddHHmmss").ToString()
$assignmentName = $bpName + '_' + $version

If (!(Get-AzContext)) {
    Write-Host "Please login to your Azure account"
    Connect-AzAccount -Tenant $tenantID -Subscription $subID
}

$bpAssignment = New-AzBlueprintAssignment -Name $assignmentName -SubscriptionId $subscriptionID -AssignmentFile $assignFile

Write-Output $bpAssignment
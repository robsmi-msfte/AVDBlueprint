param ($groupName, $userPrincipalName)
Write-Host "Adding UPN ($userPrincipalName) to group ($groupName)"

if (-Not (Get-AzADGroup -DisplayName "$groupName")) {
    $mailNickname = $groupName -replace '[\W]',''
    New-AzADGroup -DisplayName "$groupName" -MailNickname $mailNickname
}

Start-Sleep 10
if (-Not (Get-AzADGroupMember -GroupDisplayName "$groupName" | Where-Object {$_.UserPrincipalName -eq $userPrincipalName})) {
    $parameters = @{
        TargetGroupDisplayName              =  "$groupName"
        MemberUserPrincipalName             =  $userPrincipalName
    }
    Add-AzADGroupMember @parameters
}
param ($totalUsers, $prefix, $domainname, $keyvault, $forcePasswordChange, $adGroup, $avdAppGroup, $avdRolename, $appGroupRG)

Write-host "Total Users: $totalUsers"
Write-host "Prefix: $prefix"
Write-host "AD Group: $adGroup"
Write-host "KeyVault: $keyvault"
Write-host "Force PW Change: $forcePasswordChange"
Write-host "AVD App Group $avdAppGroup"
Write-host "AVD Role: $avdRolename"
Write-host "AVD App Group RG: $appGroupRG"

for ($i = 1 ; $i -le $totalUsers ; $i++) {
    $displayName = $prefix + $i
    $userPrincipalName = $displayName + '@' + $domainname
    Write-host "Creating $userPrincipalName"
    
    if ($null -eq (Get-AzADUser -UserPrincipalName $userPrincipalName)) {
        Start-Sleep -s 2
        .\addADuser.ps1 -displayName "$displayName" -userPrincipalName "$userPrincipalName" -keyVault $keyvault -forcePasswordChange $forcePasswordChange
        Start-Sleep -s 2
    }

    .\assignADGroup.ps1 -groupName "$adGroup" -userPrincipalName "$userPrincipalName"
    Start-Sleep -s 2
    .\assignAVDRole.ps1 -upn "$userPrincipalName" -roleName "$avdRolename" -appGroupName "$avdAppGroup" -appGroupRG "$appGroupRG"
    Start-Sleep -s 1
}

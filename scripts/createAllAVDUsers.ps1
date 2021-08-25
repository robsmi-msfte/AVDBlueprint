param ($totalUsers, $prefix, $domainname, $keyvault, $forcePasswordChange, $adGroup, $avdAppGroup, $avdRolename, $appGroupRG)

Write-host "Total Users: $totalUsers"
Write-host "Prefix: $prefix"
Write-host "AD Group: $adGroup"
Write-host "KeyVault: $keyvault"
Write-host "Force PW Change: $forcePasswordChange"
Write-host "AVD App Group $avdAppGroup"
Write-host "AVD Role: $avdRolename"
Write-host "AVD App Group RG: $appGroupRG"

#region Creating AD group, and adding a pause to accomodate delays in creation and reporting success

    $groupName = $adGroup
    $mailNickname = $groupName -replace '[\W]',''    
    Write-Host "Testing for existence of Azure AD Group: '$groupname'"
    if (-Not (Get-AzADGroup -DisplayName "$groupName")) {
        Write-Output (Get-AzADGroup -DisplayName $groupName)
        Write-Host "AAD group '$groupName' not found...creating group '$groupName'"
        Write-Output (New-AzADGroup -DisplayName "$groupName" -MailNickname $mailNickname)
        Write-Output (Get-AzADGroup -DisplayName $groupName)
    } else {
        Write-Host "AZ AD group found is ($groupName): not creating new group"    
    }
         
#endregion

#region Create AVD users, named "user prefix" + number, starting at 1
for ($i = 1 ; $i -le $totalUsers ; $i++) {
    $displayName = $prefix + $i
    $userPrincipalName = $displayName + '@' + $domainname
    Write-host "Creating $userPrincipalName"
    Write-Host "Adding UPN ($userPrincipalName) to group ($groupName)"
    
    
    if ($null -eq (Get-AzADUser -UserPrincipalName $userPrincipalName)) {
        #.\addADuser.ps1 -displayName "$displayName" -userPrincipalName "$userPrincipalName" -keyVault $keyvault -forcePasswordChange $forcePasswordChange
        # to address timing problems in one cloud, adding code here instead of calling an external script each time
        Write-host "DisplayName: $displayName"
        Write-host "User Principal: $userPrincipalName"

        $mailNickname = $userPrincipalName -replace '[\W]',''
        $pass = (Get-AzKeyVaultSecret -VaultName $keyvault -name $displayName).SecretValue

        $parameters = @{
            DisplayName                  =  $displayName
            UserPrincipalName            =  $userPrincipalName
            Password                     =  $pass
            MailNickname                 =  $mailNickname
            ForceChangePasswordNextLogin = [System.Convert]::ToBoolean($forcePasswordChange)

        }
        if ($null -eq (Get-AzADUser -DisplayName $parameters.DisplayName)) {
            $parameters.GetEnumerator() | ForEach-Object{
                $message = '{0} is {1}.' -f $_.key, $_.value
                Write-Output $message
            }
            New-AzADUser @parameters
        }
    }
    #endregion Create AVD users

    #region Assign AD user
    # Add the user just created to the AVD Azure AD group
    # .\assignADGroup.ps1 -groupName "$adGroup" -userPrincipalName "$userPrincipalName"
    # for timing reasons, adding code here instead of calling an external script
    # Also, adding delays during user creation and group add, to accomodate for AD->AADDS sync

    Start-Sleep -Seconds 4
    if (-Not (Get-AzADGroupMember -GroupDisplayName "$groupName" | Where-Object {$_.UserPrincipalName -eq $userPrincipalName})) {
        $parameters = @{
            TargetGroupDisplayName              =  "$groupName"
            MemberUserPrincipalName             =  $userPrincipalName
    }
        Add-AzADGroupMember @parameters
        Start-Sleep -Seconds 2
    }
    #endregion Assgning AD users
}

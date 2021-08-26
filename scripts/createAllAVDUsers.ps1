# Script to create AVD users, AVD User AD group, then add the AVD users to the AVD user group

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
    Write-Host "`n"
    Write-Host "_________ Now creating AVD Users Group in Azure AD _________"
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
    Write-Host "`n"
    Write-Host "____ Now creating users and adding them to AVD AD group ____"
    Write-host "Creating $userPrincipalName"
    Write-Host "Adding UPN ($userPrincipalName) to group ($groupName)"
    
    if (-NOT (Get-AzADUser -UserPrincipalName $userPrincipalName)) {
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
    if (-Not (Get-AzADUser -DisplayName $parameters.DisplayName)) {
        $parameters.GetEnumerator() | ForEach-Object{
             $message = '{0} is {1}.' -f $_.key, $_.value
             Write-Output $message
            }
            Start-Sleep -Seconds 1 
            New-AzADUser @parameters
        }
    if (-Not (Get-AzADGroupMember -GroupDisplayName "$groupName" | Where-Object {$_.UserPrincipalName -eq $userPrincipalName})) {
            $parameters = @{
                TargetGroupDisplayName              =  "$groupName"
                MemberUserPrincipalName             =  $userPrincipalName
        }
            Start-Sleep -Seconds 9
            Add-AzADGroupMember @parameters
        }
    }
}
#endregion Create AVD users
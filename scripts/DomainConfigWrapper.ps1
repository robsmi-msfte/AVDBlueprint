[CmdletBinding(SupportsShouldProcess=$true)]
Param(
    [Parameter(Mandatory=$true)]
    [string] $MgmtVM,

    [Parameter(Mandatory=$true)]
    [string] $DAUserUPN,

    [Parameter(Mandatory=$true)]
    [string] $KeyVault
)

#Build a credential object for $DAUserUPN
$DAUserName = $DAUserUPN.Split('@')[0]
$DAPass = ConvertTo-SecureString -String $((Get-AzKeyVaultSecret -VaultName $keyvault -name $DAUserName).SecretValue) -AsPlainText -Force
$DACredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DAUserUPN, $DAPass

#Run the config script as DAUser
Invoke-Command -Credential $DACredential -ComputerName $MgmtVM -FilePath 'C:\Windows\Temp\WVD_ADConfigApply.ps1' -ArgumentList '-Verbose'
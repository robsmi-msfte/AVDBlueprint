Install-WindowsFeature -name GPMC
Install-WindowsFeature -name RSAT-AD-Tools
Invoke-WebRequest -Uri 'https://agblueprintsa.blob.core.windows.net/blueprintscripts/WVDBlueprintSTIGs.zip' -OutFile C:\Windows\Temp\WVDBlueprintSTIGs.zip
Invoke-WebRequest -Uri 'https://agblueprintsa.blob.core.windows.net/blueprintscripts/WVD_ADStructure.ps1' -OutFile C:\Windows\Temp\WVD_ADConfigApply
Expand-Archive -LiteralPath 'C:\Windows\Temp\WVDBlueprintSTIGs.zip' -DestinationPath C:\Windows\Temp

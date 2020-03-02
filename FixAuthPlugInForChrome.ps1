# Author: Manfred Hofer
# Website: www.vBrain.info
# Description: PowerShell script to fix the popup in Chrome for the VMware Authentication plug-in
# Reference: 
# Credit:   Thanks to HWit1 and Lewpy from the VMTN thread (https://communities.vmware.com/thread/620083) for
#           pointing to the right direction.
#
# Changelog
# 03/02/2020
#   * Initial Release

#Define path of the JSON file
$jsonfile = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\preferences"
#Creates a backup of the original preferences file
$jsonFileBackup = "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Preferences.backup"
Copy-Item -Path $jsonfile -Destination $jsonFileBackup
#Create PSObject from JSON File
$jsonAsPsObject = Get-Content $jsonfile -Encoding UTF8 | ConvertFrom-Json
#Name of the JSON Object to add to the existing JSON file
$jsonObjectName = "protocol_handler"
#Value of the $jsonObjectName
$excludeValue =@"
    {
    "excluded_schemes": {
			"vmrc": false,
			"vmware-plugin": false
		}
    }
"@
#Add the jsonObjectName and excludeValue to the existing JSONasPSObject variable
$jsonAsPsObject |Add-Member -NotePropertyName $jsonObjectName -NotePropertyValue (ConvertFrom-Json $excludeValue)

#Convert the whole jsonAsPsObject to JSON again and save it under the original name
$jsonAsPsObject | ConvertTo-Json -Depth 10 -Compress | Out-File -FilePath $jsonfile -Encoding UTF8
# Author: Manfred Hofer
# Website: www.vbrain.info
# Description: Script to create a new Custom ESXi Image.

#Use "standard" for the standard profile or "no-tools" for the profile with no VMtools
$OfflinePatchImageProfile = "standard"
#Define the file path of the VIB drivers/tools.
$PathToVibs = "F:\EsxiCustomISO\HPE BRZ\pre-Gen9\6.5 U2 VIB Driver Bundles\"
#Define the software repository/offline bundle.
$PathToESXiSoftwareDepot = "F:\EsxiCustomISO\HPE BRZ\pre-Gen9"
$ESXiSoftwareDepot = "ESXi650-201803001.zip"
#If you're building your own custom iso you can define a Vendor name which should be used. E.g. Custom, company name etc.
$CustomVendorName = "VMware, Inc."
#CommunitySupported, PartnerSupported, VMwareAccepted, VMwareCertified
$CustomAcceptanceLevel ="PartnerSupported"

#### DO NOT EDIT BEYOND HERE ####

$FullPathToDepotFile = "$PathToESXiSoftwareDepot\$ESXiSoftwareDepot"
Add-EsxSoftwareDepot -DepotUrl $FullPathToDepotFile
$ESXiImageProfile = Get-EsxImageProfile |Where {$_.Name -match "standard"}

Write-Host -NoNewline -ForegroundColor Green "The following ESXi Image Profile was selected: "
Write-Host -ForegroundColor White $ESXiImageProfile.Name

$VibDriverFiles = Get-ChildItem -File $PathToVibs

foreach ($VibDriverFile in $VibDriverFiles) {
 
    $FullPathToVib = $PathToVibs + $VibDriverFile
    Add-EsxSoftwareDepot -DepotUrl "$FullPathToVib"

}

$NewImageProfileName = Read-Host -Prompt "Input your new Image Profile Name: "
New-EsxImageProfile -CloneProfile $ESXiImageProfile $NewImageProfileName -Vendor $CustomVendorName -AcceptanceLevel $CustomAcceptanceLevel

$VibPackages = Get-EsxSoftwarePackage |where {$_.vendor -notlike "VMW" -and $_.vendor -notlike "VMware"}

foreach ($VibPackage in $VibPackages) {

    Write-Host -NoNewline -ForegroundColor Green "Adding Package "
    Write-Host -NoNewline -ForegroundColor White $VibPackage
    Write-Host -NoNewline -ForegroundColor Green " to Image Profile "
    Write-Host -ForegroundColor White $NewImageProfileName
    Add-EsxSoftwarePackage -ImageProfile $NewImageProfileName $VibPackage -Force

}

Write-Host -NoNewline -ForegroundColor Green "Exporting Image Profile "
Write-Host -NoNewline -ForegroundColor White $NewImageProfileName
Write-Host -ForegroundColor Green " to Offline Bundle."

Export-EsxImageProfile -ImageProfile $NewImageProfileName -ExportToBundle "$PathToESXiSoftwareDepot\$NewImageProfileName.zip"

Write-Host -NoNewline -ForegroundColor Green "Exporting Image Profile "
Write-Host -NoNewline -ForegroundColor White $NewImageProfileName
Write-Host -ForegroundColor Green " to ISO file."

Export-EsxImageProfile -ImageProfile $NewImageProfileName -ExportToIso "$PathToESXiSoftwareDepot\$NewImageProfileName.iso"

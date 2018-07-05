# Author: Manfred Hofer
# Website: www.vbrain.info
# Description: PowerCLI script to Convert Templates to VM for Backup Reasons

Import-Module VMware.VimAutomation.Core

# vCenter and vCenter credentials
$VIServer = "vcsa.localhost.int"
$VIUsername = "administrator"
$VIPassword = "Password"
$TemplateName = "T_*"

$verboseLogFile = "VMtoTemplate.log"
$StartTime = Get-Date

Function My-Logger {
    param(
    [Parameter(Mandatory=$true)]
    [String]$message
    )

    $timeStamp = Get-Date -Format "MM-dd-yyyy_hh:mm:ss"

    Write-Host -NoNewline -ForegroundColor White "[$timestamp]"
    Write-Host -ForegroundColor Green " $message"
    $logMessage = "[$timeStamp] $message"
    $logMessage | Out-File -Append -LiteralPath $verboseLogFile
}

Start-Transcript -Path "C:\Script\VMtoTemplate.log" -Append

My-Logger "Connecting to $VIServer ..."
$pEsxi = Connect-VIServer $VIServer -User $VIUsername -Password $VIPassword -WarningAction SilentlyContinue

My-Logger "Migrate VM to Template"
# Get-VM -Name $TemplateName |Set-VM -ToTemplate -Confirm:$false

foreach ($Template in Get-VM -Name $TemplateName) {
    Set-VM $Template -ToTemplate -Confirm:$false

}

$EndTime = Get-Date
$duration = [math]::Round((New-TimeSpan -Start $StartTime -End $EndTime).TotalMinutes,2)

My-Logger "VM to Template migration completed!"
My-Logger "StartTime: $StartTime"
My-Logger "EndTime: $EndTime"
My-Logger "Duration: $duration minutes"

Disconnect-VIServer $VIServer -Confirm:$false

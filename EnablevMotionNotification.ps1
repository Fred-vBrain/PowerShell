<#
.SYNOPSIS
  Enable vMotion App Notification for a VM (and optional timeout).

.EXAMPLE
  .\Enable-AppNotification.ps1 -Server vcsa01.lab.local -VMName "AppVM01"

.EXAMPLE
  .\Enable-AppNotification.ps1 -Server esx01.lab.local -VMName "AppVM01" -TimeoutSeconds 120 -SkipCertCheck
#>

[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)]
  [string]$Server,

  [Parameter(Mandatory=$true)]
  [string]$VMName,

  [Parameter()]
  [ValidateRange(0, 86400)]
  [int]$TimeoutSeconds,

  [switch]$SkipCertCheck,

  # Pass a PSCredential or you'll be prompted
  [System.Management.Automation.PSCredential]$Credential
)

begin {
  if ($SkipCertCheck) {
    Set-PowerCLIConfiguration -Scope Session -InvalidCertificateAction Ignore -Confirm:$false | Out-Null
  }
  if (-not (Get-Module -ListAvailable -Name VMware.PowerCLI)) {
    throw "VMware.PowerCLI module not found. Install-Module VMware.PowerCLI -Scope CurrentUser"
  }
}

process {
  try {
    if ($Credential) {
      $vi = Connect-VIServer -Server $Server -Credential $Credential -ErrorAction Stop
    } else {
      $vi = Connect-VIServer -Server $Server -ErrorAction Stop
    }

    $vm = Get-VM -Name $VMName -ErrorAction Stop
    $vmView = Get-View -VIObject $vm

    # --- Enable App Notification ---
    $spec = New-Object VMware.Vim.VirtualMachineConfigSpec
    $spec.VmOpNotificationToAppEnabled = $true

    $taskMoRef = $vmView.ReconfigVM_Task($spec)
    $task = Get-Task -Id ("Task-{0}" -f $taskMoRef.Value)
    $null = $task | Wait-Task

    Write-Host ("vMotion App Notification enabled on '{0}'." -f $VMName)

    # --- Optional: set timeout ---
    if ($PSBoundParameters.ContainsKey('TimeoutSeconds')) {
      $spec2 = New-Object VMware.Vim.VirtualMachineConfigSpec
      $spec2.VmOpNotificationTimeout = [int]$TimeoutSeconds

      $taskMoRef2 = $vmView.ReconfigVM_Task($spec2)
      $task2 = Get-Task -Id ("Task-{0}" -f $taskMoRef2.Value)
      $null = $task2 | Wait-Task

      Write-Host ("Timeout set to {0} seconds on '{1}'." -f $TimeoutSeconds, $VMName)
    }

  } catch {
    Write-Error $_.Exception.Message
    if ($_.Exception.InnerException) { Write-Error $_.Exception.InnerException.Message }
    exit 1
  } finally {
    if ($vi) { Disconnect-VIServer -Server $vi -Confirm:$false | Out-Null }
  }
}

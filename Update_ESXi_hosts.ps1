$vCenter = "vCenter FQDN"
$depot = "VMFSFilePathToOfflineBundle"
$profile = "ProfileName"
$username = "vCenter Username"
$password = "vCenter PW"

Connect-VIServer -Server $vCenter -User $username -Password $password
$esxhost = Get-VMHost

foreach ($esx in $esxhost)
{
    $esxcli = $esx | Get-EsxCli -V2
    $args = $esxcli.software.profile.update.CreateArgs()
    $args.depot = $depot
    $args.profile = $profile
    $esxcli.software.profile.update.Invoke($args)

    $esx | Set-VMHost -State Maintenance
    $esx | Restart-VMHost -RunAsync -Confirm:$false

}

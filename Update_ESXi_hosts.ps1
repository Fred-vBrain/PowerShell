$vCenter = "vcsa60vsan.nested.ad.vbrain.info"
$depot = "/vmfs/volumes/NFS01/ESXi600-201803001.zip"
$profile = "ESXi-6.0.0-20180304001-standard"
$username = "administrator@vsphere.local"
$password = "Digital1#"

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

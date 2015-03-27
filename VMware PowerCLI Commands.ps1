Connect-VIServer ***.**.***.*** -User administrator -Password ********

$location = Get-Folder -NoRecursion 
New-Datacenter -Location $location -Name T04-DC-ABH

write-host "Add vHosts to the new datacenter"

Add-VMHost ***.**.***.*** -Location (Get-Datacenter -Name T04-DC-ABH) -User root -Password ******** -Force

Add-VMHost ***.**.***.*** -Location (Get-Datacenter -Name T04-DC-ABH) -User root -Password ******** -Force

write-host "Create VM"
New-VM -Name T04-VM01-ABH-Lin -Template T04-VM01-Lin-Template -VMHost ***.**.***.*** -Datastore (Get-Datastore -VMHost ***.**.***.*** -Name nfs2team04) -Confirm:$false


write-host "Enable vMotion"
Get-VMHost ***.**.***.*** | Get-VMHostNetworkAdapter -VMKernel | Set-VMHostNetworkAdapter -VMotionEnabled -Confirm:$true



Start-VM (Get-VM -Name "T04-VM01-ABH-Lin") -Confirm:$false -RunAsync

write-host "Live Migration"
Get-VM -Name T04-VM01-ABH-Lin | Move-VM -Destination (Get-VMHost ***.**.***.***) -Confirm:$false

Stop-VM -VM (Get-VM -Name "T04-VM01-ABH-Lin") -Confirm:$false

write-host "Cold Migration"
Get-VM -Name T04-VM01-ABH-Lin | Move-VM -Destination (Get-VMHost ***.**.***.***) -Confirm:$false

write-host "Delete VMs"
Remove-VM T04-VM01-ABH-Lin -DeleteFromDisk -Confirm:$false

write-host "Remove VMHosts"
Remove-VMHost ***.**.***.*** -Confirm:$false
Remove-VMHost ***.**.***.*** -Confirm:$false

write-host "Remove DataCenter"
Remove-Datacenter T04-DC-ABH -Confirm:$false
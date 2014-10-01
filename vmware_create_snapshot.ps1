#
# 20140930
#
# Version 1.00
#
# Script written to take a list of servers provided by Spacewalk's
# System Group SSM export and then compare that against all VM guests
# dumped from a VMware ESXi Cluster. Whenever a match is found, it
# will create a snapsnot, including the memory state, of the guest
# named "BeforePatch".
#
#


# Import PowerCLI module for VMware
Add-PSSnapin VMware.VimAutomation.Core


# Update the title
$host.ui.rawui.WindowTitle="PowerShell [PowerCLI Module Loaded]"


#Ask the user if we should connect to the vCenter server
$ans = Read-Host "Connect to 'vcenter.dmotorworks.com' [Y/N]"
if ($ans -eq "Y" -or $ans -eq "y") {
  #It takes some time to connect, update the user
  Write-Host ""
  Write-Host "Connecting, please wait.."
  Write-Host ""


  # Attach to the cluster
  Connect-VIServer -Server vcenter.dmotorworks.com


  # Update the title
  $host.ui.rawui.WindowTitle="PowerShell [Performing snapshots]"



  # Build a menu for the user
  Write-Host ""
  Write-Host ""
  Write-Host "VMware Clusters"
  Write-Host " 1) Dev"
  Write-Host " 2) Stage"
  Write-Host " 3) Prod"
  Write-Host ""


  # Read in input
  $meneCluster = Read-Host "Select the Cluster"


  # Build the cluster name to string
  switch ($meneCluster) {
    1 {$vmCluster = "Dev Cluster (Intel)"}
    2 {$vmCluster = "Staging Cluster (Intel)"}
    3 {$vmCluster = "Production Cluster (Intel)"}
    4 {$vmCluster = "IL Production"}
    default {"The cluster could not be determined."; exit}
  }


  # Get a full list of servers and the FQDN, sort by FQDN
  Get-Cluster "$vmCluster" | Get-VM |
    Select @{N="DnsName"; E={$_.ExtensionData.Guest.Hostname}},Name |
    Sort | Export-Csv C:\temp\vmwareSystems.csv


  # Load the various CSVs into RAM rather than reading from disk always
  $csvVMware = Get-Content("c:\temp\vmwareSystems.csv")
  $csvSpacewalk = Get-Content("c:\temp\download.csv")


  # Set the counter to 0
  $tmpCntr = 0


  # Pull out a VMware guest from the list of all VMs
  ForEach ($tmpESXSystem in $csvVMware) {
    # Remove any QUOTE characters from the ESX FQDN string
    $tmpESXSystem = $tmpESXSystem.Replace("`"","")


    # This splits the input by COMMA and stores the result into new vars
    $esxSystem = $tmpESXSystem.split(',')[0]
    $esxSystem_Snapshot = $tmpESXSystem.split(',')[1]


    # Pull out a Spacewalk system from all Spacewalk systems to be patched
    ForEach ($tmpSpacewalkSystem in $csvSpacewalk) {
      # This splits the input by COMMA and stores the result into a new var
      $spacewalkSystem = $tmpSpacewalkSystem.split(',')[0]


      # Test if the FQDN from ESXi matches what Spacewalk has
      If (($esxSystem -eq $spacewalkSystem) -and ($esxSystem -ne '')) {
        # Debug output for matching
        #Write-Host "I've matched '$esxSystem' against '$spacewalkSystem'!"


        # Create the VMware Snapshot for the guest
        ##Write-Host "Creating snapshot for '$esxSystem_Snapshot'."
        New-Snapshot -VM "$esxSystem_Snapshot" -Name BeforePatch -Memory -RunAsync


        # Increment the counter
        $tmpCntr++
      }
    }
  }


  # Clean up temp files
  del c:\temp\download.csv
  del c:\temp\vmwareSystems.csv


  # Notify that we're all done
  Write-Host "Snapshot process has completed on '$tmpCntr' VMs"
  Write-Host ""
  Write-Host "Press any key to continue ..."
  Write-Host ""
  $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}


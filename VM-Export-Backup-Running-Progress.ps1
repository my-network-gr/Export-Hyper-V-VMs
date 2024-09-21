# Ensure progress bars are displayed
$ProgressPreference = 'Continue'

# Define the backup path
$backupPath = "U:\- BACKUP -"

# Get the list of all VMs
$vms = Get-VM

# Display all VMs
Write-Output "Available VMs:"
$vms | ForEach-Object { Write-Output $_.Name }

# Get the list of all running VMs
$runningVms = $vms | Where-Object { $_.State -eq 'Running' }

$totalVMs = $runningVms.Count
$currentVM = 0

# Loop through each running VM and export it
foreach ($vm in $runningVms) {
    $currentVM++
    $vmName = $vm.Name
    $vmBackupPath = "$backupPath\$vmName"

    # Check if the backup directory exists
    if (Test-Path -Path $vmBackupPath) {
        # Delete the backup directory contents
        Remove-Item -Path $vmBackupPath -Recurse -Force
        Write-Output "Deleted existing backup directory for $vmName"
    }

    # Create the backup directory
    New-Item -ItemType Directory -Path $vmBackupPath

    try {
        # Export the VM
        Export-VM -Name $vmName -Path $vmBackupPath -ErrorAction Stop

        # Update per-VM progress
        Write-Progress -Activity "Exporting $vmName" -Status "Exporting..." -PercentComplete 100

        Write-Output "Exported ${vmName} to $vmBackupPath"
    } catch {
        Write-Output "Failed to export ${vmName}: $_"
    }

    # Update overall progress
    $overallPercentComplete = [math]::Round(($currentVM / $totalVMs) * 100)
    Write-Progress -Activity "Overall Progress" -Status "$overallPercentComplete% Complete" -PercentComplete $overallPercentComplete
}

# Clear the progress bar after completion
Write-Progress -Activity "Overall Progress" -Status "Completed" -Completed

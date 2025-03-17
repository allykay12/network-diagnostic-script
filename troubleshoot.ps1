# ================================
# PowerShell Server Troubleshooting Script
# Author: Ally Powers
# Date: March 2025
# ================================

# Log file location
$logFile = "./logs/troubleshoot-$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').log"
New-Item -ItemType Directory -Force -Path "./logs" | Out-Null

# Start Logging
Start-Transcript -Path $logFile -Append

# 1. Check CPU and Memory Usage
Write-Output "=== SYSTEM PERFORMANCE ==="
Get-CimInstance -ClassName Win32_OperatingSystem | 
Format-Table FreePhysicalMemory, TotalVisibleMemorySize, FreeSpaceInPagingFiles

# 2. Check Disk Usage
Write-Output "=== DISK SPACE USAGE ==="
Get-PSDrive | Where-Object { $_.Provider -like 'FileSystem' } | 
Format-Table Name, @{Name="Used";Expression={$_.Used/1GB -as [int]}}, @{Name="Free";Expression={$_.Free/1GB -as [int]}} 

# 3. Restart Failing Services
Write-Output "=== RESTARTING FAILED SERVICES ==="
$failedServices = Get-Service | Where-Object { $_.Status -eq 'Stopped' }
foreach ($service in $failedServices) {
    Write-Output "Restarting $($service.DisplayName)"
    Start-Service -Name $service.Name -ErrorAction SilentlyContinue
}

# 4. Analyze Windows Event Logs for Critical Errors
Write-Output "=== EVENT LOG ERRORS ==="
$events = Get-EventLog -LogName System -EntryType Error -Newest 10
foreach ($event in $events) {
    Write-Output "[$($event.TimeGenerated)] $($event.Message)"
}

# 5. Network Connectivity Test
Write-Output "=== NETWORK TEST ==="
Test-NetConnection -ComputerName google.com -Port 443

# 6. Final Summary
Write-Output "=== TROUBLESHOOTING COMPLETE ==="
Write-Output "Log saved to $logFile"

# End Logging

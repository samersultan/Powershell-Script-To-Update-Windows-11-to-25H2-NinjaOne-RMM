#Requires -RunAsAdministrator

$ErrorActionPreference = 'SilentlyContinue'
$Log = "C:\ProgramData\NinjaRMMAgent\logs\Win11-25H2-Silent.log"

function Log {
    param([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $Line = "$Timestamp - $Message"
    Write-Output $Line
    Add-Content -Path $Log -Value $Line -ErrorAction SilentlyContinue
}

Log "=== START 25H2 SILENT INSTALL ==="

# OS check using build number instead of ProductName
$cv = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
$BuildNumber = [int]$cv.CurrentBuild
$DisplayVersion = $cv.DisplayVersion
$ProductName = $cv.ProductName

Log "Detected ProductName: $ProductName"
Log "Detected DisplayVersion: $DisplayVersion"
Log "Detected Build: $BuildNumber"

if ($BuildNumber -lt 22000) {
    Log "Device is not Windows 11. Exiting."
    exit 1
}

# Set target release
$WU = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"
if (-not (Test-Path $WU)) {
    New-Item -Path $WU -Force | Out-Null
}

New-ItemProperty -Path $WU -Name "ProductVersion" -Value "Windows 11" -PropertyType String -Force | Out-Null
New-ItemProperty -Path $WU -Name "TargetReleaseVersion" -Value 1 -PropertyType DWord -Force | Out-Null
New-ItemProperty -Path $WU -Name "TargetReleaseVersionInfo" -Value "25H2" -PropertyType String -Force | Out-Null

Log "Target set to Windows 11 25H2"

# Refresh policy
gpupdate /target:computer /force | Out-Null

# Ensure services
foreach ($svc in @("wuauserv","bits")) {
    Set-Service -Name $svc -StartupType Automatic -ErrorAction SilentlyContinue
    Start-Service -Name $svc -ErrorAction SilentlyContinue
    Log "Service checked: $svc"
}

# Trigger update silently
$uso = "$env:SystemRoot\System32\UsoClient.exe"
if (-not (Test-Path $uso)) {
    Log "UsoClient.exe not found. Exiting."
    exit 1
}

Start-Process -FilePath $uso -ArgumentList "RefreshSettings" -WindowStyle Hidden
Start-Sleep -Seconds 5
Start-Process -FilePath $uso -ArgumentList "StartScan" -WindowStyle Hidden
Start-Sleep -Seconds 20
Start-Process -FilePath $uso -ArgumentList "StartDownload" -WindowStyle Hidden
Start-Sleep -Seconds 30
Start-Process -FilePath $uso -ArgumentList "StartInstall" -WindowStyle Hidden

Log "Update triggered silently"

# Wait for reboot-required state
$maxMinutes = 30
$elapsed = 0
$rebootNeeded = $false

while ($elapsed -lt $maxMinutes) {
    $rebootPending = (
        (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired") -or
        (Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending")
    )

    if ($rebootPending) {
        Log "Reboot required detected"
        $rebootNeeded = $true
        break
    }

    Log "Waiting... $elapsed minute(s)"
    Start-Sleep -Seconds 60
    $elapsed++
}

# Force reboot
if ($rebootNeeded) {
    Log "Rebooting in 60 seconds"
    shutdown.exe /r /t 60 /f /c "Windows 11 25H2 installing. System will reboot automatically."
} else {
    Log "Timeout reached. Forcing reboot anyway in 120 seconds"
    shutdown.exe /r /t 120 /f /c "Windows 11 25H2 update in progress. Forced reboot."
}

exit 0

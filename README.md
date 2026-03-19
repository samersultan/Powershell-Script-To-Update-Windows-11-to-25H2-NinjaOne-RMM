# Windows 11 25H2 Silent Upgrade Script (NinjaOne / PowerShell)

## Overview
This PowerShell script targets Windows 11 devices to upgrade to **version 25H2** using Windows Update for Business policies. It runs silently, triggers the update process, and forces a reboot when the system is ready.

Designed for use with:
- NinjaOne RMM
- Scheduled task deployment
- Manual execution as Administrator

---

## Features
- Targets Windows 11 using build detection (not ProductName)
- Sets Windows Update for Business policy to 25H2
- Runs fully silent (no user interaction)
- Triggers scan, download, and install via UsoClient
- Waits up to 30 minutes for staging
- Forces reboot automatically

---

## Requirements
- Windows 11 device (Build 22000 or higher)
- Administrator privileges
- Internet access or configured update source (Microsoft Update / WSUS / WUfB)
- Minimum recommended 25 GB free disk space

---

## How It Works
1. Detects OS using build number
2. Sets registry policy:
   - ProductVersion = Windows 11
   - TargetReleaseVersion = Enabled
   - TargetReleaseVersionInfo = 25H2
3. Forces Group Policy refresh
4. Starts Windows Update services
5. Triggers:
   - Scan
   - Download
   - Install
6. Monitors for reboot-required state
7. Forces reboot when ready or after timeout

---

## Usage (NinjaOne)

1. Go to:
   **Administration > Library > Automation > Scripts**

2. Create a new PowerShell script and paste the code

3. Configure:
   - Run As: **System**
   - Max Runtime: **60–120 minutes**

4. Deploy:
   - Run on demand
   - Or schedule via automation policy

---

## Usage (Manual)

Run PowerShell as Administrator:

```powershell
.\Win11-25H2-Upgrade.ps1

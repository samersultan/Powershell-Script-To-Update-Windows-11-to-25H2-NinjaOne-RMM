# NinjaOne Automation - Windows 11 25H2 Upgrade Script

## Script Name
`NinjaOne-Automation-Update-Win11-25h2.ps1`

---

## Overview
This PowerShell script targets Windows 11 devices to upgrade to **version 25H2** using Windows Update for Business policies. It runs silently, triggers the update process, and forces a reboot when the system is ready.

Designed for use with:
- NinjaOne RMM
- Scheduled task deployment
- Manual execution as Administrator

---

## Features
- Uses build-based detection (Windows 11 = Build 22000+)
- Sets Windows Update target release to **25H2**
- Fully silent execution (no user interaction)
- Triggers scan, download, and install via UsoClient
- Waits up to 30 minutes for update staging
- Forces reboot automatically

---

## Requirements
- Windows 11 device (Build 22000 or higher)
- Administrator or SYSTEM privileges
- Internet access or configured update source (Microsoft Update / WSUS / WUfB)
- Recommended: 25 GB+ free disk space

---

## How It Works
1. Detects OS using build number
2. Sets registry policy:
   - `ProductVersion = Windows 11`
   - `TargetReleaseVersion = 1`
   - `TargetReleaseVersionInfo = 25H2`
3. Forces Group Policy refresh
4. Ensures Windows Update services are running
5. Triggers:
   - Scan
   - Download
   - Install
6. Monitors for reboot-required state
7. Forces reboot when ready or after timeout

---

## Usage (NinjaOne)

1. Navigate to:  
   **Administration > Library > Automation > Scripts**

2. Create a new PowerShell script:
   - Name: `NinjaOne-Automation-Update-Win11-25h2.ps1`
   - Paste script contents

3. Configure:
   - Run As: **System**
   - Max Runtime: **60–120 minutes**

4. Deploy:
   - Run on demand  
   - Or assign via automation policy

---

## Usage (Manual)

Run PowerShell as Administrator:

```powershell
.\NinjaOne-Automation-Update-Win11-25h2.ps1

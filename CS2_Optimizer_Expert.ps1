# ==============================================================================
# CS2 PERFORMANCE OPTIMIZER - ELITE TIER SYSTEM
# ==============================================================================
# ZIEL: Skalierbare Latenz-Optimierung (Daily Driver bis eSport Pro)
# AUTOR: Antigravity System Engineer
# ==============================================================================

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "![ERROR] Dieses Skript MUSS als Administrator ausgeführt werden!" -ForegroundColor Red
    Pause
    exit
}

$BackupPath = "$PSScriptRoot\system_backup_tier.json"

function Backup-Settings {
    Write-Host "Erstelle Backup der aktuellen Services & Registry..." -ForegroundColor Gray
    # Erstellt bei der ersten Ausführung eine Sicherung kritischer Dienste
    $backup = @{
        SysMain = (Get-Service SysMain -ErrorAction SilentlyContinue).StartType
        WSearch = (Get-Service WSearch -ErrorAction SilentlyContinue).StartType
        DiagTrack = (Get-Service DiagTrack -ErrorAction SilentlyContinue).StartType
    }
    $backup | ConvertTo-Json | Out-File $BackupPath -ErrorAction SilentlyContinue
    Write-Host "Backup gesichert." -ForegroundColor Green
}

function Apply-Tier1 {
    Write-Host "`n[TIER 1] Wende Daily Driver Optimierungen an..." -ForegroundColor Cyan
    # Ultimate Performance Plan
    $pwr = powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
    powercfg -setactive ($pwr -split ' ')[3]
    # Game Mode & App Suspension
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AutoGameModeEnabled" -Value 1 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Value 1 -ErrorAction SilentlyContinue
    # Network Throttling Override
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 0xffffffff -ErrorAction SilentlyContinue
    Write-Host "Tier 1: Abgeschlossen." -ForegroundColor Green
}

function Apply-Tier2 {
    Apply-Tier1
    Write-Host "`n[TIER 2] Wende Enthusiast Optimierungen an..." -ForegroundColor Cyan
    # Telemetry Blocker
    Set-Service -Name DiagTrack -StartupType Disabled -ErrorAction SilentlyContinue
    Stop-Service -Name DiagTrack -Force -ErrorAction SilentlyContinue
    # Delivery Optimization deaktivieren (P2P Update Sharing)
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Value 0 -ErrorAction SilentlyContinue
    # GPU MSI Mode Injection (Message Signaled Interrupts)
    $gpu = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Enum\PCI" -Recurse | Where-Object { $_.GetValue("DeviceDesc") -match "RTX 3070" }
    if ($gpu) {
        $msiPath = "$($gpu.PSPath)\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties"
        if (-not (Test-Path $msiPath)) { New-Item -Path $msiPath -Force | Out-Null }
        Set-ItemProperty -Path $msiPath -Name "MSISupported" -Value 1
        Write-Host "MSI-Mode für RTX 3070 erzwungen." -ForegroundColor Magenta
    }
    Write-Host "Tier 2: Abgeschlossen." -ForegroundColor Green
}

function Apply-Tier3 {
    Apply-Tier2
    Write-Host "`n[TIER 3] Wende God-Tier eSport Optimierungen an..." -ForegroundColor Red
    Write-Host "WARNUNG: Die Windows-Suche und das Dateicaching werden nun im Kernel blockiert." -ForegroundColor Yellow
    
    # SysMain (SuperFetch) killen -> Verhindert Disk/RAM I/O im Hintergrund
    Set-Service -Name SysMain -StartupType Disabled -ErrorAction SilentlyContinue
    Stop-Service -Name SysMain -Force -ErrorAction SilentlyContinue
    
    # Windows Search Indexer killen -> Verhindert CPU-Spikes durch HDD-Scanning
    Set-Service -Name WSearch -StartupType Disabled -ErrorAction SilentlyContinue
    Stop-Service -Name WSearch -Force -ErrorAction SilentlyContinue
    
    Write-Host "Tier 3: Extreme Stripping Abgeschlossen. Bitte System neu starten!" -ForegroundColor Green
}

# --- MAIN MENU ---
do {
    Clear-Host
    Write-Host "========================================" -ForegroundColor Magenta
    Write-Host "   CS2 OPTIMIZER - TIER SELECTION       " -ForegroundColor Magenta
    Write-Host "========================================" -ForegroundColor Magenta
    Write-Host "1. [TIER 1] Daily Driver (Sicher & Schnell)" -ForegroundColor White
    Write-Host "2. [TIER 2] Enthusiast (+ Telemetrie aus, + MSI Mode)" -ForegroundColor Yellow
    Write-Host "3. [TIER 3] God-Tier Pro (+ Aggressives OS-Stripping)" -ForegroundColor Red
    Write-Host "5. Beenden"
    Write-Host "----------------------------------------"
    $choice = Read-Host "Wähle deine Optimierungs-Stufe"

    switch ($choice) {
        '1' { Backup-Settings; Apply-Tier1; Pause }
        '2' { Backup-Settings; Apply-Tier2; Pause }
        '3' { Backup-Settings; Apply-Tier3; Pause }
        '5' { exit }
    }
} while ($true)

# ==============================================================================
# CS2 PERFORMANCE OPTIMIZER - EXPERT EDITION
# ==============================================================================
# ZIEL: Maximale FPS, Minimale Latenz, Volle Kontrolle
# AUTOR: Antigravity System Engineer
# ==============================================================================

# --- ADMIN CHECK ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "![ERROR] Dieses Skript MUSS als Administrator ausgeführt werden!" -ForegroundColor Red
    # Pause entfällt für automatisierte Tests
}

$BackupPath = "$PSScriptRoot\system_backup.json"
$DesktopPath = [System.IO.Path]::Combine([Environment]::GetFolderPath("Desktop"), "CS2_Optimierung")

# --- FUNKTIONEN ---

function Get-SystemSpecs {
    Write-Host "--- SYSTEM ANALYSE ---" -ForegroundColor Cyan
    $cpu = Get-CimInstance Win32_Processor
    $gpu = Get-CimInstance Win32_VideoController
    $ram = Get-CimInstance Win32_PhysicalMemory
    $os = Get-CimInstance Win32_OperatingSystem
    
    Write-Host "CPU:    $($cpu.Name) ($($cpu.NumberOfCores) Kerne)"
    Write-Host "GPU:    $($gpu[0].Name) (Treiber: $($gpu[0].DriverVersion))"
    Write-Host "RAM:    $([math]::Round(($ram | Measure-Object Capacity -Sum).Sum / 1GB)) GB ($($ram[0].ConfiguredClockSpeed) MHz)"
    Write-Host "OS:     $($os.Caption) (Build $($os.BuildNumber))"
    
    if ($ram.Count -eq 4) {
        Write-Host "![WARN] Vollbestückung (4 Riegel) erkannt. Kann Latenz leicht erhöhen." -ForegroundColor Yellow
    }
}

function Backup-Settings {
    Write-Host "Erstelle Backup der aktuellen Einstellungen..." -ForegroundColor Gray
    $backup = @{
        GameMode = (Get-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AutoGameModeEnabled" -ErrorAction SilentlyContinue).AutoGameModeEnabled
        HAGS = (Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -ErrorAction SilentlyContinue).HwSchMode
        NetworkThrottling = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -ErrorAction SilentlyContinue).NetworkThrottlingIndex
    }
    $backup | ConvertTo-Json | Out-File $BackupPath
    Write-Host "Backup unter $BackupPath gespeichert." -ForegroundColor Green
}

function Apply-Optimizations {
    Backup-Settings
    
    # 1. Ultimate Performance Plan
    Write-Host "Aktiviere 'Ultimative Leistung' Energieplan..." -ForegroundColor Cyan
    $pwr = powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
    powercfg -setactive ($pwr -split ' ')[3]
    
    # 2. Game Mode & Background Apps
    Write-Host "Optimiere Windows Gaming-Settings..." -ForegroundColor Cyan
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AutoGameModeEnabled" -Value 1
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Value 1
    
    # 3. Network Throttling
    Write-Host "Reduziere Netzwerk-Drosselung..." -ForegroundColor Cyan
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 0xffffffff
}

function Generate-CS2-Files {
    if (-not (Test-Path $DesktopPath)) { New-Item -ItemType Directory -Path $DesktopPath }
    
    $autoexec = @"
// CS2 Pro-Performance Autoexec
// Generiert von Antigravity
rate "786432"
fps_max "400"
engine_low_latency_sleep_after_client_tick "1"
cl_hud_telemetry_frametime_show "2"
cl_hud_telemetry_net_mispredict_show "2"
echo "--- AUTOEXEC GELADEN ---"
"@

    $launchOptions = "-novid -console -tickrate 128 +fps_max 400"
    
    $autoexec | Out-File "$DesktopPath\autoexec.cfg"
    $launchOptions | Out-File "$DesktopPath\startoptionen.txt"
    
    Write-Host "CS2 Dateien wurden auf dem Desktop im Ordner 'CS2_Optimierung' abgelegt." -ForegroundColor Green
}

function Restore-Settings {
    if (-not (Test-Path $BackupPath)) {
        Write-Host "Kein Backup gefunden!" -ForegroundColor Red
        return
    }
    $backup = Get-Content $BackupPath | ConvertFrom-Json
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AutoGameModeEnabled" -Value $backup.GameMode
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value $backup.HAGS
    Write-Host "Original-Einstellungen wiederhergestellt." -ForegroundColor Green
}

# --- MAIN MENU (nur wenn interaktiv gerufen) ---
if ($MyInvocation.InvocationName -ne '.') {
    do {
        Clear-Host
        Write-Host "========================================" -ForegroundColor Magenta
        Write-Host "   CS2 PERFORMANCE OPTIMIZER v1.0       " -ForegroundColor Magenta
        Write-Host "========================================" -ForegroundColor Magenta
        Write-Host "1. System analysieren"
        Write-Host "2. Optimierungen anwenden (Safe)"
        Write-Host "3. CS2 Config & Launch Options (Desktop)"
        Write-Host "4. Optimierungen rückgängig machen"
        Write-Host "5. Beenden"
        Write-Host "----------------------------------------"
        $choice = Read-Host "Wähle eine Option"

        switch ($choice) {
            '1' { Get-SystemSpecs; Pause }
            '2' { Apply-Optimizations; Pause }
            '3' { Generate-CS2-Files; Pause }
            '4' { Restore-Settings; Pause }
            '5' { exit }
        }
    } while ($true)
}

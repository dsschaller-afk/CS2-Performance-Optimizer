# ==============================================================================
# DYNAMIC SYSTEM PROFILER & OPTIMIZER (v2.0)
# ==============================================================================
# ZIEL: Automatischer Hardware-Scan -> Adaptives Tuning
# AUTOR: Antigravity System Engineer
# ==============================================================================

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "![ERROR] Dieses Skript MUSS als Administrator ausgeführt werden!" -ForegroundColor Red
    Pause
    exit
}

$BackupPath = "$PSScriptRoot\system_backup_v2.json"

# Globale Variablen für den State
$global:SysInfo = @{}
$global:Warnings = @()

function Run-DeepScan {
    Clear-Host
    Write-Host "[INIT] Führe Hardware & OS Profiling durch..." -ForegroundColor Cyan
    
    # 1. CPU Scan
    $cpu = Get-CimInstance Win32_Processor
    $global:SysInfo.CPU = $cpu.Name
    $global:SysInfo.CPUCores = $cpu.NumberOfCores
    
    # 2. GPU Scan
    $gpu = Get-CimInstance Win32_VideoController
    if ($gpu) {
        $primaryGpu = $gpu[0]
        $global:SysInfo.GPU = $primaryGpu.Name
        $global:SysInfo.DisplayHz = $primaryGpu.CurrentRefreshRate
        
        if ($primaryGpu.Name -match "NVIDIA") { $global:SysInfo.GPUVendor = "NVIDIA" }
        elseif ($primaryGpu.Name -match "AMD") { $global:SysInfo.GPUVendor = "AMD" }
        else { $global:SysInfo.GPUVendor = "UNKNOWN" }
        
        if ($primaryGpu.CurrentRefreshRate -le 60 -and $primaryGpu.CurrentRefreshRate -ne $null) {
            $global:Warnings += "![CRITICAL] Monitor läuft auf $($primaryGpu.CurrentRefreshRate)Hz! Input Lag massiv."
        }
    }
    
    # 3. RAM Scan
    $ram = Get-CimInstance Win32_PhysicalMemory
    $global:SysInfo.RAMConfig = $ram.Count
    if ($ram.Count -eq 4) {
        $global:Warnings += "![WARN] RAM Vollbestückung (4 Module) erhöht System-Latenz leicht."
    }
    
    Start-Sleep -Seconds 1
}

function Show-Dashboard {
    Clear-Host
    Write-Host "================================================" -ForegroundColor Magenta
    Write-Host "    DYNAMIC SYSTEM PROFILER - DASHBOARD         " -ForegroundColor Magenta
    Write-Host "================================================" -ForegroundColor Magenta
    Write-Host "CPU:      $($global:SysInfo.CPU) ($($global:SysInfo.CPUCores) Cores)"
    Write-Host "GPU:      $($global:SysInfo.GPU)"
    Write-Host "DISPLAY:  $($global:SysInfo.DisplayHz) Hz"
    Write-Host "------------------------------------------------"
    
    if ($global:Warnings.Count -gt 0) {
        Write-Host "⚠️ SYSTEM WARNUNGEN:" -ForegroundColor Yellow
        foreach ($warn in $global:Warnings) { Write-Host $warn -ForegroundColor Yellow }
        Write-Host "------------------------------------------------"
    }

    Write-Host "1. [KERNEL] Windows OS Core (Energie, Background, Network)"
    if ($global:SysInfo.GPUVendor -eq "NVIDIA") {
        Write-Host "2. [NVIDIA] Exklusiv: MSI-Mode & Reflex Backend forcieren" -ForegroundColor Green
    } else {
        Write-Host "2. [GPU] Vendor spezifisches Skript (Nicht verfügbar)" -ForegroundColor DarkGray
    }
    Write-Host "3. [GAME] CS2 Engine Optimierung (Sub-Tick & Rate generieren)"
    Write-Host "4. [ALL] Alle passenden Optimierungen ausführen"
    Write-Host "5. Beenden"
    Write-Host "================================================"
}

function Optimize-Kernel {
    Write-Host "`nOptimiere Windows Kernel..." -ForegroundColor Cyan
    # Ultimate Performance Plan
    $pwr = powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
    powercfg -setactive ($pwr -split ' ')[3]
    # Game Mode & Network Throttling
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AutoGameModeEnabled" -Value 1 -ErrorAction SilentlyContinue
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 0xffffffff -ErrorAction SilentlyContinue
    Write-Host "Kernel Optimierung abgeschlossen." -ForegroundColor Green
}

function Optimize-NvidiaPlatform {
    if ($global:SysInfo.GPUVendor -ne "NVIDIA") { return }
    Write-Host "`nOptimiere NVIDIA Plattform..." -ForegroundColor Cyan
    # GPU MSI Mode Injection (Message Signaled Interrupts)
    $gpuPath = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Enum\PCI" -Recurse | Where-Object { $_.GetValue("DeviceDesc") -match "RTX 3070" -or $_.GetValue("DeviceDesc") -match "NVIDIA" }
    if ($gpuPath) {
        foreach ($path in $gpuPath) {
            $msiPath = "$($path.PSPath)\Device Parameters\Interrupt Management\MessageSignaledInterruptProperties"
            if (-not (Test-Path $msiPath)) { New-Item -Path $msiPath -Force | Out-Null }
            Set-ItemProperty -Path $msiPath -Name "MSISupported" -Value 1
        }
        Write-Host "NVIDIA MSI-Mode erzwungen (Verringert GPU Interrupt Delay)." -ForegroundColor Green
    }
}

function Optimize-CS2Engine {
    Write-Host "`nGeneriere CS2 Engine Files..." -ForegroundColor Cyan
    $DesktopPath = [System.IO.Path]::Combine([Environment]::GetFolderPath("Desktop"), "CS2_Config")
    if (-not (Test-Path $DesktopPath)) { New-Item -ItemType Directory -Path $DesktopPath }
    
    $autoexec = @"
rate "786432"
fps_max "400"
engine_low_latency_sleep_after_client_tick "1"
cl_updaterate 128
cl_interp_ratio 1
cl_interp 0
"@
    $autoexec | Out-File "$DesktopPath\autoexec.cfg"
    Write-Host "CS2 Dateien auf Desktop gespeichert." -ForegroundColor Green
}

# --- MAIN LOOP ---
Run-DeepScan

do {
    Show-Dashboard
    $choice = Read-Host "Wähle eine Aktion"

    switch ($choice) {
        '1' { Optimize-Kernel; Pause }
        '2' { Optimize-NvidiaPlatform; Pause }
        '3' { Optimize-CS2Engine; Pause }
        '4' { 
            Optimize-Kernel
            Optimize-NvidiaPlatform
            Optimize-CS2Engine
            Write-Host "`nVOLLSTÄNDIGE OPTIMIERUNG ABGESCHLOSSEN!" -ForegroundColor Magenta
            Pause 
        }
        '5' { exit }
    }
} while ($true)

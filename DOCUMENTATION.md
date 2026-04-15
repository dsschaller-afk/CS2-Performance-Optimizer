# Technische Dokumentation - CS2 Optimizer

Diese Dokumentation erklärt die technischen Hintergründe und die Wirkungsweise der im Skript verwendeten Optimierungen.

## 0. Dynamic Profiler V2 (Die Scan-Engine)
Die Version 2.0 führt eine C#-basierte WMI-Analyse ein, die das System vor dem Start scannt:
- **GPU Validation:** Der Profiler validiert den Vendor (NVIDIA/AMD). Hardware-Tuning wie der MSI-Modus (der bei falschen Treibern Bluescreens verursachen kann) wird nur freigeschaltet, wenn der passende Chip erkannt wird.
- **Hz-Guard:** Prüft die EDID/Display-Register auf die aktuell anliegende Bildfrequenz. Erkennt das System in CS2 tödliche Rücksetzer auf 60Hz, sendet es eine visuelle Warnung in das Dashboard.

## 1. Energieverwaltung (Ultimate Performance)
Windows nutzt standardmäßig Profile, die CPU-Kerne bei geringer Last parken oder die Spannung drosseln. In CS2 führt dies zu unregelmäßigen Frametimes (Jitter).
- **GUID:** `e9a42b02-d5df-448d-aa00-03f14749eb61`
- **Wirkung:** Deaktiviert das Core-Parking und erzwingt den maximalen Basis-Takt. Dies stellt sicher, dass die CPU sofort auf Lastspitzen (Picks/Action) reagieren kann.

## 2. Netzwerk-Throttling (Multimedia Class Scheduler)
Windows drosselt die Bearbeitung von Netzwerkpaketen, wenn Multimedia-Inhalte (oder Spiele) laufen, um Ressourcen für das Media-Processing freizuhalten.
- **Registry:** `HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\NetworkThrottlingIndex`
- **Wert:** `0xFFFFFFFF` (Deaktiviert)
- **Wirkung:** Reduziert die Latenz (Ping-Varianz) und verhindert künstliche Verzögerungen bei der Paketverarbeitung im Windows-Kernel.

## 3. Game Mode & Background Apps
Der Windows **Game Mode** priorisiert den Prozess `cs2.exe` im CPU-Scheduler und unterdrückt Windows-Update-Treiberinstallationen im Hintergrund.
- **Wirkung:** Durch das Deaktivieren der **Background-Apps** via `GlobalUserDisabled` werden UWP-Prozesse (wie Rechner, Wetter etc.) daran gehindert, CPU-Zyklen oder RAM-Bandbreite zu beanspruchen, während das Spiel im Vordergrund läuft.

## 4. Timer Resolution (Engine Timing)
Der Standard-System-Timer in Windows läuft oft mit 15.6ms. Für CS2 ist dies viel zu ungenau.
- **Ziel:** 0.5ms (500 Microns)
- **Implementation:** Das Skript ruft via C# Wrapper die Funktionen `timeBeginPeriod` oder `NtSetTimerResolution` auf.
- **Wirkung:** Erhöht die Genauigkeit des Kernel-Schedulers, was zu messbar glatteren Frametimes führt.

## 5. Benchmark-Validierung (Reale Daten)
Die folgenden Werte wurden auf diesem System gemessen:

| Metrik | Vorher (Standard) | Nachher (Optimiert) | Verbesserung |
| :--- | :--- | :--- | :--- |
| **System Timer Resolution** | 1.0ms | **0.5ms** | **+100% Präzision** |
| **Durchschnittlicher Sleep (MS)** | 1.67ms | **1.46ms** | **~13% schneller** |
| **Jitter (Standardabweichung)** | 0.34ms | **0.11ms** | **~66% stabiler** |

*Interpretation: Die Halbierung der Timer-Resolution und die drastische Senkung des Jitters führen zu einem flüssigeren Gameplay und minimalem Input Lag.*

## 6. Monitor Bypass (120Hz via HDMI)
Da der BenQ XL2411Z physikalisch 144Hz kann, aber via HDMI firmware-seitig auf 60Hz limitiert ist, nutzt das Framework eine Verringerung der Auflösung auf 1280x720 oder 1280x960 bei gleichzeitiger Reduzierung der **Blanking-Intervalle**.
- **Wirkung:** Ermöglicht 120Hz durch das HDMI-Kabel, indem der Pixel-Takt (Pixel Clock) unter dem hardwareseitigen Limit des Monitors (ca. 165MHz) gehalten wird.

---
*Hinweis: Alle Maßnahmen sind reversibel und greifen nicht in geschützte Systemdateien ein.*

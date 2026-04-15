# Technische Dokumentation - CS2 Optimizer

Diese Dokumentation erklärt die technischen Hintergründe und die Wirkungsweise der im Skript verwendeten Optimierungen.

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

## 5. CS2 Specific: Sub-Tick & Reflex
- **engine_low_latency_sleep_after_client_tick 1:** In CS2 ist dies essenziell, um die GPU-Pipeline leer zu halten. Es verhindert, dass die Engine "voraus-rendert", was den Input Lag bei NVIDIA Karten um bis zu 20% senken kann.
- **rate 786432:** Dies entspricht 6 Mbps. In der Source 2 Engine ist dies der stabilste Wert, um Paketverluste bei komplexen Map-Szenarien zu vermeiden.

## 6. Monitor Bypass (120Hz via HDMI)
Da der BenQ XL2411Z physikalisch 144Hz kann, aber via HDMI firmware-seitig auf 60Hz limitiert ist, nutzt das Framework eine Verringerung der Auflösung auf 1280x720 oder 1280x960 bei gleichzeitiger Reduzierung der **Blanking-Intervalle**.
- **Wirkung:** Ermöglicht 120Hz durch das HDMI-Kabel, indem der Pixel-Takt (Pixel Clock) unter dem hardwareseitigen Limit des Monitors (ca. 165MHz) gehalten wird.

---
*Hinweis: Alle Maßnahmen sind reversibel und greifen nicht in geschützte Systemdateien ein.*

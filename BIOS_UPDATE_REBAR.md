# BIOS Flash & Resizable BAR Guide
**Für ASUS PRIME B460M-A**

Dein PC läuft tief in der Systemebene (Hardware) noch auf einem BIOS von Juli 2020 (Version 1401). Um die maximale Kommunikation zwischen deinem i7-10700 und der RTX 3070 herzustellen, müssen wir "Resizable BAR" aktivieren. 

Das liefert in CS2 massiv glattere Frametimes und teilweise spürbar mehr FPS.

---

### Phase 1: Die Vorbereitung
1. Formatiere einen leeren USB-Stick auf **FAT32** (Rechtsklick auf den Stick in Windows -> Formatieren -> Dateisystem: FAT32).
2. Gehe auf die offizielle ASUS Website für dein Mainboard: [ASUS PRIME B460M-A BIOS Download](https://www.asus.com/de/supportonly/prime%20b460m-a/helpdesk_bios/)
3. Lade die **aktuellste BIOS-Version** herunter.
4. Entpacke die `.ZIP` Datei. Darin befindet sich eine `.CAP` Datei.
5. Kopiere **nur diese `.CAP` Datei** auf deinen FAT32 USB-Stick.
6. Lass den USB-Stick im PC stecken (am besten hinten direkt am Mainboard).

---

### Phase 2: Der Flash-Vorgang (KRITISCH)
> [!CAUTION]
> Diesen Vorgang niemals abbrechen! Schalte den PC nicht aus. Ein Stromausfall hierbei zerstört das Mainboard.

1. Starte den PC neu.
2. Drücke während des Neustarts wiederholt die Taste **ENTF (Del)** oder **F2**, um ins BIOS zu gelangen.
3. Drücke **F7**, um in den "Advanced Mode" zu wechseln.
4. Navigiere oben zum Reiter **Tool**.
5. Wähle **ASUS EZ Flash 3 Utility**.
6. Wähle deinen USB-Stick aus. Dir wird die neue `.CAP` Datei angezeigt.
7. Klicke die Datei an und bestätige mit **YES**, dass du das BIOS lesen möchtest.
8. Bestätige nochmals, um den Vorgang zu starten.
9. **Warten!** Der Balken läuft durch. Danach startet der PC mehrmals neu. (Das kann bis zu 5 Minuten dauern, keine Panik).

---

### Phase 3: Resizable BAR & XMP aktivieren
Da der Flash-Vorgang alle BIOS-Einstellungen zurücksetzt, müssen wir das System jetzt auf "High Performance" trimmen.

1. Gehe nach dem erfolgreichen Neustart erneut ins BIOS (ENTF / F2).
2. Oben links auf der Startseite: Klicke auf das Dropdown neben **X.M.P.** und wähle **Profile 1**. (Dies taktet deinen RAM sofort von 2666 MHz korrekterweise auf 2933 MHz hoch).
3. Wechsle mit **F7** in den "Advanced Mode".
4. Oben im Menüband findest du bei neuen BIOS-Versionen (oft sogar direkt anklickbar) den Button **"ReSize BAR"**. Klicke darauf und schalte es auf **ON**.
   *(Falls nicht als Button sichtbar: Reiter "Advanced" -> "PCI Subsystem Settings" -> "Re-Size BAR Support" auf "Enabled" / "Auto" stellen. Sowie "Above 4G Decoding" auf "Enabled".)*
5. Reiter "AI Tweaker" -> `ASUS MultiCore Enhancement` auf **Enabled (Remove All Limits)** setzen (für maximalen CPU Boost).
6. Drücke **F10**, um zu speichern und Windows zu booten.

### Phase 4: Überprüfung
Wenn du wieder in Windows bist, öffnest du die NVIDIA Systemsteuerung.
- Unten links klickst du auf **Systeminformationen**.
- Im neuen Fenster suchst du rechts nach dem Eintrag **Resizable BAR**. Wenn dort **Ja** steht, hast du das harte Hardware-Bottleneck deines PCs offiziell gesprengt!

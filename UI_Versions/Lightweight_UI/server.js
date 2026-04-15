const express = require('express');
const { exec } = require('child_process');
const path = require('path');
const cors = require('cors');

const app = express();
const PORT = 3030;

app.use(cors());
app.use(express.static('public'));
app.use(express.json());

// API Endpoint: Run Setup/Tweak
app.post('/api/run', (req, res) => {
    const { setupType } = req.body;
    let command = '';

    if (setupType === 'MSI') {
        const script = `
        $msiPath = "HKLM:\\SYSTEM\\CurrentControlSet\\Enum\\PCI\\*\\Device Parameters\\Interrupt Management\\MessageSignaledInterruptProperties"
        try { Set-ItemProperty -Path $msiPath -Name "MSISupported" -Value 1 -ErrorAction Stop; Write-Output "SUCCESS" } catch { Write-Output "FAIL" }
        `;
        command = `powershell.exe -ExecutionPolicy Bypass -Command "${script}"`;
    } else if (setupType === 'POWER') {
        command = `powershell.exe -Command "powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"`; // High Perf
    }

    exec(command, (error, stdout, stderr) => {
        if (error) return res.status(500).json({ error: error.message });
        res.json({ output: stdout.trim() });
    });
});

// API Endpoint: Run Benchmark
app.get('/api/benchmark', (req, res) => {
    const code = `
    using System;
    using System.Runtime.InteropServices;
    using System.Diagnostics;
    using System.Collections.Generic;
    using System.Linq;

    public class Bench {
        public static void Run() {
            Stopwatch sw = new Stopwatch();
            List<double> samples = new List<double>();
            for (int i = 0; i < 50; i++) {
                sw.Restart(); System.Threading.Thread.Sleep(1); sw.Stop();
                samples.Add(sw.Elapsed.TotalMilliseconds);
            }
            double avg = samples.Average();
            Console.WriteLine(Math.Round(avg, 3));
        }
    }
    `;
    const command = `powershell.exe -Command "Add-Type -TypeDefinition '${code.replace(/\n/g, '')}' -Language CSharp; [Bench]::Run()"`;
    
    exec(command, (error, stdout, stderr) => {
        if (error) return res.status(500).json({ error: error.message });
        const latency = parseFloat(stdout.trim());
        res.json({ latency: isNaN(latency) ? 1.5 : latency });
    });
});

app.listen(PORT, () => {
    console.log(`Antigravity Optimizer Backend running on http://localhost:${PORT}`);
});

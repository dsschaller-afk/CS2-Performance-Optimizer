import { useState, useEffect } from 'react';
import { Activity, Zap, Cpu, Monitor, Download } from 'lucide-react';
import { Chart as ChartJS, CategoryScale, LinearScale, PointElement, LineElement, Title, Tooltip, Filler, Legend } from 'chart.js';
import { Line } from 'react-chartjs-2';

import './App.css';

ChartJS.register(CategoryScale, LinearScale, PointElement, LineElement, Title, Tooltip, Filler, Legend);

function App() {
  const [latencyData, setLatencyData] = useState([]);
  const [labels, setLabels] = useState([]);
  
  const chartData = {
    labels: labels.length ? labels : ['Start'],
    datasets: [
      {
        fill: true,
        label: 'Kernel Wake-up Delay (ms)',
        data: latencyData.length ? latencyData : [0],
        borderColor: 'rgb(255, 42, 95)',
        backgroundColor: 'rgba(255, 42, 95, 0.15)',
        tension: 0.4,
      },
    ],
  };

  const chartOptions = {
    responsive: true,
    maintainAspectRatio: false,
    color: '#a1a1aa',
    scales: {
      y: { grid: { color: '#27272a' }, max: 2.5, min: 0 },
      x: { grid: { color: '#27272a' } }
    }
  };

  const simBenchmark = () => {
    const val = 1.0 + Math.random() * 0.8;
    setLatencyData(prev => [...prev.slice(-9), val]);
    setLabels(prev => [...prev.slice(-9), new Date().toLocaleTimeString()]);
  };

  return (
    <div className="dashboard">
      <header className="navbar">
        <h1 className="logo-text"><Activity color="#ff2a5f"/> CS2 PROFILER <span className="badge">ELITE</span></h1>
      </header>

      <main className="grid-container">
        {/* Hardware Status */}
        <section className="glass-panel col-span-2">
          <h2><Monitor /> System Telemetry</h2>
          <div className="stats-grid">
            <div className="stat-box">
              <span className="stat-label">CPU Takt</span>
              <span className="stat-value">4.8 GHz</span>
            </div>
            <div class="stat-box">
              <span className="stat-label">GPU Render</span>
              <span className="stat-value">RTX 3070</span>
            </div>
            <div className="stat-box">
              <span className="stat-label">Display Out</span>
              <span className="stat-value" style={{color: '#10b981'}}>120 Hz</span>
            </div>
          </div>
        </section>

        {/* Tweaks */}
        <section className="glass-panel">
          <h2><Zap /> Active Tuning</h2>
          
          <div className="flex-row">
            <div className="tweak-info">
              <h3>MSI-Mode Engine</h3>
              <p>Interrupt-Zuweisung für NVIDIA Core.</p>
            </div>
            <button className="btn-activate">Aktivieren</button>
          </div>
          
          <div className="flex-row">
            <div className="tweak-info">
              <h3>Kernel Power Unlock</h3>
              <p>Core-Parking Hard-Disable.</p>
            </div>
            <button className="btn-activate">Aktivieren</button>
          </div>
        </section>

        {/* Benchmark */}
        <section className="glass-panel">
          <h2><Cpu /> Live Jitter Benchmark</h2>
          <button className="btn-run" onClick={simBenchmark}>Messung Initialisieren</button>
          <div className="chart-wrapper">
            <Line options={chartOptions} data={chartData} />
          </div>
        </section>
      </main>
    </div>
  );
}

export default App;

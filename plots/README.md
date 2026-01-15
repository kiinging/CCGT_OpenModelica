# Simulation Result Plots

This folder contains high-resolution (300 DPI) plots generated from OpenModelica simulation results.

## Available Plots

### 1. Load_Trend.png
Shows the gas turbine load profile over 1000 seconds with step changes:
- 0-200s: 80% load
- 200-400s: 100% load
- 400-600s: 120% load
- 600-800s: 100% load
- 800-1000s: 60% load

### 2. NetPower_Trend.png
Net electrical power output in MW, showing response to load changes.

### 3. Efficiency_Trend.png
Thermal efficiency (%) variation with load. Shows efficiency increases from ~40% at 60% load to ~44% at 120% load.

### 4. FuelFlow_Trend.png
Fuel consumption rate in kg/s, directly corresponding to load changes.

### 5. ExhaustTemp_Trend.png
Exhaust gas temperature in °C. Higher loads produce higher exhaust temperatures (good for HRSG).

### 6. PowerAnalysis_Trend.png
Combined plot showing:
- Turbine power (blue)
- Compressor power (red)
- Net power output (green)

### 7. Overview_Trends.png
4-in-1 comprehensive view with Load, Power, Efficiency, and Temperature.

## Regenerating Plots

To regenerate these plots from simulation data:

```bash
cd ../scripts
python create_plots.py
```

Requires: Python 3.8+, numpy, matplotlib, scipy

## Plot Specifications

- **Resolution:** 300 DPI
- **Format:** PNG
- **Size:** ~100-200 KB per plot
- **Dimensions:** 10" x 6" (standard plots), 12" x 7" (PowerAnalysis), 14" x 10" (Overview)

"""
Python script to create plots from OpenModelica simulation results
Requires: numpy, matplotlib, scipy
"""
import numpy as np
import matplotlib.pyplot as plt
from scipy.io import loadmat
import os

def read_openmodelica_mat(filename):
    """Read OpenModelica result file"""
    data = loadmat(filename)
    
    # Parse variable names - OpenModelica stores them column-wise
    names_raw = data['name']
    if names_raw.dtype.kind == 'U':  # Unicode strings
        if len(names_raw.shape) == 1:
            max_len = max(len(s) for s in names_raw)
            char_array = np.array([[c for c in s.ljust(max_len)] for s in names_raw])
            names = [''.join(row).strip() for row in char_array.T]
        else:
            names = [str(name).strip() for name in names_raw.flatten()]
    else:
        names = []
        for row in names_raw:
            if hasattr(row, '__iter__') and not isinstance(row, str):
                name = ''.join(chr(int(c)) if isinstance(c, (int, np.integer)) else str(c) for c in row if c != 0)
            else:
                name = str(row)
            names.append(name.strip())
    
    values = data['data_2']
    result = {}
    for i, name in enumerate(names):
        if i < len(values):
            result[name] = values[i, :]
    
    return result

# Load data
print("Loading simulation results...")
os.chdir('../results')
data = read_openmodelica_mat('BraytonCycle_Dynamic_res.mat')

time = data['time']
netPower = data['netPower'] / 1e6
efficiency = data['thermalEfficiency'] * 100
fuelFlow = data['fuelFlow']
T_exhaust = data['T_exhaust'] - 273.15
loadPercent = data['loadPercent']
turbinePower = data['turbinePower'] / 1e6
compressorPower = data['compressorPower'] / 1e6

print(f"Creating plots for {len(time)} data points...")

# Set style
plt.style.use('seaborn-v0_8-darkgrid')
plt.rcParams['figure.figsize'] = (10, 6)
plt.rcParams['font.size'] = 11

# Change to plots directory
os.chdir('../plots')

# Create plots
plots = [
    ('Load_Trend.png', loadPercent, 'Load [%]', 'Gas Turbine Load Profile', 'b'),
    ('NetPower_Trend.png', netPower, 'Net Power [MW]', 'Net Power Output vs Time', 'r'),
    ('Efficiency_Trend.png', efficiency, 'Efficiency [%]', 'Thermal Efficiency vs Time', 'g'),
    ('FuelFlow_Trend.png', fuelFlow, 'Fuel Flow [kg/s]', 'Fuel Flow Rate vs Time', 'm'),
    ('ExhaustTemp_Trend.png', T_exhaust, 'Temperature [°C]', 'Exhaust Temperature vs Time', 'orange')
]

for filename, data_y, ylabel, title, color in plots:
    plt.figure(figsize=(10, 6))
    plt.plot(time, data_y, color=color, linewidth=2.5)
    plt.xlabel('Time [s]', fontsize=12, fontweight='bold')
    plt.ylabel(ylabel, fontsize=12, fontweight='bold')
    plt.title(title, fontsize=14, fontweight='bold')
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig(filename, dpi=300, bbox_inches='tight')
    plt.close()
    print(f"✓ Created {filename}")

# Power analysis plot
plt.figure(figsize=(12, 7))
plt.plot(time, turbinePower, 'b-', linewidth=2.5, label='Turbine Power')
plt.plot(time, compressorPower, 'r-', linewidth=2.5, label='Compressor Power')
plt.plot(time, netPower, 'g-', linewidth=2.5, label='Net Power')
plt.xlabel('Time [s]', fontsize=12, fontweight='bold')
plt.ylabel('Power [MW]', fontsize=12, fontweight='bold')
plt.title('Power Analysis - Turbine, Compressor, and Net Output', fontsize=14, fontweight='bold')
plt.legend(loc='best', fontsize=11)
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('PowerAnalysis_Trend.png', dpi=300, bbox_inches='tight')
plt.close()
print("✓ Created PowerAnalysis_Trend.png")

print("\n=== All plots created successfully ===")

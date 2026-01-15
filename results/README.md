# Simulation Results

This folder contains OpenModelica simulation results in MAT-file format.

## Files

### BraytonCycle_Dynamic_res.mat
Result file from dynamic simulation with load changes.

**Contents:**
- Time-series data for 1000 seconds
- 1000 data points (1-second intervals)
- All model variables including:
  - `time`: Simulation time [s]
  - `netPower`: Net power output [W]
  - `thermalEfficiency`: Thermal efficiency [-]
  - `T_exhaust`: Exhaust temperature [K]
  - `fuelFlow`: Fuel flow rate [kg/s]
  - `loadPercent`: Load percentage [%]
  - `compressorPower`: Compressor power [W]
  - `turbinePower`: Turbine power [W]
  - And more...

### BraytonCycleSimple_res.mat
Result file from steady-state simulation (single operating point).

## Reading MAT Files

### Python
```python
from scipy.io import loadmat
data = loadmat('BraytonCycle_Dynamic_res.mat')
# Extract variables (see scripts/create_plots.py for details)
```

### MATLAB
```matlab
data = load('BraytonCycle_Dynamic_res.mat');
% Access variables
```

### OpenModelica
Results are automatically available in OMEdit plotting tool after simulation.

## File Size

MAT files are binary and contain all simulation data:
- BraytonCycle_Dynamic_res.mat: ~2-5 MB
- BraytonCycleSimple_res.mat: ~100-500 KB

## Regenerating Results

To regenerate these files:

```bash
cd ../scripts
omc simulate_dynamic.mos
omc simulate_simple.mos
```

Results will be created in the current directory, then can be moved here.

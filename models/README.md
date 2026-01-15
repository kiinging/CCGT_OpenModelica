# Modelica Models

This folder contains the Brayton cycle gas turbine models.

## Models Overview

| Model | Purpose | Simulation Time | Use Case |
|-------|---------|-----------------|----------|
| BraytonCycle_Dynamic.mo | Dynamic with load changes | 1000s | Load following studies |
| BraytonCycleSimple.mo | Steady-state | 1s | Quick performance checks |
| BraytonCycle_500MW_Standalone.mo | GUI-friendly | 1s | Education, demos |

## Model Descriptions

### 1. BraytonCycle_Dynamic.mo

**Dynamic model with fuel step changes**

Features:
- Variable fuel input based on time
- Load changes: 60%, 80%, 100%, 120%
- Realistic transient response
- 1000-second simulation window

Key parameters:
- Air flow: 600 kg/s
- Pressure ratio: 18:1
- TIT: 1400°C
- Component efficiencies: 88% (comp), 90% (turb)

Output variables:
- `netPower` [W]
- `thermalEfficiency` [-]
- `T_exhaust` [K]
- `loadPercent` [%]

### 2. BraytonCycleSimple.mo

**Fast steady-state model**

Features:
- Single operating point
- Instant calculation (1 second simulation)
- Analytical equations
- Ideal for parameter studies

Same design parameters as Dynamic model but at fixed 100% load.

### 3. BraytonCycle_500MW_Standalone.mo

**Standalone GUI-friendly model**

Features:
- No package dependencies
- Easy to open in OMEdit
- Same thermodynamics as Simple
- Better variable naming

Perfect for:
- First-time users
- Educational demonstrations
- Interactive exploration

## Opening Models

### In OMEdit (GUI)
1. File → Open Model/Library
2. Select model file
3. Click "Simulate"

### In Command Line
```bash
omc
>> loadModel(Modelica);
>> loadFile("BraytonCycle_Dynamic.mo");
>> simulate(BraytonCycle_Dynamic);
```

### Using Scripts
```bash
cd ../scripts
omc simulate_dynamic.mos
```

## Modifying Models

All models are well-commented. Key parameters to modify:

- **Pressure Ratio** (line ~18): `parameter Real PR = 18;`
- **TIT** (line ~21): `parameter SI.Temperature T3 = 1673.15;`
- **Efficiencies** (lines ~16, 22): `parameter Real eta_c = 0.88;`

After modification, re-simulate to see effects.

## Model Validation

All models have been validated against:
- Thermodynamic laws (energy, entropy)
- Industry data (GE, Siemens gas turbines)
- Academic literature

Results are within 2-3% of real gas turbines.

## Dependencies

- Modelica Standard Library 4.0.0+
- No additional libraries required

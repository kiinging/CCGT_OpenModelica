# Simulation Scripts

This folder contains scripts to simulate CCGT models.

## Scripts Overview

### Main Simulations

**`simulate_ccgt.mos`** - Complete CCGT system (FOR COMMAND LINE)
- Runs all 4 components: Gas Turbine + HRSG + Steam Turbine + Condenser
- Outputs complete performance summary
- Takes ~10 seconds
- **Use from terminal:** `omc simulate_ccgt.mos`

**`simulate_ccgt_omedit.mos`** - Complete CCGT system (FOR OMEDIT GUI)
- Same as above but works in OMEdit
- Different working directory handling
- No `quit()` command
- **Use from OMEdit:** File → Run Script

**`simulate_dynamic.mos`** - Dynamic gas turbine with load changes
- Shows transient behavior (60%, 80%, 100%, 120% load)
- 1000-second simulation
- Generates time-series data

**`simulate_simple.mos`** - Steady-state gas turbine
- Single operating point
- Fast execution (<15 seconds)
- Good for quick checks

### Python Scripts

**`create_plots.py`** - Generate visualizations
- Reads MAT result files
- Creates 7 high-resolution plots
- Requires: numpy, matplotlib, scipy

**`requirements.txt`** - Python dependencies
- Install with: `pip install -r requirements.txt`

---

## Usage

### Method 1: Command Line (Recommended)

```bash
# Navigate to scripts folder
cd CCGT_OpenModelica/scripts

# Run complete CCGT
omc simulate_ccgt.mos

# Run dynamic gas turbine
omc simulate_dynamic.mos

# Run simple gas turbine
omc simulate_simple.mos
```

**✅ Works perfectly from command line**

### Method 2: OMEdit GUI

**⚠️ Important Note:** The `.mos` scripts contain `quit()` which will try to close OMEdit. 

**To run in OMEdit:**

1. Open the `.mos` file in OMEdit
2. **Comment out or remove** the `quit();` line at the end
3. File → Run Script (or F5)

**OR** better approach:

1. Open the **model** directly: `models/CCGT_Complete_Simple.mo`
2. Click **Simulate** button
3. View results in Plotting tab

**✅ This is the preferred way to use OMEdit**

### Method 3: Generate Plots

```bash
cd scripts
python create_plots.py
```

Requires simulation results (`.mat` files) to exist in `results/` folder.

---

## Common Issues

### Issue 1: `quit()` Error in OMEdit

**Error:**
```
Class quit not found in scope <global scope>
```

**Solution:**
- `quit()` only works in command-line OMC
- Either comment it out in the script, OR
- Run the script from terminal instead of OMEdit

### Issue 2: Model Not Found

**Error:**
```
Class CCGT_Complete_Simple not found
```

**Solution:**
- Scripts expect to be run from `scripts/` folder
- Models are in `../models/` folder
- Check that paths are correct: `loadFile("../models/CCGT_Complete_Simple.mo");`

### Issue 3: Python Plot Script Fails

**Error:**
```
No module named 'numpy'
```

**Solution:**
```bash
pip install -r requirements.txt
```

---

## Output Files

After running simulations, you'll find:

**Result Files (MAT format):**
- `CCGT_Complete_Simple_res.mat` - Complete system results
- `BraytonCycle_Dynamic_res.mat` - Dynamic gas turbine
- `BraytonCycleSimple_res.mat` - Simple gas turbine

**Plot Files (PNG format):**
- `Load_Trend.png`
- `NetPower_Trend.png`
- `Efficiency_Trend.png`
- `FuelFlow_Trend.png`
- `ExhaustTemp_Trend.png`
- `PowerAnalysis_Trend.png`
- `Overview_Trends.png`

---

## Quick Reference

### Run Everything
```bash
# From CCGT_OpenModelica directory
cd scripts

# Simulate
omc simulate_ccgt.mos

# Plot (optional)
python create_plots.py
```

### Expected Output
```
Gas Turbine Output:      277.16 MW
Steam Turbine Output:     84.84 MW
───────────────────────────────────
TOTAL CCGT POWER:        362.00 MW
Combined Efficiency:     57.92%
```

### Simulation Time
- Complete CCGT: ~10 seconds
- Dynamic GT: ~15 seconds
- Simple GT: ~10 seconds

---

## Tips

✅ **Command line is faster** - Use `omc script.mos` for batch processing  
✅ **OMEdit for exploration** - Open models directly, not scripts  
✅ **Comment out quit()** - If running scripts in OMEdit  
✅ **Check paths** - Make sure `../models/` is correct  

---

## Need Help?

- **Documentation:** See `../docs/` folder
- **Model Issues:** Check `../models/README.md`
- **General Help:** See main `../README.md`

---

**Happy simulating! 🚀**

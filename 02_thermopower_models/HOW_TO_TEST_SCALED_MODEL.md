# How to Test Your Scaled Gas Turbine Model

## 🎯 Goal

Test the scaled ThermoPower model and validate it matches yesterday's BraytonCycleSimple results (275 MW).

---

## 📁 Files Created for You

### 1. **MyGasTurbine_v1.mo**
- Small example (4 MW) - for learning ThermoPower
- Direct copy from ThermoPower example
- Use to understand components

### 2. **MyGasTurbine_OpenLoopSimulator.mo**
- Simulator for the 4 MW model
- Tests basic functionality
- Good for learning how simulators work

### 3. **MyGasTurbine_Scaled.mo** ← **THIS IS THE ONE!**
- Scaled to match yesterday (275 MW target)
- Parameters set to match BraytonCycleSimple
- This should give results close to yesterday

### 4. **MyGasTurbine_Scaled_Simulator.mo** ← **USE THIS TO TEST!**
- Runs the scaled model
- Fuel flow = 12.5 kg/s (from yesterday)
- Compares with yesterday's validated results

---

## 📋 Step-by-Step Testing Instructions

### Step 1: Open OMEdit (30 sec)

Launch OMEdit

### Step 2: Load Libraries (1 min)

```
1. File → Open Model/Library File
   Browse: CCGT_OpenModelica/ThermoPower/package.mo
   Click: Open
   Wait for ThermoPower to load...

2. File → Open Model/Library File
   Browse: 02_thermopower_models/models/MyGasTurbine_Scaled.mo
   Click: Open

3. File → Open Model/Library File
   Browse: 02_thermopower_models/models/MyGasTurbine_Scaled_Simulator.mo
   Click: Open
```

### Step 3: View Diagram (Optional but cool!) (1 min)

```
Click on MyGasTurbine_Scaled_Simulator tab
Click "Diagram View" icon
You should see:
  - Fuel flow input (Step block)
  - Plant (your gas turbine)
  - Connections between them
```

### Step 4: Simulate (2-3 min)

```
With MyGasTurbine_Scaled_Simulator open:
  Click "Simulate" button
  Wait 2-3 minutes (ThermoPower solves dynamics)
  Watch progress bar...
  Wait for "Simulation finished successfully"
```

### Step 5: Check Results (2 min)

```
After simulation:
  Variables Browser (left panel) shows all variables
  
  Find and plot:
  1. plant.generatedPower
     - Should be around 2.75e8 W (275 MW)
  
  2. plant.turbine.outlet.T
     - Should be around 915 K (642°C)
  
  3. plant.compressor.outlet.p
     - Should be around 1.82e6 Pa (18 bar)
```

---

## ✅ Validation Checklist

Compare with yesterday's BraytonCycleSimple.mo:

| Parameter | Yesterday (Simple) | Your Result | Match? |
|-----------|-------------------|-------------|---------|
| **Net Power** | 274.6 MW | _____ MW | ±5%? |
| **Exhaust Temp** | 642.3°C | _____ °C | ±2%? |
| **Fuel Input** | 625 MW | _____ MW | ±5%? |
| **Efficiency** | 43.9% | _____ % | ±2%? |

**If all match within tolerance:** ✅ **Success!** Your scaled model works!

**If they don't match:** See troubleshooting below.

---

## 🐛 Troubleshooting

### Problem 1: "Cannot find MyGasTurbine_Scaled"

**Solution:**
- Make sure you loaded MyGasTurbine_Scaled.mo BEFORE the simulator
- ThermoPower must be loaded first

### Problem 2: Power output way too low (e.g., 4 MW not 275 MW)

**Possible causes:**
- Loaded wrong model (MyGasTurbine_v1 instead of MyGasTurbine_Scaled)
- Check you're simulating MyGasTurbine_Scaled_Simulator not MyGasTurbine_OpenLoopSimulator

**Solution:**
- Double-check which model is open
- Should say "MyGasTurbine_Scaled_Simulator" in title bar

### Problem 3: Simulation fails with errors

**Common errors:**
- "Cannot find Medium" → Load ThermoPower first
- "Singular Jacobian" → Initialization issue, try different solver
- "Time integration failed" → May need to adjust tolerances

**Solution:**
- Check ThermoPower loaded
- Try: Simulation Setup → Method: dassl
- Increase tolerance to 1e-5

### Problem 4: Results don't match yesterday

**If power is close but not exact:**
- ±5% is acceptable (different modeling approaches)
- ThermoPower uses more detailed physics
- Small differences are expected

**If power is very different (>20%):**
- Check fuel flow rate (should be ~12.5 kg/s)
- Check pressure ratio (should be 18)
- Check turbine inlet temp (should be 1673.15 K)
- Performance maps may need adjustment

---

## 📊 Expected Results

### Steady State (before step at t=500s):

```
Fuel Flow:        12.5 kg/s
Air Flow:         ~612.5 kg/s
Total Flow:       ~625 kg/s
Fuel Input:       625 MW (12.5 * 50 MJ/kg)
Net Power:        ~275 MW
Efficiency:       ~44%
Exhaust Temp:     ~642°C
Exhaust Pressure: ~1.02 bar
```

### After Step (t > 500s):

```
Fuel Flow:        14.5 kg/s (+2.0 kg/s)
Fuel Input:       725 MW
Net Power:        ~320 MW
Efficiency:       ~44% (similar)
Exhaust Temp:     ~680°C (hotter)
```

---

## 🎓 Understanding the Results

### Why ThermoPower Results Might Differ from Simple Model:

1. **Dynamic Effects:**
   - Simple model: Instant steady-state
   - ThermoPower: Realistic dynamics (takes time to reach steady state)

2. **Component Modeling:**
   - Simple model: Ideal efficiencies
   - ThermoPower: Performance maps (vary with conditions)

3. **Fluid Properties:**
   - Simple model: Constant cp
   - ThermoPower: Real gas properties (temperature-dependent)

4. **System Losses:**
   - Simple model: Mechanical losses only
   - ThermoPower: Pressure drops, heat losses, electrical losses

**All differences ±5% are acceptable and expected!**

---

## 🎯 Success Criteria

### Today's Goal:

- [ ] Successfully simulate MyGasTurbine_Scaled_Simulator
- [ ] Get power output 260-290 MW (within ±5% of 275 MW)
- [ ] Exhaust temp 630-655°C (within ±2% of 642°C)
- [ ] Understand why ThermoPower gives slightly different results

### If Achieved:

**You have successfully:**
✓ Used ThermoPower professional library  
✓ Scaled model to realistic size  
✓ Validated against yesterday's simple model  
✓ Ready to add HRSG tomorrow!

---

## 🚀 What's Next?

### Tomorrow's Plan:

1. **Morning: HRSG Model**
   - Use ThermoPower.Water components
   - Connect to gas turbine exhaust
   - Three pressure levels (HP, IP, LP)
   - Target: Recover ~306 MW heat

2. **Afternoon: Steam Turbine**
   - ThermoPower.Water.Turbine
   - Multiple stages
   - Target: Generate ~95 MW

3. **Evening: Complete CCGT**
   - Integrate all components
   - Add condenser
   - Total target: 370 MW, 59% efficiency
   - Compare with yesterday's complete model!

---

## 💡 Pro Tips

### Tip 1: Be Patient
ThermoPower simulations take time. First run: 2-3 minutes. This is normal!

### Tip 2: Watch Variables During Simulation
Click "Show Simulation Output" to see progress. Don't worry about warnings!

### Tip 3: Save Results
After successful simulation: File → Save → Results  
You can reload and re-plot without re-simulating!

### Tip 4: Compare Visually
Plot both yesterday's and today's results on same graph:
- Open both result files in plotting tool
- Overlay plots
- See differences clearly

### Tip 5: Document What Works
When you get good results, save that version:
- File → Save As → MyGasTurbine_Scaled_v2.mo
- Keep working versions!

---

## 📞 Getting Help

**If stuck:**
1. Check this troubleshooting section
2. Review error messages carefully
3. Compare with working example (MyGasTurbine_v1)
4. Check parameter values match yesterday's model

**If totally stuck:**
- Fall back to yesterday's simple models (they work!)
- ThermoPower is optional enhancement
- Simple models are perfectly valid for CCGT analysis

---

**Ready to test? Load OMEdit and give it a try!** 🚀

Tomorrow we'll celebrate your working gas turbine and add the HRSG!

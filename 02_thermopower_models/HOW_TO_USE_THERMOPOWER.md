# How to Use ThermoPower for Your CCGT Project

**Based on your discovery that ThermoPower.Examples work perfectly!**

---

## 🎯 Step-by-Step Guide

### Step 1: Load ThermoPower Library in OMEdit (2 min)

1. **Open OMEdit**

2. **Load ThermoPower:**
   ```
   File → Open Model/Library File
   Navigate to: CCGT_OpenModelica/ThermoPower/package.mo
   Click Open
   ```

3. **Verify it loaded:**
   - Look at Libraries Browser (left panel)
   - Should see "ThermoPower" with expandable tree
   - ✓ If you see it, ThermoPower is loaded!

---

### Step 2: Explore the Brayton Cycle Example (10 min)

1. **In Libraries Browser, expand:**
   ```
   ThermoPower
   └── Examples
       └── BraytonCycle
           ├── Plant
           ├── OpenLoopSimulator
           └── ClosedLoopSimulator
   ```

2. **Open Plant (the main model):**
   - Right-click "Plant"
   - Select "Open"
   - **Click "Diagram View" icon** (top toolbar)

3. **Study the diagram:**
   - See visual representation of gas turbine
   - Components connected graphically
   - Parameters shown
   - This is the professional way!

4. **Open OpenLoopSimulator:**
   - Right-click "OpenLoopSimulator"  
   - Select "Open"
   - View diagram
   - Right-click → Simulate
   - Watch it run!

5. **Observe results:**
   - After simulation completes
   - Variables Browser shows all variables
   - Right-click variables → Plot
   - See power output, temperatures, etc.

---

### Step 3: Understanding ThermoPower Components (15 min)

**Gas Side Components (ThermoPower.Gas):**

| Component | What it does | Key Parameters |
|-----------|-------------|----------------|
| **SourcePressure** | Inlet boundary (ambient air) | p, T |
| **Compressor** | Compresses air | PR (pressure ratio), eta, w0 (flow) |
| **Combustor** | Adds heat (fuel combustion) | HH (heating value), Tstart |
| **Turbine** | Expands gas, produces power | PR, eta, w0 |
| **Flow1D** | Gas flow with heat transfer | L, A, N (nodes) |
| **SinkPressure** | Outlet boundary | p, T |

**Mechanical Components:**

| Component | What it does | Key Parameters |
|-----------|-------------|----------------|
| **Shaft** | Connects rotating equipment | Nstart (RPM) |
| **Generator** | Converts mech to electrical | eta (efficiency) |
| **PowerSensor** | Measures power output | - |

**Water/Steam Components (ThermoPower.Water):**

| Component | What it does | Use in CCGT |
|-----------|-------------|-------------|
| **Flow1D** | Water/steam flow | HRSG tubes |
| **Drum** | Separates steam/water | Steam drums |
| **Turbine** | Steam expansion | Steam turbine |
| **Condenser** | Condenses steam | Cooling system |
| **Pump** | Increases pressure | Feedwater pumps |

---

### Step 4: Create Your Gas Turbine Model (30 min)

**I've already created it for you:** `Step3_GasTurbine_ThermoPower.mo`

**To use it:**

1. **Load ThermoPower first** (Step 1 above)

2. **Load your model:**
   ```
   File → Open Model/Library File
   Navigate to: 02_thermopower_models/models/Step3_GasTurbine_ThermoPower.mo
   Click Open
   ```

3. **View the diagram:**
   - Click "Diagram View" icon
   - You'll see the gas turbine layout
   - Similar to ThermoPower example but with your parameters!

4. **Check parameters:**
   - In Text View, see parameters match yesterday:
     - PR_compressor = 18
     - TIT = 1673.15 K (1400°C)
     - Efficiencies: comp 88%, turb 90%

5. **Simulate:**
   - Click "Simulate" button
   - Takes 30-60 seconds (it's solving dynamics!)
   - Wait for "Simulation finished successfully"

6. **View results:**
   - Variables Browser → powerSensor → W
   - Right-click → Plot
   - Should see power output ~275 MW (2.75e8 W)

---

### Step 5: Understanding the Parameters (Important!)

**Compressor Setup:**
```modelica
ThermoPower.Gas.Compressor compressor(
  PR0 = 18,           // Design pressure ratio
  w0 = 612.5,         // Design mass flow [kg/s]
  eta = 0.88,         // Isentropic efficiency
  Ndesign = 3000,     // Design RPM
  pstart_in = 101325, // Inlet pressure [Pa]
  pstart_out = 1823850, // Outlet pressure [Pa] (18*101325)
  ...
);
```

**Turbine Setup:**
```modelica
ThermoPower.Gas.Turbine turbine(
  PR0 = 17.5,         // Expansion ratio (slightly less than compression)
  w0 = 625,           // Flow including fuel [kg/s]
  eta = 0.90,         // Isentropic efficiency
  Tstart_in = 1673.15, // Inlet temp [K] (1400°C)
  Tstart_out = 915,   // Outlet temp [K] (~642°C)
  ...
);
```

**Combustor Setup:**
```modelica
ThermoPower.Gas.Combustor combustor(
  HH = 50e6,          // Fuel heating value [J/kg]
  Tstart = 1673.15,   // Exit temperature [K]
  pstart = 1770000,   // Pressure [Pa] (with 3% loss)
  ...
);
```

---

### Step 6: Troubleshooting Common Issues

**Issue 1: "Cannot find ThermoPower"**
- Solution: Load ThermoPower library first (Step 1)
- File → Open → ThermoPower/package.mo

**Issue 2: "Simulation takes very long"**
- Normal! ThermoPower solves dynamics (not just steady-state)
- First simulation: 30-60 seconds
- Later simulations: faster (cached)
- Be patient!

**Issue 3: "Model doesn't balance"**
- Check all `redeclare package Medium` statements
- Must specify Medium for EVERY component
- Air: `ThermoPower.Gas.Air`
- FlueGas: `ThermoPower.Gas.FlueGas`

**Issue 4: "Initialization failed"**
- Check `pstart`, `Tstart` parameters
- They should be reasonable operating points
- Look at ThermoPower examples for guidance

**Issue 5: Warnings about Modelica.SIunits**
- **These are OK!** Just warnings, not errors
- OpenModelica translates automatically
- Model still works correctly

---

### Step 7: Next Steps - Building Complete CCGT

**Once gas turbine works (Step 4), add HRSG:**

1. **Study ThermoPower water components:**
   ```
   ThermoPower → Water → (explore components)
   ```

2. **Look at water/steam examples:**
   ```
   ThermoPower → Examples → RankineCycle
   ```

3. **Create HRSG model:**
   - Use `ThermoPower.Water.Flow1D` for tubes
   - Connect gas side (hot) to water side (cold)
   - Three pressure levels: HP, IP, LP
   - Steam drums for separation

4. **Add steam turbine:**
   - Use `ThermoPower.Water.Turbine`
   - Multiple stages (HP, IP, LP)
   - Connect to condenser

5. **Complete CCGT:**
   - Gas turbine → HRSG → Steam turbine → Condenser
   - All with diagram view!
   - Professional representation

---

## 🎓 Learning Resources

### Within ThermoPower:

1. **UsersGuide:**
   ```
   ThermoPower → UsersGuide (in OMEdit)
   ```
   - Read sections on Gas and Water components
   - Understand connector types
   - Learn initialization strategies

2. **Examples:**
   ```
   ThermoPower → Examples
   ├── BraytonCycle (you know this!)
   ├── RankineCycle (steam cycle)
   ├── CombinedCycle (future reference)
   └── (others)
   ```

3. **Component Documentation:**
   - Right-click any component
   - Select "View Documentation"
   - See equations, parameters, usage notes

### External Resources:

- **ThermoPower GitHub:** https://github.com/casella/ThermoPower
- **Paper:** Casella & Leva (2006) - ThermoPower library description
- **Modelica tutorials:** Learn connector-based modeling

---

## 💡 Pro Tips

### Tip 1: Always Load ThermoPower First
Before opening your models, load ThermoPower library. Otherwise, components won't be found.

### Tip 2: Use Diagram View
- Text view is for experts
- Diagram view is intuitive and visual
- Switch between views to learn

### Tip 3: Copy from Examples
- Don't start from scratch
- Copy working example
- Modify parameters gradually
- Validate at each step

### Tip 4: Start Simple
- Don't add everything at once
- Gas turbine first (done!)
- Then HRSG
- Then steam turbine
- Finally integrate

### Tip 5: Save Intermediate Versions
- Save working versions as you progress
- Step3_GasTurbine_v1.mo, v2.mo, etc.
- Easy to roll back if something breaks

### Tip 6: Compare with Yesterday
- Your simple model: 275 MW, 43.9%, 642°C
- ThermoPower should give similar results
- Validates both approaches!

---

## ✅ Success Checklist

### Today's Goals:

- [ ] ThermoPower library loaded in OMEdit
- [ ] Explored BraytonCycle example
- [ ] Understood component diagram view
- [ ] Opened Step3_GasTurbine_ThermoPower.mo
- [ ] Simulated successfully
- [ ] Saw power output ~275 MW
- [ ] Understood parameter setup

### Tomorrow's Goals:

- [ ] Study ThermoPower.Water components
- [ ] Create HRSG with three pressure levels
- [ ] Connect gas turbine exhaust to HRSG
- [ ] Simulate integrated GT+HRSG
- [ ] Recover ~306 MW heat

### End of Week Goals:

- [ ] Complete CCGT with steam turbine
- [ ] Total power: 365-375 MW
- [ ] Combined efficiency: 58-60%
- [ ] Professional diagram view
- [ ] Validated against yesterday's simple model

---

## 🎯 Quick Reference Commands

**In OMEdit:**
```
Load library:     File → Open → ThermoPower/package.mo
Open model:       File → Open → your_model.mo
Diagram view:     Click icon (or Ctrl+D)
Simulate:         Click button (or Ctrl+T)
Plot variable:    Right-click variable → Plot
```

**Key directories:**
```
ThermoPower/Examples/BraytonCycle/  ← Study this!
02_thermopower_models/models/        ← Your models here
```

---

## 🚀 You're Ready!

You have everything needed to build professional CCGT models:
- ✓ ThermoPower library works
- ✓ Examples to learn from
- ✓ Starter model created (Step3)
- ✓ This guide for reference

**Next action:** Open OMEdit and try Step3_GasTurbine_ThermoPower.mo!

**Have fun building your industrial-standard CCGT!** 🎉

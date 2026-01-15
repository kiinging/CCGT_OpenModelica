# ThermoPower Library Setup Guide

> **Complete installation and configuration guide for the ThermoPower library**

This guide will help you install and configure the ThermoPower library for use with your CCGT models.

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation Methods](#installation-methods)
3. [Verification](#verification)
4. [Configuration](#configuration)
5. [Troubleshooting](#troubleshooting)
6. [First Test Model](#first-test-model)

---

## Prerequisites

### Required Software

**OpenModelica:**
- Version: **1.18.0 or later** (recommended: latest stable)
- Download: https://openmodelica.org/download/
- **Note:** ThermoPower may not work with very old OM versions

**Git:**
- For cloning ThermoPower repository
- Windows: Git for Windows (https://git-scm.com/)
- Linux/Mac: Usually pre-installed

**Optional but Recommended:**
- Python 3.8+ (for result analysis)
- Matplotlib (for plotting)

---

## Installation Methods

### Method 1: Git Submodule (Already Done! ✓)

Since you've already run:
```bash
git submodule add https://github.com/casella/ThermoPower.git ThermoPower
```

**You're mostly done!** Just need to tell OpenModelica where to find it.

**Verify the submodule:**
```bash
cd CCGT_OpenModelica
git submodule status

# Should show:
# <commit-hash> ThermoPower (heads/master)
```

**If ThermoPower folder is empty:**
```bash
git submodule init
git submodule update
```

---

### Method 2: Manual Clone (Alternative)

If you need ThermoPower in OpenModelica's default library location:

**Windows:**
```powershell
cd %APPDATA%\OpenModelica\libraries
git clone https://github.com/casella/ThermoPower.git
```

**Linux:**
```bash
cd ~/.openmodelica/libraries/
git clone https://github.com/casella/ThermoPower.git
```

**Mac:**
```bash
cd ~/Documents/OpenModelica/libraries/
git clone https://github.com/casella/ThermoPower.git
```

---

### Method 3: Download ZIP (Not Recommended)

1. Go to: https://github.com/casella/ThermoPower
2. Click "Code" → "Download ZIP"
3. Extract to OpenModelica libraries folder (see Method 2 paths)
4. Rename folder to "ThermoPower" (remove "-master" suffix)

**Why not recommended:** Hard to update, no version tracking

---

## Verification

### Test 1: Load ThermoPower Library

**In OMEdit:**
```
1. File → Open Model/Library File
2. Navigate to: CCGT_OpenModelica/ThermoPower/package.mo
3. Click "Open"
4. Check Libraries Browser (left panel)
   → Should show "ThermoPower" with tree structure
```

**From Command Line:**
```bash
omc << EOF
loadFile("ThermoPower/package.mo");
getErrorString();
EOF
```

**Expected Output:**
```
true
""
```

**If you see errors:** See Troubleshooting section below

---

### Test 2: Check Example Models

**In OMEdit:**
```
1. Expand "ThermoPower" in Libraries Browser
2. Expand "Examples"
3. Expand "RankineCycle"
4. Right-click "RankineCycle" → Simulate
5. Should simulate successfully (~30 seconds)
```

**Success indicators:**
- Simulation completes without errors
- Variables appear in Variables Browser
- You can plot results (e.g., turbine.power)

---

### Test 3: Import in Your Model

Create a test file: `test_thermopower.mo`

```modelica
model TestThermoPower
  import ThermoPower;
  
  // Create a simple component
  ThermoPower.Water.SourcePressure source(
    p = 100e5,
    T = 500 + 273.15
  );
  
  annotation(experiment(StartTime=0, StopTime=1));
end TestThermoPower;
```

**Simulate:**
- Should complete without "Cannot find ThermoPower" errors
- If it simulates, ThermoPower is correctly loaded!

---

## Configuration

### Option 1: Load ThermoPower in Every Model (Manual)

**In each model file:**
```modelica
model YourModel
  import ThermoPower;
  
  // Or import specific packages:
  import ThermoPower.Water;
  import ThermoPower.Gas;
  
  // Your model code...
end YourModel;
```

**Pros:** Explicit, portable
**Cons:** Must remember to add to each file

---

### Option 2: Load ThermoPower Automatically (Recommended)

**Create package.mo in 02_thermopower_models/models/:**

```modelica
package CCGT_ThermoPower "CCGT models using ThermoPower"
  extends Modelica.Icons.Package;
  
  // This makes ThermoPower available to all models in this package
  import ThermoPower;
  
  annotation(uses(ThermoPower(version="3.1")));
end CCGT_ThermoPower;
```

**Then your models become:**
```modelica
within CCGT_ThermoPower;  // Note: "within" the package

model CCGT_Basic
  // ThermoPower automatically available!
  ThermoPower.Gas.Compressor comp;
  // ...
end CCGT_Basic;
```

**Pros:** Clean, organized, automatic loading
**Cons:** Requires package structure (worth it!)

---

### Option 3: Set Library Path in OMEdit (Global)

**In OMEdit:**
```
Tools → Options → Libraries
Click "Add Library" button
Browse to: CCGT_OpenModelica/ThermoPower
Click OK
Restart OMEdit
```

**Now ThermoPower is always available!**

---

## Troubleshooting

### Problem 1: "Cannot load ThermoPower"

**Symptom:**
```
Error: Class ThermoPower not found
```

**Solutions:**
1. **Check path:**
   ```bash
   ls CCGT_OpenModelica/ThermoPower/package.mo
   # Should exist!
   ```

2. **Load manually in OMEdit:**
   ```
   File → Open Model/Library File
   Select: ThermoPower/package.mo
   ```

3. **Check .gitmodules:**
   ```bash
   cat .gitmodules
   # Should contain:
   # [submodule "ThermoPower"]
   #   path = ThermoPower
   #   url = https://github.com/casella/ThermoPower.git
   ```

4. **Reinitialize submodule:**
   ```bash
   git submodule deinit ThermoPower
   git submodule update --init ThermoPower
   ```

---

### Problem 2: "Medium.X is not defined"

**Symptom:**
```
Error: Variable Medium.X is not defined in scope
```

**Solution:** Always declare the medium!

**Wrong:**
```modelica
ThermoPower.Water.Flow1D pipe;  // ✗ No medium specified
```

**Correct:**
```modelica
ThermoPower.Water.Flow1D pipe(
  redeclare package Medium = ThermoPower.Water.StandardWater
);  // ✓ Medium specified
```

**Common Media:**
- `ThermoPower.Water.StandardWater` - For water/steam
- `ThermoPower.Gas.FlueGas` - For combustion products
- `ThermoPower.Gas.Air` - For air

---

### Problem 3: Simulation Fails to Initialize

**Symptom:**
```
Error: Initialization failed
```

**Solutions:**

1. **Provide good initial guesses:**
   ```modelica
   ThermoPower.Water.Flow1D evaporator(
     p_start = 80e5,           // Expected pressure
     T_start = 540 + 273.15,   // Expected temperature
     m_flow_start = 35         // Expected flow rate
   );
   ```

2. **Enable steady-state initialization:**
   ```modelica
   ThermoPower.Water.Flow1D evaporator(
     steadyStateInit = true    // Start in steady state
   );
   ```

3. **Reduce complexity temporarily:**
   ```modelica
   // Start with fewer nodes:
   ThermoPower.Water.Flow1D evaporator(
     nNodes = 3  // Instead of 20
   );
   ```

4. **Check boundary conditions:**
   ```modelica
   // ALL boundaries must be specified!
   ThermoPower.Water.SourcePressure source(
     p = 100e5,   // Must specify
     T = 500      // Must specify
   );
   ```

---

### Problem 4: Simulation is Very Slow

**Symptom:** Takes 10+ minutes

**Solutions:**

1. **Reduce spatial discretization:**
   ```modelica
   nNodes = 5  // Start small, increase if needed
   ```

2. **Use appropriate solver:**
   ```
   Simulation Setup → Method: dassl
   Tolerance: 1e-4 (not 1e-6 for initial testing)
   ```

3. **Enable steady-state initialization:**
   ```modelica
   steadyStateInit = true
   ```

4. **Simplify medium (for testing):**
   ```modelica
   // For quick tests, use simpler medium:
   redeclare package Medium = Modelica.Media.Water.StandardWater
   // Instead of full IAPWS-97
   ```

---

### Problem 5: "Package ThermoPower has version conflict"

**Symptom:**
```
Warning: Package ThermoPower version mismatch
Required: 3.1
Found: 3.2
```

**Solution:** Usually safe to ignore (backward compatible)

**Or update your code:**
```modelica
annotation(uses(ThermoPower(version="3.2")));  // Update version
```

---

### Problem 6: Git Submodule Issues

**Symptom:** ThermoPower folder is empty or outdated

**Solutions:**

**Update submodule:**
```bash
git submodule update --remote ThermoPower
```

**Reset submodule:**
```bash
git submodule deinit -f ThermoPower
git submodule update --init ThermoPower
```

**Check submodule status:**
```bash
git submodule status
cd ThermoPower
git branch
git log --oneline -5  # See recent commits
```

---

## First Test Model

### Create Your First ThermoPower Model

**File:** `02_thermopower_models/models/FirstTest.mo`

```modelica
model FirstTest "Simple test of ThermoPower components"
  import ThermoPower;
  
  // Water circuit
  ThermoPower.Water.SourcePressure source(
    p = 100e5,                    // 100 bar
    T = 300 + 273.15,             // 300°C
    redeclare package Medium = ThermoPower.Water.StandardWater
  ) annotation(Placement(transformation(extent={{-80,-10},{-60,10}})));
  
  ThermoPower.Water.SinkPressure sink(
    p = 100e5,
    redeclare package Medium = ThermoPower.Water.StandardWater
  ) annotation(Placement(transformation(extent={{60,-10},{80,10}})));
  
  ThermoPower.Water.Flow1D pipe(
    N = 5,                        // 5 nodes
    L = 10,                       // 10 meters
    A = 0.01,                     // 0.01 m² cross-section
    omega = 0.4,                  // Perimeter
    Dhyd = 0.1,                   // Hydraulic diameter
    wnom = 10,                    // Nominal flow rate
    redeclare package Medium = ThermoPower.Water.StandardWater,
    FFtype = ThermoPower.Choices.Flow1D.FFtypes.Cfnom,
    initOpt = ThermoPower.Choices.Init.Options.steadyState
  ) annotation(Placement(transformation(extent={{-20,-10},{0,10}})));
  
equation
  connect(source.flange, pipe.inlet);
  connect(pipe.outlet, sink.flange);
  
  annotation(
    experiment(StartTime=0, StopTime=100, Tolerance=1e-6),
    Documentation(info="<html>
    <h4>First ThermoPower Test Model</h4>
    <p>This simple model tests basic ThermoPower functionality:</p>
    <ul>
    <li>Water source at 100 bar, 300°C</li>
    <li>Simple pipe with 5 nodes</li>
    <li>Water sink at 100 bar</li>
    </ul>
    <p>If this simulates successfully, ThermoPower is working!</p>
    </html>")
  );
end FirstTest;
```

**To simulate:**
```
1. Open in OMEdit
2. Load ThermoPower library first (if not auto-loaded)
3. Click "Simulate" button
4. Should complete in ~10 seconds
5. Plot variables like: pipe.T[3], pipe.p, pipe.w
```

**Expected Results:**
- Temperature: ~573 K (300°C) throughout
- Pressure: ~100e5 Pa (100 bar)
- Flow rate: Determined by friction model

**If this works:** ThermoPower is correctly installed! 🎉

---

## Next Steps

### Now That ThermoPower is Installed:

1. **Explore Examples:**
   ```
   ThermoPower → Examples → RankineCycle
   ThermoPower → Examples → BraytonCycle
   ```

2. **Read Documentation:**
   ```
   ThermoPower → UsersGuide (in OMEdit)
   ```

3. **Start Simple:**
   - Build gas turbine only (tomorrow!)
   - Then add HRSG
   - Then steam cycle
   - Finally integrate

4. **Follow Level 2 Guide:**
   - See `02_thermopower_models/README.md`
   - Day-by-day learning path

---

## Quick Reference

### Essential Commands

**Load ThermoPower:**
```modelica
import ThermoPower;
```

**Specify medium (ALWAYS!):**
```modelica
redeclare package Medium = ThermoPower.Water.StandardWater
```

**Good initialization:**
```modelica
p_start = 80e5;
T_start = 540 + 273.15;
steadyStateInit = true;
```

**Connection syntax:**
```modelica
connect(comp1.outlet, comp2.inlet);  // Gas/Water components
connect(source.flange, pipe.inlet);  // Alternative names
```

---

## Version Information

**ThermoPower Versions:**
- **3.1** - Stable, well-tested (recommended for learning)
- **3.2+** - Latest features, may have breaking changes

**Check your version:**
```bash
cd ThermoPower
git describe --tags
```

**Update to specific version:**
```bash
cd ThermoPower
git fetch --all --tags
git checkout tags/v3.1  # Or desired version
```

---

## Additional Resources

**Official Documentation:**
- GitHub: https://github.com/casella/ThermoPower
- Paper: [Casella & Leva, 2006 - ThermoPower Modelica Library](https://modelica.org/events/Conference2006/Proceedings/sessions/Session2a2.pdf)

**Modelica Documentation:**
- Modelica Standard Library: https://doc.modelica.org/
- OpenModelica User's Guide: https://openmodelica.org/doc/

**Community:**
- OpenModelica Forum: https://openmodelica.org/forum/
- Modelica Forum: https://forum.modelica.org/

---

## Summary Checklist

Before starting ThermoPower modeling, verify:

- [ ] OpenModelica 1.18+ installed
- [ ] ThermoPower submodule initialized (`git submodule status`)
- [ ] ThermoPower loads in OMEdit without errors
- [ ] Example model simulates successfully
- [ ] FirstTest.mo works
- [ ] You understand medium declaration
- [ ] You've read UsersGuide in ThermoPower

**All checked?** You're ready for `02_thermopower_models/README.md`! 🚀

---

## Getting Help

**If stuck:**
1. Check this troubleshooting section
2. Review ThermoPower examples
3. Search OpenModelica forum
4. Open issue on GitHub
5. Check ThermoPower GitHub issues

**Common Issues Database:**
- Most problems are medium declaration or initialization
- Check ThermoPower/Examples for working patterns
- Start simple, add complexity gradually

---

**Good luck with ThermoPower! See you in Level 2!** 💪

*"The best way to learn ThermoPower is to start simple, fail fast, and iterate."*

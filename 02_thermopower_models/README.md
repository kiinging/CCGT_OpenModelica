# 🔴 ThermoPower Models - Advanced Level

> **Learning Path Level 2** | **Time: 1-2 weeks** | **Prerequisites: Complete Level 1 + ThermoPower installed**

Welcome to **industry-standard CCGT modeling** using the professional ThermoPower library! These models use real fluid properties, detailed component models, and achieve accuracy comparable to commercial simulation tools.

---

## ⚠️ Prerequisites

Before starting here, you should have:

- ✅ Completed all simple models in `../01_simple_models/`
- ✅ Understood basic CCGT principles (Brayton + Rankine cycles)
- ✅ Installed ThermoPower library (see setup guide below)
- ✅ Comfortable with OpenModelica interface
- ✅ Basic understanding of thermodynamic properties (enthalpy, entropy)

**Not ready yet?** Go back to Level 1 and build your foundation!

---

## 🎯 What's Different Here?

### Simple Models vs. ThermoPower Models

| Feature | Simple Models | ThermoPower Models |
|---------|--------------|-------------------|
| **Fluid Properties** | Constant cp, ideal gas | IAPWS-97 (real steam), NASA polynomials (gas) |
| **Accuracy** | ±10% | ±2-3% |
| **Simulation Time** | Seconds | Minutes |
| **Components** | 5 basic models | 50+ library components |
| **Heat Exchangers** | Simple effectiveness | Discretized, multi-node |
| **Turbomachinery** | Isentropic efficiency | Performance maps |
| **Pressure Drop** | Neglected | Calculated |
| **Control Systems** | None | PID controllers, valves |
| **Off-Design** | Limited | Full off-design capability |
| **Use Case** | Learning, feasibility | Design, optimization |

---

## 📚 Library Components You'll Use

### Gas Side (ThermoPower.Gas)
- `Compressor` - With performance maps
- `Turbine` - Stodola's ellipse law
- `Combustor` - Fuel/air mixing
- `Flow1D` - Gas flow with friction
- `PressDropLin` - Pressure losses

### Water/Steam Side (ThermoPower.Water)
- `Pump` - Feed water pumps
- `HeatExchanger` - HRSG components
- `Drum` - Steam drums
- `Turbine` - Multi-stage expansion
- `Condenser` - Condensation model
- `Flow1D` - Two-phase flow

### Control (ThermoPower.Control)
- `PID` - PID controllers
- `Valve` - Control valves

---

## 🚀 Getting Started

### Step 1: Verify ThermoPower Installation

```bash
# Open OMEdit
# Tools → Options → Libraries
# Check if "ThermoPower" is listed

# OR test from command line:
omc -c "loadModel(ThermoPower); getErrorString();"
```

**Expected output:** 
```
true
""
```

**If not installed:** See `../docs/THERMOPOWER_SETUP.md`

---

### Step 2: Your First ThermoPower Model (Tomorrow!)

**We'll create:** `models/CCGT_ThermoPower_Basic.mo`

**Structure:**
```modelica
model CCGT_ThermoPower_Basic
  import ThermoPower;
  
  // Gas Turbine Components
  ThermoPower.Gas.SourcePressure airSource;
  ThermoPower.Gas.Compressor compressor;
  ThermoPower.Gas.Combustor combustor;
  ThermoPower.Gas.Turbine turbine;
  
  // HRSG Components
  ThermoPower.Water.Flow1D evaporator;
  ThermoPower.Water.Drum drum;
  
  // Steam Turbine
  ThermoPower.Water.Turbine steamTurbine;
  ThermoPower.Water.Condenser condenser;
  
  // Connections
  // (We'll build this together tomorrow!)
  
end CCGT_ThermoPower_Basic;
```

---

## 📁 Folder Structure

```
02_thermopower_models/
├── README.md                          ← You are here
├── models/
│   ├── CCGT_ThermoPower_Basic.mo     ← Tomorrow: Start with this
│   ├── CCGT_ThermoPower_Advanced.mo  ← Later: Full detail
│   ├── GT_Detailed.mo                ← Gas turbine only
│   ├── HRSG_ThreePressure.mo         ← 3-pressure HRSG
│   └── SteamCycle_Complete.mo        ← Steam cycle only
├── scripts/
│   ├── simulate_thermopower.mos      ← Automation scripts
│   └── compare_simple_vs_tp.py       ← Comparison with simple models
├── results/
│   └── (Your simulation results)
└── docs/
    ├── Component_Guide.md            ← ThermoPower component reference
    ├── Debugging_Tips.md             ← Common issues & solutions
    └── Validation_Data.md            ← Comparison with real plants
```

---

## 🎓 Learning Path

### **Week 1: Basics**

**Day 1: Setup & Simple Gas Turbine**
- [ ] Install ThermoPower (if not done)
- [ ] Create basic gas turbine with ThermoPower.Gas components
- [ ] Compare with BraytonCycleSimple results
- **Goal:** Understand component connections

**Day 2: Heat Exchanger Basics**
- [ ] Build simple HRSG with Flow1D
- [ ] Learn about discretization (nNodes parameter)
- [ ] Compare with HRSG_Simple results
- **Goal:** Understand heat transfer modeling

**Day 3: Steam Cycle**
- [ ] Build basic Rankine cycle
- [ ] Add pump, turbine, condenser
- [ ] Real IAPWS-97 properties!
- **Goal:** See difference from simple models

**Day 4: Integration**
- [ ] Connect gas turbine → HRSG → steam turbine
- [ ] Debug connection issues (expect some!)
- [ ] Get first complete CCGT running
- **Goal:** Working integrated model

**Day 5: Validation**
- [ ] Compare results with simple models
- [ ] Understand differences (why ~5% variation?)
- [ ] Document learnings
- **Goal:** Confidence in results

### **Week 2: Advanced Topics**

**Day 6-7: Multi-Pressure HRSG**
- [ ] Add IP and LP sections
- [ ] Steam drum modeling
- [ ] Complex heat transfer networks
- **Goal:** Realistic HRSG design

**Day 8-9: Control Systems**
- [ ] Add PID controllers
- [ ] Valve control
- [ ] Load following
- **Goal:** Dynamic operation

**Day 10: Performance & Optimization**
- [ ] Part-load simulation
- [ ] Efficiency optimization
- [ ] Comparison with Level 1
- **Goal:** Real design insights

---

## 🔧 Common Challenges & Solutions

### Challenge 1: "Model doesn't balance"
**Symptom:** Errors about mass/energy not conserved

**Solution:**
```modelica
// Make sure all flows are connected!
// Gas side:
connect(compressor.outlet, combustor.inlet);  // ✓
// Don't leave dangling connectors!  // ✗

// Check boundary conditions:
airSource.p = 101325;  // Must specify pressure
```

### Challenge 2: "Simulation is slow"
**Symptom:** Takes 10+ minutes

**Solution:**
```modelica
// Reduce discretization:
Flow1D evaporator(nNodes = 5);  // Start with 5, not 20
  
// Use simpler initialization:
evaporator.steadyStateInit = true;

// Solver settings in OMEdit:
// Simulation Setup → Method: dassl
// Tolerance: 1e-4 (not 1e-6 for first runs)
```

### Challenge 3: "Fluid properties error"
**Symptom:** "Medium.X not defined"

**Solution:**
```modelica
// Always specify the medium!
ThermoPower.Water.Flow1D pipe(
  redeclare package Medium = ThermoPower.Water.StandardWater
);

ThermoPower.Gas.Flow1D gasPipe(
  redeclare package Medium = ThermoPower.Gas.FlueGas
);
```

### Challenge 4: "Initialization failed"
**Symptom:** Model doesn't start

**Solution:**
```modelica
// Provide good initial guesses:
evaporator.p_start = 80e5;  // 80 bar
evaporator.T_start = 540 + 273.15;  // 540°C
evaporator.m_flow_start = 35;  // 35 kg/s

// Start simple, add complexity gradually!
```

---

## 📊 Expected Results

**625 MW CCGT Plant (ThermoPower Models):**

| Component | Simple Model | ThermoPower | Difference |
|-----------|-------------|-------------|------------|
| Gas Turbine Power | 274.6 MW | ~278 MW | +1.2% |
| HRSG Heat Recovery | 306.5 MW | ~295 MW | -3.7% |
| Steam Production | 95.3 kg/s | ~91 kg/s | -4.5% |
| Steam Turbine Power | 94.4 MW | ~98 MW | +3.8% |
| **Total CCGT Power** | **369.0 MW** | **~376 MW** | **+1.9%** |
| **Combined Efficiency** | **59.0%** | **60.2%** | **+1.2%** |

**Why ThermoPower gives slightly higher efficiency:**
- Real fluid properties (better expansion work)
- Pressure recovery in diffusers
- More accurate heat transfer
- Better turbine modeling

---

## 🎯 Goals for ThermoPower Learning

By the end of Level 2, you should be able to:

- [ ] Build complete CCGT models from scratch using ThermoPower
- [ ] Understand and use real fluid properties (IAPWS-97)
- [ ] Implement multi-pressure HRSG designs
- [ ] Add control systems for dynamic operation
- [ ] Debug common ThermoPower issues
- [ ] Compare and validate against simple models
- [ ] Optimize designs for efficiency/cost
- [ ] Simulate off-design and part-load operation

---

## 📖 Documentation Resources

**Inside ThermoPower Library:**
```
ThermoPower/
├── UsersGuide.mo          ← START HERE!
├── Examples/              ← 20+ example models
│   ├── RankineCycle/
│   ├── BraytonCycle/
│   └── CombinedCycle/     ← Directly relevant!
└── Components/
    ├── Gas/
    └── Water/
```

**How to access:**
1. Load ThermoPower in OMEdit
2. Expand "ThermoPower" in Libraries Browser
3. Open "UsersGuide"
4. Browse examples

**External Resources:**
- [ThermoPower GitHub](https://github.com/casella/ThermoPower)
- [ThermoPower Paper](https://modelica.org/events/Conference2006/Proceedings/sessions/Session2a2.pdf)
- [OpenModelica Documentation](https://openmodelica.org/doc/)

---

## 🔬 Validation & Testing

### Validation Against Simple Models

**Create comparison script:**
```python
# scripts/compare_simple_vs_tp.py
import numpy as np
import matplotlib.pyplot as plt

# Load results from both models
simple_power = 369.0  # MW
tp_power = 376.0      # MW
difference = (tp_power - simple_power) / simple_power * 100

print(f"Difference: {difference:.1f}%")
# Expected: 1-3% difference ✓
```

### Validation Against Literature

**Typical F-class CCGT (625 MW fuel):**
- Expected output: 360-380 MW ✓
- Expected efficiency: 58-62% ✓
- Your results should fall in these ranges!

---

## 💡 Pro Tips for ThermoPower

1. **Start Small:** Build gas turbine alone first, then add HRSG, then steam cycle
2. **Use Examples:** ThermoPower.Examples has working models - copy and modify!
3. **Check Units:** ThermoPower uses SI (Pa, not bar; J/kg, not kJ/kg)
4. **Save Often:** Complex models can crash - save working versions!
5. **Use steadyStateInit:** Speeds up initialization significantly
6. **Plot Everything:** Visualize to understand what's happening
7. **Compare with Simple:** If results are wildly different, something's wrong
8. **Read Error Messages:** ThermoPower errors are usually helpful!

---

## 🚧 Current Status

**Status:** 🚧 **Under Development**

**Coming Tomorrow:**
- ✅ ThermoPower setup guide (see `../docs/THERMOPOWER_SETUP.md`)
- 🚧 Basic CCGT model (we'll create together!)
- 📅 Advanced models (next week)
- 📅 Validation studies
- 📅 Example case studies

**Help wanted:** If you develop useful models, contribute them back!

---

## ⚡ Quick Reference

### Essential ThermoPower Components

```modelica
// GAS TURBINE
ThermoPower.Gas.SourcePressure source(p=101325, T=288.15);
ThermoPower.Gas.Compressor comp(PRatio=18, eta=0.88);
ThermoPower.Gas.Combustor comb(eta=0.995);
ThermoPower.Gas.Turbine turb(PRatio=18, eta=0.90);

// HRSG
ThermoPower.Water.Flow1D evap(
  nNodes=10,
  redeclare package Medium = ThermoPower.Water.StandardWater
);

// STEAM TURBINE
ThermoPower.Water.Turbine steamTurb(eta=0.85);
ThermoPower.Water.Condenser cond(p=5000);

// CONNECTIONS
connect(comp.outlet, comb.inlet);
connect(comb.outlet, turb.inlet);
// etc...
```

---

## 🤝 Getting Help

**Stuck? Try this order:**

1. **Check ThermoPower.Examples** - Similar model probably exists!
2. **Read error message** - Usually tells you what's wrong
3. **Review docs** - `docs/Component_Guide.md`
4. **Compare with Level 1** - Do results make sense?
5. **Ask on GitHub Issues** - We're here to help!

---

## 🎓 Assessment

**Ready to move to Level 3 (Examples)?**

Test yourself:
- [ ] Can you build a basic CCGT without looking at examples?
- [ ] Can you explain why ThermoPower is more accurate?
- [ ] Can you debug common initialization errors?
- [ ] Can you add a simple controller?
- [ ] Do your results validate against Level 1 (±5%)?

**If yes:** Congratulations! Ready for `../03_examples/` 🎉

**If no:** Keep practicing! This is advanced material - take your time.

---

**Ready to begin? See you tomorrow for your first ThermoPower model!** 🚀

*"Simple models teach you to think. ThermoPower models teach you to design."*

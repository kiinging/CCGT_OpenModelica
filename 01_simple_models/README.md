# 🟢 Simple Models - Start Here!

> **Learning Path Level 1** | **Time: 2-4 hours** | **Prerequisites: Basic thermodynamics**

Welcome! This is where you **begin your CCGT learning journey**. These simplified analytical models help you understand the fundamental principles of Combined Cycle Gas Turbines without getting lost in complexity.

---

## 🎯 What You'll Learn

- **Brayton Cycle** - How gas turbines convert fuel to power
- **Heat Recovery** - Capturing waste heat efficiently
- **Rankine Cycle** - Steam turbines and power generation
- **Combined Cycle** - Why 1+1 = 1.4 (59% efficiency!)
- **Energy Balance** - Where does all the energy go?

---

## 📁 Models Overview

### Core Component Models

| Model | Purpose | Output | Status |
|-------|---------|--------|--------|
| **BraytonCycleSimple.mo** | Gas turbine (625 MW fuel) | 274.6 MW power | ✅ Ready |
| **BraytonCycle_500MW_Standalone.mo** | Gas turbine (500 MW fuel) | ~220 MW power | ✅ Ready |
| **HRSG_Simple.mo** | Heat recovery steam generator | 306.5 MW heat, 95.3 kg/s steam | ✅ Ready |
| **SteamTurbine_Simple.mo** | Steam turbine (3 stages) | 94.4 MW power | ✅ Ready |
| **Condenser_Simple.mo** | Steam condenser | 231.6 MW cooling | ✅ Ready |

### Integrated Models

| Model | Purpose | Output | Status |
|-------|---------|--------|--------|
| **CCGT_Complete_Simple.mo** | Complete CCGT (all-in-one) | 362 MW, 57.9% eff | ✅ Ready |
| **BraytonCycle_Dynamic.mo** | Dynamic simulation | Time-varying | ✅ Ready |

---

## 🚀 Quick Start - Your First Simulation

### Step 1: Open OpenModelica
```bash
# Launch OpenModelica (OMEdit)
OMEdit
```

### Step 2: Load Your First Model
```
File → Open Model/Library File
Navigate to: 01_simple_models/models/BraytonCycleSimple.mo
```

### Step 3: Simulate!
```
Right-click "BraytonCycleSimple" in Libraries Browser
→ Select "Simulate"
→ Wait ~2 seconds
→ See results!
```

### Step 4: Check Your Results
**Expected outputs:**
- Net Power (W_net): **274,600,000 W** (274.6 MW) ✓
- Thermal Efficiency (eta_thermal): **0.439** (43.9%) ✓
- Exhaust Temperature (T4): **915.45 K** (642.3°C) ✓

**Congratulations!** 🎉 You just simulated a gas turbine!

---

## 📚 Recommended Learning Sequence

### **Lesson 1: Gas Turbine Basics (30 min)**
1. Open `BraytonCycleSimple.mo`
2. Read the inline documentation
3. Simulate and observe results
4. Try changing parameters:
   - Increase `r_pressure` (18 → 20) → Higher efficiency!
   - Increase `T3` (1673.15 → 1773.15) → More power!
5. Read: `docs/01_Understanding_Brayton_Cycle.md` (if exists)

**Key Question:** Why is the exhaust so hot (642°C)? 
**Answer:** This "waste" heat is our opportunity for the steam cycle!

---

### **Lesson 2: Heat Recovery (30 min)**
1. Open `HRSG_Simple.mo`
2. Notice: Input gas is 642°C (matches gas turbine exhaust!)
3. Simulate and observe:
   - Heat recovered: **306.5 MW** (49% of original fuel!)
   - Steam produced: **95.3 kg/s**
4. Compare: HRSG heat (306 MW) > Gas turbine power (275 MW)
   - This is NORMAL! We're recovering the "waste"

**Key Insight:** The HRSG captures MORE energy than the gas turbine produced! This is why combined cycle is so efficient.

---

### **Lesson 3: Steam Power (30 min)**
1. Open `SteamTurbine_Simple.mo`
2. Notice: Steam input is 95.3 kg/s (matches HRSG output!)
3. Simulate and observe:
   - Power output: **94.4 MW**
   - From heat input: 306.5 MW
   - Rankine efficiency: 30.8%

**Key Question:** Why only 94 MW from 306 MW heat?
**Answer:** Steam cycles have fundamental thermodynamic limits (Carnot). Still, it's 94 MW of "free" power from waste heat!

---

### **Lesson 4: Complete CCGT (30 min)**
1. Open `CCGT_Complete_Simple.mo`
2. This model combines everything automatically
3. Simulate and observe:
   - Gas turbine: 277 MW
   - Steam turbine: 85 MW
   - **Total: 362 MW** from 625 MW fuel
   - **Efficiency: 57.9%** ✓

**Key Insight:** Without the steam cycle, efficiency would be 44%. With it: 58%! That's a 32% improvement!

---

### **Lesson 5: Energy Balance (30 min)**
1. Open `Condenser_Simple.mo`
2. This is where remaining heat is rejected
3. Complete the energy balance:

```
INPUT:  625 MW (fuel)
OUTPUT: 
  - Gas Turbine:    275 MW (44%)
  - Steam Turbine:   94 MW (15%)
  - Condenser Loss: 232 MW (37%)
  - Stack Loss:      44 MW (7%)
  ─────────────────────────────
  TOTAL:           645 MW (103%... wait, that's wrong!)
```

**Exercise:** Find where the energy actually goes. Check your calculations!

---

## 🔬 Understanding the Models

### What Makes These "Simple"?

**Simplifications used:**
1. **Constant specific heats** (cp doesn't change with temperature)
2. **Ideal gas assumptions** (PV = mRT)
3. **Steady-state only** (no time dynamics, except BraytonCycle_Dynamic)
4. **Perfect mixing** (uniform temperature/pressure)
5. **No pressure losses** (simplified piping)
6. **Analytical enthalpies** (h = cp × T, not real steam tables)

**Result:**
- ✅ Fast simulation (~seconds)
- ✅ Easy to understand
- ✅ Good for learning fundamentals
- ✅ ~5-10% accuracy (good enough for feasibility)
- ❌ Not suitable for final design

---

## 🎓 Learning Exercises

### Exercise 1: Parameter Sensitivity
**Task:** How does pressure ratio affect efficiency?

1. Open `BraytonCycleSimple.mo`
2. Change `r_pressure` from 18 to: 10, 15, 20, 25, 30
3. Record `eta_thermal` for each
4. Plot pressure ratio vs efficiency
5. **Question:** Is there an optimal ratio?

### Exercise 2: Temperature Limits
**Task:** What if we could increase turbine inlet temperature?

1. Change `T3` from 1673.15K to 1773.15K (100°C hotter)
2. Simulate and compare:
   - Power output
   - Efficiency
   - Exhaust temperature
3. **Question:** Why don't we just make it hotter?
   **Hint:** Material limits!

### Exercise 3: Energy Flow
**Task:** Create a complete Sankey diagram

1. Simulate all models
2. Record all energy flows
3. Draw (on paper or software) showing:
   - Fuel input
   - Gas turbine power
   - HRSG heat recovery
   - Steam turbine power
   - Condenser rejection
   - Stack loss
4. Verify: Input = Outputs

### Exercise 4: Part-Load Operation
**Task:** What happens at 50% load?

1. Open `BraytonCycle_Dynamic.mo`
2. Reduce fuel flow to 50%
3. **Question:** Is efficiency better or worse at part-load?

---

## 📊 Expected Results Summary

**625 MW CCGT Plant (Simple Models):**

| Component | Input | Output | Efficiency |
|-----------|-------|--------|------------|
| Gas Turbine | 625 MW fuel | 274.6 MW power | 43.9% |
| HRSG | 367.7 MW exhaust heat | 306.5 MW recovered | 83.4% |
| Steam Turbine | 306.5 MW heat | 94.4 MW power | 30.8% |
| Condenser | 212.1 MW heat | - | - |
| **Total CCGT** | **625 MW fuel** | **369.0 MW power** | **59.0%** ✓ |

**Key Numbers to Remember:**
- Gas turbine: ~275 MW (44% of fuel)
- Steam turbine: ~95 MW (15% of fuel)
- Total: ~370 MW (59% combined!)

---

## 🐛 Troubleshooting

### "Model doesn't simulate"
**Solution:** Check OpenModelica version (need 1.18+)
```bash
omc --version
```

### "Too many equations" error
**Solution:** Models are already fixed! Re-download if you modified them.

### "Values are NaN (Not a Number)"
**Solution:** Check parameter values - no negative temperatures or zero mass flows.

### "Results don't match expected"
**Solution:** 
1. Check units (W vs MW, K vs °C)
2. Verify at time = 0 (steady-state)
3. Compare with documented results above

---

## 📖 Additional Resources

**In this folder:**
- `docs/` - Detailed documentation for each model
- `scripts/` - Automation scripts for batch simulation
- `results/` - Pre-computed results for verification
- `plots/` - Visualization examples

**Recommended Reading:**
- Walsh & Fletcher: *Gas Turbine Performance*
- Kehlhofer: *Combined-Cycle Gas & Steam Turbine Power Plants*

---

## ✅ Before Moving to Level 2 (ThermoPower)

**Checklist - Have you:**
- [ ] Successfully simulated all 5 core models?
- [ ] Understood why HRSG heat > Gas turbine power?
- [ ] Completed the energy balance exercise?
- [ ] Tried changing at least 3 parameters?
- [ ] Understood the simplifications made?

**If yes to all:** You're ready for `../02_thermopower_models/`! 🚀

**If no:** That's okay! Take your time. Understanding simple models deeply is better than rushing to complex ones.

---

## 🎯 What's Next?

Once you're comfortable with these models:

**Level 2:** `../02_thermopower_models/`
- Industry-standard ThermoPower library
- Real fluid properties
- More accurate results (~2-3% error)
- Component-level detail
- Control systems

**Level 3:** `../03_examples/`
- Real case studies
- Design optimization
- Economic analysis

---

## 💡 Pro Tips

1. **Save your experiments:** `File → Save Total Model` to save modified versions
2. **Use plotting:** Right-click variables in Variables Browser → Plot
3. **Compare runs:** Use the Plot window to overlay multiple simulations
4. **Document learning:** Keep notes on what you discover!

---

## 🤝 Need Help?

- Check troubleshooting section above
- Review model documentation (inside .mo files)
- See main repo README: `../README.md`
- Open an issue on GitHub

---

**Happy Learning! 🎓**

*Remember: Every expert started as a beginner. Take your time, experiment, and enjoy discovering how these amazing machines work!*

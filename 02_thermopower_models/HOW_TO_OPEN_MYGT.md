# How to Open and Use MyGasTurbine_v1

## ✅ I Created a Standalone Model for You!

**File:** `02_thermopower_models/models/MyGasTurbine_v1.mo`

This is a copy of the ThermoPower Plant example that you can modify!

---

## 📋 Step-by-Step Instructions

### Step 1: Open OMEdit (30 seconds)

Launch OMEdit application

### Step 2: Load ThermoPower Library (30 seconds)

```
File → Open Model/Library File
Browse to: CCGT_OpenModelica/ThermoPower/package.mo
Click: Open
```

**Wait** for it to load (you'll see "ThermoPower" in Libraries Browser on left)

### Step 3: Load Your Model (30 seconds)

```
File → Open Model/Library File  
Browse to: CCGT_OpenModelica/02_thermopower_models/models/MyGasTurbine_v1.mo
Click: Open
```

### Step 4: View Diagram (10 seconds)

1. Look at toolbar (top of window)
2. Find icon with boxes/rectangles (Diagram View icon)
3. **Click it!**
4. **You should see the gas turbine layout!** ✓

If diagram is empty, try:
- Close and reopen the model
- Make sure ThermoPower loaded first
- Try: View → Diagram View from menu

### Step 5: Simulate (2 minutes)

1. Click "Simulate" button (play icon)
2. Wait ~1-2 minutes (solving dynamics)
3. When done, Variables Browser shows results
4. Right-click `generatedPower` → Plot
5. Should see ~4 MW output

---

## 🎯 What You Have Now

### Your Model Includes:
- ✓ Air compressor
- ✓ Combustion chamber  
- ✓ Gas turbine
- ✓ Shaft connecting them
- ✓ Generator
- ✓ Power sensor
- ✓ All connections working!

### Current Scale:
- **4 MW** (example scale)
- You need: **275 MW** (your target)
- **Scaling factor:** ~69x

### Why So Small?
The ThermoPower example is a small demonstration turbine. Tomorrow we'll discuss how to scale it up to your 625 MW fuel input!

---

## 📊 Understanding the Model

### Key Parameters (in the model):

**Compressor:**
- Inlet: 244.4 K, 0.343 bar (about 0.34 atm - altitude?)
- Outlet: ~600 K, ~8.3 bar
- Pressure ratio: ~24
- Design speed: 157 rpm

**Combustion Chamber:**
- Exit temp: 1370 K (1097°C)
- Heating value: 41.6 MJ/kg
- Volume: 0.05 m³

**Turbine:**
- Inlet: 1370 K, ~7.85 bar
- Outlet: 800 K, ~1.52 bar  
- Expansion ratio: ~5

**Generator:**
- Rated: 4 MW
- Mechanical efficiency included

---

## 🔍 Compare with Yesterday

| Parameter | Yesterday (Simple) | ThermoPower Example | Your Target |
|-----------|-------------------|---------------------|-------------|
| **Power Output** | 274.6 MW | 4 MW | 275 MW |
| **Scale** | Medium | Very small | Medium |
| **Pressure Ratio** | 18 | ~24 | 18 |
| **Turbine Inlet** | 1400°C | 1097°C | 1400°C |
| **Air Inlet** | 15°C, 1 atm | -29°C, 0.34 atm | 15°C, 1 atm |

**ThermoPower example ≈ 1.5% of your target scale!**

---

## ⚠️ Important Notes

### This Model Works But:
1. **Different scale** - It's tiny (4 MW vs your 275 MW)
2. **Different conditions** - Altitude/cold climate settings
3. **Performance maps** - Specific to this turbine design
4. **You need scaling** - Tomorrow's task!

### What's Good:
1. ✓ All ThermoPower components working
2. ✓ Proper connections
3. ✓ Diagram view should appear
4. ✓ Foundation for your larger model

---

## 🎓 What to Learn Today

### Study the Diagram:
1. See how components are arranged
2. Understand connection lines
3. Note the shaft (mechanical connection)
4. See electrical connection to grid

### Check Parameters:
1. Right-click any component
2. Select "Parameters"
3. See what values are set
4. Compare with yesterday's model

### Observe Results:
1. After simulation
2. Plot different variables:
   - `generatedPower` - electrical output
   - `compressor.outlet.T` - compressed air temp
   - `turbine.inlet.T` - turbine inlet temp
   - `powerSensor.W` - mechanical power

---

## 🚀 Tomorrow's Plan

### Morning: Understand Scaling

**Option A: Scale Up (Complex)**
- Increase all mass flows by 69x
- Adjust component sizes
- Update performance maps
- Risk: Maps may not be valid at new scale

**Option B: Use as Learning Reference (Easier)**
- Keep this as example of ThermoPower usage
- Build new model at correct scale
- Use similar component structure
- Validate approach against this working example

**Option C: Hybrid Approach (Recommended)**
- Use yesterday's simple model equations
- Package in ThermoPower-style components
- Get diagram view benefits
- Match your validated 275 MW results

### Afternoon: HRSG Planning
- Study ThermoPower water/steam examples
- Understand HRSG component structure
- Plan connection strategy

---

## ✅ Success for Today

If you can:
- [ ] Load MyGasTurbine_v1.mo in OMEdit
- [ ] See diagram view with components
- [ ] Simulate successfully (~1-2 min)
- [ ] See ~4 MW power output in results
- [ ] Understand it's scaled too small

**Then you're ready for tomorrow's scaling discussion!**

---

## 💡 Pro Tips

### Tip 1: Always Load ThermoPower First
Before opening any model that uses ThermoPower, load the library first!

### Tip 2: Be Patient with Simulation
ThermoPower solves full dynamics. First simulation takes 1-2 minutes. This is normal!

### Tip 3: Save Your Experiments
When you modify parameters, do: File → Save As → MyGasTurbine_v2.mo
Keep numbered versions so you can go back!

### Tip 4: Study the Original
You can always compare with `ThermoPower.Examples.BraytonCycle.Plant` if something breaks.

---

## 🎯 Quick Test

Try this in OMEdit after loading your model:

```
1. Simulate model (wait for completion)
2. In Variables Browser, find: generatedPower
3. Right-click → Plot
4. You should see line around 4e6 (4 MW)
5. Success = Model works! ✓
```

---

**Ready? Open OMEdit and try it!** 🚀

Tomorrow we'll tackle the scaling challenge together!

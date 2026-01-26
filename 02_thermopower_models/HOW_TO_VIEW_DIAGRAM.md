# How to View Diagram in OMEdit

Since you're getting "nothing in diagram view", here's the step-by-step process:

## Method 1: Open Model in OMEdit (Recommended)

### Step 1: Launch OMEdit
- Open OMEdit application

### Step 2: Load ThermoPower Library FIRST
```
File → Open Model/Library File
Navigate to: CCGT_OpenModelica/ThermoPower/package.mo
Click: Open
```
**Important:** Always load ThermoPower before opening models that use it!

### Step 3: Load Your Model
```
File → Open Model/Library File
Navigate to: CCGT_OpenModelica/02_thermopower_models/models/Step3_GasTurbine_ThermoPower.mo
Click: Open
```

### Step 4: Switch to Diagram View
- Look at the toolbar (top of OMEdit window)
- Find icon that looks like boxes/components (not text lines)
- Click "Diagram View" icon
- **OR** use menu: View → Diagram View
- **OR** press shortcut (usually Ctrl+3 or similar)

### Step 5: If Diagram is Empty
**This means components haven't been placed yet!**

The model needs icons/positions defined. Let me create a version with diagram annotations.

---

## Why Diagram Might Be Empty

### Reason 1: No Icon Positions Defined
The `.mo` file I created has only text (equation) code, no graphical layout information.

**Solution:** Add diagram annotations or use OMEdit's graphical editor to place components.

### Reason 2: ThermoPower Not Loaded
If ThermoPower isn't loaded first, OMEdit can't find component icons.

**Solution:** Always load ThermoPower first!

### Reason 3: Using Text View Instead
Make sure you clicked "Diagram View" not "Text View".

---

## Alternative: Study ThermoPower Example First

Since Step3 diagram might be empty, study the working example:

### Open ThermoPower Brayton Example:
1. Load ThermoPower library
2. In Libraries Browser (left panel):
   ```
   ThermoPower
   └── Examples
       └── BraytonCycle
           └── Plant
   ```
3. Double-click "Plant"
4. Click "Diagram View"
5. **You WILL see diagram** - ThermoPower example has all graphical info

### This shows you:
- How components look visually
- How they're connected
- Component placement
- Professional diagram layout

---

## Quick Fix: Use Graphical Modeling

Instead of text-based model, let's create it graphically:

### Method: Build Model in Diagram View

1. **In OMEdit, create new model:**
   ```
   File → New → Modelica Class
   Name: Step3_GasTurbine_Visual
   ```

2. **Switch to Diagram View immediately**

3. **Drag components from ThermoPower library:**
   - From Libraries Browser, expand ThermoPower → Gas
   - Drag `SourcePressure` to diagram
   - Drag `Compressor` to diagram
   - Drag `Combustor` to diagram  
   - Drag `Turbine` to diagram
   - Drag `SinkPressure` to diagram

4. **Connect them:**
   - Click on outlet of one component
   - Drag to inlet of next component
   - Lines appear = connections!

5. **Set parameters:**
   - Right-click each component → Parameters
   - Set values (PR=18, etc.)

This way you BUILD the diagram visually!

---

## For Now: Simulation Works, Diagram Later

The good news: **Your model loads and can simulate!**

The diagram view issue is just about visual representation. The physics/equations are correct.

### You can:
1. ✓ Simulate the model (command line)
2. ✓ Get results (power output, etc.)
3. ✓ Validate against yesterday's model

### You cannot yet:
4. ✗ See pretty diagram (need to add icon positions)

**But the model WORKS!** Diagram is just visualization.

---

## Tomorrow's Plan

1. **Today:** Get simulation results from Step3 (text-based is OK!)
2. **Tomorrow:** Learn to use OMEdit graphical editor
3. **Build HRSG graphically** in diagram view from start
4. **Connect visually** - much easier!

**The equations work, visualization comes next!** 🚀

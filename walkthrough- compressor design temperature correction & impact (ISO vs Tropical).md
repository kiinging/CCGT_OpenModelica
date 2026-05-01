# Walkthrough: Compressor Design Temperature Correction & Impact

## What Was Changed

### Single Parameter Fix
**File:** [CombineCycle.mo](file:///c:/Users/user/OneDrive/Documents/FYP1/CCGT_OpenModelica-main%20-%20M701F%20working%20model/CCGT_OpenModelica-main/ThermoPower/ThermoPower/CombineCycle.mo)

```diff
 // OpenLoopCombineCycle_M701F (line 1215)
-Tdes_in = 305.15   ← told model "compressor was designed for 32°C"
+Tdes_in = 288.15   ← correctly says "compressor was designed for ISO 15°C"

 // CloseLoopCombineCycle_M701F (line 1421)
-Tdes_in = 305.15
+Tdes_in = 288.15
```

No other parameters were changed. The ISO model (`OpenLoopCombineCycle_M701F_ISO`) already had `Tdes_in = 288.15`.

---

## Why It Was Changed

### The Problem
The M701F gas turbine compressor is physically designed and manufactured at ISO conditions (15°C, 288.15 K). When `Tdes_in` was set to `305.15` (the tropical ambient temperature), the model treated the compressor as if it were *designed* for 32°C operation. This meant:

- At 32°C ambient, the corrected speed = 100% (design point)
- The compressor operated at the centre of its performance map
- **No off-design effects** → no tropical derating visible

### The Physics
The ThermoPower compressor calculates corrected speed for map lookup:

```
N_corrected = N_actual / (N_design × √(T_inlet / Tdes_in))
```

| Condition | Before Fix | After Fix |
|---|---|---|
| ISO (15°C) | N_corr = 1.000 | N_corr = 1.000 |
| Tropical (32°C) | N_corr = 1.000 ← wrong | **N_corr = 0.972** ← correct |

At 97.2% corrected speed, the compressor operating point shifts down the map:
- Lower pressure ratio
- Lower mass flow capacity  
- Lower isentropic efficiency
- → Significantly reduced GT net power output

This is exactly what happens in real gas turbines at elevated ambient temperatures.

---

## Results: Before vs After Fix

### Before Fix (Tdes_in = 305.15 — incorrect)

| Condition | Fuel | GT | ST | Total | η_CC | GT:ST |
|---|---|---|---|---|---|---|
| ISO (15°C) | 19.72 kg/s | 337 MW | 161 MW | 498 MW | 53.6% | 2.09:1 |
| Tropical (32°C) | 19.72 kg/s | 331 MW | 170 MW | 501 MW | 54.0% | 1.95:1 |
| Derating | — | −6 MW (−1.8%) | +9 MW (+5.6%) | **+3 MW (+0.6%)** | +0.4 pp | — |

> ⚠️ **Problem:** Tropical model showed *higher* total power than ISO — physically impossible for same fuel input. No meaningful derating captured.

### After Fix (Tdes_in = 288.15 — correct)

| Condition | Fuel | GT | ST | Total | η_CC | GT:ST |
|---|---|---|---|---|---|---|
| ISO (15°C) | 19.72 kg/s | 337 MW | 161 MW | 498 MW | 53.6% | 2.09:1 |
| Tropical (32°C) | 19.72 kg/s | 292 MW | 196 MW | 488 MW | 52.5% | 1.49:1 |
| **Derating** | — | **−45 MW (−13.4%)** | +35 MW (+21.7%) | **−10 MW (−2.0%)** | **−1.1 pp** | shifted |

> ✅ **Correct behavior:** GT power drops significantly at tropical conditions. ST partially compensates due to hotter exhaust gas. Net CC derating of 2.0% is now visible.

### Physical Explanation of the Results

1. **GT drops 45 MW (−13.4%)**
   - Compressor at 97.2% corrected speed → lower PR → less compression work recovered by turbine
   - Higher compressor inlet temperature → more specific work to compress each kg of air
   - Net effect: substantially less GT shaft power

2. **ST rises 35 MW (+21.7%)**  
   - Lower compressor PR → less expansion in gas turbine → higher exhaust temperature
   - Hotter exhaust → more heat available in HRSG → more steam generated
   - More steam × similar enthalpy drop = significantly more ST power

3. **Net CC derating −10 MW (−2.0%)**
   - Real CCGTs see 3-5% net derating for 17°C above ISO
   - The model shows 2% — the ST compensation is slightly aggressive
   - Qualitatively correct pattern: GT loss > ST gain

---

## Impact on Previous GA Optimisation Results

### Previous GA Results (now invalid — based on incorrect baseline)

| Run | Baseline η | Optimised η | Δη |
|---|---|---|---|
| Theoretical (wide bounds) | 54.09% | 55.02% | +0.93 pp |
| Practical (tropical bounds) | 54.09% | 54.39% | +0.30 pp |

> These results used the incorrect baseline (GT=331 MW, ST=170 MW, η=54.09%). They are saved in `ga_results_theoretical/` and `ga_results_practical/` for reference but should be re-run.

### New Baseline for GA Re-run

| Parameter | Before Fix | After Fix |
|---|---|---|
| GT power | 331 MW | **292 MW** |
| ST power | 170 MW | **196 MW** |
| Total | 501 MW | **488 MW** |
| η_CC | 54.09% | **52.5%** |
| GT:ST ratio | 1.95:1 | **1.49:1** |

### What Needs to Be Done Before GA Re-run

1. **Clear `ga_workspace/`** — compiled model is based on old `Tdes_in`, must recompile
2. **Update `ga_optimise_m701f.py`** — update baseline comment (cosmetic only, doesn't affect execution)
3. **Update `GA_Individual.mo`** — the wrapper extends `OpenLoopCombineCycle_M701F`, which now has the fix. The wrapper itself doesn't set `Tdes_in`, so it will inherit the corrected value automatically. **No change needed.**
4. **Re-run both GA scenarios** (theoretical + practical bounds)
5. **Rename old results** (already done: `ga_results_theoretical/`, `ga_results_practical/`)

---

## Updated Thesis Narrative

### Before (incorrect)
> "Tropical conditions have minimal impact on total CC output (501 MW vs 498 MW ISO)."

### After (correct)
> "Operating the M701F at 32°C tropical ambient reduces GT output by 13.4% compared to ISO conditions due to off-design compressor operation at 97.2% corrected speed. The steam cycle partially compensates by recovering additional heat from the elevated exhaust gas temperature (+21.7% ST power), limiting the net combined cycle derating to 2.0% (−10 MW). The GA optimisation targets recovery of this efficiency gap by adjusting condenser vacuum, HRSG pressure, and compressor PR within practical tropical constraints."

---

## Summary of All Changes Made This Session

| # | Change | File | Lines | Reason |
|---|---|---|---|---|
| 1 | `Tdes_in = 305.15` → `288.15` | CombineCycle.mo | 1215 | OpenLoop compressor designed at ISO |
| 2 | `Tdes_in = 305.15` → `288.15` | CombineCycle.mo | 1421 | CloseLoop compressor designed at ISO |

**Files NOT changed** (no action needed):
- `GA_Individual.mo` — inherits from OpenLoop, auto-picks up the fix
- `ga_optimise_m701f.py` — FUEL_FLOW and BOUNDS unchanged
- `OpenLoopCombineCycle_M701F_ISO` — already had `Tdes_in = 288.15`

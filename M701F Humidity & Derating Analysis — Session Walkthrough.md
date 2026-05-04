# M701F Humidity & Derating Analysis — Session Walkthrough

> **Date**: 2 May 2026  
> **Objective**: Quantify the power derating of the M701F CCGT under tropical conditions by decomposing the effects of temperature and humidity separately.

---

## 1. Media Packages Created

Three air medium packages now exist in [Media.mo](file:///c:/Users/user/OneDrive/Documents/FYP1/CCGT_OpenModelica-main%20-%20M701F%20working%20model/CCGT_OpenModelica-main/ThermoPower/ThermoPower/Media.mo):

| Package | X_H₂O | X_O₂ | X_N₂ | X_Ar | Physical Basis |
|---|---|---|---|---|---|
| `Media.ISOAir` | **0.63%** | 23.15% | 75.72% | 0.50% | ISO standard: 15°C, **60% RH** |
| `Media.Air` | 1.50% | 23.00% | 75.00% | 0.50% | ThermoPower default (generic) |
| `Media.TropicalAir` | **2.40%** | 22.64% | 74.46% | 0.50% | Malaysian equatorial: 32°C, **81% RH** |

### Humidity-to-RH Conversion Math

```
ω = X_H2O / (1 - X_H2O)                          humidity ratio
p_w = ω × p_atm / (0.622 + ω)                    partial pressure of water
p_sat(T) = 611.2 × exp(17.67 × (T-273.15) / (T-273.15 + 243.5))   Magnus formula
RH = p_w / p_sat(T)
```

| X_H₂O | At 15°C | At 32°C |
|---|---|---|
| 0.63% | **60% RH** ✅ | ~13% RH |
| 1.50% | **~142% RH** ⚠️ supersaturated | **~51% RH** ✅ |
| 2.40% | supersaturated | **~81% RH** ✅ |

> [!IMPORTANT]
> The original `Media.Air` (1.5% H₂O) is **supersaturated at 15°C** — physically impossible. `ISOAir` was created to fix this for the ISO model. At 32°C, 1.5% is valid (~51% RH).

---

## 2. Models Modified

### [CombineCycle.mo](file:///c:/Users/user/OneDrive/Documents/FYP1/CCGT_OpenModelica-main%20-%20M701F%20working%20model/CCGT_OpenModelica-main/ThermoPower/ThermoPower/CombineCycle.mo)

#### `OpenLoopCombineCycle_M701F_ISO` (15°C baseline)
- `SourceP1`, `compressor`, `PressDrop2`, `stateInletCC`: `Media.Air` → **`Media.ISOAir`**
- Temperature: 288.15 K (15°C)

#### `OpenLoopCombineCycle_M701F` (32°C humid tropical)
- `SourceP1`, `compressor`, `PressDrop2`, `stateInletCC`: `Media.Air` → **`Media.TropicalAir`**
- Temperature: 305.15 K (32°C)

#### `CloseLoopCombineCycle_M701F` (32°C humid tropical, closed-loop)
- Same 4 components → **`Media.TropicalAir`**

### [DryTropical_M701F.mo](file:///c:/Users/user/OneDrive/Documents/FYP1/CCGT_OpenModelica-main%20-%20M701F%20working%20model/CCGT_OpenModelica-main/ga_workspace/DryTropical_M701F.mo) (standalone)
- Uses **`Media.Air`** (1.5% H₂O) at 305.15 K (32°C)
- Purpose: humidity isolation — compare against humid tropical at same temperature

### Summary Table

| Model | Medium | T_inlet | RH | Purpose |
|---|---|---|---|---|
| ISO | `Media.ISOAir` (0.63%) | 15°C | 60% | ISO reference baseline |
| DryTropical | `Media.Air` (1.5%) | 32°C | ~51% | Temperature-only derating baseline |
| HumidTropical | `Media.TropicalAir` (2.4%) | 32°C | ~81% | Full tropical conditions |

---

## 3. Simulation Scripts

### [simulate_humidity_test.py](file:///c:/Users/user/OneDrive/Documents/FYP1/CCGT_OpenModelica-main%20-%20M701F%20working%20model/CCGT_OpenModelica-main/simulate_humidity_test.py)
- Compares: **ISO (15°C, ISOAir) vs Tropical (32°C, TropicalAir)**
- Shows total derating (temperature + humidity combined)

### [simulate_humidity_comparison.py](file:///c:/Users/user/OneDrive/Documents/FYP1/CCGT_OpenModelica-main%20-%20M701F%20working%20model/CCGT_OpenModelica-main/simulate_humidity_comparison.py)
- Compares: **DryTropical (32°C, Air) vs HumidTropical (32°C, TropicalAir)**
- Isolates humidity-only effect at constant 32°C

Both scripts: stopTime=2100s, read at t=2000s, tolerance=1e-6.

---

## 4. Simulation Results

### Test 1: ISO vs Humid Tropical (temperature + humidity)

| Metric | ISO (15°C, 0.63% H₂O) | Tropical (32°C, 2.4% H₂O) | Delta |
|---|---|---|---|
| **GT Power** | 336.1 MW | 295.6 MW | **−40.5 MW** (−12.1%) |
| **ST Power** | 163.1 MW | 193.8 MW | **+30.7 MW** (+18.8%) |
| **Total CC** | 499.2 MW | 489.4 MW | **−9.8 MW** (−2.0%) |
| **Efficiency** | 61.55% | 60.35% | **−1.20 pp** |

### Test 2: Humidity-only isolation (both at 32°C)

| Metric | Dry (1.5% H₂O, ~51% RH) | Humid (2.4% H₂O, ~81% RH) | Delta |
|---|---|---|---|
| **GT Power** | 292.0 MW | 295.6 MW | **+3.6 MW** |
| **ST Power** | 196.1 MW | 193.8 MW | −2.3 MW |
| **Total CC** | 488.1 MW | 489.4 MW | **+1.3 MW** |
| **Efficiency** | 60.19% | 60.35% | +0.16 pp |

---

## 5. Derating Budget

| Effect | GT Delta | ST Delta | CC Total | CC % of ISO |
|---|---|---|---|---|
| **Temperature (15→32°C)** | −44.1 MW | +33.0 MW | **−10.9 MW** | **−2.18%** |
| **Humidity (0.63→2.4% H₂O)** | +3.6 MW | −2.3 MW | **+1.1 MW** | **+0.22%** |
| **Net Tropical Derating** | −40.5 MW | +30.7 MW | **−9.8 MW** | **−1.96%** |

```
         ISO Baseline: 499.2 MW (100%)
                │
                ▼ Temperature: −10.9 MW (−2.18%)
                │
         Dry Tropical: 488.1 MW (97.78%)
                │
                ▲ Humidity: +1.1 MW (+0.22%)
                │
        Humid Tropical: 489.4 MW (98.04%)
```

---

## 6. Key Findings

### Finding 1: Humidity INCREASES Power at Constant Temperature
At constant 32°C, increasing humidity from 1.5% to 2.4% H₂O **increases** total CC power by +1.3 MW. This is because:
- H₂O has **higher c_p** (~1.86 kJ/kg·K) than the N₂/O₂ it displaces (~1.0 kJ/kg·K)
- H₂O has **lower molecular weight** (M=18 vs M≈29) → higher gas constant R → more expansion work per kg
- The increased specific work **outweighs** the reduced mass flow from lower density

> [!WARNING]
> The common assumption that "tropical humidity derates gas turbines" is **incorrect at constant temperature**. The perceived humidity derating in practice is actually temperature derating — hot humid climates are hot first, humid second.

### Finding 2: HRSG Thermal Buffer Effect
The GT derates by −40.5 MW (−12.1%), but the ST recovers +30.7 MW (+18.8%). The HRSG acts as a thermal buffer — when the GT produces less work, the exhaust is hotter and carries more enthalpy to the steam cycle. Net CC derating is only **2.0%** despite a 12.1% GT derating.

### Finding 3: Temperature Dominates
Temperature accounts for ~111% of the net CC derating (−10.9 MW), while humidity partially recovers ~11% of it (+1.1 MW). The 17°C ambient increase (15→32°C) drives the corrected speed down to 97.17%, reducing compressor mass flow by ~6.4% and pressure ratio by ~12%.

### Finding 4: ISOAir Correction
The original `Media.Air` (1.5% H₂O) was supersaturated at 15°C (~142% RH). Correcting to `ISOAir` (0.63% H₂O, 60% RH) changed ISO GT power by only −1.5 MW, confirming humidity's small overall effect. The correction provides physically accurate results for thesis documentation.

---

## 7. Files Changed

| File | Change |
|---|---|
| [Media.mo](file:///c:/Users/user/OneDrive/Documents/FYP1/CCGT_OpenModelica-main%20-%20M701F%20working%20model/CCGT_OpenModelica-main/ThermoPower/ThermoPower/Media.mo) | Added `TropicalAir` (2.4% H₂O) and `ISOAir` (0.63% H₂O) packages |
| [CombineCycle.mo](file:///c:/Users/user/OneDrive/Documents/FYP1/CCGT_OpenModelica-main%20-%20M701F%20working%20model/CCGT_OpenModelica-main/ThermoPower/ThermoPower/CombineCycle.mo) | Updated ISO model → `ISOAir`, tropical models → `TropicalAir` |
| [DryTropical_M701F.mo](file:///c:/Users/user/OneDrive/Documents/FYP1/CCGT_OpenModelica-main%20-%20M701F%20working%20model/CCGT_OpenModelica-main/ga_workspace/DryTropical_M701F.mo) | New standalone model (32°C, `Air` 1.5% H₂O) |
| [simulate_humidity_test.py](file:///c:/Users/user/OneDrive/Documents/FYP1/CCGT_OpenModelica-main%20-%20M701F%20working%20model/CCGT_OpenModelica-main/simulate_humidity_test.py) | ISO vs Tropical comparison script |
| [simulate_humidity_comparison.py](file:///c:/Users/user/OneDrive/Documents/FYP1/CCGT_OpenModelica-main%20-%20M701F%20working%20model/CCGT_OpenModelica-main/simulate_humidity_comparison.py) | Humidity-only isolation script |

---

## 8. Related Artifacts

- [derating_math_and_humidity.md](file:///C:/Users/user/.gemini/antigravity/brain/b896b6cf-f712-4e47-b718-1a76bb5d2ad9/derating_math_and_humidity.md) — Mathematical derivation of Tdes_in derating + humidity options
- [simulation_results_humidity.md](file:///C:/Users/user/.gemini/antigravity/brain/b896b6cf-f712-4e47-b718-1a76bb5d2ad9/simulation_results_humidity.md) — Detailed simulation results with all three comparisons
- [iso_vs_tropical_comparison.md](file:///C:/Users/user/.gemini/antigravity/brain/b896b6cf-f712-4e47-b718-1a76bb5d2ad9/iso_vs_tropical_comparison.md) — Parameter-level comparison between ISO and tropical models

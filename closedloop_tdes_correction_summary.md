# Closed-Loop M701F — Tdes_in Correction Summary

## 1. What Was Changed

### Root Cause
The compressor `Tdes_in` parameter was set to `305.15 K` (32°C, the tropical ambient), which told the model the compressor was *designed* for tropical conditions. In reality, the M701F compressor is designed at **ISO 15°C (288.15 K)**. This masked all tropical derating effects.

### Changes Made to `CloseLoopCombineCycle_M701F`

| # | Parameter | Before | After | Line |
|---|---|---|---|---|
| 1 | `compressor.Tdes_in` | 305.15 | **288.15** | 1421 |
| 2 | `powerSensor1_GT.y_start` | 331e6 | **281e6** | 1440 |
| 3 | `powerSetPoint.offset` | 331e6 | **281e6** | 1510 |
| 4 | `powerController.PVstart` | 0.662 | **0.562** | 1516 |

### Why Each Change Was Needed

1. **`Tdes_in = 288.15`** — The compressor was physically designed at ISO. At 32°C, the corrected speed drops to 97.2%, shifting the operating point down the compressor map → lower PR, lower mass flow, lower GT power.

2. **`y_start = 281e6`** — The GT power sensor initial guess must match the actual achievable output. With 331e6, the initialization created an inconsistent state.

3. **`offset = 281e6`** — The PID setpoint must match what the derated GT can physically deliver. At 331 MW, the PID saturated at CSmax=21 kg/s trying to reach an impossible target, dumping excess fuel into the HRSG.

4. **`PVstart = 0.562`** — PID initial process variable = 281/500 = 0.562, consistent with the new setpoint.

---

## 2. Why the Old Model Was Wrong

With `Tdes_in = 305.15` (before fix), the PID setpoint was 331 MW — achievable because the compressor thought it was at design point. After correcting to `Tdes_in = 288.15`, the maximum GT output dropped to ~281 MW. The PID was still targeting 331 MW:

```
PID: "GT = 281 MW, setpoint = 331 MW → error = +50 MW → MAX FUEL!"
     → CSmax = 21 kg/s (saturated)
     → Extra fuel → hotter exhaust → ST jumps to 226 MW
     → GT stuck at ~281 MW (compressor can't deliver more)
```

This produced a flat, unresponsive GT output with an artificially inflated ST.

---

## 3. Results — Before vs After

### Before Fix (Tdes_in = 32°C, setpoint = 331 MW)

![Before — Tdes_in = 32°C](images_M701F_closedloop/Compressor%20Tdes_in%20=%2032.png)

| Parameter | Value |
|---|:---:|
| GT Power (steady) | ~335 MW |
| ST Power (steady) | ~170 MW |
| Total CC | ~505 MW |
| GT:ST Ratio | 1.97:1 |
| Ramp response | ✅ Visible at t=800s |
| PID status | Normal (not saturated) |

### After Fix — PID saturated (Tdes_in = 15°C, setpoint still 331 MW)

| Parameter | Value |
|---|:---:|
| GT Power | ~281 MW (flat) |
| ST Power | ~226 MW (flat) |
| Total CC | ~507 MW |
| GT:ST Ratio | 1.24:1 |
| Ramp response | ❌ Not visible (PID saturated at CSmax) |
| PID status | **Saturated** — could not reach 331 MW setpoint |

### After Fix — Corrected (Tdes_in = 15°C, setpoint = 281 MW)

![After — Tdes_in = 15°C, corrected setpoint](images_M701F_closedloop/Compressor%20Tdes_in%20=%2015.png)

| Parameter | Value |
|---|:---:|
| GT Power (steady) | **~281 MW** |
| GT Power (after ramp) | **~286 MW** |
| ST Power (steady) | **~137 MW** |
| ST Power (after ramp) | **~139 MW** |
| Total CC (steady) | **~418 MW** |
| Total CC (after ramp) | **~425 MW** |
| GT:ST Ratio | **2.05:1** |
| Ramp response | ✅ **Visible at t=800s (+5 MW GT ramp)** |
| PID status | **Normal — tracking setpoint** |

---

## 4. Key Observations

### Power Output
- GT dropped from 335 MW → 281 MW (−16%) due to off-design compressor
- ST dropped from 170 MW → 137 MW (−19%) — expected because PID now delivers less fuel
- Total CC dropped from 505 MW → 418 MW (−17%)

### Controller Behavior
- PID now tracks the 281 MW setpoint correctly
- The +5 MW ramp at t=800s is clearly visible (GT ramps from 281 → 286 MW)
- ST responds with a ~200s thermal lag (137 → 139 MW)
- No PID saturation — controller output within [CSmin, CSmax] range

### GT:ST Ratio
- Restored to **2.05:1** — close to the design target of 2:1
- Previous saturated state had an artificial 1.24:1 ratio (excess fuel boosted ST)

---

## 5. Comparison: All Three Operating Points

| Scenario | GT | ST | Total | η_CC | GT:ST |
|---|:---:|:---:|:---:|:---:|:---:|
| **Open-loop ISO (15°C)** | 337 MW | 161 MW | 498 MW | 53.6% | 2.09:1 |
| **Open-loop Tropical (32°C)** | 292 MW | 196 MW | 488 MW | 52.5% | 1.49:1 |
| **Closed-loop Tropical (32°C)** | 281 MW | 137 MW | 418 MW | 45.0% | 2.05:1 |

> **Note:** The closed-loop total (418 MW) is lower than the open-loop tropical (488 MW) because the PID controls fuel flow to a lower setpoint. The open-loop model steps fuel to 19.72 kg/s, while the closed-loop settles at a lower fuel flow (~17 kg/s) to achieve the 281 MW GT target. The 2:1 GT:ST ratio is restored because the PID balances fuel to achieve the target GT power, not maximum total output.

# Scale Up OpenLoopCombineCycle to 500 MW Target

## Current Power Output Analysis

![Current GT and ST power output from OpenLoopCombineCycle](C:\Users\user\.gemini\antigravity\brain\cfc36601-0167-4484-b52f-ec88af20927f\image3.png)

### What the Plot Shows

The chart plots **`generatedPower_GT`** (red) and **`generatedPower_ST`** (blue) over 1000 seconds (1 ks).

| Signal | Steady-State (t < 500 s) | After Fuel Step (t > 600 s) | Physical Cause |
|--------|:---:|:---:|---|
| **GT Power** | **~69 MW** | **~76 MW** | Fuel flow steps from 6.39 → 7.29 kg/s. More fuel → hotter combustion → more turbine expansion work → higher net shaft power (turbine work minus compressor work). Response is fast (~10 s) because the gas path has very little thermal inertia. |
| **ST Power** | **~57 MW** | **~70 MW** | Hotter GT exhaust (620°C → 690°C) enters the HRSG. The superheater, evaporator, and economizer absorb more heat → more steam is produced → steam turbine output rises. Response is slow (~100 s settling) because the water/steam/metal masses in the HRSG have huge thermal inertia. |
| **Combined** | **~126 MW** | **~146 MW** | — |

### Why GT Responds Faster Than ST
- The **gas turbine** path is nearly pure gas with tiny volumes (combustion chamber V = 0.05 m³). Changes in fuel flow translate to turbine inlet temperature changes within seconds.
- The **steam turbine** power depends on the HRSG, which contains thousands of kilograms of water and metal. The economizer alone has `fluidVol = 28.977 m³` of water and `metalVol = 8.061 m³` of steel. These thermal masses act as a thermal buffer, creating the visible ~100 s lag.

### Current Model Scale Summary

| Parameter | Current Value |
|-----------|:---:|
| GT output (post-step) | ~76 MW |
| ST output (post-step) | ~70 MW |
| **Total CC output** | **~146 MW** |
| **Target** | **500 MW** |
| **Scale factor needed** | **~3.4×** |
| Fuel flow rate | 7.29 kg/s |
| Air mass flow (compressor nominal) | ~300 kg/s |
| Steam mass flow (nominal) | 55 kg/s |
| Compressor PR | ~24:1 |
| TIT | ~1370 K |
| Steam pressure | 30 bar |
| Condenser pressure | 5390 Pa |

---

## Scaling Strategy: 146 MW → 500 MW

> [!IMPORTANT]
> **Target split:** In a real-world CCGT plant, the GT typically produces about **2/3** of the total power and the ST about **1/3**. For 500 MW total, we aim for approximately **GT ≈ 330 MW** and **ST ≈ 170 MW**. This represents roughly a **4.3× scale-up on GT** and **2.4× scale-up on ST**.

### Scaling Philosophy

There are two levers to increase power in a CCGT:
1. **Increase mass flow** (bigger machine) — proportional to power.
2. **Increase thermodynamic intensity** (higher TIT, higher PR, higher steam pressure) — improves efficiency.

For a 3.4× scale-up, we need **both**. The approach below is modular: GT parameters are scaled first, then ST/HRSG parameters are scaled to match the new exhaust conditions.

---

## Proposed Changes

### Phase 1 — Gas Turbine Scale-Up

#### [MODIFY] [CombineCycle.mo](file:///c:/Users/user/OneDrive/Documents/CCGT_OpenModelica-main%20-%20Copy/CCGT_OpenModelica-main%20-%20Copy/ThermoPower/ThermoPower/CombineCycle.mo)

**1.1 — Scale compressor map tables (`tablePhicC`)**

The reduced mass flow parameter `φ_c` (phi_c) in the compressor map physically represents:
```
φ_c = ṁ·√(T_in) / p_in
```
To increase air mass flow from ~300 → ~990 kg/s (3.3×), we multiply all `tablePhicC` values by **3.3**.

| Row/Col | Current (N=100%) | Scaled (×3.3) |
|---------|:---:|:---:|
| β=1 | 43.0e-3 | 141.9e-3 |
| β=2 | 43.8e-3 | 144.5e-3 |
| β=3 | 45.2e-3 | 149.2e-3 |
| β=4 | 46.1e-3 | 152.1e-3 |
| β=5 | 46.6e-3 | 153.8e-3 |

**1.2 — Scale turbine map tables (`tablePhicT`)**

Similarly, the turbine reduced mass flow needs to pass the larger gas flow. Multiply all `tablePhicT` values by **3.3**.

| Current | Scaled (×3.3) |
|:---:|:---:|
| 4.68e-3 | 15.44e-3 |

**1.3 — Increase Turbine Inlet Temperature (TIT)**

Raise from 1370 K → **1550 K** (modern F-class GT level). This improves GT thermal efficiency and delivers hotter exhaust for better HRSG performance.

| Parameter | Current | New |
|-----------|:---:|:---:|
| `CombustionChamber1.Tstart` | 1370 | 1550 |
| `turbine.Tstart_in` | 1370 | 1550 |
| `turbine.Tdes_in` | 1400 | 1550 |
| `turbine.Tstart_out` | 800 | 870 |
| `PressDrop1.Tstart` | 1370 | 1550 |

**1.4 — Increase Compressor Pressure Ratio**

Scale the `tablePR` values up by a factor of **1.15** (from ~27:1 → ~31:1 at design point) to improve cycle efficiency.

**1.5 — Scale pressure drop components**

| Parameter | Current | New | Rationale |
|-----------|:---:|:---:|---|
| `PressDrop1.wnom` | 306 | 1010 | 3.3× mass flow |
| `PressDrop1.dpnom` | 26000 | 85800 | Δp ∝ ṁ² at const. area |
| `PressDrop2.wnom` | 300 | 990 | 3.3× mass flow |
| `PressDrop2.dpnom` | 0.19e5 | 0.627e5 | Δp ∝ ṁ² |

**1.6 — Scale fuel flow**

| Parameter | Current | New | Rationale |
|-----------|:---:|:---:|---|
| `SourceW1.w0` | 6.06 | 20 | ~3.3× matches air flow scale |
| `fuelFlowRateStep.offset` | 6.39 | 21.1 | 3.3× baseline fuel |
| `fuelFlowRateStep.height` | 0.9 | 3.0 | 3.3× step size |

**1.7 — Combustion chamber sizing**

| Parameter | Current | New | Rationale |
|-----------|:---:|:---:|---|
| `CombustionChamber1.V` | 0.05 | 0.165 | 3.3× volume for proportional residence time |
| `CombustionChamber1.S` | 0.05 | 0.165 | 3.3× surface |

**1.8 — Generator and grid**

If the `BraytonPlant` model with its embedded generator/grid is reused, `Pnom` must increase. However, in the `OpenLoopCombineCycle` simulator the GT shaft connects to a `ConstantSpeed` source (which acts as an infinite grid), so no `Pnom` change is needed there.

---

### Phase 2 — Steam Cycle & HRSG Scale-Up

With ~3.3× more gas at a higher temperature entering the HRSG, the steam side must be scaled to absorb the additional heat.

**2.1 — Scale steam mass flow and pump**

| Parameter | Current | New | Rationale |
|-----------|:---:|:---:|---|
| `steamTurbine.wnom` | 55 | 180 | ~3.3× steam flow |
| `steamTurbine.wstart` | 55 | 180 | Match nominal |
| `steamTurbine.Kt` | 0.0104 | 0.0343 | Stodola: Kt ∝ ṁ (at same PR) |
| `steamTurbine.pnom` | 3e6 | 9e6 | Raise to 90 bar for better Rankine efficiency |
| `steamTurbine.PRstart` | 30 | 167 | 9e6/5390/10 |

**2.2 — Scale pump**

| Parameter | Current | New | Rationale |
|-----------|:---:|:---:|---|
| `q_nom` | {0, 0.055, 0.1} | {0, 0.18, 0.33} | 3.3× volumetric flow |
| `head_nom` | {450, 300, 0} | {1000, 700, 0} | Higher head for 90 bar discharge |
| `nominalMassFlowRate` | 55 | 180 | 3.3× |
| `nominalOutletPressure` | 3e6 | 9e6 | Match new steam pressure |
| `nominalInletPressure` | 50000 | 50000 | Condenser pressure unchanged |

**2.3 — Scale HRSG heat exchangers**

All three HRSG components (economizer, evaporator, superheater) need their volumes and exchange surfaces scaled to handle 3.3× the gas and water flow.

#### Economizer

| Parameter | Current | New | Rationale |
|-----------|:---:|:---:|---|
| `exchSurface_G` | 40095.9 | 132316 | 3.3× surface |
| `exchSurface_F` | 3439.389 | 11350 | 3.3× |
| `extSurfaceTub` | 3888.449 | 12832 | 3.3× |
| `gasVol` | 10 | 33 | 3.3× |
| `fluidVol` | 28.977 | 95.6 | 3.3× |
| `metalVol` | 8.061 | 26.6 | 3.3× |
| `gasNomFlowRate` | 500 | 1650 | 3.3× |
| `fluidNomFlowRate` | 55 | 180 | 3.3× |
| `fluidNomPressure` | 3e6 | 9e6 | Match new steam pressure |
| `dpnom_G` | 1000 | 3300 | ∝ ṁ² (at constant area ratio) |
| `dpnom_F` | 20000 | 66000 | Same scaling |

#### Evaporator

| Parameter | Current | New | Rationale |
|-----------|:---:|:---:|---|
| `exchSurface` | 24402 | 80527 | 3.3× |
| `gasVol` | 10 | 33 | 3.3× |
| `fluidVol` | 12.4 | 40.9 | 3.3× |
| `metalVol` | 4.801 | 15.8 | 3.3× |
| `gasNomFlowRate` | 500 | 1650 | 3.3× |
| `fluidNomFlowRate` | 55 | 180 | 3.3× |
| `fluidNomPressure` | 3e6 | 9e6 | Match new steam pressure |
| `dpnom_G` | 1000 | 3300 | ∝ ṁ² |
| `Tstart` | 623.15 | 673.15 | Hotter gas from upgraded GT |

#### Superheater

| Parameter | Current | New | Rationale |
|-----------|:---:|:---:|---|
| `exchSurface_G` | 2314.8 | 7639 | 3.3× |
| `exchSurface_F` | 450.218 | 1486 | 3.3× |
| `extSurfaceTub` | 504.652 | 1665 | 3.3× |
| `gasVol` | 10 | 33 | 3.3× |
| `fluidVol` | 4.468 | 14.7 | 3.3× |
| `metalVol` | 1.146 | 3.78 | 3.3× |
| `gasNomFlowRate` | 500 | 1650 | 3.3× |
| `fluidNomFlowRate` | 55 | 180 | 3.3× |
| `fluidNomPressure` | 3e6 | 9e6 | Match new steam pressure |
| `Tstart_G` | 723.15 | 823.15 | Hotter GT exhaust |
| `Tstart_M` | 573.15 | 623.15 | Higher metal temp |
| `dpnom_G` | 1000 | 3300 | ∝ ṁ² |
| `dpnom_F` | 20000 | 66000 | Same scaling |

**2.4 — Condenser**

| Parameter | Current | New | Rationale |
|-----------|:---:|:---:|---|
| `p` | 5390 | 5390 | Keep same — condenser pressure is constrained by cooling water temperature |
| `Vtot` | 10 (default) | 33 | 3.3× for larger steam flow |

---

### Phase 3 — Control System Re-tuning

**3.1 — Void fraction PID controller**

| Parameter | Current | New | Rationale |
|-----------|:---:|:---:|---|
| `CSmin` | 500 | 500 | Pump min speed unchanged |
| `CSmax` | 2500 | 4000 | Higher max speed for larger pump |
| `PVstart` | 0.1 | 0.1 | Same setpoint |
| `Kp` | -2 | -2 | Try keeping same, re-tune if unstable |
| `Ti` | 300 | 300 | May need reduction if too sluggish |

**3.2 — Initialization start values**

Various `y_start` values on first-order filters (e.g., `powerSensor1_GT.y_start = 170e6`) should be updated to approximately **330e6** for GT and **170e6** for ST to help the solver initialize closer to the new operating point.

---

## Summary of Expected 500 MW Split

| Component | Current | Target | Scale Factor |
|-----------|:---:|:---:|:---:|
| GT Power | 76 MW | ~330 MW | 4.3× |
| ST Power | 70 MW | ~170 MW | 2.4× |
| **Total** | **146 MW** | **~500 MW** | **3.4×** |
| GT Efficiency | ~25% | ~33% | Higher TIT + PR |
| CC Efficiency | ~48% | ~55% | Better heat recovery |

> [!WARNING]
> **Iteration will be required.** These are first-pass scaling estimates based on thermodynamic similitude. After applying the changes, we must run the simulation and verify:
> 1. The model converges (initialization succeeds).
> 2. GT power reaches ~330 MW and ST power reaches ~170 MW.
> 3. The void fraction controller remains stable.
> 4. Stack temperature stays above 120°C (acid dew point constraint from README).
> 5. If the output is not exactly 500 MW, we fine-tune the fuel flow rate offset parameter as the primary adjustment knob.

---

## Verification Plan

### Automated Tests
1. **Run the simulation** in OpenModelica for 1000 s (same as current `StopTime`).
2. **Check `generatedPower_GT`** settles to ~330 MW (±10%).
3. **Check `generatedPower_ST`** settles to ~170 MW (±10%).
4. **Check `stateGasOutlet.T`** remains above 393 K (120°C) — acid dew point limit.
5. **Check evaporator void fraction** settles to ~0.2 (controller tracks setpoint).

### Manual Verification
- Compare before/after power output plots side by side.
- Verify transient response shape is similar (fast GT, slow ST).

---

## Open Questions

> [!IMPORTANT]
> **Q1:** Should I target a specific GT/ST power split (e.g., 330/170 MW), or is the total 500 MW the only constraint?

> [!IMPORTANT]
> **Q2:** Should the changes be made as a **new model** (e.g., `OpenLoopCombineCycle_500MW`), or should the **existing** `OpenLoopCombineCycle` model be modified in-place?

> [!IMPORTANT]
> **Q3:** The compressor and turbine efficiency tables (`tableEtaC`, `tableEtaT`) are kept the same because map shape vs β is a turbomachinery design property. Should we also adjust efficiency values for the larger machine (e.g., slightly higher peak η for a modern F-class turbine), or keep them unchanged?

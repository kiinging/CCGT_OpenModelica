# ISO vs Tropical M701F Open-Loop Model Comparison

Comparing `OpenLoopCombineCycle_M701F_ISO` (lines 973–1185) with `OpenLoopCombineCycle_M701F` (lines 1187–1399).

---

## Summary

The two models are **structurally identical** — same topology, same components, same equation connections. The **only differences** are in **two parameters** on the compressor component and the system-level ambient temperatures. Everything else — turbomachinery maps, HRSG sizing, fuel flow, steam cycle — is byte-for-byte identical.

---

## Parameter-by-Parameter Differences

| Parameter | ISO Model (`_M701F_ISO`) | Tropical Model (`_M701F`) | Effect |
|---|---|---|---|
| **`SourceP1.T`** (air inlet temp) | **288.15 K** (15 °C) | **305.15 K** (32 °C) | Hotter inlet air → lower air density → less mass flow → less GT power |
| **`compressor.Tstart_in`** | **288.15 K** | **305.15 K** | Initialization hint matching actual inlet |
| **`compressor.Tdes_in`** | **288.15 K** (15 °C) | **288.15 K** (15 °C) | ⚠️ **Same in both!** Design-point reference is always ISO |
| **`system.T_amb`** | **288.15 K** (15 °C) | **305.15 K** (32 °C) | System-level ambient temperature |
| **`system.T_wb`** | **284.15 K** (11 °C) | **301.15 K** (28 °C) | System-level wet-bulb temperature |

> [!IMPORTANT]
> These are the **only five** parameter differences between the two models. All turbomachinery maps (`tableEtaC`, `tableEtaT`, `tablePR`, `tablePhicC`, `tablePhicT`), combustion chamber settings, HRSG heat exchanger surfaces, steam turbine parameters, condenser pressure, fuel flow, and PID controllers are **100% identical**.

---

## How Derating Actually Works

The derating mechanism in this model is entirely driven by **thermodynamic first-principles** through the compressor's corrected-flow formulation, not by any explicit "derating factor" parameter.

### The `Tdes_in` / `Tstart_in` Mechanism

The ThermoPower `Gas.Compressor` uses **corrected flow** (reduced/non-dimensional flow):

```
φ_c = ṁ · √(T_in) / p_in
```

The compressor map tables (`tablePhicC`) store values of φ_c vs corrected speed. The key parameter is:

| Parameter | Role |
|---|---|
| **`Tdes_in`** | The **design-point inlet temperature** used to compute the corrected speed: `N_corrected = N / √(T_in / Tdes_in)` |
| **`Tstart_in`** | Just an initialization hint for the solver — doesn't affect steady-state physics |

### Why the Tropical Model Derates

In the **tropical model**, `Tdes_in = 288.15 K` (ISO) but actual `T_in = 305.15 K`:

1. **Corrected speed drops**: `N_corr = N / √(305.15/288.15) = N / 1.029` → the compressor operates at ~97% corrected speed instead of 100%
2. **Lower corrected flow**: At lower corrected speed, the compressor map gives lower φ_c, meaning less air mass flow
3. **Lower pressure ratio**: The PR map also gives a lower value at reduced corrected speed
4. **Cascade effect**: Less air → less combustion power → less turbine work → less GT output

> [!TIP]
> The derating is **automatic** and arises from the mismatch between `Tdes_in` (288.15 K, ISO reference) and the actual inlet temperature. The same mechanism would work for any ambient temperature — just change `SourceP1.T`, `compressor.Tstart_in`, and `system.T_amb`.

---

## Humidity and Ambient Temperature Handling

### Humidity

> [!WARNING]
> **No parameter in either model explicitly accounts for humidity.** 
> 
> - The air source (`Gas.SourcePressure`) uses `Media.Air`, which in ThermoPower is typically modeled as **dry air** (a fixed-composition ideal gas mixture of N₂, O₂, Ar, CO₂). 
> - There is no relative humidity input, no wet-air medium, and no moisture correction.
> - The `system.T_wb` (wet-bulb temperature) parameter exists in the system block but is **not used** by any component in these models — it would only matter if you had an evaporative cooling or cooling tower component.

### Ambient Temperature

Ambient temperature enters the model through **three paths**:

1. **`SourceP1.T`** — Sets the actual thermodynamic temperature of the air entering the compressor. **This is the primary derating driver.**
2. **`compressor.Tstart_in`** — Initialization hint (affects solver convergence, not steady-state result)
3. **`system.T_amb`** — Available to any component that references `system.T_amb`, but in the open-loop model no component directly uses it for heat rejection or environmental correction

---

## What Controls the Derating — Summary

| Control Lever | Parameter(s) | Present? |
|---|---|---|
| **Ambient air temperature** | `SourceP1.T` | ✅ Yes — **primary derating driver** |
| **Compressor design reference temp** | `compressor.Tdes_in` | ✅ Yes — fixed at 288.15 K (ISO) in both models, establishes the corrected-speed baseline |
| **Corrected speed via maps** | `tablePhicC`, `tablePR` | ✅ Yes — implicitly, through corrected-flow lookup |
| **Humidity / moisture** | — | ❌ **Not modeled** |
| **Explicit derating factor** | — | ❌ **Not present** — derating is emergent, not parameterized |
| **Fuel flow** | `fuelFlowRateStep.offset` | Same (17.22 kg/s) in both — no fuel-side derating |

---

## Key Insight for Your Thesis

The tropical derating in your model is a **physically correct emergent behavior**: hotter air reduces air density, which reduces corrected speed and mass flow through the compressor maps, naturally producing less power. This is exactly how real gas turbines derate. However, **humidity effects are absent** — in reality, high tropical humidity further affects air density and combustion, causing an additional ~1-3% derating that this model does not capture.

# Create `OpenLoopCombineCycle_500MW` — 500 MW Total Output

## Background

The existing `OpenLoopCombineCycle` model produces roughly **170–175 MW total** (GT ≈ 120 MW, ST ≈ 50 MW) via a single-pressure HRSG. The user wants a new model targeting **500 MW total combined-cycle output**, which is the *only* constraint. The model should be open-loop (fuel flow via step input, not power-controller feedback).

### Scaling Approach

A typical 500 MW CCGT splits roughly **330 MW GT / 170 MW ST** (≈ 2 : 1 ratio). Scaling factor from the baseline is approximately **500 / 170 ≈ 2.9×** overall. The GT scales by mass-flow and fuel-flow increases; the ST scales by proportionally larger HRSG surfaces, higher steam flow, and a bigger steam turbine.

---

## Proposed Changes

### [MODIFY] [CombineCycle.mo](file:///c:/Users/user/OneDrive/Documents/CCGT_OpenModelica-main%20-%20Copy/CCGT_OpenModelica-main%20-%20Copy/ThermoPower/ThermoPower/CombineCycle.mo)

Insert a new model `OpenLoopCombineCycle_500MW` inside the `Simulators` package (after `OpenLoopCombineCycle`, before `CloseLoopCombineCycle`). The model is a full copy of `OpenLoopCombineCycle` with the following parameter adjustments:

#### Gas Turbine (Brayton) Side — targeting ≈ 330 MW shaft power

| Parameter | Original | 500 MW | Rationale |
|-----------|----------|--------|-----------|
| `tablePhicC` flow coefficients | `38–49 × 10⁻³` | `×2.9` (~`111–143 × 10⁻³`) | Compressor swallowing capacity scales with mass flow |
| `tablePhicT` flow coefficients | `4.68 × 10⁻³` | `×2.9` (~`13.6 × 10⁻³`) | Turbine flow capacity scales similarly |
| `compressor.pstart_out` | `2.45e6` | `2.45e6` | Pressure ratio stays the same (characteristic of machine design) |
| `SourceW1.w0` (fuel) | `6.06 kg/s` | `17.6 kg/s` | Fuel flow ∝ GT power |
| `PressDrop1.wnom` | `306 kg/s` | `888 kg/s` | Flue-gas nominal flow |
| `PressDrop2.wnom` | `300 kg/s` | `870 kg/s` | Air nominal flow |
| `CombustionChamber1.V` | `0.05 m³` | `0.15 m³` | Larger chamber volume |
| `CombustionChamber1.S` | `0.05 m²` | `0.15 m²` | Larger chamber surface |
| `fuelFlowRateStep.offset` | `6.39` | `17.6` | Steady-state fuel flow |
| `fuelFlowRateStep.height` | `0.9` | `2.6` | Step perturbation ∝ scale |
| `generator / grid Pnom` | `4e6 / 1e9` | Not used (const speed) | No change needed — open loop uses ConstantSpeed |
| `powerSensor1_GT.y_start` | `170e6` | `330e6` | Updated initial guess |

> [!IMPORTANT]
> The compressor/turbine efficiency tables (`tableEtaC`, `tableEtaT`) and pressure-ratio table (`tablePR`) are kept **unchanged** — they represent dimensionless map shapes that are valid across machine sizes. Only the flow-capacity tables (`tablePhicC`, `tablePhicT`) are scaled.

#### Steam Cycle (Rankine) Side — targeting ≈ 170 MW

| Parameter | Original | 500 MW | Rationale |
|-----------|----------|--------|-----------|
| **HRSG gas flow** (`gasNomFlowRate`) | `500 kg/s` | `1450 kg/s` | GT exhaust mass flow ≈ air + fuel |
| **Steam mass flow** (`fluidNomFlowRate`) | `55 kg/s` | `160 kg/s` | ∝ ST power |
| **Steam pressure** (`fluidNomPressure`) | `30 bar` | `90 bar` | Higher pressure for larger plant efficiency |
| **Condenser pressure** | `5390 Pa` | `5390 Pa` | Unchanged — typical condenser vacuum |
| **Economizer** | | | |
| &nbsp;&nbsp;`exchSurface_G` | `40096` | `116300` (×2.9) | Heat transfer area scales with duty |
| &nbsp;&nbsp;`exchSurface_F` | `3439` | `9975` (×2.9) | |
| &nbsp;&nbsp;`extSurfaceTub` | `3888` | `11275` (×2.9) | |
| &nbsp;&nbsp;`gasVol` | `10` | `29` | |
| &nbsp;&nbsp;`fluidVol` | `28.977` | `84` | |
| &nbsp;&nbsp;`metalVol` | `8.061` | `23.4` | |
| &nbsp;&nbsp;`Tstart_G` | `473 K` | `493 K` | Slightly hotter due to higher exhaust energy |
| &nbsp;&nbsp;`Tstart_M` | `423 K` | `443 K` | |
| **Evaporator** | | | |
| &nbsp;&nbsp;`exchSurface` | `24402` | `70800` (×2.9) | |
| &nbsp;&nbsp;`gasVol` | `10` | `29` | |
| &nbsp;&nbsp;`fluidVol` | `12.4` | `36` | |
| &nbsp;&nbsp;`metalVol` | `4.801` | `13.9` | |
| &nbsp;&nbsp;`Tstart` | `623 K` | `623 K` | Saturation temp set by pressure |
| **Superheater** | | | |
| &nbsp;&nbsp;`exchSurface_G` | `2315` | `6715` (×2.9) | |
| &nbsp;&nbsp;`exchSurface_F` | `450` | `1306` (×2.9) | |
| &nbsp;&nbsp;`extSurfaceTub` | `505` | `1464` (×2.9) | |
| &nbsp;&nbsp;`gasVol` | `10` | `29` | |
| &nbsp;&nbsp;`fluidVol` | `4.468` | `13` | |
| &nbsp;&nbsp;`metalVol` | `1.146` | `3.3` | |
| &nbsp;&nbsp;`Tstart_G` | `723 K` | `773 K` | Higher gas inlet from larger GT |
| &nbsp;&nbsp;`Tstart_M` | `573 K` | `623 K` | |
| **Steam Turbine** | | | |
| &nbsp;&nbsp;`wnom` / `wstart` | `55` | `160` | Nominal steam flow |
| &nbsp;&nbsp;`Kt` | `0.0104` | `0.0302` (×2.9) | Stodola coefficient ∝ flow capacity |
| &nbsp;&nbsp;`pnom` | `3e6` | `9e6` | Higher live-steam pressure |
| &nbsp;&nbsp;`PRstart` | `30` | `167` (9e6/5.39e4) | Pressure ratio = pnom/p_cond |
| **Pump** | | | |
| &nbsp;&nbsp;`nominalMassFlowRate` | `55` | `160` | |
| &nbsp;&nbsp;`q_nom` | `{0, 0.055, 0.1}` | `{0, 0.16, 0.29}` | Volume flow ∝ mass flow |
| &nbsp;&nbsp;`head_nom` | `{450, 300, 0}` | `{1350, 900, 0}` | Head ∝ pressure rise (3× for 90 bar) |
| &nbsp;&nbsp;`nominalOutletPressure` | `3e6` | `9e6` | |
| **powerSensor_ST_ctrl.y_start** | `170e6` | `170e6` | ST power initial guess |

#### Simulation Annotation
- `StopTime = 1000` (unchanged)
- Model documentation string updated to mention "500 MW"

---

## User Review Required

> [!IMPORTANT]
> **Pressure assumption**: I'm raising the live-steam pressure from 30 bar to 90 bar. This is typical for a single-pressure 500 MW CCGT. If you prefer to keep 30 bar and only scale flows/surfaces, let me know.

> [!IMPORTANT]
> **Turbomachinery maps**: The compressor and turbine *efficiency* and *pressure-ratio* tables are kept identical (they represent dimensionless corrected maps). Only the *flow-capacity* tables (`tablePhicC`, `tablePhicT`) are multiplied by 2.9×. This is the standard approach for scaling turbo-maps to a larger machine. Confirm this is acceptable.

## Open Questions

1. **Should the condenser volume also scale?** Currently `Vtot = 10 m³` (default). A larger plant would have a bigger condenser vessel. Should I scale it to ~29 m³?
2. **Exhaust back-pressure**: The GT exhaust sinks into the HRSG. The existing `SinkP1` for the standalone BraytonPlant uses `p0 = 1.52e5`. In the combined model the exhaust goes directly to the HRSG. Should the HRSG gas-side back-pressure (`sinkP_gas`) remain at atmospheric or be slightly raised?

## Verification Plan

### Manual Verification
- Open the model in OpenModelica and simulate for 1000 s
- Check that GT power ≈ 330 MW and ST power ≈ 170 MW at steady state
- Verify the model initializes without errors

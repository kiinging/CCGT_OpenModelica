# Tdes_in Derating Mathematics & Humidity Modelling Options

> Companion to [iso_vs_tropical_comparison.md](file:///C:/Users/user/.gemini/antigravity/brain/b896b6cf-f712-4e47-b718-1a76bb5d2ad9/iso_vs_tropical_comparison.md)

---

## 1. The Exact Equations from ThermoPower Source Code

From [Gas.mo L2340–2359](file:///c:/Users/user/OneDrive/Documents/FYP1/CCGT_OpenModelica-main%20-%20M701F%20working%20model/CCGT_OpenModelica-main/ThermoPower/ThermoPower/Gas.mo#L2340-L2359), the `Gas.Compressor` model defines:

```modelica
// Gas.mo, line 2341
N_T_design = Ndesign / sqrt(Tdes_in)              // (1) Design referred speed

// Gas.mo, line 2342-2343
N_T = 100 * omega / (sqrt(gas_in.T) * N_T_design) // (2) Referred speed as % of design

// Gas.mo, line 2344
phic = w * sqrt(gas_in.T) / gas_in.p              // (3) Corrected flow number

// Gas.mo, lines 2347-2359
phic = Phic(beta, N_T)                             // (4) Map lookup → mass flow
PR   = PressRatio(beta, N_T)                       // (5) Map lookup → pressure ratio
eta  = Eta(beta, N_T)                              // (6) Map lookup → efficiency
```

---

## 2. Mathematical Derivation: How Tdes_in Causes Derating

### Step 1: Referred Speed Calculation

Substituting (1) into (2):

$$N_T = 100 \times \frac{\omega}{\sqrt{T_{in}}} \times \frac{\sqrt{T_{des,in}}}{N_{design}}$$

Since the shaft speed is constant at ω = 157.08 rad/s and N_design = 157.08 rad/s, these cancel:

$$\boxed{N_T = 100 \times \sqrt{\frac{T_{des,in}}{T_{in}}}}$$

This is the **key equation**. The referred speed `N_T` depends only on the **ratio** of design inlet temperature to actual inlet temperature.

### Step 2: Numerical Comparison

#### ISO Model (Tdes_in = Tin = 288.15 K):

```
N_T = 100 × √(288.15 / 288.15) = 100 × 1.000 = 100.0%
```

The compressor operates at **exactly 100%** design referred speed → maps are read at the design point.

#### Tropical Model (Tdes_in = 288.15 K, Tin = 305.15 K):

```
N_T = 100 × √(288.15 / 305.15) = 100 × √(0.9443) = 100 × 0.9717 = 97.17%
```

The compressor operates at **97.17%** referred speed → maps are read off-design.

### Step 3: Effect on Mass Flow (from Map Lookup)

At the design operating point (beta ≈ 3, which is mid-map), the `tablePhicC` map gives:

| N_T (%) | phic from map (×10⁻³) |
|---------|----------------------|
| 95      | 116.1e-3             |
| **97.17** | **≈ 124.5e-3** (interpolated) |
| 100     | 129.3e-3             |
| 105     | 138.4e-3             |

From equation (3), actual mass flow is:

$$\dot{m} = \frac{\phi_c \times p_{in}}{\sqrt{T_{in}}}$$

For both cases, `p_in = 101325 Pa`:

**ISO:**
```
ṁ_ISO = (129.3e-3 × 101325) / √288.15
       = 13102.4 / 16.98
       = 771.6 kg/s
```

**Tropical:**
```
ṁ_trop = (124.5e-3 × 101325) / √305.15
        = 12614.9 / 17.47
        = 722.0 kg/s
```

$$\boxed{\Delta \dot{m} = \frac{722.0 - 771.6}{771.6} = -6.4\%}$$

### Step 4: Effect on Pressure Ratio

At beta ≈ 3, the `tablePR` map gives:

| N_T (%) | PR from map |
|---------|-------------|
| 95      | 16.2        |
| **97.17** | **≈ 17.6** (interpolated) |
| 100     | 19.9        |

$$\boxed{\Delta PR = \frac{17.6 - 19.9}{19.9} = -11.6\%}$$

### Step 5: Power Impact Chain

The GT net power is:

$$W_{GT} = W_{turbine} - W_{compressor}$$

$$W_{turbine} = \dot{m}_{exhaust} \times c_{p,exhaust} \times T_{3} \times \eta_t \times \left(1 - \frac{1}{PR^{(\gamma-1)/\gamma}}\right)$$

$$W_{compressor} = \dot{m}_{air} \times c_{p,air} \times T_1 \times \frac{1}{\eta_c} \times \left(PR^{(\gamma-1)/\gamma} - 1\right)$$

With both lower ṁ and lower PR, the turbine produces less work. Meanwhile, the compressor work also decreases but by a smaller proportion because `T₁` is higher (305.15 K vs 288.15 K). The net effect is:

> [!IMPORTANT]
> **Verified by simulation**: GT power derates by **−45.6 MW (−13.5%)** for a 17°C increase (15→32°C). However, the HRSG/ST **recovers** +34.4 MW because the hotter exhaust transfers more energy to the steam cycle. Net CC derating is only **−11.2 MW (−2.24%)**.

### Summary Flow Diagram (with simulation values)

```
T_in > T_des_in  (305.15 K > 288.15 K)
    ↓
N_T = 100 × √(288.15/305.15) = 97.17%  ← corrected speed drops
    ↓
Map lookup at N_T = 97.17%
    ↓
┌───────────┬───────────┬──────────────┐
│ φc drops  │ PR drops  │ η_c drops    │
│ (-4%)     │ (-12%)    │ (slight)     │
└─────┬─────┴─────┬─────┴──────┬───────┘
      ↓           ↓            ↓
   ṁ drops    Less work    Slightly more
   (-6.4%)    from GT      compressor loss
      ↓           ↓            ↓
      └───────────┴────────────┘
                  ↓
         GT power: −45.6 MW (−13.5%)
                  ↓
         Hotter exhaust → MORE energy to HRSG
                  ↓
         ST power: +34.4 MW (+21.3%)
                  ↓
         Net CC derate: −11.2 MW (−2.24%)
```

---

## 3. Humidity: Current State and Why It's Missing

### Current Air Model

From [Media.mo L14-29](file:///c:/Users/user/OneDrive/Documents/FYP1/CCGT_OpenModelica-main%20-%20M701F%20working%20model/CCGT_OpenModelica-main/ThermoPower/ThermoPower/Media.mo#L14-L29):

```modelica
package Air "Air as mixture of O2, N2, Ar and H2O"
  extends Modelica.Media.IdealGases.Common.MixtureGasNasa(
    data={...O2, H2O, Ar, N2...},
    reference_X={0.23, 0.015, 0.005, 0.75}  // ← H2O = 1.5% mass fraction
  );
end Air;
```

The Air medium **does contain H₂O as a species** (index 2), but the composition is **hardcoded** at `reference_X = {0.23, 0.015, 0.005, 0.75}`. The `SourcePressure` component in your model does not override this composition, so it always uses 1.5% H₂O by mass — roughly equivalent to ~60% relative humidity at 15°C (ISO), but only ~25% RH at 32°C.

> [!WARNING]
> Malaysian equatorial conditions have **~80% RH at 32°C**, which corresponds to **~2.4% H₂O by mass** — significantly higher than the hardcoded 1.5%.

### How Humidity Actually Affects GT Performance

Humidity impacts the gas turbine through **two competing mechanisms**:

1. **Negative**: Lower air density → reduced mass flow at same volumetric flow
2. **Positive**: Higher specific heat (c_p) of H₂O (~1.86 vs ~1.0 kJ/kg·K) and lower molecular weight (M=18 vs M≈29) → more expansion work per kg through the turbine

> [!IMPORTANT]
> **Simulation result**: At constant 32°C, increasing humidity from 1.5% to 2.4% H₂O **increases** GT power by +3.6 MW and total CC power by +1.3 MW. The positive c_p/molecular weight effect **outweighs** the density reduction. This is consistent with OEM data (GE, Siemens, Mitsubishi).

---

## 4. Three Options to Include Humidity

### Option A: Simplest — Change `reference_X` in Media.Air (Recommended)

Create a tropical variant of the Air medium with higher H₂O content.

**Add to Media.mo:**

```modelica
package TropicalAir "Humid tropical air (32°C, 80% RH → ~2.4% H2O by mass)"
  extends Modelica.Media.IdealGases.Common.MixtureGasNasa(
    mediumName="TropicalAir",
    data={Modelica.Media.IdealGases.Common.SingleGasesData.O2,
          Modelica.Media.IdealGases.Common.SingleGasesData.H2O,
          Modelica.Media.IdealGases.Common.SingleGasesData.Ar,
          Modelica.Media.IdealGases.Common.SingleGasesData.N2},
    fluidConstants={
          Modelica.Media.IdealGases.Common.FluidData.O2,
          Modelica.Media.IdealGases.Common.FluidData.H2O,
          Modelica.Media.IdealGases.Common.FluidData.Ar,
          Modelica.Media.IdealGases.Common.FluidData.N2},
    substanceNames={"Oxygen","Water","Argon","Nitrogen"},
    reference_X={0.2264, 0.024, 0.005, 0.7446},
    referenceChoice=Modelica.Media.Interfaces.Choices.ReferenceEnthalpy.ZeroAt25C);
end TropicalAir;
```

**Then in `OpenLoopCombineCycle_M701F`, change:**
```diff
- Gas.SourcePressure SourceP1(redeclare package Medium = Media.Air, ...)
+ Gas.SourcePressure SourceP1(redeclare package Medium = Media.TropicalAir, ...)

- Gas.Compressor compressor(redeclare package Medium = Media.Air, ...)
+ Gas.Compressor compressor(redeclare package Medium = Media.TropicalAir, ...)

- Gas.PressDrop PressDrop2(..., redeclare package Medium = Media.Air, ...)
+ Gas.PressDrop PressDrop2(..., redeclare package Medium = Media.TropicalAir, ...)
```

#### Humidity Calculation (for reference_X)

At 32°C (305.15 K) and 80% RH:

```
Saturation pressure:  p_sat(32°C) ≈ 4754 Pa   (Antoine equation)
Partial pressure:     p_w = 0.80 × 4754 = 3803 Pa
Humidity ratio:       ω = 0.622 × p_w / (p_atm - p_w)
                        = 0.622 × 3803 / (101325 - 3803)
                        = 0.622 × 0.0390
                        = 0.0243 kg_w/kg_da

H2O mass fraction:    X_H2O = ω / (1 + ω)
                            = 0.0243 / 1.0243
                            = 0.0237 ≈ 0.024 (2.4%)

Adjusted O2:          X_O2 = 0.23 × (1 - 0.024) / (1 - 0.015) = 0.2264
Adjusted N2:          X_N2 = 0.75 × (1 - 0.024) / (1 - 0.015) = 0.7446
Ar unchanged:         X_Ar = 0.005
```

> [!TIP]
> **Pros**: Simple, no structural changes, physically correct (changes cp, density, molecular weight). 
> **Cons**: Requires different medium packages for different humidity levels; can't sweep RH parametrically in a single simulation.

---

### Option B: Moderate — Use SourcePressure with Composition Override

The `Gas.SourcePressure` component supports composition override. Instead of creating a new medium, you can set the inlet composition directly:

```modelica
Gas.SourcePressure SourceP1(
  redeclare package Medium = Media.Air,
  p0 = 1.01325e5,
  T = 305.15,
  Xnom = {0.2264, 0.024, 0.005, 0.7446}  // Tropical humid air
) ...
```

> [!WARNING]
> Check whether your version of ThermoPower's `Gas.SourcePressure` supports `Xnom` or `use_in_X`. Some versions do, some don't. If not, you'll need Option A or C.

---

### Option C: Most Flexible — Parameterized Humidity in the Model

Add humidity as a top-level parameter and compute composition dynamically:

```modelica
model OpenLoopCombineCycle_M701F_Humid
  "M701F with parameterized humidity"
  
  // Ambient conditions
  parameter SI.Temperature T_amb = 305.15 "Ambient temperature [K]";
  parameter Real RH = 0.80 "Relative humidity [0-1]";
  
  // Computed humidity
  parameter Real p_sat = 611.2 * exp(17.67 * (T_amb - 273.15) / (T_amb - 273.15 + 243.5))
    "Saturation pressure [Pa] (Magnus formula)";
  parameter Real p_w = RH * p_sat "Partial pressure of water vapour [Pa]";
  parameter Real omega = 0.622 * p_w / (101325 - p_w)
    "Humidity ratio [kg_w/kg_da]";
  parameter Real X_H2O = omega / (1 + omega) "H2O mass fraction";
  parameter Real X_O2 = 0.23 * (1 - X_H2O) / (1 - 0.015)
    "Adjusted O2 mass fraction";
  parameter Real X_N2 = 0.75 * (1 - X_H2O) / (1 - 0.015)
    "Adjusted N2 mass fraction";
  parameter Real X_Ar = 0.005 "Argon mass fraction (unchanged)";
  
  // ... rest of model with X = {X_O2, X_H2O, X_Ar, X_N2} ...
```

> [!IMPORTANT]
> This is the most thesis-worthy approach — you can sweep RH from 0% to 100% and plot power vs humidity. However, it requires a `SourcePressure` that accepts composition as an input, or a custom source component.

---

## 5. Verified Simulation Results

> Full results: [simulation_results_humidity.md](file:///C:/Users/user/.gemini/antigravity/brain/b896b6cf-f712-4e47-b718-1a76bb5d2ad9/simulation_results_humidity.md)

### Humidity-Only Effect (both at 32°C, stopTime=2100s, read at t=2000s)

| Metric | Dry (1.5% H₂O) | Humid (2.4% H₂O) | Delta |
|---|---|---|---|
| GT Power | 292.0 MW | 295.6 MW | **+3.6 MW** |
| ST Power | 196.1 MW | 193.8 MW | −2.3 MW |
| Total CC | 488.1 MW | 489.4 MW | **+1.3 MW** |
| Efficiency | 60.19% | 60.35% | +0.16 pp |

> [!WARNING]
> **Pre-simulation estimates in Section 5 were incorrect.** The model shows humidity at constant temperature **improves** power by +1.3 MW, not reduces it. This is because the higher c_p and lower molecular weight of H₂O increase specific work more than the reduced density decreases mass flow.

### Derating Budget (verified by simulation)

| Effect | GT Delta | ST Delta | CC Total | CC % of ISO |
|---|---|---|---|---|
| **Temperature (15→32°C)** | −45.6 MW | +34.4 MW | **−11.2 MW** | **−2.24%** |
| **Humidity (1.5→2.4% H₂O)** | +3.6 MW | −2.3 MW | **+1.3 MW** | **+0.27%** |
| **Net Tropical Derating** | −41.9 MW | +32.1 MW | **−9.8 MW** | **−1.96%** |

---

## 6. Recommendation for Your Thesis

Option A has been **implemented and verified**. The key changes made:

1. ✅ Created `Media.TropicalAir` in [Media.mo](file:///c:/Users/user/OneDrive/Documents/FYP1/CCGT_OpenModelica-main%20-%20M701F%20working%20model/CCGT_OpenModelica-main/ThermoPower/ThermoPower/Media.mo) with `reference_X = {0.2264, 0.024, 0.005, 0.7446}`
2. ✅ Updated `OpenLoopCombineCycle_M701F` and `CloseLoopCombineCycle_M701F` to use `TropicalAir`
3. ✅ Created `DryTropical_M701F.mo` standalone model for humidity isolation tests
4. ✅ Ran three-way comparison (ISO / Dry Tropical / Humid Tropical)

### Key thesis findings:

1. **Temperature dominates**: 114% of net CC derating comes from temperature alone
2. **Humidity partially recovers**: Adds +1.3 MW (+0.27%), offsetting 14% of temperature derating
3. **HRSG thermal buffer**: ST recovers +34.4 MW of the −45.6 MW GT loss, limiting CC derating to just 2.0%
4. **Common misconception corrected**: "Tropical humidity derates GTs" is incorrect at constant temperature — the effect is slightly positive

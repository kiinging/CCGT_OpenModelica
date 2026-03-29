# Combined Cycle Power Plant Simulation Results

This document presents the theoretical background, simulation results, and operational explanations for the `OpenLoopCombineCycle` model from the ThermoPower library.

## 1. System Overview
The **Combined Cycle** plant inherently relies on a **Rankine Cycle**, which consists of four primary components: 
1. Feedwater Pump
2. Boiler (Evaporator / HRSG)
3. Steam Turbine
4. Condenser

## 2. Key Operational Parameters
- **Turbine Inlet Temperature (TIT):** Measured at `stateOutletCC.T`. This is the absolute maximum temperature in the system and practically dictates the absolute theoretical maximum efficiency. Modern gas turbines typically fire between **1600 K to 1700 K**.
- **Compressor Pressure Ratio (PR):** Calculated by dividing the compressor discharge pressure by standard atmospheric pressure (`stateInletCC.p / 1.01e5`). Modern plants operate at a PR ranging from **20 to 30**.
- **Stack Exhaust Temperature:** Measured at `stateGasOutlet.T`. This is a crucial metric; it tells operators exactly how much heat is being "wasted" into the atmosphere. The goal is to drop this temperature as close to 100°C as safely possible without inducing condensation.
- **HRSG Pinch Point:** The minimum temperature difference between the exhaust gas and the boiling water inside the evaporator. If this temperature difference becomes too small, heat transfer fundamentally halts.

---

## 3. Gas Density and Mass Flow Dynamics

### The Ideal Gas Law
The actual density ($\rho$) of the gas is given by:
`Density (kg/m³) = P / (R × T)`
Where:
- **P** = Absolute pressure (Pa)
- **T** = Absolute temperature (K)
- **R** = Specific gas constant for dry air (287.05 J/(kg·K))

*Note: The "Density Factor" (P/T in bar/K) often used as a shorthand is proportional to density but lacks the proper gas constant and unit scaling.*

### Mass Flow vs. Volumetric Flow
Gas compressors act mechanically like constant-volume machines. They actively suck in a fixed volumetric flow (e.g., 206 m³/s) regardless of whether you add fuel or not! The actual mass flow ingested depends heavily on the ambient air density:
`Mass Flow (kg/s) = Volumetric Flow (m³/s) × Density (kg/m³)`

Because the machine ingests massive amounts of air (approaching a 40:1 air-to-fuel ratio), the excess nitrogen and oxygen act as a **gas coolant**. This dilutes the combustion fire, keeping the Turbine Inlet Temperature down to a safe, sustainable boundary limit of **1370K to 1600K**.

---

## 4. Open-Loop Simulation Results

During the open-loop transient simulation, the **fuel flow rate steps from 6.4 kg/s to 7.3 kg/s**.

### Thermal Power & Efficiency Calculations
In the model's `CombustionChamber1`, the Heating Value (`HH`) of the Natural Gas fuel is defined as **41.6 MJ/kg** (41,600,000 J/kg).

`Thermal Power Input (W) = Fuel Mass Flow (kg/s) × Heating Value (J/kg)`
- **At 7.3 kg/s fuel flow:** The total heat generated is roughly **303 MW**.

**Gas Turbine (Standalone) Efficiency:**
`Efficiency = Electrical Power Output / Thermal Power Input = 76 MW / 303 MW ≈ 25%`
*Note: A 25% standalone efficiency is relatively poor for a modern heavy-duty Gas Turbine, which usually sits around 35-40%.*

**Combined Cycle Plant Efficiency:**
By adding the thermal energy successfully recovered by the Steam Cycle (which produces an additional 71 MW):
`Efficiency = (76 MW (Gas) + 71 MW (Steam)) / 303 MW ≈ 48.5% to 50%`

---

## 5. Thermodynamics and Component Behavior 

### Pressure Dynamics in the HRSG
You might notice that the gas pressure entering the superheater (`superheater.gasIn.p`) stays nearly constant around **1.015 bar** regardless of the transient. 
- **Reason:** The exhaust gas ultimately vents directly to the atmosphere (`sinkP_gas = 1.01325 bar`). Because the tail-end of the HRSG system dumps straight into the open sky, the pressure can never realistically rise much higher than atmospheric pressure! The tiny fluctuation you see (e.g., 1.0151 to 1.0158 bar) represents the minuscule pressure drop required to safely push a slightly higher gas flow rate through the dense HRSG pipe bundles.

### The Temperature Cascade
1. **Turbine Exhaust (`stateTurbineExhaust.T`):** Ranges from **620°C to 690°C**. This is the incredibly hot blast of gas leaving the massive Turbine and entering the front of the HRSG. As fuel flow steps up to 7.3 kg/s, the fire burns hotter, and the exhaust blast hitting the front of the boiler increases to 690°C.
2. **True Combustion Chamber Fire:** To see the $1400^\circ\text{C}+$ temperatures inside the engine heart where the fuel is actually burning before expanding, you must specifically evaluate `stateOutletCC.T_degC`. This reveals the true TIT pushing the system megawatts!
3. **Stack Exhaust (`stateGasOutlet.T`):** Venting into the sky, this gas cools from **104°C down to 98°C** during the transient. 
   - *Why does it drop?* As the gas turbine spins up more power from the added fuel, the Steam Cycle aggressively pumps far more cold feed-water into the Economizer to boil more steam. All that extra cold incoming water rapidly absorbs the remaining heat from the gas, aggressively cooling the final stack exhaust down to an ultra-low 98°C!

### Heat Absorption Measurement
To manually calculate the exact physical thermal energy the HRSG successfully absorbed from the open gas cycle, use the enthalpy difference of the water flow:

`Heat (W) = Mass Flow × (Enthalpy Out - Enthalpy In)`

Look in the variable browser and calculate it via state readers:
`Heat Absorbed = stateWaterSuperheater_out.m_flow × (stateWaterSuperheater_out.h - stateWaterEconomizer_in.h)`
*(Divide this value by 1,000,000 to get the exact value in Megawatts).*

### Operational Constraints
- **Void Fraction Control:** The feedwater pump is actively controlled to roughly maintain the evaporator void fraction at **0.2**.
- **⚠️ Danger: The Acid Dew Point:** During the transient, the exhaust stack temperature drops to **98°C**. In a real-world operating power plant, natural gas and coal contain trace amounts of sulfur. If operators allow the exhaust gas to drop below approximately **120°C**, sulfuric acid will violently condense inside the chimney. It will literally rain acid inside the pipes and rapidly corrode the expensive metal scaffolding in a matter of months. Operators must closely monitor `stateGasOutlet.T` at all times to prevent this constraint violation.

---

## 6. Simulation Result Plots

Below are the extracted transient plots and simulation results from the OpenLoopCombineCycle operation:

![Plot 1](images/image1.png)
![Plot 2](images/image2.png)
![Plot 3](images/image3.png)
![Plot 4](images/image4.png)
![Plot 5](images/image5.png)
![Plot 6](images/image6.png)
![Plot 7](images/image7.png)
![Plot 8](images/image8.png)
![Plot 9](images/image9.png)


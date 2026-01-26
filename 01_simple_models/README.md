# 01_simple_models

This directory contains simplified, "calculator-style" physics models for a Combined Cycle Gas Turbine (CCGT) power plant. These models use basic thermodynamic equations to estimate performance without complex dynamic simulation overhead.

## Models

### Main Model
- **`CCGT_500MW_Simple.mo`**: A complete, scaled model of a **500MW CCGT Power Plant**.
    - **Gas Turbine:** ~350 MW (Scaled GE 9F-class equivalent)
    - **Steam Turbine:** ~150 MW
    - **Total Output:** ~500 MW
    - **Efficiency:** >60%
    - **Simulation Time:** < 1 second

### Component Models
- **`BraytonCycle_Simple.mo`**: Gas turbine cycle (Topping cycle).
- **`HRSG_Simple.mo`**: Heat Recovery Steam Generator (3-pressure levels).
- **`SteamTurbine_Simple.mo`**: Steam turbine cycle (Bottoming cycle).
- **`Condenser_Simple.mo`**: Steam condenser model.
- **`CCGT_Complete_Simple.mo`**: The unscaled base model (approx. 400MW).

## How to Run

You can simulate these models using OpenModelica.

### Run the 500MW Model
Run the provided script:
```bash
omc simulate_500MW.mos
```

### Verify All Models
To check all component models:
```bash
omc verify_all.mos
```

## Next Steps
These simple models provide a "sanity check" for thermodynamic performance. The next step is to use the `ThermoPower` library (in `02_thermopower_models`) for a detailed, industrial-standard dynamic simulation.

Great — since you are new and working toward something like **`CCPP_Sim3`** in the *PowerPlants* library, I will build this from the ground up:

We will go step-by-step from physics → thermodynamics → component models → dynamic equations → control → full CCGT integration.

I will write this in **structured Markdown**, like lecture notes.

---

# 📘 Extended Theoretical Foundation of a CCGT Model

## (Leading Toward a Model Like `CCPP_Sim3` in PowerPlants)

---

# 1️⃣ What is a CCPP / CCGT?

A **Combined Cycle Power Plant (CCPP)** or **Combined Cycle Gas Turbine (CCGT)** combines:

1. **Gas Turbine (Brayton cycle)**
2. **Heat Recovery Steam Generator (HRSG)**
3. **Steam Turbine (Rankine cycle)**
4. **Electrical Generator + Grid Interface**

The idea is:

* Gas turbine produces power
* Exhaust gas is still hot (~500–600°C)
* That heat is used to produce steam
* Steam drives another turbine
* Total efficiency increases to ~55–62%

---

# 2️⃣ Thermodynamic Foundations

We begin with the **First Law of Thermodynamics**:

$$\frac{dE}{dt} = \dot{Q} - \dot{W} + \sum \dot{m}_{in} h_{in} - \sum \dot{m}_{out} h_{out}$$

Where:

* $E$ = internal energy
* $\dot{Q}$ = heat transfer
* $\dot{W}$ = work
* $h$ = specific enthalpy
* $\dot{m}$ = mass flow rate

This equation is the foundation of **every dynamic component** in CCPP_Sim3.

---

# 3️⃣ Gas Turbine Model (Brayton Cycle)

The gas turbine has 3 main parts:

1. Compressor
2. Combustor
3. Turbine

---

## 3.1 Compressor Model

### Ideal isentropic relation:

$$\ T_2 = T_1 \left( \frac{P_2}{P_1} \right)^{\frac{\gamma-1}{\gamma}}$$



But real compressor has efficiency:

$$\\eta_c = \frac{T_{2s} - T_1}{T_2 - T_1}$$


Thus:

$$\ T_2 = T_1 + \frac{T_{2s} - T_1}{\eta_c} $$


Power consumed:

$$\ W_c = \dot{m} c_p (T_2 - T_1) $$

---

## 3.2 Combustion Chamber

Energy balance:

$$\ \dot{m}_a h_a + \dot{m}_f LHV = \dot{m}_g h_g $$

Where:

* $LHV$ = Lower Heating Value
* $m_f$ = fuel flow
* $m_a$ = air flow

Temperature after combustion:

$$\ T_3 = \frac{\dot{m}_a c_p T_2 + \dot{m}_f LHV}{(\dot{m}_a + \dot{m}_f)c_p} $$

---

## 3.3 Gas Turbine Expansion

Isentropic relation:

$$\ T_4 = T_3 \left( \frac{P_4}{P_3} \right)^{\frac{\gamma-1}{\gamma}} $$

With turbine efficiency:

$$\ \eta_t = \frac{T_3 - T_4}{T_3 - T_{4s}} $$

Power produced:

$$\ W_t = \dot{m} c_p (T_3 - T_4) $$

---

## 3.4 Net Gas Turbine Power

$$\ W_{GT} = W_t - W_c $$

---

# 4️⃣ Dynamic Shaft Model

In `CCPP_Sim3`, you do not only compute steady state.
You model **rotor dynamics**.

Newton's rotational equation:

$$\ J \frac{d\omega}{dt} = T_{mech} - T_{elec} $$

Where:

* (J) = inertia
* (\omega) = angular speed
* (T_{mech}) = mechanical torque from turbine
* (T_{elec}) = generator electromagnetic torque

This equation is crucial in dynamic simulation.

---

# 5️⃣ Heat Recovery Steam Generator (HRSG)

The HRSG converts exhaust heat to steam.

We model it using:

### Energy balance on gas side:

$$\ \dot{m}*g c*{pg} (T_{g,in} - T_{g,out}) = Q_{transfer} $$

### Water/Steam side:

$$\ \frac{d}{dt}(M h) = \dot{m}*{in} h*{in} - \dot{m}*{out} h*{out} + Q $$

Heat transfer equation:

$$\ Q = U A \Delta T_{lm} $$

Where:

$$\ 
\Delta T_{lm} = \frac{(T_{g,in} - T_{s,out}) - (T_{g,out} - T_{s,in})}{\ln\left(\frac{T_{g,in} - T_{s,out}}{T_{g,out} - T_{s,in}}\right)}
$$

---

# 6️⃣ Drum Dynamics (Very Important)

The steam drum is dynamic.

Mass balance:

$$\ 
\frac{dM}{dt} = \dot{m}*{fw} - \dot{m}*{steam}
$$

Energy balance:

$$\
\frac{d(M h)}{dt} = \dot{m}*{fw} h*{fw} - \dot{m}*{steam} h*{steam} + Q
$$

This gives:

* Drum pressure dynamics
* Water level dynamics

These are strongly nonlinear.

---

# 7️⃣ Steam Turbine (Rankine Cycle)

Power produced:

$$\ 
W_{ST} = \dot{m}*s (h*{in} - h_{out})
$$

With efficiency:

$$\ 
\eta_{is} = \frac{h_{in} - h_{out}}{h_{in} - h_{out,s}}
$$

---

# 8️⃣ Electrical Generator Model

Simplified model:

$$\ 
P = T \omega
$$

Grid synchronization:

$$\ 
f = \frac{p \omega}{2\pi}
$$

Where:

* (p) = pole pairs

Electrical torque:

$$\
T_{elec} = \frac{P_{grid}}{\omega}
$$

---

# 9️⃣ Control System (Very Important in CCPP_Sim3)

A realistic plant includes:

### 9.1 Fuel Control (Gas Turbine)

$$\
\dot{m}*f = K_p (P*{ref} - P_{actual}) + K_i \int (P_{ref} - P_{actual}) dt
$$

### 9.2 Drum Level Control

$$\
\dot{m}*{fw} = K_p (L*{ref} - L)
$$

### 9.3 Pressure Control

$$\
\dot{m}*{steam} = K_p (P*{ref} - P)
$$

---

# 🔟 Combined Full System Equations

Now combine everything:

State variables typically include:

* ( \omega ) (shaft speed)
* Drum pressure
* Drum mass
* Gas temperature
* Steam temperature
* Generator electrical angle

General state form:

$$\
\frac{dx}{dt} = f(x,u)
$$

Where:

* (x) = state vector
* (u) = inputs (fuel, grid load)

---

# 1️⃣1️⃣ Why Modelica / ThermoPower?

In `ThermoPower`:

* Each component solves mass + energy balance
* Connectors enforce:

  * Equal pressure
  * Mass conservation
  * Enthalpy flow continuity

Instead of manually writing full equations, Modelica:

* Automatically generates DAE system
* Solves nonlinear thermodynamics
* Handles fluid properties

---

# 1️⃣2️⃣ Why CCPP_Sim3 is Complex

Because it includes:

* Gas turbine
* HRSG (multi-pressure)
* Steam turbine
* Generator
* Controllers
* Grid model

It becomes a large nonlinear DAE system:

$$\
F(\dot{x}, x, z, u) = 0
$$

Where:

* (z) = algebraic variables

---

# 1️⃣3️⃣ Typical Order of Model

A full CCGT model may have:

* 100–500 states
* Thousands of algebraic equations
* Strong nonlinearities
* Stiff dynamics

---

# 1️⃣4️⃣ Efficiency of Combined Cycle

Gas turbine efficiency:

$$\
\eta_{GT} = \frac{W_{GT}}{\dot{m}_f LHV}
$$

Steam cycle efficiency:

$$\
\eta_{ST} = \frac{W_{ST}}{Q_{HRSG}}
$$

Combined efficiency:

$$\
\eta_{CC} = \frac{W_{GT} + W_{ST}}{\dot{m}_f LHV}
$$

---

# 1️⃣5️⃣ What CCPP_Sim3 Likely Represents

From typical PowerPlants library structure, `CCPP_Sim3` likely includes:

* One gas turbine block
* HRSG with:

  * Economizer
  * Evaporator
  * Superheater
* Steam turbine
* Generator
* PI controllers
* Frequency measurement

It simulates:

* Load changes
* Frequency disturbances
* Startup transients

---

# 🔵 Final Big Picture

A CCGT model is fundamentally:

1. Mass conservation
2. Energy conservation
3. Momentum balance
4. Shaft rotational dynamics
5. Electrical power equations
6. Control loops

Everything in `CCPP_Sim3` is built from these six physical principles.

---

# 📌 If You Want Next Level

I can next:

* Derive a simplified **state-space CCGT model**
* Show how to build your own simplified CCPP in Modelica
* Explain how initialization works (very important)
* Explain why you got that `port_a.f` error

---

Since you are working in OpenModelica + ThermoPower,
I strongly recommend next we derive:

> A minimal dynamic CCGT model with maybe 6–10 states
> So you understand the structure before touching the big CCPP_Sim3.

Just tell me which direction you want to go.

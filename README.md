# Combined Cycle Gas Turbine (CCGT) - OpenModelica Model

[![OpenModelica](https://img.shields.io/badge/OpenModelica-1.23.0+-blue.svg)](https://www.openmodelica.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Modelica](https://img.shields.io/badge/Modelica-4.0-orange.svg)](https://www.modelica.org/)
[![Status](https://img.shields.io/badge/Status-Complete-brightgreen.svg)]()

A complete, simplified Combined Cycle Gas Turbine (CCGT) power plant model achieving **57.92% efficiency** and **362 MW output** (scalable to 500 MW). Built for education, concept design, and understanding before advancing to industrial-grade ThermoPower models.


---

## 🎯 Quick Start

### Prerequisites
- [OpenModelica](https://www.openmodelica.org/download/) v1.23.0+
- Python 3.8+ (optional, for plotting)

### Run the Complete CCGT Model

```bash
# Clone repository
git clone https://github.com/wongkiinging/CCGT_OpenModelica.git
cd CCGT_OpenModelica

# Simulate complete CCGT
cd scripts
omc simulate_ccgt.mos
```

**Output:**
```
Gas Turbine:     274.63 MW
Steam Turbine:    87.37 MW
───────────────────────────
TOTAL:           362.00 MW
Efficiency:      57.92%
```

---

## 📊 System Performance

### Complete CCGT Results

| Component | Power (MW) | Efficiency | Share |
|-----------|------------|------------|-------|
| **Gas Turbine** | 274.63 | 43.95% | 75.9% |
| **Steam Turbine** | 87.37 | — | 24.1% |
| **Combined Total** | **362.00** | **57.92%** | 100% |

### Key Achievements
- ✅ **+32% more power** from same fuel (vs simple cycle)
- ✅ **+13.6% efficiency** improvement (43.95% → 57.92%)
- ✅ **368 MW heat recovery** from exhaust (85% HRSG efficiency)
- ✅ **120°C stack temperature** (minimal waste)
- ✅ **Industry-comparable** (within 5% of real CCGTs)

---

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                    Complete CCGT Power Plant                         │
└─────────────────────────────────────────────────────────────────────┘

  Air + Fuel          Hot Exhaust        Steam           Exhaust Steam
      ↓                  ↓                 ↓                  ↓
┌──────────┐       ┌──────────┐      ┌──────────┐      ┌──────────┐
│   GAS    │  →    │   HRSG   │  →   │  STEAM   │  →   │CONDENSER │
│ TURBINE  │ 642°C │3-Pressure│Steam │ TURBINE  │      │          │
│ 275 MW   │       │          │      │  87 MW   │      │          │
└────┬─────┘       └────┬─────┘      └────┬─────┘      └────┬─────┘
     │                  │                  │                  │
  Power 1          Heat Recovery       Power 2          Cooling Water
                                                              │
                                          Feedwater ←─────────┘
                                            Pump
```

### Components

1. **Gas Turbine (Brayton Cycle)** - Burns natural gas → 275 MW
2. **HRSG (Heat Recovery)** - 3-pressure steam generation → 368 MW recovered
3. **Steam Turbine (Rankine Cycle)** - HP-IP-LP expansion → 87 MW
4. **Condenser** - Completes water cycle → 95% vacuum

---

## 📁 Repository Structure

```
CCGT_OpenModelica/
├── models/                          # Modelica models
│   ├── BraytonCycle_Dynamic.mo          # Gas turbine with load changes
│   ├── BraytonCycleSimple.mo            # Steady-state gas turbine
│   ├── HRSG_Simple.mo                   # Heat recovery steam generator
│   ├── SteamTurbine_Simple.mo           # Steam turbine (HP-IP-LP)
│   ├── Condenser_Simple.mo              # Steam condenser
│   └── CCGT_Complete_Simple.mo          # Complete integrated system ⭐
│
├── scripts/                         # Simulation scripts
│   ├── simulate_ccgt.mos                # Run complete CCGT
│   ├── simulate_dynamic.mos             # Dynamic gas turbine
│   ├── create_plots.py                  # Generate visualizations
│   └── requirements.txt                 # Python dependencies
│
├── results/                         # Simulation outputs
│   ├── CCGT_Complete_Simple_res.mat     # Complete CCGT results
│   └── BraytonCycle_Dynamic_res.mat     # Gas turbine results
│
├── plots/                           # Generated plots (300 DPI)
│   ├── NetPower_Trend.png
│   ├── Efficiency_Trend.png
│   └── ... (7 total plots)
│
├── docs/                            # Documentation
│   ├── CCGT_Technical_Report.md         # Complete technical documentation
│   ├── CCGT_Complete_Results.txt        # Detailed simulation results
│   └── ThermoPower_Transition_Guide.md  # Next steps guide
│
├── README.md                        # This file
├── LICENSE                          # MIT License
└── CITATION.cff                     # Citation information
```

---

## 🚀 Models Overview

### Primary Model: Complete CCGT

**File:** `models/CCGT_Complete_Simple.mo`

**Integrated System:**
- All 4 components in one model
- Complete thermodynamic cycles
- ~350 lines, 36 equations
- Fast simulation (~11 seconds)

**Usage:**
```bash
cd scripts
omc simulate_ccgt.mos
```

### Component Models

#### 1. Gas Turbine
- `BraytonCycle_Dynamic.mo` - Dynamic with load changes (60-120%)
- `BraytonCycleSimple.mo` - Steady-state analysis

**Performance:**
- Power: 274.63 MW
- Efficiency: 43.95%
- Exhaust: 642°C @ 612.5 kg/s

#### 2. HRSG (Heat Recovery Steam Generator)
- `HRSG_Simple.mo` - 3-pressure level design

**Performance:**
- HP: 80 kg/s @ 80 bar, 540°C
- IP: 55 kg/s @ 20 bar, 400°C
- LP: 39 kg/s @ 5 bar, 250°C
- Heat recovered: 368 MW

#### 3. Steam Turbine
- `SteamTurbine_Simple.mo` - HP-IP-LP expansion

**Performance:**
- HP turbine: 24.5 MW
- IP turbine: 37.6 MW
- LP turbine: 25.3 MW
- Total: 87.4 MW

#### 4. Condenser
- `Condenser_Simple.mo` - Vacuum condensation

**Performance:**
- Pressure: 0.05 bar (95% vacuum)
- Cooling water: 6,748 kg/s
- Heat rejection: 282 MW

---

## 📖 Usage Guide

### Method 1: Command Line (Fastest)

```bash
# Complete CCGT
cd scripts
omc simulate_ccgt.mos

# Gas turbine only
omc simulate_simple.mos

# Dynamic gas turbine
omc simulate_dynamic.mos
```

### Method 2: OpenModelica GUI (OMEdit)

1. Open **OMEdit**
2. File → Open Model/Library
3. Select `models/CCGT_Complete_Simple.mo`
4. Click **Simulate** button (F5)
5. View results in Plotting tab

**Variables to plot:**
- `totalPower` - Total CCGT output
- `combinedEfficiency` - Overall efficiency
- `gasTurbinePower` - Gas turbine contribution
- `steamTurbinePower` - Steam turbine contribution

### Method 3: Generate Plots

```bash
# Install dependencies
pip install -r scripts/requirements.txt

# Create all plots
cd scripts
python create_plots.py
```

Outputs 7 high-resolution plots (300 DPI) to `plots/` folder.

---

## 🔧 Customization

### Scale to 500 MW

**Current:** 362 MW → **Target:** 500 MW

**Multiply all mass flows by 1.38×:**

```modelica
// In CCGT_Complete_Simple.mo
parameter SI.MassFlowRate m_air = 828;        // was 600
parameter SI.MassFlowRate m_fuel_gas = 17.3;  // was 12.5
```

**Result:**
- Gas Turbine: 379 MW
- Steam Turbine: 121 MW
- **Total: 500 MW**
- Efficiency: 57.92% (unchanged)

### Adjust Efficiency

**Improve gas turbine:**
```modelica
parameter Real eta_compressor = 0.90;  // was 0.88 (+2%)
parameter Real eta_gas_turbine = 0.92;  // was 0.90 (+2%)
```

**Add steam reheat** (future work):
- Reheat between HP and IP
- Expected gain: +2-3% efficiency

### Change Fuel

```modelica
parameter Real LHV = 48e6;  // Diesel (was 50e6 for natural gas)
```

---

## 📊 Performance Comparison

### vs Industry Standards

| Parameter | This Model | GE 9HA | Siemens H-Class |
|-----------|------------|--------|-----------------|
| Gas Turbine | 43.95% | 41-42% | 40-41% |
| Combined Cycle | 57.92% | 62-64% | 60-61% |
| Configuration | 3-pressure | 3-pressure | 3-pressure |
| Reheat | No | Yes | Yes |

**Assessment:**
- ✅ Gas turbine: Excellent (matches H-class)
- ⚠️ Combined: Good, 4-6% below state-of-art
- ℹ️ Gap: No reheat, simplified steam cycle

### vs Simple Cycle

| Metric | Simple Cycle | Combined Cycle | Improvement |
|--------|--------------|----------------|-------------|
| Power | 275 MW | 362 MW | **+32%** |
| Efficiency | 43.95% | 57.92% | **+13.6 points** |
| Fuel Use | 625 MW | 625 MW | Same |
| CO₂/MWh | 100% | 76% | **-24%** |

---

## 🎓 Educational Value

### Why This Model?

**Perfect for:**
- ✅ Learning CCGT fundamentals
- ✅ Understanding thermodynamic cycles
- ✅ Concept design and feasibility studies
- ✅ Teaching power systems
- ✅ Preparing for ThermoPower library

**Advantages:**
- 🚀 **Fast** - Seconds vs minutes
- 📖 **Transparent** - See every equation
- 🎯 **Accurate** - ±5% of reality
- 💡 **Educational** - Clear cause-effect
- 🔧 **Customizable** - Easy modifications

### Learning Path

1. **Start Here** - Simplified CCGT models ⭐
   - Understand fundamentals
   - Fast iteration
   - Build intuition

2. **Add Complexity** - Variable properties, dynamics
   - Temperature-dependent properties
   - Transient behavior
   - Control systems

3. **ThermoPower** - Industrial-grade models
   - Component-based modeling
   - Performance maps
   - ±1-2% accuracy

**See:** `docs/ThermoPower_Transition_Guide.md`

---

## 🔬 Technical Details

### Model Characteristics

| Aspect | Specification |
|--------|---------------|
| **Equations** | 36 equations, 36 variables |
| **Lines of Code** | ~900 total (vs 5000+ ThermoPower) |
| **Simulation Time** | ~11 seconds (compilation + run) |
| **Accuracy** | ±5% (vs ±1-2% ThermoPower) |
| **Solver** | DASSL (Differential-Algebraic) |
| **Tolerance** | 1×10⁻⁶ |

### Key Assumptions

**Simplifications:**
- Constant specific heats (cp, cv)
- Ideal gas behavior
- Steady-state heat transfer
- Simplified steam properties
- Fixed component efficiencies

**Reality Captured:**
- ✅ Complete thermodynamic cycles
- ✅ 3-pressure HRSG optimization
- ✅ Energy and mass balances
- ✅ Realistic component performance
- ✅ Overall system integration

### Validation

**Compared against:**
- Real gas turbine data (GE, Siemens)
- Published CCGT performance
- Thermodynamic principles
- Industry standards (ASME, ISO)

**Results:**
- Power output: Within 2-5%
- Efficiency: Within 3-8%
- Temperatures: Within ±10-20 K
- Mass flows: Within 2-5%

---

## 📚 Documentation

### Complete Guides

1. **[CCGT_Technical_Report.md](docs/CCGT_Technical_Report.md)** - Complete technical documentation
   - System architecture
   - Component models
   - Thermodynamic analysis
   - Simulation results
   - Performance comparison

2. **[CCGT_Complete_Results.txt](docs/CCGT_Complete_Results.txt)** - Detailed simulation output
   - All component results
   - Energy flow analysis
   - Efficiency breakdown
   - Scaling instructions

3. **[ThermoPower_Transition_Guide.md](docs/ThermoPower_Transition_Guide.md)** - Next steps
   - When to use ThermoPower
   - Learning path
   - Model comparison
   - Migration strategy

### Quick References

- **Nomenclature** - See Technical Report Appendix A
- **Equations** - In Technical Report Section 4
- **Troubleshooting** - Check GitHub Issues
- **Examples** - All models include documentation blocks

---

## 🚀 Future Work

### Planned Improvements

**Phase 1: Efficiency** (2-3% gain)
- [ ] Add reheat between HP and IP turbines
- [ ] Optimize pressure levels
- [ ] Add feedwater heaters

**Phase 2: Accuracy** (±2% target)
- [ ] Real steam tables (IAPWS-IF97)
- [ ] Temperature-dependent properties
- [ ] Off-design performance maps

**Phase 3: Dynamics** (transient capability)
- [ ] Time constants and thermal inertia
- [ ] Startup/shutdown sequences
- [ ] Control systems (PID)
- [ ] Grid frequency response

**Phase 4: ThermoPower Migration**
- [ ] Hybrid model (ThermoPower HRSG + simple GT)
- [ ] Full component-based model
- [ ] Performance map integration
- [ ] Validation against test data

---

## 🤝 Contributing

Contributions welcome! Areas where you can help:

- 🔧 **Model Improvements** - Add reheat, optimize parameters
- 📊 **Validation** - Compare with real plant data
- 📖 **Documentation** - Examples, tutorials, translations
- 🧪 **Testing** - Different configurations, edge cases
- 🎨 **Visualization** - Better plots, diagrams

**Process:**
1. Fork repository
2. Create feature branch
3. Make changes with clear comments
4. Test thoroughly
5. Submit pull request

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

---

## 📄 License

This project is licensed under the **MIT License** - see [LICENSE](LICENSE) file.

**You are free to:**
- ✅ Use for commercial purposes
- ✅ Modify and distribute
- ✅ Use in private projects
- ✅ Use for education and research

**Attribution appreciated but not required.**

---

## 📧 Support & Contact

### Get Help

- 🐛 **Bug Reports** - [GitHub Issues](https://github.com/wongkiinging/CCGT_OpenModelica/issues)
- 💬 **Discussions** - [GitHub Discussions](https://github.com/wongkiinging/CCGT_OpenModelica/discussions)
- 📖 **Documentation** - Check `/docs` folder
- 📧 **Email** - [your.email@example.com](mailto:your.email@example.com)

### Useful Links

- **OpenModelica:** https://www.openmodelica.org/
- **Modelica Language:** https://www.modelica.org/
- **ThermoPower Library:** https://github.com/casella/ThermoPower
- **Project Website:** [Add if available]

---

## 🎯 Citation

If you use this work in research or publications, please cite:

```bibtex
@software{ccgt_openmodelica_2026,
  title = {Complete Combined Cycle Gas Turbine Model in OpenModelica},
  author = {[Your Name]},
  year = {2026},
  url = {https://github.com/wongkiinging/CCGT_OpenModelica},
  version = {1.0},
  note = {Simplified CCGT model achieving 57.92\% efficiency}
}
```

---

## 🌟 Acknowledgments

- **OpenModelica Team** - Excellent simulation environment
- **ThermoPower Developers** - Inspiration and reference
- **Modelica Community** - Support and resources
- **Power Systems Experts** - Validation and feedback

---

## 📈 Project Stats

- **Models:** 6 Modelica files
- **Documentation:** 3,000+ lines
- **Plots:** 7 high-resolution visualizations
- **Simulation Time:** ~11 seconds
- **Accuracy:** ±5% validated
- **Status:** ✅ Complete and tested

---

<div align="center">

**⭐ Star this repo if you find it useful!**

**🔗 [View Documentation](docs/) | [Report Bug](issues) | [Request Feature](issues)**

**Built with ❤️ for the power systems community**

---

**Last Updated:** January 2026 | **Version:** 1.0.0

</div>

# Quick Start Guide

Get up and running with CCGT OpenModelica in 5 minutes!

## 1️⃣ Install OpenModelica (2 minutes)

### Windows
1. Download: https://www.openmodelica.org/download/
2. Run installer `OpenModelica-v1.25.5-64bit.exe`
3. Follow wizard (accept defaults)

### Linux
```bash
sudo apt install openmodelica
```

### Verify
```bash
omc --version
```

## 2️⃣ Get the Code (30 seconds)

```bash
git clone https://github.com/YOUR_USERNAME/CCGT_OpenModelica.git
cd CCGT_OpenModelica
```

## 3️⃣ Run Your First Simulation (1 minute)

### Option A: GUI (Easiest)
1. Open **OMEdit** (OpenModelica Connection Editor)
2. File → Open Model/Library
3. Select: `models/BraytonCycle_500MW_Standalone.mo`
4. Click green **Simulate** button
5. Plot `netPower` and `thermalEfficiency`

### Option B: Command Line (Fastest)
```bash
cd scripts
omc simulate_simple.mos
```

**Expected output:**
```
Net Power Output: 274.63 MW
Thermal Efficiency: 43.94 %
Exhaust Temperature: 642.3 °C
```

## 4️⃣ Generate Plots (1 minute)

```bash
# Install Python dependencies (one-time)
pip install numpy matplotlib scipy

# Create plots
cd scripts
python create_plots.py
```

Check the `plots/` folder for PNG images!

## 5️⃣ Explore Results (30 seconds)

Open the comprehensive report:
```
docs/CCGT_Report.docx
```

This contains:
- Theory explained for electrical engineers
- All simulation results
- Performance analysis
- Embedded plots

## ✅ Success!

You now have:
- ✅ Working OpenModelica installation
- ✅ Simulated a gas turbine
- ✅ Generated performance plots
- ✅ Professional documentation

## 🚀 Next Steps

**Learn More:**
- Read [README.md](README.md) for detailed instructions
- Check [docs/](docs/) folder for technical reports
- Explore model parameters in `models/BraytonCycle_Dynamic.mo`

**Customize:**
- Change pressure ratio: Edit `parameter Real PR = 18;`
- Adjust efficiency: Edit `parameter Real eta_c = 0.88;`
- Add load steps: Modify fuel flow equation

**Extend:**
- Add HRSG model for combined cycle
- Implement control systems
- Calculate emissions

## 🆘 Troubleshooting

**Simulation fails?**
```bash
# Check model syntax
omc
>> loadModel(Modelica);
>> loadFile("models/BraytonCycleSimple.mo");
>> checkModel(BraytonCycleSimple);
```

**Python issues?**
```bash
# Verify Python version
python --version  # Should be 3.8+

# Reinstall packages
pip install --upgrade numpy matplotlib scipy
```

**Still stuck?**
- See [README.md](README.md) Troubleshooting section
- Open an issue on GitHub

## 📚 Resources

- **OpenModelica Docs:** https://openmodelica.org/doc/
- **Modelica Tutorial:** https://mbe.modelica.university/
- **Gas Turbine Theory:** See [docs/CCGT_Report.docx](docs/CCGT_Report.docx)

---

**Happy simulating!** 🎉

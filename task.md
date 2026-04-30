# GA Optimization of 500MW CCGT — Task Tracker

## Setup
- [ ] Install Python 3.12
- [ ] Install required packages (OMPython, DEAP, numpy, matplotlib, pandas)
- [ ] Verify OpenModelica + Python integration works

## Model Compilation
- [ ] Create `compile_model.mos` script
- [ ] Compile `OpenLoopCombineCycle_500MW` into standalone executable
- [ ] Verify single simulation with default parameters

## GA Optimizer
- [ ] Create `ga_optimizer.py` with 3 parameters:
  1. Fuel mass flow rate (`fuelFlowRateStep.offset`)
  2. Condenser pressure (`condenser.p`)
  3. Steam drum pressure (HRSG `fluidNomPressure` + related params)
- [ ] Implement fitness function (thermal efficiency + constraints)
- [ ] Implement GA with DEAP
- [ ] Test with small population (5 individuals, 3 generations)

## Post-Processing
- [ ] Create `plot_results.py` for convergence plots
- [ ] Run full GA optimization
- [ ] Generate results summary

## Verification
- [ ] Verify optimal parameters produce valid simulation
- [ ] Cross-check baseline efficiency (~48-50%)
- [ ] Document results in walkthrough

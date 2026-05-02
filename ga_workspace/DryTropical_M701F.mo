within;
// Dry tropical variant: same as OpenLoopCombineCycle_M701F but uses Media.Air (1.5% H2O)
// instead of Media.TropicalAir (2.4% H2O), at the same 32 degC (305.15 K) ambient.
// This isolates the humidity-only effect on derating.
model OpenLoopCombineCycle_M701F_DryTropical "M701F tropical 32 degC with DRY air (1.5% H2O) — humidity comparison baseline"
  extends Modelica.Icons.Example;
  import ThermoPower;
  // ============================================================
  // Brayton Cycle (GT) — identical to OpenLoopCombineCycle_M701F
  //   except: uses Media.Air (1.5% H2O) instead of TropicalAir (2.4%)
  // ============================================================
  parameter Real tableEtaC[6, 4] = [0, 95, 100, 105; 1, 88.3e-2, 86.7e-2, 86.1e-2; 2, 89.9e-2, 88.7e-2, 87.7e-2; 3, 89.0e-2, 87.95e-2, 87.2e-2; 4, 88.3e-2, 86.9e-2, 84.5e-2; 5, 85.1e-2, 83.5e-2, 81.9e-2];
  parameter Real tableEtaT[5, 4] = [1, 90, 100, 110; 2.36, 92.6e-2, 93.1e-2, 92.9e-2; 2.88, 93.6e-2, 94.2e-2, 94.1e-2; 3.56, 94.1e-2, 94.2e-2, 94.1e-2; 4.46, 93.8e-2, 93.9e-2, 93.6e-2];
  parameter Real tablePR[6, 4] = [0, 95, 100, 105; 1, 17.6, 21.1, 25.0; 2, 17.2, 20.7, 24.0; 3, 16.2, 19.9, 22.6; 4, 14.8, 19.0, 21.1; 5, 13.3, 16.8, 18.9];
  parameter Real tablePhicC[6, 4] = [0, 95, 100, 105; 1, 109.5e-3, 123.0e-3, 133.8e-3; 2, 112.4e-3, 125.3e-3, 137.0e-3; 3, 116.1e-3, 129.3e-3, 138.4e-3; 4, 119.0e-3, 131.8e-3, 139.9e-3; 5, 121.0e-3, 133.3e-3, 141.0e-3];
  parameter Real tablePhicT[5, 4] = [1, 90, 100, 110; 2.36, 14.74e-3, 14.74e-3, 14.74e-3; 2.88, 14.74e-3, 14.74e-3, 14.74e-3; 3.56, 14.74e-3, 14.74e-3, 14.74e-3; 4.46, 14.74e-3, 14.74e-3, 14.74e-3];
  replaceable package FlueGas = ThermoPower.Media.FlueGas constrainedby Modelica.Media.Interfaces.PartialMedium "Flue gas model";
  replaceable package Water = ThermoPower.Water.StandardWater constrainedby Modelica.Media.Interfaces.PartialPureSubstance "Fluid model";
  // ---- GT Components ----
  // 32 degC (305.15 K), sea-level, but using STANDARD Air (1.5% H2O) — dry tropical baseline
  ThermoPower.Gas.SourcePressure SourceP1(redeclare package Medium = ThermoPower.Media.Air, p0 = 1.01325e5, T = 305.15);
  ThermoPower.Gas.Compressor compressor(redeclare package Medium = ThermoPower.Media.Air, tablePhic = tablePhicC, tableEta = tableEtaC, pstart_in = 1.01325e5, pstart_out = 2.13e6, Tstart_in = 305.15, tablePR = tablePR, Table = ThermoPower.Choices.TurboMachinery.TableTypes.matrix, Tstart_out = 660, explicitIsentropicEnthalpy = true, Tdes_in = 288.15, Ndesign = 157.08);
  ThermoPower.Gas.Turbine turbine(redeclare package Medium = FlueGas, pstart_in = 2.06e6, pstart_out = 1.05e5, tablePhic = tablePhicT, tableEta = tableEtaT, Table = ThermoPower.Choices.TurboMachinery.TableTypes.matrix, Tstart_out = 903, Tdes_in = 1580, Tstart_in = 1580, Ndesign = 157.08);
  ThermoPower.Gas.CombustionChamber CombustionChamber1(gamma = 1, Cm = 1, pstart = 2.09e6, Tstart = 1580, V = 0.125, S = 0.125, initOpt = ThermoPower.Choices.Init.Options.steadyState, HH = 47.1e6);
  ThermoPower.Gas.SourceMassFlow SourceW1(redeclare package Medium = ThermoPower.Media.NaturalGas, w0 = 17.22, p0 = 2200000, T = 300, use_in_w0 = true);
  ThermoPower.Gas.PressDrop PressDrop1(redeclare package Medium = FlueGas, FFtype = ThermoPower.Choices.PressDrop.FFtypes.OpPoint, wnom = 768, rhonom = 3.5, dpnom = 26000, pstart = 2090000, Tstart = 1580);
  ThermoPower.Gas.PressDrop PressDrop2(pstart = 2.13e6, FFtype = ThermoPower.Choices.PressDrop.FFtypes.OpPoint, A = 1, redeclare package Medium = ThermoPower.Media.Air, dpnom = 0.19e5, wnom = 748, rhonom = 12, Tstart = 660);
  Modelica.Mechanics.Rotational.Sensors.PowerSensor powerSensor_GT;
  Modelica.Mechanics.Rotational.Sources.ConstantSpeed constantSpeed_GT(w_fixed = 157, phi(start = 0, fixed = true));
  Modelica.Blocks.Continuous.FirstOrder fuelFlowActuator(k = 1, T = 4, y_start = 500, initType = Modelica.Blocks.Types.Init.SteadyState);
  Modelica.Blocks.Continuous.FirstOrder powerSensor1_GT(k = 1, T = 1, y_start = 333e6, initType = Modelica.Blocks.Types.Init.SteadyState);
  Modelica.Blocks.Interfaces.RealOutput generatedPower_GT;
  ThermoPower.PowerPlants.HRSG.Components.StateReader_gas stateInletCC(redeclare package Medium = ThermoPower.Media.Air);
  ThermoPower.PowerPlants.HRSG.Components.StateReader_gas stateOutletCC(redeclare package Medium = ThermoPower.Media.FlueGas);
  // ============================================================
  // Steam Cycle (Rankine) — identical to OpenLoopCombineCycle_M701F
  // ============================================================
  ThermoPower.CombineCycle.Models.PrescribedPresureCondenser condenser(p = 5390, Vtot = 20, redeclare package Medium = Water, initOpt = ThermoPower.Choices.Init.Options.fixedState);
  ThermoPower.CombineCycle.Models.PrescribedSpeedPump prescribedSpeedPump(n0 = 1500, nominalMassFlowRate = 105, q_nom = {0, 0.105, 0.19}, redeclare package FluidMedium = Water, head_nom = {1100, 750, 0}, rho0 = 1000, nominalOutletPressure = 8000000, nominalInletPressure = 50000);
  Modelica.Blocks.Continuous.FirstOrder nPumpActuator(k = 1, initType = Modelica.Blocks.Types.Init.SteadyState, T = 2, y_start = 1500);
  Modelica.Blocks.Interfaces.RealOutput generatedPower_ST;
  Modelica.Blocks.Continuous.FirstOrder powerSensor_ST_ctrl(k = 1, T = 1, y_start = 167e6, initType = Modelica.Blocks.Types.Init.SteadyState);
  Modelica.Blocks.Interfaces.RealOutput voidFraction_ST;
  Modelica.Blocks.Continuous.FirstOrder voidFractionSensor_ST(k = 1, T = 1, initType = Modelica.Blocks.Types.Init.SteadyState, y_start = 0.2);
  ThermoPower.Water.SteamTurbineStodola steamTurbine(wstart = 105, wnom = 105, Kt = 0.0198, redeclare package Medium = Water, PRstart = 148, pnom = 8000000);
  Modelica.Mechanics.Rotational.Sensors.PowerSensor powerSensor_ST;
  ThermoPower.CombineCycle.Models.HE economizer(redeclare package FluidMedium = Water, redeclare package FlueGasMedium = FlueGas, N_F = 6, exchSurface_G = 51120, exchSurface_F = 4385, extSurfaceTub = 4958, gasVol = 17, fluidVol = 49.3, metalVol = 13.7, rhomcm = 7900*578.05, lambda = 20, gasNomFlowRate = 768, fluidNomFlowRate = 105, gamma_G = 30, gamma_F = 3000, rhonom_G = 1, Kfnom_F = 150, FFtype_G = ThermoPower.Choices.Flow1D.FFtypes.OpPoint, FFtype_F = ThermoPower.Choices.Flow1D.FFtypes.Kfnom, N_G = 6, gasNomPressure = 101325, fluidNomPressure = 8000000, Tstart_G = 493.15, Tstart_M = 443.15, dpnom_G = 1000, dpnom_F = 34000);
  ThermoPower.CombineCycle.Models.Evaporator evaporator(redeclare package FluidMedium = Water, redeclare package FlueGasMedium = FlueGas, gasVol = 17, fluidVol = 21.1, metalVol = 8.16, gasNomFlowRate = 768, fluidNomFlowRate = 105, N = 4, rhom = 7900, cm = 578.05, gamma = 85, exchSurface = 31110, gasNomPressure = 101325, fluidNomPressure = 8000000, Tstart = 568.15, FFtype_G = ThermoPower.Choices.Flow1D.FFtypes.OpPoint, dpnom_G = 1000, rhonom_G = 1);
  ThermoPower.CombineCycle.Models.HE superheater(redeclare package FluidMedium = Water, redeclare package FlueGasMedium = FlueGas, N_F = 7, exchSurface_G = 2951, exchSurface_F = 574, extSurfaceTub = 644, gasVol = 17, fluidVol = 7.6, metalVol = 1.95, rhomcm = 7900*578.05, lambda = 20, gasNomFlowRate = 768, gamma_G = 90, gamma_F = 6000, fluidNomFlowRate = 105, rhonom_G = 1, Kfnom_F = 150, FluidPhaseStart = ThermoPower.Choices.FluidPhase.FluidPhases.Steam, FFtype_G = ThermoPower.Choices.Flow1D.FFtypes.OpPoint, FFtype_F = ThermoPower.Choices.Flow1D.FFtypes.Kfnom, N_G = 7, gasNomPressure = 101325, fluidNomPressure = 8000000, Tstart_G = 803.15, Tstart_M = 623.15, dpnom_G = 1000, dpnom_F = 34000);
  ThermoPower.PowerPlants.HRSG.Components.StateReader_gas stateGasInletEvaporator(redeclare package Medium = FlueGas);
  ThermoPower.PowerPlants.HRSG.Components.StateReader_gas stateGasInletEconomizer(redeclare package Medium = FlueGas);
  ThermoPower.PowerPlants.HRSG.Components.StateReader_gas stateGasOutlet(redeclare package Medium = FlueGas);
  ThermoPower.PowerPlants.HRSG.Components.StateReader_water stateWaterSuperheater_in(redeclare package Medium = Water);
  ThermoPower.PowerPlants.HRSG.Components.StateReader_water stateWaterSuperheater_out(redeclare package Medium = Water);
  ThermoPower.PowerPlants.HRSG.Components.StateReader_water stateWaterEvaporator_in(redeclare package Medium = Water);
  ThermoPower.PowerPlants.HRSG.Components.StateReader_water stateWaterEconomizer_in(redeclare package Medium = Water);
  ThermoPower.Gas.SinkPressure sinkP_gas(T = 400, redeclare package Medium = FlueGas);
  Modelica.Mechanics.Rotational.Sources.ConstantSpeed constantSpeed_ST(w_fixed = 157, phi(start = 0, fixed = true));
  inner ThermoPower.System system(allowFlowReversal = false, initOpt = ThermoPower.Choices.Init.Options.steadyState, T_amb = 305.15, T_wb = 301.15);
  Modelica.Blocks.Sources.Step fuelFlowRateStep(height = 2.5, startTime = 500, offset = 17.22);
  Modelica.Blocks.Sources.Step voidFractionSetPoint(offset = 0.2, height = 0, startTime = 0);
  ThermoPower.CombineCycle.Models.PID voidFractionController(PVmin = 0.1, PVmax = 0.9, CSmax = 2500, PVstart = 0.1, CSstart = 0.5, steadyStateInit = true, CSmin = 500, Kp = -2, Ti = 300);
  ThermoPower.PowerPlants.HRSG.Components.StateReader_gas stateTurbineExhaust(redeclare package Medium = FlueGas);
equation
  // ==== GT Connections ====
  connect(SourceW1.flange, CombustionChamber1.inf);
  connect(SourceP1.flange, compressor.inlet);
  connect(PressDrop1.outlet, turbine.inlet);
  connect(compressor.outlet, PressDrop2.inlet);
  connect(compressor.shaft_b, turbine.shaft_a);
  connect(powerSensor_GT.flange_a, turbine.shaft_b);
  connect(fuelFlowActuator.u, fuelFlowRateStep.y);
  connect(fuelFlowActuator.y, SourceW1.in_w0);
  connect(powerSensor_GT.power, powerSensor1_GT.u);
  connect(powerSensor1_GT.y, generatedPower_GT);
  connect(CombustionChamber1.ina, stateInletCC.outlet);
  connect(stateInletCC.inlet, PressDrop2.outlet);
  connect(stateOutletCC.inlet, CombustionChamber1.out);
  connect(stateOutletCC.outlet, PressDrop1.inlet);
  connect(constantSpeed_GT.flange, powerSensor_GT.flange_b);
  // ==== Bridge: GT exhaust -> HRSG ====
  connect(turbine.outlet, stateTurbineExhaust.inlet);
  connect(stateTurbineExhaust.outlet, superheater.gasIn);
  // ==== ST Connections ====
  connect(prescribedSpeedPump.inlet, condenser.waterOut);
  connect(generatedPower_ST, powerSensor_ST_ctrl.y);
  connect(nPumpActuator.u, voidFractionController.CS);
  connect(voidFractionController.SP, voidFractionSetPoint.y);
  connect(voidFractionController.PV, voidFraction_ST);
  connect(voidFraction_ST, voidFractionSensor_ST.y);
  connect(powerSensor_ST.flange_a, steamTurbine.shaft_b);
  connect(condenser.steamIn, steamTurbine.outlet);
  connect(prescribedSpeedPump.outlet, stateWaterEconomizer_in.inlet);
  connect(stateWaterEconomizer_in.outlet, economizer.waterIn);
  connect(economizer.waterOut, stateWaterEvaporator_in.inlet);
  connect(stateWaterEvaporator_in.outlet, evaporator.waterIn);
  connect(economizer.gasIn, stateGasInletEconomizer.outlet);
  connect(stateGasInletEconomizer.inlet, evaporator.gasOut);
  connect(sinkP_gas.flange, stateGasOutlet.outlet);
  connect(stateGasOutlet.inlet, economizer.gasOut);
  connect(evaporator.gasIn, stateGasInletEvaporator.outlet);
  connect(stateGasInletEvaporator.inlet, superheater.gasOut);
  connect(evaporator.waterOut, stateWaterSuperheater_in.inlet);
  connect(stateWaterSuperheater_in.outlet, superheater.waterIn);
  connect(superheater.waterOut, stateWaterSuperheater_out.inlet);
  connect(stateWaterSuperheater_out.outlet, steamTurbine.inlet);
  connect(powerSensor_ST_ctrl.u, powerSensor_ST.power);
  connect(voidFractionSensor_ST.u, evaporator.voidFraction);
  connect(nPumpActuator.y, prescribedSpeedPump.nPump);
  connect(constantSpeed_ST.flange, powerSensor_ST.flange_b);
  annotation(experiment(StopTime = 2500, Tolerance = 1e-06));
end OpenLoopCombineCycle_M701F_DryTropical;

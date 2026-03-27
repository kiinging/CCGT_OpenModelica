within ThermoPower;

package MyCCGT2
  model MyBraytonCycle
    parameter Real tableEtaC[6, 4] = [0, 95, 100, 105; 1, 82.5e-2, 81e-2, 80.5e-2; 2, 84e-2, 82.9e-2, 82e-2; 3, 83.2e-2, 82.2e-2, 81.5e-2; 4, 82.5e-2, 81.2e-2, 79e-2; 5, 79.5e-2, 78e-2, 76.5e-2];
    parameter Real tablePhicC[6, 4] = [0, 95, 100, 105; 1, 38.3e-3, 43e-3, 46.8e-3; 2, 39.3e-3, 43.8e-3, 47.9e-3; 3, 40.6e-3, 45.2e-3, 48.4e-3; 4, 41.6e-3, 46.1e-3, 48.9e-3; 5, 42.3e-3, 46.6e-3, 49.3e-3];
    parameter Real tablePR[6, 4] = [0, 95, 100, 105; 1, 22.6, 27, 32; 2, 22, 26.6, 30.8; 3, 20.8, 25.5, 29; 4, 19, 24.3, 27.1; 5, 17, 21.5, 24.2];
    parameter Real tablePhicT[5, 4] = [1, 90, 100, 110; 2.36, 4.68e-3, 4.68e-3, 4.68e-3; 2.88, 4.68e-3, 4.68e-3, 4.68e-3; 3.56, 4.68e-3, 4.68e-3, 4.68e-3; 4.46, 4.68e-3, 4.68e-3, 4.68e-3];
    parameter Real tableEtaT[5, 4] = [1, 90, 100, 110; 2.36, 89e-2, 89.5e-2, 89.3e-2; 2.88, 90e-2, 90.6e-2, 90.5e-2; 3.56, 90.5e-2, 90.6e-2, 90.5e-2; 4.46, 90.2e-2, 90.3e-2, 90e-2];
    Electrical.Generator generator(Pnom = 4e6, initOpt = Choices.Init.Options.steadyState) annotation(
      Placement(transformation(extent = {{92, -80}, {132, -40}}, rotation = 0)));
    Modelica.Blocks.Interfaces.RealInput fuelFlowRate annotation(
      Placement(transformation(extent = {{-210, -10}, {-190, 10}}, rotation = 0)));
    Modelica.Blocks.Interfaces.RealOutput generatedPower annotation(
      Placement(transformation(extent = {{196, -10}, {216, 10}}, rotation = 0)));
    Gas.Compressor compressor(redeclare package Medium = Media.Air, tablePhic = tablePhicC, tableEta = tableEtaC, pstart_in = 0.343e5, pstart_out = 8.3e5, Tstart_in = 244.4, tablePR = tablePR, Table = Choices.TurboMachinery.TableTypes.matrix, Tstart_out = 600.4, explicitIsentropicEnthalpy = true, Tdes_in = 244.4, Ndesign = 157.08) annotation(
      Placement(transformation(extent = {{-158, -90}, {-98, -30}}, rotation = 0)));
    Gas.Turbine turbine(redeclare package Medium = Media.FlueGas, pstart_in = 7.85e5, pstart_out = 1.52e5, tablePhic = tablePhicT, tableEta = tableEtaT, Table = Choices.TurboMachinery.TableTypes.matrix, Tstart_out = 800, Tdes_in = 1400, Tstart_in = 1370, Ndesign = 157.08) annotation(
      Placement(transformation(extent = {{-6, -90}, {54, -30}}, rotation = 0)));
    Gas.CombustionChamber CombustionChamber1(gamma = 1, Cm = 1, pstart = 8.11e5, Tstart = 1370, V = 0.05, S = 0.05, initOpt = Choices.Init.Options.steadyState, HH = 41.6e6) annotation(
      Placement(transformation(extent = {{-72, 20}, {-32, 60}}, rotation = 0)));
    Gas.SourcePressure SourceP1(redeclare package Medium = Media.Air, p0 = 0.343e5, T = 244.4) annotation(
      Placement(transformation(extent = {{-188, -30}, {-168, -10}}, rotation = 0)));
    Gas.SinkPressure SinkP1(redeclare package Medium = Media.FlueGas, p0 = 1.52e5, T = 800) annotation(
      Placement(transformation(extent = {{94, -10}, {114, 10}}, rotation = 0)));
    Gas.SourceMassFlow SourceW1(redeclare package Medium = Media.NaturalGas, w0 = 2.02, p0 = 811000, T = 300, use_in_w0 = true) annotation(
      Placement(transformation(extent = {{-100, 70}, {-80, 90}}, rotation = 0)));
    Gas.PressDrop PressDrop1(redeclare package Medium = Media.FlueGas, FFtype = Choices.PressDrop.FFtypes.OpPoint, wnom = 102, rhonom = 2, dpnom = 26000, pstart = 811000, Tstart = 1370) annotation(
      Placement(transformation(origin = {0, 8}, extent = {{-10, -10}, {10, 10}}, rotation = 270)));
    Gas.PressDrop PressDrop2(pstart = 8.3e5, FFtype = Choices.PressDrop.FFtypes.OpPoint, A = 1, redeclare package Medium = Media.Air, dpnom = 0.19e5, wnom = 100, rhonom = 4.7, Tstart = 600) annotation(
      Placement(transformation(origin = {-104, 10}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
    Modelica.Mechanics.Rotational.Sensors.PowerSensor powerSensor annotation(
      Placement(transformation(extent = {{60, -70}, {80, -50}}, rotation = 0)));
    Modelica.Blocks.Continuous.FirstOrder gasFlowActuator(k = 1, T = 4, y_start = 500, initType = Modelica.Blocks.Types.Init.SteadyState) annotation(
      Placement(transformation(extent = {{-138, 92}, {-122, 108}}, rotation = 0)));
    Modelica.Blocks.Continuous.FirstOrder powerSensor1(k = 1, T = 1, y_start = 56.8e6, initType = Modelica.Blocks.Types.Init.SteadyState) annotation(
      Placement(transformation(extent = {{146, -118}, {162, -102}}, rotation = 0)));
    PowerPlants.HRSG.Components.StateReader_gas stateInletCC(redeclare package Medium = Media.Air) annotation(
      Placement(transformation(extent = {{-100, 30}, {-80, 50}}, rotation = 0)));
    PowerPlants.HRSG.Components.StateReader_gas stateOutletCC(redeclare package Medium = Media.FlueGas) annotation(
      Placement(transformation(extent = {{-24, 30}, {-4, 50}}, rotation = 0)));
    inner System system(allowFlowReversal = false) annotation(
      Placement(transformation(extent = {{158, 160}, {178, 180}})));
    Electrical.Grid grid(Pgrid = 1e9) annotation(
      Placement(transformation(extent = {{144, -70}, {164, -50}})));
  equation
    connect(SourceW1.flange, CombustionChamber1.inf) annotation(
      Line(points = {{-80, 80}, {-52, 80}, {-52, 60}}, color = {159, 159, 223}, thickness = 0.5));
    connect(turbine.outlet, SinkP1.flange) annotation(
      Line(points = {{48, -36}, {48, 0}, {94, 0}}, color = {159, 159, 223}, thickness = 0.5));
    connect(SourceP1.flange, compressor.inlet) annotation(
      Line(points = {{-168, -20}, {-152, -20}, {-152, -36}}, color = {159, 159, 223}, thickness = 0.5));
    connect(PressDrop1.outlet, turbine.inlet) annotation(
      Line(points = {{-1.83697e-015, -2}, {-1.83697e-015, -36}, {0, -36}}, color = {159, 159, 223}, thickness = 0.5));
    connect(compressor.outlet, PressDrop2.inlet) annotation(
      Line(points = {{-104, -36}, {-104, 0}}, color = {159, 159, 223}, thickness = 0.5));
    connect(compressor.shaft_b, turbine.shaft_a) annotation(
      Line(points = {{-110, -60}, {6, -60}}, color = {0, 0, 0}, thickness = 0.5));
    connect(powerSensor.flange_a, turbine.shaft_b) annotation(
      Line(points = {{60, -60}, {42, -60}}, color = {0, 0, 0}, thickness = 0.5));
    connect(gasFlowActuator.u, fuelFlowRate) annotation(
      Line(points = {{-139.6, 100}, {-166, 100}, {-166, 0}, {-200, 0}}, color = {0, 0, 127}));
    connect(gasFlowActuator.y, SourceW1.in_w0) annotation(
      Line(points = {{-121.2, 100}, {-96, 100}, {-96, 85}}, color = {0, 0, 127}));
    connect(powerSensor.power, powerSensor1.u) annotation(
      Line(points = {{62, -71}, {62, -110}, {144.4, -110}}, color = {0, 0, 127}));
    connect(powerSensor1.y, generatedPower) annotation(
      Line(points = {{162.8, -110}, {184.4, -110}, {184.4, 0}, {206, 0}}, color = {0, 0, 127}));
    connect(CombustionChamber1.ina, stateInletCC.outlet) annotation(
      Line(points = {{-72, 40}, {-84, 40}}, color = {159, 159, 223}, thickness = 0.5));
    connect(stateInletCC.inlet, PressDrop2.outlet) annotation(
      Line(points = {{-96, 40}, {-104, 40}, {-104, 20}}, color = {159, 159, 223}, thickness = 0.5));
    connect(stateOutletCC.inlet, CombustionChamber1.out) annotation(
      Line(points = {{-20, 40}, {-32, 40}}, color = {159, 159, 223}, thickness = 0.5));
    connect(stateOutletCC.outlet, PressDrop1.inlet) annotation(
      Line(points = {{-8, 40}, {1.83697e-015, 40}, {1.83697e-015, 18}}, color = {159, 159, 223}, thickness = 0.5));
    connect(generator.shaft, powerSensor.flange_b) annotation(
      Line(points = {{94.8, -60}, {80, -60}}, color = {0, 0, 0}, thickness = 0.5));
    connect(generator.port, grid.port) annotation(
      Line(points = {{129.2, -60}, {145.4, -60}}, color = {0, 0, 255}, thickness = 0.5));
    annotation(
      Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-200, -200}, {200, 200}}, initialScale = 0.1)),
      Icon(coordinateSystem(preserveAspectRatio = false, extent = {{-200, -200}, {200, 200}}, initialScale = 0.1), graphics = {Rectangle(extent = {{-200, 200}, {200, -200}}, lineColor = {170, 170, 255}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Text(extent = {{-140, 140}, {140, -140}}, lineColor = {170, 170, 255}, textString = "P")}),
      Documentation(revisions = "<html>
  <ul>
  <li><i>10 Dec 2008</i>
      by <a>Luca Savoldelli</a>:<br>
         First release.</li>
  </ul>
  </html>", info = "<html>
  <p>This model contains the  gas turbine, generator and network models. The network model is based on swing equation.
  </html>"));
  end MyBraytonCycle;

  model MyBraytonOpenLoopSimulator
    extends Modelica.Icons.Example;
    Examples.BraytonCycle.Plant plant annotation(
      Placement(transformation(extent = {{20, -20}, {60, 20}}, rotation = 0)));
    Modelica.Blocks.Sources.Step fuelFlowRate(height = 0.3, startTime = 500, offset = 2.13) annotation(
      Placement(transformation(extent = {{-40, -10}, {-20, 10}}, rotation = 0)));
    inner System system annotation(
      Placement(transformation(extent = {{80, 80}, {100, 100}})));
  equation
    connect(plant.fuelFlowRate, fuelFlowRate.y) annotation(
      Line(points = {{20, 0}, {-19, 0}}, color = {0, 0, 127}));
    annotation(
      Diagram(graphics),
      experiment(StopTime = 1000, __Dymola_NumberOfIntervals = 5000, Tolerance = 1e-006),
      Documentation(revisions = "<html>
  <ul>
  <li><i>10 Dec 2008</i>
      by <a>Luca Savoldelli</a>:<br>
         First release.</li>
  </ul>
  </html>", info = "<html>
  <p>This model allows to simulate an open loop transients.
  </html>"),
      __Dymola_experimentSetupOutput);
  end MyBraytonOpenLoopSimulator;

  model MyBraytonClosedLoopSimulator
    extends Modelica.Icons.Example;
    Examples.BraytonCycle.Plant plant annotation(
      Placement(transformation(extent = {{20, -20}, {60, 20}}, rotation = 0)));
    Modelica.Blocks.Sources.Ramp powerSetPoint(offset = 4e6, height = 2e6, duration = 10, startTime = 500) annotation(
      Placement(transformation(extent = {{-80, -6}, {-60, 14}}, rotation = 0)));
    Examples.RankineCycle.Models.PID pID(Ti = 5, PVmin = 2e6, PVmax = 12e6, CSmin = 0, CSmax = 4, steadyStateInit = true, Kp = 0.25, holdWhenSimplified = true) annotation(
      Placement(transformation(extent = {{-32, -10}, {-12, 10}}, rotation = 0)));
    inner System system annotation(
      Placement(transformation(extent = {{80, 80}, {100, 100}})));
  equation
    connect(plant.fuelFlowRate, pID.CS) annotation(
      Line(points = {{20, 0}, {-12, 0}}, color = {0, 0, 127}));
    connect(pID.SP, powerSetPoint.y) annotation(
      Line(points = {{-32, 4}, {-59, 4}}, color = {0, 0, 127}));
    connect(pID.PV, plant.generatedPower) annotation(
      Line(points = {{-32, -4}, {-50, -4}, {-50, -40}, {80, -40}, {80, 0}, {60.6, 0}}, color = {0, 0, 127}));
    annotation(
      Diagram(graphics),
      experiment(StopTime = 1000, Tolerance = 1e-006),
      Documentation(revisions = "<html>
  <ul>
  <li><i>10 Dec 2008</i>
      by <a>Luca Savoldelli</a>:<br>
         First release.</li>
  </ul>
  </html>", info = "<html>
  <p>This model simulates a simple continuous-time control system for the steam power plant. The generated power is controlled to the set point by a PI controller with anti-windup.</p>
  <p>The model starts at steady state.
  </html>"));
  end MyBraytonClosedLoopSimulator;

  model MyRankineCyclePlant
    import ThermoPower;
    replaceable package FlueGas = ThermoPower.Media.FlueGas constrainedby Modelica.Media.Interfaces.PartialMedium "Flue gas model";
    replaceable package Water = ThermoPower.Water.StandardWater constrainedby Modelica.Media.Interfaces.PartialPureSubstance "Fluid model";
    ThermoPower.Examples.RankineCycle.Models.PrescribedPressureCondenser condenser(p = 5390, redeclare package Medium = Water, initOpt = ThermoPower.Choices.Init.Options.fixedState) annotation(
      Placement(transformation(extent = {{100, -100}, {140, -60}}, rotation = 0)));
    ThermoPower.Examples.RankineCycle.Models.PrescribedSpeedPump prescribedSpeedPump(n0 = 1500, nominalMassFlowRate = 55, q_nom = {0, 0.055, 0.1}, redeclare package FluidMedium = Water, head_nom = {450, 300, 0}, rho0 = 1000, nominalOutletPressure = 3000000, nominalInletPressure = 50000) annotation(
      Placement(transformation(extent = {{40, -180}, {0, -140}}, rotation = 0)));
    Modelica.Blocks.Continuous.FirstOrder temperatureActuator(k = 1, y_start = 750, T = 4, initType = Modelica.Blocks.Types.Init.SteadyState) annotation(
      Placement(transformation(extent = {{-280, 90}, {-260, 110}}, rotation = 0)));
    Modelica.Blocks.Continuous.FirstOrder powerSensor(k = 1, T = 1, y_start = 56.8e6, initType = Modelica.Blocks.Types.Init.SteadyState) annotation(
      Placement(transformation(extent = {{240, 90}, {260, 110}}, rotation = 0)));
    Modelica.Blocks.Interfaces.RealOutput generatedPower annotation(
      Placement(transformation(extent = {{290, 90}, {310, 110}}, rotation = 0), iconTransformation(extent = {{92, 30}, {112, 50}})));
    Modelica.Blocks.Interfaces.RealInput gasFlowRate annotation(
      Placement(transformation(extent = {{-310, -10}, {-290, 10}}, rotation = 0), iconTransformation(extent = {{-108, 50}, {-88, 70}})));
    Modelica.Blocks.Interfaces.RealInput gasTemperature annotation(
      Placement(transformation(extent = {{-310, 90}, {-290, 110}}, rotation = 0), iconTransformation(extent = {{-108, -10}, {-88, 10}})));
    Modelica.Blocks.Continuous.FirstOrder gasFlowActuator(k = 1, T = 4, y_start = 500, initType = Modelica.Blocks.Types.Init.SteadyState) annotation(
      Placement(transformation(extent = {{-280, -10}, {-260, 10}}, rotation = 0)));
    Modelica.Blocks.Continuous.FirstOrder nPumpActuator(k = 1, initType = Modelica.Blocks.Types.Init.SteadyState, T = 2, y_start = 1500) annotation(
      Placement(transformation(extent = {{-280, -110}, {-260, -90}}, rotation = 0)));
    Modelica.Blocks.Interfaces.RealInput nPump annotation(
      Placement(transformation(extent = {{-310, -110}, {-290, -90}}, rotation = 0), iconTransformation(extent = {{-108, -70}, {-88, -50}})));
    Modelica.Blocks.Interfaces.RealOutput voidFraction annotation(
      Placement(transformation(extent = {{290, -110}, {310, -90}}, rotation = 0), iconTransformation(extent = {{92, -50}, {112, -30}})));
    Modelica.Blocks.Continuous.FirstOrder voidFractionSensor(k = 1, T = 1, initType = Modelica.Blocks.Types.Init.SteadyState, y_start = 0.2) annotation(
      Placement(transformation(extent = {{240, -110}, {260, -90}}, rotation = 0)));
    ThermoPower.Water.SteamTurbineStodola steamTurbine(wstart = 55, wnom = 55, Kt = 0.0104, redeclare package Medium = Water, PRstart = 30, pnom = 3000000) annotation(
      Placement(transformation(extent = {{50, 30}, {100, 80}}, rotation = 0)));
    Modelica.Mechanics.Rotational.Sensors.PowerSensor powerSensor1 annotation(
      Placement(transformation(extent = {{138, 68}, {166, 40}}, rotation = 0)));
    ThermoPower.Examples.RankineCycle.Models.HE economizer(redeclare package FluidMedium = Water, redeclare package FlueGasMedium = FlueGas, N_F = 6, exchSurface_G = 40095.9, exchSurface_F = 3439.389, extSurfaceTub = 3888.449, gasVol = 10, fluidVol = 28.977, metalVol = 8.061, rhomcm = 7900*578.05, lambda = 20, gasNomFlowRate = 500, fluidNomFlowRate = 55, gamma_G = 30, gamma_F = 3000, rhonom_G = 1, Kfnom_F = 150, FFtype_G = ThermoPower.Choices.Flow1D.FFtypes.OpPoint, FFtype_F = ThermoPower.Choices.Flow1D.FFtypes.Kfnom, N_G = 6, gasNomPressure = 101325, fluidNomPressure = 3000000, Tstart_G = 473.15, Tstart_M = 423.15, dpnom_G = 1000, dpnom_F = 20000) annotation(
      Placement(transformation(extent = {{-120, -80}, {-80, -120}}, rotation = 0)));
    ThermoPower.Examples.HRB.Models.Evaporator evaporator(redeclare package FluidMedium = Water, redeclare package FlueGasMedium = FlueGas, gasVol = 10, fluidVol = 12.400, metalVol = 4.801, gasNomFlowRate = 500, fluidNomFlowRate = 55, N = 4, rhom = 7900, cm = 578.05, gamma = 85, exchSurface = 24402, gasNomPressure = 101325, fluidNomPressure = 3000000, Tstart = 623.15, FFtype_G = ThermoPower.Choices.Flow1D.FFtypes.OpPoint, dpnom_G = 1000, rhonom_G = 1) annotation(
      Placement(transformation(extent = {{-120, 0}, {-80, -40}}, rotation = 0)));
    ThermoPower.Examples.RankineCycle.Models.HE superheater(redeclare package FluidMedium = Water, redeclare package FlueGasMedium = FlueGas, N_F = 7, exchSurface_G = 2314.8, exchSurface_F = 450.218, extSurfaceTub = 504.652, gasVol = 10, fluidVol = 4.468, metalVol = 1.146, rhomcm = 7900*578.05, lambda = 20, gasNomFlowRate = 500, gamma_G = 90, gamma_F = 6000, fluidNomFlowRate = 55, rhonom_G = 1, Kfnom_F = 150, FluidPhaseStart = ThermoPower.Choices.FluidPhase.FluidPhases.Steam, FFtype_G = ThermoPower.Choices.Flow1D.FFtypes.OpPoint, FFtype_F = ThermoPower.Choices.Flow1D.FFtypes.Kfnom, N_G = 7, gasNomPressure = 101325, fluidNomPressure = 3000000, Tstart_G = 723.15, Tstart_M = 573.15, dpnom_G = 1000, dpnom_F = 20000) annotation(
      Placement(transformation(extent = {{-120, 80}, {-80, 40}}, rotation = 0)));
    ThermoPower.PowerPlants.HRSG.Components.StateReader_gas stateGasInlet(redeclare package Medium = FlueGas) annotation(
      Placement(transformation(extent = {{-150, 50}, {-130, 70}}, rotation = 0)));
    ThermoPower.PowerPlants.HRSG.Components.StateReader_gas stateGasInletEvaporator(redeclare package Medium = FlueGas) annotation(
      Placement(transformation(extent = {{-150, -30}, {-130, -10}}, rotation = 0)));
    ThermoPower.PowerPlants.HRSG.Components.StateReader_gas stateGasInletEconomizer(redeclare package Medium = FlueGas) annotation(
      Placement(transformation(extent = {{-150, -110}, {-130, -90}}, rotation = 0)));
    ThermoPower.PowerPlants.HRSG.Components.StateReader_gas stateGasOutlet(redeclare package Medium = FlueGas) annotation(
      Placement(transformation(extent = {{-70, -110}, {-50, -90}}, rotation = 0)));
    ThermoPower.PowerPlants.HRSG.Components.StateReader_water stateWaterSuperheater_in(redeclare package Medium = Water) annotation(
      Placement(transformation(origin = {-100, 20}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
    ThermoPower.PowerPlants.HRSG.Components.StateReader_water stateWaterSuperheater_out(redeclare package Medium = Water) annotation(
      Placement(transformation(origin = {-100, 102}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
    ThermoPower.PowerPlants.HRSG.Components.StateReader_water stateWaterEvaporator_in(redeclare package Medium = Water) annotation(
      Placement(transformation(origin = {-100, -60}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
    ThermoPower.PowerPlants.HRSG.Components.StateReader_water stateWaterEconomizer_in(redeclare package Medium = Water) annotation(
      Placement(transformation(origin = {-100, -140}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
    ThermoPower.Gas.SourceMassFlow sourceW_gas(w0 = 500, redeclare package Medium = FlueGas, T = 750, use_in_w0 = true, use_in_T = true) annotation(
      Placement(transformation(extent = {{-200, 50}, {-180, 70}}, rotation = 0)));
    ThermoPower.Gas.SinkPressure sinkP_gas(T = 400, redeclare package Medium = FlueGas) annotation(
      Placement(transformation(extent = {{-40, -110}, {-20, -90}}, rotation = 0)));
    inner ThermoPower.System system(allowFlowReversal = false, initOpt = ThermoPower.Choices.Init.Options.steadyState) annotation(
      Placement(transformation(extent = {{240, 160}, {260, 180}})));
    Modelica.Mechanics.Rotational.Sources.ConstantSpeed constantSpeed(w_fixed = 157, phi(start = 0, fixed = true)) annotation(
      Placement(transformation(extent = {{200, 44}, {180, 64}})));
  equation
    connect(prescribedSpeedPump.inlet, condenser.waterOut) annotation(
      Line(points = {{40, -160}, {120, -160}, {120, -100}}, thickness = 0.5, color = {0, 0, 255}));
    connect(generatedPower, powerSensor.y) annotation(
      Line(points = {{300, 100}, {261, 100}}, color = {0, 0, 127}));
    connect(gasFlowActuator.u, gasFlowRate) annotation(
      Line(points = {{-282, 0}, {-300, 0}}, color = {0, 0, 127}));
    connect(temperatureActuator.u, gasTemperature) annotation(
      Line(points = {{-282, 100}, {-300, 100}}, color = {0, 0, 127}));
    connect(nPumpActuator.u, nPump) annotation(
      Line(points = {{-282, -100}, {-300, -100}}, color = {0, 0, 127}));
    connect(voidFraction, voidFractionSensor.y) annotation(
      Line(points = {{300, -100}, {261, -100}}, color = {0, 0, 127}));
    connect(powerSensor1.flange_a, steamTurbine.shaft_b) annotation(
      Line(points = {{138, 54}, {91, 54}, {91, 55}}, color = {0, 0, 0}, thickness = 0.5));
    connect(stateGasInlet.inlet, sourceW_gas.flange) annotation(
      Line(points = {{-146, 60}, {-180, 60}}, color = {159, 159, 223}, thickness = 0.5));
    connect(condenser.steamIn, steamTurbine.outlet) annotation(
      Line(points = {{120, -60}, {120, 75}, {95, 75}}, thickness = 0.5, color = {0, 0, 255}));
    connect(prescribedSpeedPump.outlet, stateWaterEconomizer_in.inlet) annotation(
      Line(points = {{0, -160}, {-100, -160}, {-100, -146}}, thickness = 0.5, color = {0, 0, 255}));
    connect(stateWaterEconomizer_in.outlet, economizer.waterIn) annotation(
      Line(points = {{-100, -134}, {-100, -120}}, thickness = 0.5));
    connect(economizer.waterOut, stateWaterEvaporator_in.inlet) annotation(
      Line(points = {{-100, -80}, {-100, -66}}, thickness = 0.5, color = {0, 0, 255}));
    connect(stateWaterEvaporator_in.outlet, evaporator.waterIn) annotation(
      Line(points = {{-100, -54}, {-100, -40}}, thickness = 0.5, color = {0, 0, 255}));
    connect(economizer.gasIn, stateGasInletEconomizer.outlet) annotation(
      Line(points = {{-120, -100}, {-128, -100}, {-134, -100}}, color = {159, 159, 223}, thickness = 0.5));
    connect(stateGasInletEconomizer.inlet, evaporator.gasOut) annotation(
      Line(points = {{-146, -100}, {-160, -100}, {-160, -50}, {-40, -50}, {-40, -20}, {-80, -20}}, color = {159, 159, 223}, thickness = 0.5));
    connect(sinkP_gas.flange, stateGasOutlet.outlet) annotation(
      Line(points = {{-40, -100}, {-54, -100}}, color = {159, 159, 223}, thickness = 0.5));
    connect(stateGasOutlet.inlet, economizer.gasOut) annotation(
      Line(points = {{-66, -100}, {-74, -100}, {-80, -100}}, color = {159, 159, 223}, thickness = 0.5));
    connect(evaporator.gasIn, stateGasInletEvaporator.outlet) annotation(
      Line(points = {{-120, -20}, {-134, -20}}, color = {159, 159, 223}, thickness = 0.5));
    connect(stateGasInletEvaporator.inlet, superheater.gasOut) annotation(
      Line(points = {{-146, -20}, {-160, -20}, {-160, 30}, {-40, 30}, {-40, 60}, {-80, 60}}, color = {159, 159, 223}, thickness = 0.5));
    connect(evaporator.waterOut, stateWaterSuperheater_in.inlet) annotation(
      Line(points = {{-100, 0}, {-100, 14}}, thickness = 0.5, color = {0, 0, 255}));
    connect(stateWaterSuperheater_in.outlet, superheater.waterIn) annotation(
      Line(points = {{-100, 26}, {-100, 40}}, thickness = 0.5, color = {0, 0, 255}));
    connect(superheater.waterOut, stateWaterSuperheater_out.inlet) annotation(
      Line(points = {{-100, 80}, {-100, 96}}, thickness = 0.5, color = {0, 0, 255}));
    connect(stateWaterSuperheater_out.outlet, steamTurbine.inlet) annotation(
      Line(points = {{-100, 108}, {-100, 120}, {55, 120}, {55, 75}}, thickness = 0.5, color = {0, 0, 255}));
    connect(superheater.gasIn, stateGasInlet.outlet) annotation(
      Line(points = {{-120, 60}, {-128, 60}, {-134, 60}}, color = {159, 159, 223}, thickness = 0.5));
    connect(powerSensor.u, powerSensor1.power) annotation(
      Line(points = {{238, 100}, {140.8, 100}, {140.8, 69.4}}, color = {0, 0, 127}));
    connect(voidFractionSensor.u, evaporator.voidFraction) annotation(
      Line(points = {{238, -100}, {200, -100}, {200, -32}, {-78.8, -32}}, color = {0, 0, 127}));
    connect(gasFlowActuator.y, sourceW_gas.in_w0) annotation(
      Line(points = {{-259, 0}, {-220, 0}, {-220, 80}, {-196, 80}, {-196, 65}}, color = {0, 0, 127}));
    connect(temperatureActuator.y, sourceW_gas.in_T) annotation(
      Line(points = {{-259, 100}, {-190, 100}, {-190, 65}}, color = {0, 0, 127}));
    connect(nPumpActuator.y, prescribedSpeedPump.nPump) annotation(
      Line(points = {{-259, -100}, {-220, -100}, {-220, -190}, {80, -190}, {80, -148}, {34.4, -148}}, color = {0, 0, 127}));
    connect(constantSpeed.flange, powerSensor1.flange_b) annotation(
      Line(points = {{180, 54}, {166, 54}}, color = {0, 0, 0}));
    annotation(
      Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-300, -200}, {300, 200}}, initialScale = 0.1)),
      Icon(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -100}, {100, 100}}, initialScale = 0.1), graphics = {Rectangle(extent = {{-100, 100}, {100, -100}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Text(extent = {{-88, 84}, {100, -96}}, lineColor = {0, 0, 255}, textString = "P")}),
      Documentation(revisions = "<html>
  <ul>
  <li><i>10 Dec 2008</i>
  by <a>Luca Savoldelli</a>:<br>
   First release.</li>
  </ul>
  </html>", info = "<html>
  This is a simple model of a steam plant.
  </html>"));
  end MyRankineCyclePlant;

  model MyRankineCycleClosedLoopSimulator
    extends Modelica.Icons.Example;
    Modelica.Blocks.Sources.Ramp gasTemperature(height = 0, duration = 0, offset = 750) annotation(
      Placement(transformation(extent = {{-40, -14}, {-20, 6}}, rotation = 0)));
    Examples.RankineCycle.Models.Plant plant(economizer(gasFlow(wnm = 2))) annotation(
      Placement(transformation(extent = {{20, -24}, {60, 16}}, rotation = 0)));
    Modelica.Blocks.Sources.Step voidFractionSetPoint(offset = 0.2, height = 0, startTime = 0) annotation(
      Placement(transformation(extent = {{-80, -54}, {-60, -34}}, rotation = 0)));
    Examples.RankineCycle.Models.PID voidFractionController(PVmin = 0.1, PVmax = 0.9, CSmax = 2500, PVstart = 0.1, CSstart = 0.5, steadyStateInit = true, CSmin = 500, Kp = -2, Ti = 300) annotation(
      Placement(transformation(extent = {{-40, -58}, {-20, -38}}, rotation = 0)));
    Modelica.Blocks.Sources.Ramp powerSetPoint(duration = 450, startTime = 500, height = -56.8e6*0.35, offset = 56.8e6) annotation(
      Placement(transformation(extent = {{-80, 20}, {-60, 40}}, rotation = 0)));
    Examples.RankineCycle.Models.PID powerController(steadyStateInit = true, PVmin = 20e6, PVmax = 100e6, Ti = 240, CSmin = 100, CSmax = 1000, Kp = 2, CSstart = 0.7, holdWhenSimplified = true) annotation(
      Placement(transformation(extent = {{-40, 44}, {-20, 24}}, rotation = 0)));
  equation
    connect(voidFractionController.SP, voidFractionSetPoint.y) annotation(
      Line(points = {{-40, -44}, {-50, -44}, {-59, -44}}, color = {0, 0, 127}));
    connect(voidFractionController.CS, plant.nPump) annotation(
      Line(points = {{-20, -48}, {0, -48}, {0, -16}, {20.4, -16}}, color = {0, 0, 127}));
    connect(voidFractionController.PV, plant.voidFraction) annotation(
      Line(points = {{-40, -52}, {-50, -52}, {-50, -72}, {90, -72}, {90, -12}, {60.4, -12}}, color = {0, 0, 127}));
    connect(powerSetPoint.y, powerController.SP) annotation(
      Line(points = {{-59, 30}, {-50, 30}, {-40, 30}}, color = {0, 0, 127}));
    connect(powerController.PV, plant.generatedPower) annotation(
      Line(points = {{-40, 38}, {-50, 38}, {-50, 60}, {90, 60}, {90, 4}, {60.4, 4}}, color = {0, 0, 127}));
    connect(gasTemperature.y, plant.gasTemperature) annotation(
      Line(points = {{-19, -4}, {20.4, -4}}, color = {0, 0, 127}, smooth = Smooth.None));
    connect(powerController.CS, plant.gasFlowRate) annotation(
      Line(points = {{-20, 34}, {0, 34}, {0, 8}, {20.4, 8}}, color = {0, 0, 127}, smooth = Smooth.None));
    annotation(
      Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -100}, {100, 100}}, initialScale = 0.1), graphics),
      experiment(StopTime = 3000, Tolerance = 1e-006),
      Icon(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -100}, {100, 100}}, initialScale = 0.1), graphics),
      Documentation(revisions = "<html>
  <ul>
  <li><i>10 Dec 2008</i>
      by <a>Luca Savoldelli</a>:<br>
         First release.</li>
  </ul>
  </html>", info = "<html>
  <p>This model simulates a simple continuous-time control system for the steam power plant.
  <p>The generated power and the evaporator void fraction are controlled to the set point by PI controllers with anti-windup.</p>
  </html>"),
      experimentSetupOutput(equdistant = false));
  end MyRankineCycleClosedLoopSimulator;

  model MyCombinedCycleModel
    ThermoPower.Electrical.Generator generator(Pnom = 4e6, initOpt = Choices.Init.Options.steadyState) annotation(
      Placement(transformation(origin = {-108, -24}, extent = {{92, -80}, {132, -40}})));
    Modelica.Blocks.Interfaces.RealInput fuelFlowRate annotation(
      Placement(transformation(origin = {-68, 62}, extent = {{-210, -10}, {-190, 10}}), iconTransformation(origin = {162, -142}, extent = {{-210, -10}, {-190, 10}})));
    Modelica.Blocks.Interfaces.RealOutput generatedPower annotation(
      Placement(transformation(origin = {-186, -18}, extent = {{196, -10}, {216, 10}}), iconTransformation(origin = {162, -142}, extent = {{196, -10}, {216, 10}})));
    ThermoPower.Gas.Compressor compressor(redeclare package Medium = Media.Air, Ndesign = 157.08, Table = Choices.TurboMachinery.TableTypes.matrix, Tdes_in = 244.4, Tstart_in = 244.4, Tstart_out = 600.4, explicitIsentropicEnthalpy = true, pstart_in = 0.343e5, pstart_out = 8.3e5, tableEta = tableEtaC, tablePR = tablePR, tablePhic = tablePhicC) annotation(
      Placement(transformation(origin = {-108, -24}, extent = {{-158, -90}, {-98, -30}})));
    ThermoPower.Gas.Turbine turbine(redeclare package Medium = Media.FlueGas, Ndesign = 157.08, Table = Choices.TurboMachinery.TableTypes.matrix, Tdes_in = 1400, Tstart_in = 1370, Tstart_out = 800, pstart_in = 7.85e5, pstart_out = 1.52e5, tableEta = tableEtaT, tablePhic = tablePhicT) annotation(
      Placement(transformation(origin = {-108, -24}, extent = {{-6, -90}, {54, -30}})));
    ThermoPower.Gas.CombustionChamber CombustionChamber1(Cm = 1, HH = 41.6e6, S = 0.05, Tstart = 1370, V = 0.05, gamma = 1, initOpt = Choices.Init.Options.steadyState, pstart = 8.11e5) annotation(
      Placement(transformation(origin = {-108, -24}, extent = {{-72, 20}, {-32, 60}})));
    ThermoPower.Gas.SourcePressure SourceP1(redeclare package Medium = Media.Air, T = 244.4, p0 = 0.343e5) annotation(
      Placement(transformation(origin = {-108, -24}, extent = {{-188, -30}, {-168, -10}})));
    ThermoPower.Gas.SourceMassFlow SourceW1(redeclare package Medium = Media.NaturalGas, T = 300, p0 = 811000, use_in_w0 = true, w0 = 2.02, use_in_T = true, use_in_X = true) annotation(
      Placement(transformation(origin = {-108, -24}, extent = {{-100, 70}, {-80, 90}})));
    ThermoPower.Gas.PressDrop PressDrop1(FFtype = Choices.PressDrop.FFtypes.OpPoint, redeclare package Medium = Media.FlueGas, Tstart = 1370, dpnom = 26000, pstart = 811000, rhonom = 2, wnom = 102) annotation(
      Placement(transformation(origin = {-108, -16}, extent = {{-10, -10}, {10, 10}}, rotation = 270)));
    ThermoPower.Gas.PressDrop PressDrop2(A = 1, FFtype = Choices.PressDrop.FFtypes.OpPoint, redeclare package Medium = Media.Air, Tstart = 600, dpnom = 0.19e5, pstart = 8.3e5, rhonom = 4.7, wnom = 100) annotation(
      Placement(transformation(origin = {-212, -14}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
    Modelica.Mechanics.Rotational.Sensors.PowerSensor powerSensor annotation(
      Placement(transformation(origin = {-102, -31}, extent = {{54, -63}, {72, -45}})));
    Modelica.Blocks.Continuous.FirstOrder powerSensor1(T = T, initType = Modelica.Blocks.Types.Init.SteadyState, k = 1, y_start = 56.8e6) annotation(
      Placement(transformation(origin = {-253, 133}, extent = {{219, -177}, {243, -153}})));
    ThermoPower.PowerPlants.HRSG.Components.StateReader_gas stateInletCC(redeclare package Medium = Media.Air) annotation(
      Placement(transformation(origin = {-108, -24}, extent = {{-100, 30}, {-80, 50}})));
    ThermoPower.PowerPlants.HRSG.Components.StateReader_gas stateOutletCC(redeclare package Medium = Media.FlueGas) annotation(
      Placement(transformation(origin = {-108, -24}, extent = {{-24, 30}, {-4, 50}})));
    inner ThermoPower.System system(allowFlowReversal = false) annotation(
      Placement(transformation(origin = {-279.6, -88}, extent = {{189.6, 192}, {213.6, 216}})));
    Examples.HRB.Models.Evaporator evaporator annotation(
      Placement(transformation(origin = {78, -36}, extent = {{-10, -10}, {10, 10}})));
    PowerPlants.HRSG.Components.HE superheater annotation(
      Placement(transformation(origin = {78, 46}, extent = {{-10, -10}, {10, 10}})));
    PowerPlants.HRSG.Components.HE economizer annotation(
      Placement(transformation(origin = {78, -124}, extent = {{-14, -14}, {14, 14}})));
    Water.SteamTurbineStodola steamTurbine(redeclare package Medium = Water) annotation(
      Placement(transformation(origin = {138, 16}, extent = {{-10, -10}, {10, 10}})));
    Examples.RankineCycle.Models.PrescribedPressureCondenser prescribedPressureCondenser(p = 5390) annotation(
      Placement(transformation(origin = {180, -72}, extent = {{-10, -10}, {10, 10}})));
    PowerPlants.HRSG.Components.PrescribedSpeedPump prescribedSpeedPump annotation(
      Placement(transformation(origin = {144, -170}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
    Examples.RankineCycle.Models.PID pid annotation(
      Placement(transformation(origin = {-54, -168}, extent = {{-10, -10}, {10, 10}})));
    Gas.SinkP sinkP_gas annotation(
      Placement(transformation(origin = {146, -124}, extent = {{-16, -14}, {16, 14}})));
    Electrical.Generator generator_steam annotation(
      Placement(transformation(origin = {246, 16}, extent = {{-10, -10}, {10, 10}})));
    Modelica.Blocks.Interfaces.RealOutput voidFraction annotation(
      Placement(transformation(origin = {274, -46}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {308, -84}, extent = {{-10, -10}, {10, 10}})));
    Modelica.Blocks.Interfaces.RealOutput generatedpower annotation(
      Placement(transformation(origin = {298, 66}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {272, 90}, extent = {{-10, -10}, {10, 10}})));
    Modelica.Blocks.Sources.Step fuelsource annotation(
      Placement(transformation(origin = {-353, 71}, extent = {{-19, -19}, {19, 19}})));
    Modelica.Blocks.Sources.Step voidFractionSetPoint annotation(
      Placement(transformation(origin = {-141, -153}, extent = {{-21, -21}, {21, 21}})));
    Modelica.Blocks.Interfaces.RealInput nPump annotation(
      Placement(transformation(origin = {-2, -150}, extent = {{-20, -20}, {20, 20}}), iconTransformation(origin = {10, -154}, extent = {{-20, -20}, {20, 20}})));
    PowerPlants.HRSG.Components.StateReader_gas stateReader_gas annotation(
      Placement(transformation(origin = {110, -124}, extent = {{-10, -10}, {10, 10}})));
    PowerPlants.HRSG.Components.StateReader_gas stateReader_gas1 annotation(
      Placement(transformation(origin = {44, -128}, extent = {{-10, -10}, {10, 10}})));
    PowerPlants.HRSG.Components.StateReader_water stateReader_water annotation(
      Placement(transformation(origin = {78, -80}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
    PowerPlants.HRSG.Components.StateReader_water stateReader_water1 annotation(
      Placement(transformation(origin = {78, -2}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
    PowerPlants.HRSG.Components.StateReader_water stateReader_water2 annotation(
      Placement(transformation(origin = {78, 82}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
    PowerPlants.HRSG.Components.StateReader_gas stateReader_gas2 annotation(
      Placement(transformation(origin = {50, -36}, extent = {{-10, -10}, {10, 10}})));
    PowerPlants.HRSG.Components.StateReader_gas stateReader_gas3 annotation(
      Placement(transformation(origin = {2, 46}, extent = {{-10, -10}, {10, 10}})));
    Modelica.Mechanics.Rotational.Sensors.PowerSensor powerSensor2 annotation(
      Placement(transformation(origin = {192, 16}, extent = {{-10, -10}, {10, 10}})));
    Modelica.Blocks.Continuous.FirstOrder firstOrder(T = 1) annotation(
      Placement(transformation(origin = {240, 66}, extent = {{-14, -14}, {14, 14}})));
  equation
    connect(SourceW1.flange, CombustionChamber1.inf) annotation(
      Line(points = {{-188, 56}, {-160, 56}, {-160, 36}}, color = {159, 159, 223}, thickness = 0.5));
    connect(SourceP1.flange, compressor.inlet) annotation(
      Line(points = {{-276, -44}, {-260, -44}, {-260, -60}}, color = {159, 159, 223}, thickness = 0.5));
    connect(PressDrop1.outlet, turbine.inlet) annotation(
      Line(points = {{-108, -26}, {-108, -60}, {-108, -60}}, color = {159, 159, 223}, thickness = 0.5));
    connect(compressor.outlet, PressDrop2.inlet) annotation(
      Line(points = {{-212, -60}, {-212, -24}}, color = {159, 159, 223}, thickness = 0.5));
    connect(compressor.shaft_b, turbine.shaft_a) annotation(
      Line(points = {{-218, -84}, {-102, -84}}, thickness = 0.5));
    connect(powerSensor.flange_a, turbine.shaft_b) annotation(
      Line(points = {{-48, -85}, {-57, -85}, {-57, -84}, {-66, -84}}, thickness = 0.5));
    connect(powerSensor.power, powerSensor1.u) annotation(
      Line(points = {{-46, -95}, {-46, -32}, {-36, -32}}, color = {0, 0, 127}));
    connect(powerSensor1.y, generatedPower) annotation(
      Line(points = {{-9, -32}, {5.5, -32}, {5.5, -18}, {20, -18}}, color = {0, 0, 127}));
    connect(CombustionChamber1.ina, stateInletCC.outlet) annotation(
      Line(points = {{-180, 16}, {-192, 16}}, color = {159, 159, 223}, thickness = 0.5));
    connect(stateInletCC.inlet, PressDrop2.outlet) annotation(
      Line(points = {{-204, 16}, {-212, 16}, {-212, -4}}, color = {159, 159, 223}, thickness = 0.5));
    connect(stateOutletCC.inlet, CombustionChamber1.out) annotation(
      Line(points = {{-128, 16}, {-140, 16}}, color = {159, 159, 223}, thickness = 0.5));
    connect(stateOutletCC.outlet, PressDrop1.inlet) annotation(
      Line(points = {{-116, 16}, {-108, 16}, {-108, -6}}, color = {159, 159, 223}, thickness = 0.5));
    connect(generator.shaft, powerSensor.flange_b) annotation(
      Line(points = {{-13.2, -84}, {-20.6, -84}, {-20.6, -85}, {-30, -85}}, thickness = 0.5));
    connect(fuelFlowRate, SourceW1.in_w0) annotation(
      Line(points = {{-268, 62}, {-204, 62}}, color = {0, 0, 127}));
    connect(fuelsource.y, fuelFlowRate) annotation(
      Line(points = {{-332, 71}, {-300.5, 71}, {-300.5, 62}, {-268, 62}}, color = {0, 0, 127}));
    connect(voidFractionSetPoint.y, pid.SP) annotation(
      Line(points = {{-118, -153}, {-91.5, -153}, {-91.5, -164}, {-64, -164}}, color = {0, 0, 127}));
    connect(pid.CS, nPump) annotation(
      Line(points = {{-44, -168}, {-25, -168}, {-25, -150}, {-2, -150}}, color = {0, 0, 127}));
    connect(prescribedSpeedPump.inlet, prescribedPressureCondenser.waterOut) annotation(
      Line(points = {{154, -170}, {180, -170}, {180, -82}}, color = {0, 0, 255}, thickness = 1.5));
    connect(prescribedSpeedPump.outlet, economizer.waterOut) annotation(
      Line(points = {{134, -170}, {78, -170}, {78, -138}}, color = {0, 0, 255}, thickness = 1.5));
    connect(prescribedPressureCondenser.steamIn, steamTurbine.outlet) annotation(
      Line(points = {{180, -62}, {164, -62}, {164, 77}, {146, 77}, {146, 24}}, color = {0, 0, 255}, thickness = 1.5));
    connect(economizer.gasIn, stateReader_gas1.outlet) annotation(
      Line(points = {{64, -124}, {61, -124}, {61, -128}, {50, -128}}, color = {159, 159, 223}, thickness = 1.5));
    connect(evaporator.waterOut, stateReader_water.inlet) annotation(
      Line(points = {{78, -46}, {78, -74}}, color = {0, 0, 255}, thickness = 1.5));
    connect(stateReader_water.outlet, economizer.waterIn) annotation(
      Line(points = {{78, -86}, {78, -110}}, color = {0, 0, 255}, thickness = 1.5));
    connect(superheater.waterOut, stateReader_water1.inlet) annotation(
      Line(points = {{78, 36}, {78, 4}}, color = {0, 0, 255}, thickness = 1.5));
    connect(stateReader_water1.outlet, evaporator.waterIn) annotation(
      Line(points = {{78, -8}, {78, -26}}, color = {0, 0, 255}, thickness = 1.5));
    connect(stateReader_water2.outlet, superheater.waterIn) annotation(
      Line(points = {{78, 76}, {78, 56}}, color = {0, 0, 255}, thickness = 1.5));
    connect(stateReader_water2.inlet, steamTurbine.inlet) annotation(
      Line(points = {{78, 88}, {130, 88}, {130, 24}}, color = {0, 0, 255}, thickness = 1.5));
    connect(evaporator.gasIn, stateReader_gas2.outlet) annotation(
      Line(points = {{68, -36}, {56, -36}}, color = {159, 159, 223}, thickness = 1.5));
    connect(stateReader_gas2.inlet, superheater.gasOut) annotation(
      Line(points = {{44, -36}, {44, 22}, {98, 22}, {98, 46}, {88, 46}}, color = {159, 159, 223}, thickness = 1.5));
    connect(evaporator.gasOut, stateReader_gas1.inlet) annotation(
      Line(points = {{88, -36}, {102, -36}, {102, -94}, {26, -94}, {26, -128}, {38, -128}}, color = {159, 159, 223}, thickness = 1.5));
    connect(superheater.gasIn, stateReader_gas3.outlet) annotation(
      Line(points = {{68, 46}, {8, 46}}, color = {159, 159, 223}, thickness = 1.5));
    connect(stateReader_gas3.inlet, turbine.outlet) annotation(
      Line(points = {{-4, 46}, {-60, 46}, {-60, -60}}, color = {159, 159, 223}, thickness = 1.5));
    connect(pid.PV, voidFraction) annotation(
      Line(points = {{-64, -172}, {-92, -172}, {-92, -206}, {312, -206}, {312, -46}, {274, -46}}, color = {0, 0, 127}));
    connect(evaporator.voidFraction, voidFraction) annotation(
      Line(points = {{89, -30}, {246, -30}, {246, -46}, {274, -46}}, color = {0, 0, 127}));
    connect(steamTurbine.shaft_b, powerSensor2.flange_a) annotation(
      Line(points = {{144, 16}, {182, 16}}));
    connect(powerSensor2.flange_b, generator_steam.shaft) annotation(
      Line(points = {{202, 16}, {237, 16}}));
    connect(firstOrder.y, generatedpower) annotation(
      Line(points = {{255, 66}, {298, 66}}, color = {0, 0, 127}));
    connect(powerSensor2.power, firstOrder.u) annotation(
      Line(points = {{184, 6}, {184, 66}, {223, 66}}, color = {0, 0, 127}));
    connect(nPump, prescribedSpeedPump.pumpSpeed_rpm) annotation(
      Line(points = {{-2, -150}, {28, -150}, {28, -186}, {206, -186}, {206, -176}, {152, -176}}, color = {0, 0, 127}));
    connect(economizer.gasOut, stateReader_gas.inlet) annotation(
      Line(points = {{92, -124}, {104, -124}}, color = {159, 159, 223}, thickness = 1.5));
    connect(sinkP_gas.flange, stateReader_gas.outlet) annotation(
      Line(points = {{130, -124}, {116, -124}}, color = {159, 159, 223}, thickness = 1.5));
    annotation(
      Diagram);
  end MyCombinedCycleModel;

  model MyCombinedCycleModel_Simple
    Electrical.Generator generator(Pnom = 4e6, initOpt = Choices.Init.Options.steadyState) annotation(
      Placement(transformation(origin = {-108, -24}, extent = {{92, -80}, {132, -40}})));
    Modelica.Blocks.Interfaces.RealInput fuelFlowRate annotation(
      Placement(transformation(origin = {-68, 62}, extent = {{-210, -10}, {-190, 10}}), iconTransformation(origin = {162, -142}, extent = {{-210, -10}, {-190, 10}})));
    Modelica.Blocks.Interfaces.RealOutput generatedPower annotation(
      Placement(transformation(origin = {-186, -18}, extent = {{196, -10}, {216, 10}}), iconTransformation(origin = {162, -142}, extent = {{196, -10}, {216, 10}})));
    Gas.Compressor compressor(redeclare package Medium = Media.Air, Ndesign = 157.08, Table = Choices.TurboMachinery.TableTypes.matrix, Tdes_in = 244.4, Tstart_in = 244.4, Tstart_out = 600.4, explicitIsentropicEnthalpy = true, pstart_in = 0.343e5, pstart_out = 8.3e5, tableEta = tableEtaC, tablePR = tablePR, tablePhic = tablePhicC) annotation(
      Placement(transformation(origin = {-108, -24}, extent = {{-158, -90}, {-98, -30}})));
    Gas.Turbine turbine(redeclare package Medium = Media.FlueGas, Ndesign = 157.08, Table = Choices.TurboMachinery.TableTypes.matrix, Tdes_in = 1400, Tstart_in = 1370, Tstart_out = 800, pstart_in = 7.85e5, pstart_out = 1.52e5, tableEta = tableEtaT, tablePhic = tablePhicT) annotation(
      Placement(transformation(origin = {-108, -24}, extent = {{-6, -90}, {54, -30}})));
    Gas.CombustionChamber CombustionChamber1(Cm = 1, HH = 41.6e6, S = 0.05, Tstart = 1370, V = 0.05, gamma = 1, initOpt = Choices.Init.Options.steadyState, pstart = 8.11e5) annotation(
      Placement(transformation(origin = {-108, -24}, extent = {{-72, 20}, {-32, 60}})));
    Gas.SourcePressure SourceP1(redeclare package Medium = Media.Air, T = 244.4, p0 = 0.343e5) annotation(
      Placement(transformation(origin = {-108, -24}, extent = {{-188, -30}, {-168, -10}})));
    Gas.SourceMassFlow SourceW1(redeclare package Medium = Media.NaturalGas, T = 300, p0 = 811000, use_in_w0 = true, w0 = 2.02, use_in_T = true, use_in_X = true) annotation(
      Placement(transformation(origin = {-108, -24}, extent = {{-100, 70}, {-80, 90}})));
    Gas.PressDrop PressDrop1(FFtype = Choices.PressDrop.FFtypes.OpPoint, redeclare package Medium = Media.FlueGas, Tstart = 1370, dpnom = 26000, pstart = 811000, rhonom = 2, wnom = 102) annotation(
      Placement(transformation(origin = {-108, -16}, extent = {{-10, -10}, {10, 10}}, rotation = 270)));
    Gas.PressDrop PressDrop2(A = 1, FFtype = Choices.PressDrop.FFtypes.OpPoint, redeclare package Medium = Media.Air, Tstart = 600, dpnom = 0.19e5, pstart = 8.3e5, rhonom = 4.7, wnom = 100) annotation(
      Placement(transformation(origin = {-212, -14}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
    Modelica.Mechanics.Rotational.Sensors.PowerSensor powerSensor annotation(
      Placement(transformation(origin = {-102, -31}, extent = {{54, -63}, {72, -45}})));
    Modelica.Blocks.Continuous.FirstOrder powerSensor1(T = T, initType = Modelica.Blocks.Types.Init.SteadyState, k = 1, y_start = 56.8e6) annotation(
      Placement(transformation(origin = {-253, 133}, extent = {{219, -177}, {243, -153}})));
    PowerPlants.HRSG.Components.StateReader_gas stateInletCC(redeclare package Medium = Media.Air) annotation(
      Placement(transformation(origin = {-108, -24}, extent = {{-100, 30}, {-80, 50}})));
    PowerPlants.HRSG.Components.StateReader_gas stateOutletCC(redeclare package Medium = Media.FlueGas) annotation(
      Placement(transformation(origin = {-108, -24}, extent = {{-24, 30}, {-4, 50}})));
    inner System system(allowFlowReversal = false) annotation(
      Placement(transformation(origin = {-279.6, -88}, extent = {{189.6, 192}, {213.6, 216}})));
    Examples.HRB.Models.Evaporator evaporator annotation(
      Placement(transformation(origin = {78, -74}, extent = {{-10, -10}, {10, 10}})));
    PowerPlants.HRSG.Components.HE superheater annotation(
      Placement(transformation(origin = {78, 46}, extent = {{-10, -10}, {10, 10}})));
    Water.SteamTurbineStodola steamTurbine(redeclare package Medium = Water) annotation(
      Placement(transformation(origin = {138, 16}, extent = {{-10, -10}, {10, 10}})));
    Examples.RankineCycle.Models.PrescribedPressureCondenser prescribedPressureCondenser annotation(
      Placement(transformation(origin = {180, -72}, extent = {{-10, -10}, {10, 10}})));
    PowerPlants.HRSG.Components.PrescribedSpeedPump prescribedSpeedPump annotation(
      Placement(transformation(origin = {144, -170}, extent = {{-10, -10}, {10, 10}}, rotation = 180)));
    Examples.RankineCycle.Models.PID pid annotation(
      Placement(transformation(origin = {-54, -168}, extent = {{-10, -10}, {10, 10}})));
    Gas.SinkP sinkP_gas annotation(
      Placement(transformation(origin = {148, -108}, extent = {{-16, -14}, {16, 14}})));
    Electrical.Generator generator_steam annotation(
      Placement(transformation(origin = {246, 16}, extent = {{-10, -10}, {10, 10}})));
    Modelica.Blocks.Interfaces.RealOutput voidFraction annotation(
      Placement(transformation(origin = {274, -46}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {308, -84}, extent = {{-10, -10}, {10, 10}})));
    Modelica.Blocks.Interfaces.RealOutput generatedpower annotation(
      Placement(transformation(origin = {298, 66}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {272, 90}, extent = {{-10, -10}, {10, 10}})));
    Modelica.Blocks.Sources.Step fuelsource annotation(
      Placement(transformation(origin = {-353, 71}, extent = {{-19, -19}, {19, 19}})));
    Modelica.Blocks.Sources.Step voidFractionSetPoint annotation(
      Placement(transformation(origin = {-141, -153}, extent = {{-21, -21}, {21, 21}})));
    Modelica.Blocks.Interfaces.RealInput nPump annotation(
      Placement(transformation(origin = {-2, -150}, extent = {{-20, -20}, {20, 20}}), iconTransformation(origin = {10, -154}, extent = {{-20, -20}, {20, 20}})));
    PowerPlants.HRSG.Components.StateReader_gas stateReader_gas annotation(
      Placement(transformation(origin = {106, -74}, extent = {{-10, -10}, {10, 10}})));
    PowerPlants.HRSG.Components.StateReader_water stateReader_water annotation(
      Placement(transformation(origin = {78, -104}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
    PowerPlants.HRSG.Components.StateReader_water stateReader_water1 annotation(
      Placement(transformation(origin = {78, -2}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
    PowerPlants.HRSG.Components.StateReader_water stateReader_water2 annotation(
      Placement(transformation(origin = {78, 82}, extent = {{-10, -10}, {10, 10}}, rotation = -90)));
    PowerPlants.HRSG.Components.StateReader_gas stateReader_gas2 annotation(
      Placement(transformation(origin = {48, -46}, extent = {{-10, -10}, {10, 10}})));
    PowerPlants.HRSG.Components.StateReader_gas stateReader_gas3 annotation(
      Placement(transformation(origin = {2, 46}, extent = {{-10, -10}, {10, 10}})));
    Modelica.Mechanics.Rotational.Sensors.PowerSensor powerSensor2 annotation(
      Placement(transformation(origin = {192, 16}, extent = {{-10, -10}, {10, 10}})));
    Modelica.Blocks.Continuous.FirstOrder firstOrder(T = 1) annotation(
      Placement(transformation(origin = {240, 66}, extent = {{-14, -14}, {14, 14}})));
  equation
    connect(SourceW1.flange, CombustionChamber1.inf) annotation(
      Line(points = {{-188, 56}, {-160, 56}, {-160, 36}}, color = {159, 159, 223}, thickness = 0.5));
    connect(SourceP1.flange, compressor.inlet) annotation(
      Line(points = {{-276, -44}, {-260, -44}, {-260, -60}}, color = {159, 159, 223}, thickness = 0.5));
    connect(PressDrop1.outlet, turbine.inlet) annotation(
      Line(points = {{-108, -26}, {-108, -60}, {-108, -60}}, color = {159, 159, 223}, thickness = 0.5));
    connect(compressor.outlet, PressDrop2.inlet) annotation(
      Line(points = {{-212, -60}, {-212, -24}}, color = {159, 159, 223}, thickness = 0.5));
    connect(compressor.shaft_b, turbine.shaft_a) annotation(
      Line(points = {{-218, -84}, {-102, -84}}, thickness = 0.5));
    connect(powerSensor.flange_a, turbine.shaft_b) annotation(
      Line(points = {{-48, -85}, {-57, -85}, {-57, -84}, {-66, -84}}, thickness = 0.5));
    connect(powerSensor.power, powerSensor1.u) annotation(
      Line(points = {{-46, -95}, {-46, -32}, {-36, -32}}, color = {0, 0, 127}));
    connect(powerSensor1.y, generatedPower) annotation(
      Line(points = {{-9, -32}, {5.5, -32}, {5.5, -18}, {20, -18}}, color = {0, 0, 127}));
    connect(CombustionChamber1.ina, stateInletCC.outlet) annotation(
      Line(points = {{-180, 16}, {-192, 16}}, color = {159, 159, 223}, thickness = 0.5));
    connect(stateInletCC.inlet, PressDrop2.outlet) annotation(
      Line(points = {{-204, 16}, {-212, 16}, {-212, -4}}, color = {159, 159, 223}, thickness = 0.5));
    connect(stateOutletCC.inlet, CombustionChamber1.out) annotation(
      Line(points = {{-128, 16}, {-140, 16}}, color = {159, 159, 223}, thickness = 0.5));
    connect(stateOutletCC.outlet, PressDrop1.inlet) annotation(
      Line(points = {{-116, 16}, {-108, 16}, {-108, -6}}, color = {159, 159, 223}, thickness = 0.5));
    connect(generator.shaft, powerSensor.flange_b) annotation(
      Line(points = {{-13.2, -84}, {-20.6, -84}, {-20.6, -85}, {-30, -85}}, thickness = 0.5));
    connect(fuelFlowRate, SourceW1.in_w0) annotation(
      Line(points = {{-268, 62}, {-204, 62}}, color = {0, 0, 127}));
    connect(fuelsource.y, fuelFlowRate) annotation(
      Line(points = {{-332, 71}, {-300.5, 71}, {-300.5, 62}, {-268, 62}}, color = {0, 0, 127}));
    connect(voidFractionSetPoint.y, pid.SP) annotation(
      Line(points = {{-118, -153}, {-91.5, -153}, {-91.5, -164}, {-64, -164}}, color = {0, 0, 127}));
    connect(pid.CS, nPump) annotation(
      Line(points = {{-44, -168}, {-25, -168}, {-25, -150}, {-2, -150}}, color = {0, 0, 127}));
    connect(prescribedSpeedPump.inlet, prescribedPressureCondenser.waterOut) annotation(
      Line(points = {{154, -170}, {180, -170}, {180, -82}}, color = {0, 0, 255}, thickness = 1.5));
    connect(prescribedPressureCondenser.steamIn, steamTurbine.outlet) annotation(
      Line(points = {{180, -62}, {164, -62}, {164, 77}, {146, 77}, {146, 24}}, color = {0, 0, 255}, thickness = 1.5));
    connect(evaporator.waterOut, stateReader_water.inlet) annotation(
      Line(points = {{78, -84}, {78, -98}}, color = {0, 0, 255}, thickness = 1.5));
    connect(superheater.waterOut, stateReader_water1.inlet) annotation(
      Line(points = {{78, 36}, {78, 4}}, color = {0, 0, 255}, thickness = 1.5));
    connect(stateReader_water1.outlet, evaporator.waterIn) annotation(
      Line(points = {{78, -8}, {78, -64}}, color = {0, 0, 255}, thickness = 1.5));
    connect(stateReader_water2.outlet, superheater.waterIn) annotation(
      Line(points = {{78, 76}, {78, 56}}, color = {0, 0, 255}, thickness = 1.5));
    connect(stateReader_water2.inlet, steamTurbine.inlet) annotation(
      Line(points = {{78, 88}, {130, 88}, {130, 24}}, color = {0, 0, 255}, thickness = 1.5));
    connect(evaporator.gasIn, stateReader_gas2.outlet) annotation(
      Line(points = {{68, -74}, {62, -74}, {62, -46}, {54, -46}}, color = {159, 159, 223}, thickness = 1.5));
    connect(stateReader_gas2.inlet, superheater.gasOut) annotation(
      Line(points = {{42, -46}, {42, 22}, {98, 22}, {98, 46}, {88, 46}}, color = {159, 159, 223}, thickness = 1.5));
    connect(superheater.gasIn, stateReader_gas3.outlet) annotation(
      Line(points = {{68, 46}, {8, 46}}, color = {159, 159, 223}, thickness = 1.5));
    connect(stateReader_gas3.inlet, turbine.outlet) annotation(
      Line(points = {{-4, 46}, {-60, 46}, {-60, -60}}, color = {159, 159, 223}, thickness = 1.5));
    connect(pid.PV, voidFraction) annotation(
      Line(points = {{-64, -172}, {-92, -172}, {-92, -206}, {312, -206}, {312, -46}, {274, -46}}, color = {0, 0, 127}));
    connect(steamTurbine.shaft_b, powerSensor2.flange_a) annotation(
      Line(points = {{144, 16}, {182, 16}}));
    connect(powerSensor2.flange_b, generator_steam.shaft) annotation(
      Line(points = {{202, 16}, {237, 16}}));
    connect(firstOrder.y, generatedpower) annotation(
      Line(points = {{255, 66}, {298, 66}}, color = {0, 0, 127}));
    connect(powerSensor2.power, firstOrder.u) annotation(
      Line(points = {{184, 6}, {184, 66}, {223, 66}}, color = {0, 0, 127}));
    connect(nPump, prescribedSpeedPump.pumpSpeed_rpm) annotation(
      Line(points = {{-2, -150}, {28, -150}, {28, -186}, {206, -186}, {206, -176}, {152, -176}}, color = {0, 0, 127}));
    connect(sinkP_gas.flange, stateReader_gas.outlet) annotation(
      Line(points = {{132, -108}, {123, -108}, {123, -74}, {112, -74}}, color = {159, 159, 223}, thickness = 1.5));
    connect(stateReader_water.outlet, prescribedSpeedPump.outlet) annotation(
      Line(points = {{78, -110}, {78, -170}, {134, -170}}, color = {0, 0, 255}));
    connect(evaporator.gasOut, stateReader_gas.inlet) annotation(
      Line(points = {{88, -74}, {100, -74}}, color = {159, 159, 223}, thickness = 1.5));
    connect(evaporator.voidFraction, voidFraction) annotation(
      Line(points = {{88, -68}, {116, -68}, {116, -46}, {274, -46}}, color = {0, 0, 127}));
    annotation(
      Diagram);
  end MyCombinedCycleModel_Simple;

  model MyCombinedCyclePlant_2
    import ThermoPower;
    parameter Real tableEtaC[6, 4] = [0, 95, 100, 105; 1, 82.5e-2, 81e-2, 80.5e-2; 2, 84e-2, 82.9e-2, 82e-2; 3, 83.2e-2, 82.2e-2, 81.5e-2; 4, 82.5e-2, 81.2e-2, 79e-2; 5, 79.5e-2, 78e-2, 76.5e-2];
    parameter Real tablePhicC[6, 4] = [0, 95, 100, 105; 1, 38.3e-3, 43e-3, 46.8e-3; 2, 39.3e-3, 43.8e-3, 47.9e-3; 3, 40.6e-3, 45.2e-3, 48.4e-3; 4, 41.6e-3, 46.1e-3, 48.9e-3; 5, 42.3e-3, 46.6e-3, 49.3e-3];
    parameter Real tablePR[6, 4] = [0, 95, 100, 105; 1, 22.6, 27, 32; 2, 22, 26.6, 30.8; 3, 20.8, 25.5, 29; 4, 19, 24.3, 27.1; 5, 17, 21.5, 24.2];
    parameter Real tablePhicT[5, 4] = [1, 90, 100, 110; 2.36, 4.68e-3, 4.68e-3, 4.68e-3; 2.88, 4.68e-3, 4.68e-3, 4.68e-3; 3.56, 4.68e-3, 4.68e-3, 4.68e-3; 4.46, 4.68e-3, 4.68e-3, 4.68e-3];
    parameter Real tableEtaT[5, 4] = [1, 90, 100, 110; 2.36, 89e-2, 89.5e-2, 89.3e-2; 2.88, 90e-2, 90.6e-2, 90.5e-2; 3.56, 90.5e-2, 90.6e-2, 90.5e-2; 4.46, 90.2e-2, 90.3e-2, 90e-2];
    replaceable package FlueGas = ThermoPower.Media.FlueGas constrainedby Modelica.Media.Interfaces.PartialMedium "Flue gas model";
    replaceable package Water = ThermoPower.Water.StandardWater constrainedby Modelica.Media.Interfaces.PartialPureSubstance "Fluid model";
    ThermoPower.Examples.RankineCycle.Models.PrescribedPressureCondenser condenser(p = 5390, redeclare package Medium = Water, initOpt = ThermoPower.Choices.Init.Options.fixedState) annotation(
      Placement(transformation(extent = {{100, -100}, {140, -60}}, rotation = 0)));
    ThermoPower.Examples.RankineCycle.Models.PrescribedSpeedPump prescribedSpeedPump(n0 = 1500, nominalMassFlowRate = 55, q_nom = {0, 0.055, 0.1}, redeclare package FluidMedium = Water, head_nom = {450, 300, 0}, rho0 = 1000, nominalOutletPressure = 3000000, nominalInletPressure = 50000) annotation(
      Placement(transformation(extent = {{40, -180}, {0, -140}}, rotation = 0)));
    Modelica.Blocks.Continuous.FirstOrder powerSensor(k = 1, T = 1, y_start = 56.8e6, initType = Modelica.Blocks.Types.Init.SteadyState) annotation(
      Placement(transformation(extent = {{240, 90}, {260, 110}}, rotation = 0)));
    Modelica.Blocks.Interfaces.RealOutput generatedPower annotation(
      Placement(transformation(extent = {{290, 90}, {310, 110}}, rotation = 0), iconTransformation(extent = {{92, 30}, {112, 50}})));
    Modelica.Blocks.Interfaces.RealInput nPump annotation(
      Placement(transformation(extent = {{-310, -110}, {-290, -90}}, rotation = 0), iconTransformation(extent = {{-108, -70}, {-88, -50}})));
    Modelica.Blocks.Interfaces.RealOutput voidFraction annotation(
      Placement(transformation(extent = {{290, -110}, {310, -90}}, rotation = 0), iconTransformation(extent = {{92, -50}, {112, -30}})));
    Modelica.Blocks.Continuous.FirstOrder voidFractionSensor(k = 1, T = 1, initType = Modelica.Blocks.Types.Init.SteadyState, y_start = 0.2) annotation(
      Placement(transformation(extent = {{240, -110}, {260, -90}}, rotation = 0)));
    ThermoPower.Water.SteamTurbineStodola steamTurbine(wstart = 55, wnom = 55, Kt = 0.0104, redeclare package Medium = Water, PRstart = 30, pnom = 3000000) annotation(
      Placement(transformation(extent = {{50, 30}, {100, 80}}, rotation = 0)));
    Modelica.Mechanics.Rotational.Sensors.PowerSensor powerSensor1 annotation(
      Placement(transformation(extent = {{138, 68}, {166, 40}}, rotation = 0)));
    ThermoPower.Examples.RankineCycle.Models.HE economizer(redeclare package FluidMedium = Water, redeclare package FlueGasMedium = FlueGas, N_F = 6, exchSurface_G = 40095.9, exchSurface_F = 3439.389, extSurfaceTub = 3888.449, gasVol = 10, fluidVol = 28.977, metalVol = 8.061, rhomcm = 7900*578.05, lambda = 20, gasNomFlowRate = 500, fluidNomFlowRate = 55, gamma_G = 30, gamma_F = 3000, rhonom_G = 1, Kfnom_F = 150, FFtype_G = ThermoPower.Choices.Flow1D.FFtypes.OpPoint, FFtype_F = ThermoPower.Choices.Flow1D.FFtypes.Kfnom, N_G = 6, gasNomPressure = 101325, fluidNomPressure = 3000000, Tstart_G = 473.15, Tstart_M = 423.15, dpnom_G = 1000, dpnom_F = 20000) annotation(
      Placement(transformation(extent = {{-120, -80}, {-80, -120}}, rotation = 0)));
    ThermoPower.Examples.HRB.Models.Evaporator evaporator(redeclare package FluidMedium = Water, redeclare package FlueGasMedium = FlueGas, gasVol = 10, fluidVol = 12.400, metalVol = 4.801, gasNomFlowRate = 500, fluidNomFlowRate = 55, N = 4, rhom = 7900, cm = 578.05, gamma = 85, exchSurface = 24402, gasNomPressure = 101325, fluidNomPressure = 3000000, Tstart = 623.15, FFtype_G = ThermoPower.Choices.Flow1D.FFtypes.OpPoint, dpnom_G = 1000, rhonom_G = 1) annotation(
      Placement(transformation(extent = {{-120, 0}, {-80, -40}}, rotation = 0)));
    ThermoPower.Examples.RankineCycle.Models.HE superheater(redeclare package FluidMedium = Water, redeclare package FlueGasMedium = FlueGas, N_F = 7, exchSurface_G = 2314.8, exchSurface_F = 450.218, extSurfaceTub = 504.652, gasVol = 10, fluidVol = 4.468, metalVol = 1.146, rhomcm = 7900*578.05, lambda = 20, gasNomFlowRate = 500, gamma_G = 90, gamma_F = 6000, fluidNomFlowRate = 55, rhonom_G = 1, Kfnom_F = 150, FluidPhaseStart = ThermoPower.Choices.FluidPhase.FluidPhases.Steam, FFtype_G = ThermoPower.Choices.Flow1D.FFtypes.OpPoint, FFtype_F = ThermoPower.Choices.Flow1D.FFtypes.Kfnom, N_G = 7, gasNomPressure = 101325, fluidNomPressure = 3000000, Tstart_G = 723.15, Tstart_M = 573.15, dpnom_G = 1000, dpnom_F = 20000) annotation(
      Placement(transformation(extent = {{-120, 80}, {-80, 40}}, rotation = 0)));
    ThermoPower.PowerPlants.HRSG.Components.StateReader_gas stateGasInlet(redeclare package Medium = FlueGas) annotation(
      Placement(transformation(extent = {{-150, 50}, {-130, 70}}, rotation = 0)));
    ThermoPower.PowerPlants.HRSG.Components.StateReader_gas stateGasInletEvaporator(redeclare package Medium = FlueGas) annotation(
      Placement(transformation(extent = {{-150, -30}, {-130, -10}}, rotation = 0)));
    ThermoPower.PowerPlants.HRSG.Components.StateReader_gas stateGasInletEconomizer(redeclare package Medium = FlueGas) annotation(
      Placement(transformation(extent = {{-150, -110}, {-130, -90}}, rotation = 0)));
    ThermoPower.PowerPlants.HRSG.Components.StateReader_gas stateGasOutlet(redeclare package Medium = FlueGas) annotation(
      Placement(transformation(extent = {{-70, -110}, {-50, -90}}, rotation = 0)));
    ThermoPower.PowerPlants.HRSG.Components.StateReader_water stateWaterSuperheater_in(redeclare package Medium = Water) annotation(
      Placement(transformation(origin = {-100, 20}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
    ThermoPower.PowerPlants.HRSG.Components.StateReader_water stateWaterSuperheater_out(redeclare package Medium = Water) annotation(
      Placement(transformation(origin = {-100, 102}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
    ThermoPower.PowerPlants.HRSG.Components.StateReader_water stateWaterEvaporator_in(redeclare package Medium = Water) annotation(
      Placement(transformation(origin = {-100, -60}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
    ThermoPower.PowerPlants.HRSG.Components.StateReader_water stateWaterEconomizer_in(redeclare package Medium = Water) annotation(
      Placement(transformation(origin = {-100, -140}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
    ThermoPower.Gas.SinkPressure sinkP_gas(T = 400, redeclare package Medium = FlueGas) annotation(
      Placement(transformation(extent = {{-40, -110}, {-20, -90}}, rotation = 0)));
    inner ThermoPower.System system(allowFlowReversal = false, initOpt = ThermoPower.Choices.Init.Options.steadyState) annotation(
      Placement(transformation(extent = {{240, 160}, {260, 180}})));
    Modelica.Mechanics.Rotational.Sources.ConstantSpeed constantSpeed(w_fixed = 157, phi(start = 0, fixed = true)) annotation(
      Placement(transformation(extent = {{200, 44}, {180, 64}})));
    Gas.Turbine turbine(Tdes_in = 1399.4, Ndesign = 157.08, tablePhic = tablePhicT, tableEta = tableEtaT, redeclare package Medium = Media.FlueGas, pstart_in = 785000, pstart_out = 152000, Tstart_in = 1370, Tstart_out = 800)  annotation(
      Placement(transformation(origin = {-330, 32}, extent = {{-26, -26}, {26, 26}})));
    Gas.Compressor compressor(redeclare package Medium = Media.Air, explicitIsentropicEnthalpy = true, Tdes_in = 244.4, Ndesign = 157.08, tablePhic = tablePhicC, tableEta = tableEtaC, tablePR = tablePR, pstart_in = 34300, pstart_out = 8.3e5, Tstart_in = 244.4, Tstart_out = 600.4)  annotation(
      Placement(transformation(origin = {-529, 31}, extent = {{-21, -21}, {21, 21}})));
    Gas.SourcePressure sourcePressure(redeclare package Medium = Media.Air, p0 = 34300, R = 0, T = 244.4)  annotation(
      Placement(transformation(origin = {-568, 76}, extent = {{-10, -10}, {10, 10}})));
    Gas.CombustionChamber combustionChamber(V = 0.05, S = 0.05, gamma = 1, Cm = 1, HH = 41.6e6, pstart = 811000, Tstart = 1370, initOpt = ThermoPower.Choices.Init.Options.steadyState)  annotation(
      Placement(transformation(origin = {-438, 132}, extent = {{-24, -24}, {24, 24}})));
  Modelica.Blocks.Interfaces.RealInput fuelflowrate annotation(
      Placement(transformation(origin = {-506, 194}, extent = {{-20, -20}, {20, 20}}), iconTransformation(origin = {-85, 47}, extent = {{-17, -17}, {17, 17}})));
  Gas.SourceMassFlow sourceMassFlow(use_in_w0 = true, use_in_T = false, use_in_X = false, redeclare package Medium = Media.NaturalGas, p0 = 811000, T = 300, w0 = 2.02)  annotation(
      Placement(transformation(origin = {-444, 182}, extent = {{-10, -10}, {10, 10}})));
  PowerPlants.HRSG.Components.StateReader_gas stateReader_gas(redeclare package Medium = Media.Air)  annotation(
      Placement(transformation(origin = {-486, 132}, extent = {{-10, -10}, {10, 10}})));
  PowerPlants.HRSG.Components.StateReader_gas stateReader_gas1(redeclare package Medium = Media.FlueGas)  annotation(
      Placement(transformation(origin = {-374, 132}, extent = {{-10, -10}, {10, 10}})));
  Gas.PressDrop pressDrop(redeclare package Medium = Media.Air, wnom = 100, dpnom = 19000, FFtype = ThermoPower.Choices.PressDrop.FFtypes.OpPoint, rhonom = 4.7, pstart = 8.3e5, Tstart = 600)  annotation(
      Placement(transformation(origin = {-498, 98}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
  Gas.PressDrop pressDrop1(redeclare package Medium = Media.FlueGas, wnom = 102, dpnom = 26000, FFtype = ThermoPower.Choices.PressDrop.FFtypes.OpPoint, rhonom = 2, pstart = 811000, Tstart = 1370)  annotation(
      Placement(transformation(origin = {-350, 96}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
  Electrical.Generator generator(Pnom = 4e6, initOpt = ThermoPower.Choices.Init.Options.steadyState)  annotation(
      Placement(transformation(origin = {-212, 32}, extent = {{-12, -12}, {12, 12}})));
  Modelica.Mechanics.Rotational.Sensors.PowerSensor powerSensor2 annotation(
      Placement(transformation(origin = {-267, 31}, extent = {{-13, -13}, {13, 13}})));
  Modelica.Blocks.Continuous.FirstOrder firstOrder(k = 1, T = 1, initType = Modelica.Blocks.Types.Init.SteadyState, y_start = 56.8e6)  annotation(
      Placement(transformation(origin = {-242, 94}, extent = {{-10, -10}, {10, 10}})));
  Modelica.Blocks.Interfaces.RealOutput generatedpower annotation(
      Placement(transformation(origin = {-200, 92}, extent = {{-10, -10}, {10, 10}}), iconTransformation(origin = {-138, 114}, extent = {{-10, -10}, {10, 10}})));
  equation
    connect(prescribedSpeedPump.inlet, condenser.waterOut) annotation(
      Line(points = {{40, -160}, {120, -160}, {120, -100}}, thickness = 0.5, color = {0, 0, 255}));
    connect(generatedPower, powerSensor.y) annotation(
      Line(points = {{300, 100}, {261, 100}}, color = {0, 0, 127}));
    connect(voidFraction, voidFractionSensor.y) annotation(
      Line(points = {{300, -100}, {261, -100}}, color = {0, 0, 127}));
    connect(powerSensor1.flange_a, steamTurbine.shaft_b) annotation(
      Line(points = {{138, 54}, {91, 54}, {91, 55}}, color = {0, 0, 0}, thickness = 0.5));
    connect(condenser.steamIn, steamTurbine.outlet) annotation(
      Line(points = {{120, -60}, {120, 75}, {95, 75}}, thickness = 0.5, color = {0, 0, 255}));
    connect(prescribedSpeedPump.outlet, stateWaterEconomizer_in.inlet) annotation(
      Line(points = {{0, -160}, {-100, -160}, {-100, -146}}, thickness = 0.5, color = {0, 0, 255}));
    connect(stateWaterEconomizer_in.outlet, economizer.waterIn) annotation(
      Line(points = {{-100, -134}, {-100, -120}}, thickness = 0.5));
    connect(economizer.waterOut, stateWaterEvaporator_in.inlet) annotation(
      Line(points = {{-100, -80}, {-100, -66}}, thickness = 0.5, color = {0, 0, 255}));
    connect(stateWaterEvaporator_in.outlet, evaporator.waterIn) annotation(
      Line(points = {{-100, -54}, {-100, -40}}, thickness = 0.5, color = {0, 0, 255}));
    connect(economizer.gasIn, stateGasInletEconomizer.outlet) annotation(
      Line(points = {{-120, -100}, {-128, -100}, {-134, -100}}, color = {159, 159, 223}, thickness = 0.5));
    connect(stateGasInletEconomizer.inlet, evaporator.gasOut) annotation(
      Line(points = {{-146, -100}, {-160, -100}, {-160, -50}, {-40, -50}, {-40, -20}, {-80, -20}}, color = {159, 159, 223}, thickness = 0.5));
    connect(sinkP_gas.flange, stateGasOutlet.outlet) annotation(
      Line(points = {{-40, -100}, {-54, -100}}, color = {159, 159, 223}, thickness = 0.5));
    connect(stateGasOutlet.inlet, economizer.gasOut) annotation(
      Line(points = {{-66, -100}, {-74, -100}, {-80, -100}}, color = {159, 159, 223}, thickness = 0.5));
    connect(evaporator.gasIn, stateGasInletEvaporator.outlet) annotation(
      Line(points = {{-120, -20}, {-134, -20}}, color = {159, 159, 223}, thickness = 0.5));
    connect(stateGasInletEvaporator.inlet, superheater.gasOut) annotation(
      Line(points = {{-146, -20}, {-160, -20}, {-160, 30}, {-40, 30}, {-40, 60}, {-80, 60}}, color = {159, 159, 223}, thickness = 0.5));
    connect(evaporator.waterOut, stateWaterSuperheater_in.inlet) annotation(
      Line(points = {{-100, 0}, {-100, 14}}, thickness = 0.5, color = {0, 0, 255}));
    connect(stateWaterSuperheater_in.outlet, superheater.waterIn) annotation(
      Line(points = {{-100, 26}, {-100, 40}}, thickness = 0.5, color = {0, 0, 255}));
    connect(superheater.waterOut, stateWaterSuperheater_out.inlet) annotation(
      Line(points = {{-100, 80}, {-100, 96}}, thickness = 0.5, color = {0, 0, 255}));
    connect(stateWaterSuperheater_out.outlet, steamTurbine.inlet) annotation(
      Line(points = {{-100, 108}, {-100, 120}, {55, 120}, {55, 75}}, thickness = 0.5, color = {0, 0, 255}));
    connect(superheater.gasIn, stateGasInlet.outlet) annotation(
      Line(points = {{-120, 60}, {-128, 60}, {-134, 60}}, color = {159, 159, 223}, thickness = 0.5));
    connect(powerSensor.u, powerSensor1.power) annotation(
      Line(points = {{238, 100}, {140.8, 100}, {140.8, 69.4}}, color = {0, 0, 127}));
    connect(voidFractionSensor.u, evaporator.voidFraction) annotation(
      Line(points = {{238, -100}, {200, -100}, {200, -32}, {-78.8, -32}}, color = {0, 0, 127}));
    connect(constantSpeed.flange, powerSensor1.flange_b) annotation(
      Line(points = {{180, 54}, {166, 54}}, color = {0, 0, 0}));
    connect(turbine.shaft_b, powerSensor2.flange_a) annotation(
      Line(points = {{-314, 32}, {-302, 32}, {-302, 31}, {-280, 31}}));
    connect(powerSensor2.flange_b, generator.shaft) annotation(
      Line(points = {{-254, 31}, {-254, 32}, {-222, 32}}));
    connect(firstOrder.y, generatedpower) annotation(
      Line(points = {{-230, 94}, {-220, 94}, {-220, 92}, {-200, 92}}, color = {0, 0, 127}));
    connect(powerSensor2.power, firstOrder.u) annotation(
      Line(points = {{-277, 17}, {-277, 94}, {-254, 94}}, color = {0, 0, 127}));
    connect(turbine.outlet, stateGasInlet.inlet) annotation(
      Line(points = {{-309, 53}, {-306, 53}, {-306, 122}, {-160, 122}, {-160, 60}, {-146, 60}}, color = {159, 159, 223}, thickness = 1.5));
    connect(pressDrop1.inlet, turbine.inlet) annotation(
      Line(points = {{-350, 86}, {-350, 73}, {-351, 73}, {-351, 53}}, color = {159, 159, 223}, thickness = 0.75));
    connect(stateReader_gas1.outlet, pressDrop1.outlet) annotation(
      Line(points = {{-368, 132}, {-350, 132}, {-350, 106}}, color = {159, 159, 223}, thickness = 0.75));
    connect(stateReader_gas1.inlet, combustionChamber.out) annotation(
      Line(points = {{-380, 132}, {-414, 132}}, color = {159, 159, 223}, thickness = 0.75));
    connect(combustionChamber.inf, sourceMassFlow.flange) annotation(
      Line(points = {{-438, 156}, {-438, 175}, {-434, 175}, {-434, 182}}, color = {159, 159, 223}, thickness = 0.75));
    connect(fuelflowrate, sourceMassFlow.in_w0) annotation(
      Line(points = {{-506, 194}, {-450, 194}, {-450, 188}}, color = {0, 0, 127}));
    connect(pressDrop.outlet, stateReader_gas.inlet) annotation(
      Line(points = {{-498, 108}, {-500, 108}, {-500, 132}, {-492, 132}}, color = {159, 159, 223}, thickness = 0.75));
    connect(compressor.outlet, pressDrop.inlet) annotation(
      Line(points = {{-512, 48}, {-500, 48}, {-500, 88}, {-498, 88}}, color = {159, 159, 223}, thickness = 0.75));
    connect(sourcePressure.flange, compressor.inlet) annotation(
      Line(points = {{-558, 76}, {-542, 76}, {-542, 48}, {-546, 48}}, color = {159, 159, 223}, thickness = 0.75));
    connect(compressor.shaft_b, turbine.shaft_a) annotation(
      Line(points = {{-516, 32}, {-346, 32}}));
    connect(stateReader_gas.outlet, combustionChamber.ina) annotation(
      Line(points = {{-480, 132}, {-462, 132}}, color = {159, 159, 223}, thickness = 0.75));
    connect(nPump, prescribedSpeedPump.nPump) annotation(
      Line(points = {{-300, -100}, {-238, -100}, {-238, -192}, {90, -192}, {90, -148}, {34, -148}}, color = {0, 0, 127}));
    annotation(
      Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-300, -200}, {300, 200}}, initialScale = 0.1)),
      Icon(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -100}, {100, 100}}, initialScale = 0.1), graphics = {Rectangle(extent = {{-100, 100}, {100, -100}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Text(extent = {{-88, 84}, {100, -96}}, lineColor = {0, 0, 255}, textString = "P")}),
      Documentation(revisions = "<html>
  <ul>
  <li><i>10 Dec 2008</i>
  by <a>Luca Savoldelli</a>:<br>
   First release.</li>
  </ul>
  </html>", info = "<html>
  This is a simple model of a steam plant.
  </html>"));
  end MyCombinedCyclePlant_2;

  model MyCombinedCyclePlant_2Simulator
  MyCombinedCyclePlant_2 myCombinedCyclePlant_2 annotation(
      Placement(transformation(origin = {-1, -6}, extent = {{-25, -28}, {25, 28}})));
  Modelica.Blocks.Sources.Step step1(height = 0.3, offset = 2.13, startTime = 500) annotation(
      Placement(transformation(origin = {-101, 9}, extent = {{-13, -13}, {13, 13}})));
  Modelica.Blocks.Sources.Step step(height = 0, offset = 0.2) annotation(
      Placement(transformation(origin = {-106, -30}, extent = {{-10, -10}, {10, 10}})));
  ThermoPower.PowerPlants.Control.PID pid(CSmax = 2500, CSmin = 500, CSstart = 0.5, Kp = -2, Ni = 1, PVmax = 0.9, PVmin = 0.1, PVstart = 0.1, Ti = 300, b = 1, holdWhenSimplified = false, steadyStateInit = true) annotation(
      Placement(transformation(origin = {-60, -32}, extent = {{-10, -10}, {10, 10}})));
  equation
  connect(step.y, pid.SP) annotation(
      Line(points = {{-94, -30}, {-82, -30}, {-82, -28}, {-70, -28}}, color = {0, 0, 127}));
  connect(pid.CS, myCombinedCyclePlant_2.nPump) annotation(
      Line(points = {{-50, -32}, {-40, -32}, {-40, -22}, {-26, -22}}, color = {0, 0, 127}));
  connect(pid.PV, myCombinedCyclePlant_2.voidFraction) annotation(
      Line(points = {{-70, -36}, {-88, -36}, {-88, -66}, {56, -66}, {56, -16}, {24, -16}, {24, -18}}, color = {0, 0, 127}));
  connect(step1.y, myCombinedCyclePlant_2.fuelflowrate) annotation(
      Line(points = {{-87, 9}, {-66, 9}, {-66, 8}, {-22, 8}}, color = {0, 0, 127}));
  annotation(
      Diagram(graphics),
      Icon(graphics = {Ellipse(lineColor = {75, 138, 73}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid, extent = {{-100, -100}, {100, 100}}), Polygon(lineColor = {0, 0, 255}, fillColor = {75, 138, 73}, pattern = LinePattern.None, fillPattern = FillPattern.Solid, points = {{-36, 60}, {64, 0}, {-36, -60}, {-36, 60}})}));
end MyCombinedCyclePlant_2Simulator;
end MyCCGT2;

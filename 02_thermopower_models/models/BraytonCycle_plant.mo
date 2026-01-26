model BraytonCycle
  import ThermoPower;
  import ThermoPower.Gas;
  import ThermoPower.Media;
  import ThermoPower.Electrical;
  import ThermoPower.PowerPlants;
  import ThermoPower.System;
  parameter Real tableEtaC[6, 4] = [0, 95, 100, 105; 1, 82.5e-2, 81e-2, 80.5e-2; 2, 84e-2, 82.9e-2, 82e-2; 3, 83.2e-2, 82.2e-2, 81.5e-2; 4, 82.5e-2, 81.2e-2, 79e-2; 5, 79.5e-2, 78e-2, 76.5e-2];
  parameter Real tablePhicC[6, 4] = [0, 95, 100, 105; 1, 38.3e-3, 43e-3, 46.8e-3; 2, 39.3e-3, 43.8e-3, 47.9e-3; 3, 40.6e-3, 45.2e-3, 48.4e-3; 4, 41.6e-3, 46.1e-3, 48.9e-3; 5, 42.3e-3, 46.6e-3, 49.3e-3];
  parameter Real tablePR[6, 4] = [0, 95, 100, 105; 1, 22.6, 27, 32; 2, 22, 26.6, 30.8; 3, 20.8, 25.5, 29; 4, 19, 24.3, 27.1; 5, 17, 21.5, 24.2];
  parameter Real tablePhicT[5, 4] = [1, 90, 100, 110; 2.36, 4.68e-3, 4.68e-3, 4.68e-3; 2.88, 4.68e-3, 4.68e-3, 4.68e-3; 3.56, 4.68e-3, 4.68e-3, 4.68e-3; 4.46, 4.68e-3, 4.68e-3, 4.68e-3];
  parameter Real tableEtaT[5, 4] = [1, 90, 100, 110; 2.36, 89e-2, 89.5e-2, 89.3e-2; 2.88, 90e-2, 90.6e-2, 90.5e-2; 3.56, 90.5e-2, 90.6e-2, 90.5e-2; 4.46, 90.2e-2, 90.3e-2, 90e-2];
  Electrical.Generator generator(Pnom = 4e6, initOpt = ThermoPower.Choices.Init.Options.steadyState) annotation(
    Placement(transformation(extent = {{92, -80}, {132, -40}}, rotation = 0)));
  Modelica.Blocks.Interfaces.RealInput fuelFlowRate annotation(
    Placement(transformation(extent = {{-210, -10}, {-190, 10}}, rotation = 0)));
  Modelica.Blocks.Interfaces.RealOutput generatedPower annotation(
    Placement(transformation(extent = {{196, -10}, {216, 10}}, rotation = 0)));
  Gas.Compressor compressor(redeclare package Medium = Media.Air, tablePhic = tablePhicC, tableEta = tableEtaC, pstart_in = 0.343e5, pstart_out = 8.3e5, Tstart_in = 244.4, tablePR = tablePR, Table = ThermoPower.Choices.TurboMachinery.TableTypes.matrix, Tstart_out = 600.4, explicitIsentropicEnthalpy = true, Tdes_in = 244.4, Ndesign = 157.08) annotation(
    Placement(transformation(extent = {{-158, -90}, {-98, -30}}, rotation = 0)));
  Gas.Turbine turbine(redeclare package Medium = Media.FlueGas, pstart_in = 7.85e5, pstart_out = 1.52e5, tablePhic = tablePhicT, tableEta = tableEtaT, Table = ThermoPower.Choices.TurboMachinery.TableTypes.matrix, Tstart_out = 800, Tdes_in = 1400, Tstart_in = 1370, Ndesign = 157.08) annotation(
    Placement(transformation(extent = {{-6, -90}, {54, -30}}, rotation = 0)));
  Gas.CombustionChamber CombustionChamber1(gamma = 1, Cm = 1, pstart = 8.11e5, Tstart = 1370, V = 0.05, S = 0.05, initOpt = ThermoPower.Choices.Init.Options.steadyState, HH = 41.6e6) annotation(
    Placement(transformation(extent = {{-72, 20}, {-32, 60}}, rotation = 0)));
  Gas.SourcePressure SourceP1(redeclare package Medium = Media.Air, p0 = 0.343e5, T = 244.4) annotation(
    Placement(transformation(origin = {-2, 0}, extent = {{-188, -30}, {-168, -10}})));
  Gas.SinkPressure SinkP1(redeclare package Medium = Media.FlueGas, p0 = 1.52e5, T = 800) annotation(
    Placement(transformation(extent = {{94, -10}, {114, 10}}, rotation = 0)));
  Gas.SourceMassFlow SourceW1(redeclare package Medium = Media.NaturalGas, w0 = 2.02, p0 = 811000, T = 300, use_in_w0 = true) annotation(
    Placement(transformation(extent = {{-100, 70}, {-80, 90}}, rotation = 0)));
  Gas.PressDrop PressDrop1(redeclare package Medium = Media.FlueGas, FFtype = ThermoPower.Choices.PressDrop.FFtypes.OpPoint, wnom = 102, rhonom = 2, dpnom = 26000, pstart = 811000, Tstart = 1370) annotation(
    Placement(transformation(origin = {0, 8}, extent = {{-10, -10}, {10, 10}}, rotation = 270)));
  Gas.PressDrop PressDrop2(pstart = 8.3e5, FFtype = ThermoPower.Choices.PressDrop.FFtypes.OpPoint, A = 1, redeclare package Medium = Media.Air, dpnom = 0.19e5, wnom = 100, rhonom = 4.7, Tstart = 600) annotation(
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
    Line(points = {{-170, -20}, {-154, -20}, {-154, -36}, {-152, -36}}, color = {159, 159, 223}, thickness = 0.5));
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
end BraytonCycle;

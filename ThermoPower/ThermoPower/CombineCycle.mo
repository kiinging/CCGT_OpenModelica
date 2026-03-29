within ThermoPower;

package CombineCycle "Combined cycle models"
  extends Modelica.Icons.ExamplesPackage;

  package Models
    extends Modelica.Icons.Package;

    model HE "Heat Exchanger fluid - gas"
      replaceable package FlueGasMedium = ThermoPower.Media.FlueGas constrainedby Modelica.Media.Interfaces.PartialMedium "Flue gas model";
      replaceable package FluidMedium = ThermoPower.Water.StandardWater constrainedby Modelica.Media.Interfaces.PartialPureSubstance "Fluid model";
      parameter Integer N_G = 2 "Number of node of the gas side";
      parameter Integer N_F = 2 "Number of node of the fluid side";
      //Nominal parameter
      parameter SI.MassFlowRate gasNomFlowRate "Nominal flow rate through the gas side";
      parameter SI.MassFlowRate fluidNomFlowRate "Nominal flow rate through the fluid side";
      parameter SI.Pressure gasNomPressure "Nominal pressure in the gas side inlet";
      parameter SI.Pressure fluidNomPressure "Nominal pressure in the fluid side inlet";
      //Physical Parameter
      parameter SI.Area exchSurface_G "Exchange surface between gas - metal tube";
      parameter SI.Area exchSurface_F "Exchange surface between metal tube - fluid";
      parameter SI.Area extSurfaceTub "Total external surface of the tubes";
      parameter SI.Volume gasVol "Gas volume";
      parameter SI.Volume fluidVol "Fluid volume";
      parameter SI.Volume metalVol "Volume of the metal part in the tubes";
      parameter Real rhomcm "Metal heat capacity per unit volume [J/m^3.K]";
      parameter SI.ThermalConductivity lambda "Thermal conductivity of the metal (density by specific heat capacity)";
      //Start values
      parameter SI.Temperature Tstart_G "Average gas temperature start value" annotation(
        Dialog(tab = "Initialization"));
      parameter SI.Temperature Tstart_M "Average metal wall temperature start value" annotation(
        Dialog(tab = "Initialization"));
      parameter Choices.FluidPhase.FluidPhases FluidPhaseStart = Choices.FluidPhase.FluidPhases.Liquid "Initialization fluid phase" annotation(
        Dialog(tab = "Initialization"));
      parameter SI.CoefficientOfHeatTransfer gamma_G "Constant heat transfer coefficient in the gas side";
      parameter SI.CoefficientOfHeatTransfer gamma_F "Constant heat transfer coefficient in the fluid side";
      parameter Choices.Flow1D.FFtypes FFtype_G = ThermoPower.Choices.Flow1D.FFtypes.NoFriction "Friction Factor Type, gas side";
      parameter Real Kfnom_G = 0 "Nominal hydraulic resistance coefficient, gas side";
      parameter SI.PressureDifference dpnom_G = 0 "Nominal pressure drop, gas side (friction term only!)";
      parameter SI.Density rhonom_G = 0 "Nominal inlet density, gas side";
      parameter Real Cfnom_G = 0 "Nominal Fanning friction factor, gsa side";
      parameter Choices.Flow1D.FFtypes FFtype_F = ThermoPower.Choices.Flow1D.FFtypes.NoFriction "Friction Factor Type, fluid side";
      parameter Real Kfnom_F = 0 "Nominal hydraulic resistance coefficient, fluid side";
      parameter SI.PressureDifference dpnom_F = 0 "Nominal pressure drop, fluid side (friction term only!)";
      parameter SI.Density rhonom_F = 0 "Nominal inlet density, fluid side";
      parameter Real Cfnom_F = 0 "Nominal Fanning friction factor, fluid side";
      parameter Choices.Flow1D.HCtypes HCtype_F = ThermoPower.Choices.Flow1D.HCtypes.Downstream "Location of the hydraulic capacitance, fluid side";
      parameter Boolean counterCurrent = true "Counter-current flow";
      parameter Boolean gasQuasiStatic = false "Quasi-static model of the flue gas (mass, energy and momentum static balances";
      constant Real pi = Modelica.Constants.pi;
      Gas.FlangeA gasIn(redeclare package Medium = FlueGasMedium) annotation(
        Placement(transformation(extent = {{-120, -20}, {-80, 20}}, rotation = 0)));
      Gas.FlangeB gasOut(redeclare package Medium = FlueGasMedium) annotation(
        Placement(transformation(extent = {{80, -20}, {120, 20}}, rotation = 0)));
      Water.FlangeA waterIn(redeclare package Medium = FluidMedium) annotation(
        Placement(transformation(extent = {{-20, 80}, {20, 120}}, rotation = 0)));
      Water.FlangeB waterOut(redeclare package Medium = FluidMedium) annotation(
        Placement(transformation(extent = {{-20, -120}, {20, -80}}, rotation = 0)));
      Water.Flow1DFV fluidFlow(Nt = 1, N = N_F, wnom = fluidNomFlowRate, redeclare package Medium = FluidMedium, L = exchSurface_F^2/(fluidVol*pi*4), A = (fluidVol*4/exchSurface_F)^2/4*pi, omega = fluidVol*4/exchSurface_F*pi, Dhyd = fluidVol*4/exchSurface_F, FFtype = FFtype_F, dpnom = dpnom_F, rhonom = rhonom_F, HydraulicCapacitance = HCtype_F, Kfnom = Kfnom_F, Cfnom = Cfnom_F, FluidPhaseStart = FluidPhaseStart, redeclare model HeatTransfer = ThermoPower.Thermal.HeatTransferFV.ConstantHeatTransferCoefficient(gamma = gamma_F)) annotation(
        Placement(transformation(extent = {{-20, -76}, {20, -36}}, rotation = 0)));
      Thermal.MetalTubeFV metalTube(rhomcm = rhomcm, lambda = lambda, L = exchSurface_F^2/(fluidVol*pi*4), rint = fluidVol*4/exchSurface_F/2, WallRes = false, rext = (metalVol + fluidVol)*4/extSurfaceTub/2, Tstartbar = Tstart_M, Nw = N_F - 1) annotation(
        Placement(transformation(extent = {{-20, 0}, {20, -40}}, rotation = 0)));
      Gas.Flow1DFV gasFlow(Dhyd = 1, wnom = gasNomFlowRate, N = N_G, redeclare package Medium = FlueGasMedium, QuasiStatic = gasQuasiStatic, L = L, A = gasVol/L, omega = exchSurface_G/L, Tstartbar = Tstart_G, dpnom = dpnom_G, rhonom = rhonom_G, Kfnom = Kfnom_G, Cfnom = Cfnom_G, FFtype = FFtype_G, redeclare model HeatTransfer = ThermoPower.Thermal.HeatTransferFV.ConstantHeatTransferCoefficient(gamma = gamma_G)) annotation(
        Placement(transformation(extent = {{-20, 60}, {20, 20}}, rotation = 0)));
      Thermal.CounterCurrentFV cC(Nw = N_F - 1) annotation(
        Placement(transformation(extent = {{-20, -8}, {20, 32}}, rotation = 0)));
      final parameter SI.Distance L = 1 "Tube length";
    equation
      connect(gasFlow.infl, gasIn) annotation(
        Line(points = {{-20, 40}, {-100, 40}, {-100, 0}}, color = {159, 159, 223}, thickness = 0.5));
      connect(gasFlow.outfl, gasOut) annotation(
        Line(points = {{20, 40}, {100, 40}, {100, 0}}, color = {159, 159, 223}, thickness = 0.5));
      connect(fluidFlow.outfl, waterOut) annotation(
        Line(points = {{20, -56}, {40, -56}, {40, -100}, {0, -100}}, thickness = 0.5, color = {0, 0, 255}));
      connect(fluidFlow.infl, waterIn) annotation(
        Line(points = {{-20, -56}, {-40, -56}, {-40, 100}, {0, 100}}, thickness = 0.5, color = {0, 0, 255}));
      connect(metalTube.ext, cC.side2) annotation(
        Line(points = {{0, -13.8}, {0, 5.8}}, color = {255, 127, 0}));
      connect(metalTube.int, fluidFlow.wall) annotation(
        Line(points = {{0, -26}, {0, -46}}, color = {255, 127, 0}, smooth = Smooth.None));
      connect(gasFlow.wall, cC.side1) annotation(
        Line(points = {{0, 30}, {0, 18}}, color = {255, 127, 0}, smooth = Smooth.None));
      annotation(
        Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -100}, {100, 100}}), graphics),
        Icon(graphics = {Rectangle(extent = {{-100, 100}, {100, -100}}, lineColor = {0, 0, 255}, fillColor = {230, 230, 230}, fillPattern = FillPattern.Solid), Line(points = {{0, -80}, {0, -40}, {40, -20}, {-40, 20}, {0, 40}, {0, 80}}, color = {0, 0, 255}, thickness = 0.5), Text(extent = {{-100, -115}, {100, -145}}, lineColor = {85, 170, 255}, textString = "%name")}),
        Documentation(revisions = "<html>
<ul>
<li><i>10 Dec 2008</i>
  by <a>Luca Savoldelli</a>:<br>
     First release.</li>
</ul>
</html>", info = "<html>
</html>"));
    end HE;

    model PrescribedSpeedPump "Prescribed speed pump"
      replaceable package FluidMedium = Modelica.Media.Interfaces.PartialTwoPhaseMedium;
      parameter Modelica.SIunits.VolumeFlowRate q_nom[3] "Nominal volume flow rates";
      parameter Modelica.SIunits.Height head_nom[3] "Nominal heads";
      parameter Modelica.SIunits.Density rho0 "Nominal density";
      parameter Modelica.SIunits.Conversions.NonSIunits.AngularVelocity_rpm n0 "Nominal rpm";
      parameter Modelica.SIunits.Pressure nominalOutletPressure "Nominal live steam pressure";
      parameter Modelica.SIunits.Pressure nominalInletPressure "Nominal condensation pressure";
      parameter Modelica.SIunits.MassFlowRate nominalMassFlowRate "Nominal steam mass flow rate";
      parameter Modelica.SIunits.SpecificEnthalpy hstart = 1e5 "Fluid Specific Enthalpy Start Value";
      parameter Boolean SSInit = false "Steady-state initialization";
      function flowCharacteristic = ThermoPower.Functions.PumpCharacteristics.quadraticFlow(q_nom = q_nom, head_nom = head_nom);
      Water.FlangeA inlet(redeclare package Medium = FluidMedium) annotation(
        Placement(transformation(extent = {{-120, -20}, {-80, 20}}, rotation = 0)));
      Water.FlangeB outlet(redeclare package Medium = FluidMedium) annotation(
        Placement(transformation(extent = {{80, -20}, {120, 20}}, rotation = 0)));
      Water.Pump feedWaterPump(redeclare function flowCharacteristic = flowCharacteristic, n0 = n0, redeclare package Medium = FluidMedium, initOpt = if SSInit then Choices.Init.Options.steadyState else Choices.Init.Options.noInit, wstart = nominalMassFlowRate, w0 = nominalMassFlowRate, dp0 = nominalOutletPressure - nominalInletPressure, rho0 = rho0, hstart = hstart, use_in_n = true) annotation(
        Placement(transformation(extent = {{-40, -24}, {0, 16}}, rotation = 0)));
      Modelica.Blocks.Interfaces.RealInput nPump annotation(
        Placement(transformation(extent = {{-72, 60}, {-52, 80}}, rotation = 0), iconTransformation(extent = {{-92, 40}, {-52, 80}})));
    equation
      connect(nPump, feedWaterPump.in_n) annotation(
        Line(points = {{-62, 70}, {-25.2, 70}, {-25.2, 12}}, color = {0, 0, 127}));
      connect(feedWaterPump.infl, inlet) annotation(
        Line(points = {{-36, 0}, {-100, 0}}, color = {0, 0, 255}, thickness = 0.5, smooth = Smooth.None));
      connect(feedWaterPump.outfl, outlet) annotation(
        Line(points = {{-8, 10}, {60, 10}, {60, 0}, {100, 0}}, color = {0, 0, 255}, thickness = 0.5, smooth = Smooth.None));
      annotation(
        Icon(graphics = {Text(extent = {{-100, -118}, {100, -144}}, lineColor = {0, 0, 255}, textString = "%name"), Ellipse(extent = {{-80, 80}, {80, -80}}, lineColor = {0, 0, 0}, fillPattern = FillPattern.Sphere), Polygon(points = {{-40, 40}, {-40, -40}, {50, 0}, {-40, 40}}, lineColor = {0, 0, 0}, fillPattern = FillPattern.HorizontalCylinder, fillColor = {255, 255, 255})}),
        Diagram(graphics),
        Documentation(revisions = "<html>
<ul>
<li><i>10 Dec 2008</i>
  by <a>Luca Savoldelli</a>:<br>
     First release.</li>
</ul>
</html>"));
    end PrescribedSpeedPump;

    model PrescribedPresureCondenser "Ideal condenser with prescribed pressure"
      replaceable package Medium = Water.StandardWater constrainedby Modelica.Media.Interfaces.PartialMedium "Medium model";
      //Parameters
      parameter Modelica.SIunits.Pressure p "Nominal inlet pressure";
      parameter Modelica.SIunits.Volume Vtot = 10 "Total volume of the fluid side";
      parameter Modelica.SIunits.Volume Vlstart = 0.15*Vtot "Start value of the liquid water volume" annotation(
        Dialog(tab = "Initialisation"));
      parameter Choices.Init.Options initOpt = system.initOpt "Initialisation option" annotation(
        Dialog(tab = "Initialisation"));
      outer System system "System object";
      //Variables
      Modelica.SIunits.Density rhol "Density of saturated liquid";
      Modelica.SIunits.Density rhov "Density of saturated steam";
      Medium.SaturationProperties sat "Saturation properties";
      Medium.SpecificEnthalpy hl "Specific enthalpy of saturated liquid";
      Medium.SpecificEnthalpy hv "Specific enthalpy of saturated vapour";
      Modelica.SIunits.Mass M "Total mass, steam+liquid";
      Modelica.SIunits.Mass Ml "Liquid mass";
      Modelica.SIunits.Mass Mv "Steam mass";
      Modelica.SIunits.Volume Vl(start = Vlstart) "Liquid volume";
      Modelica.SIunits.Volume Vv "Steam volume";
      Modelica.SIunits.Energy E "Internal energy";
      Modelica.SIunits.Power Q "Thermal power";
      //Connectors
      Water.FlangeA steamIn(redeclare package Medium = Medium) annotation(
        Placement(transformation(extent = {{-20, 80}, {20, 120}}, rotation = 0)));
      Water.FlangeB waterOut(redeclare package Medium = Medium) annotation(
        Placement(transformation(extent = {{-20, -120}, {20, -80}}, rotation = 0)));
    equation
      steamIn.p = p;
      steamIn.h_outflow = hl;
      sat.psat = p;
      sat.Tsat = Medium.saturationTemperature(p);
      hl = Medium.bubbleEnthalpy(sat);
      hv = Medium.dewEnthalpy(sat);
      waterOut.p = p;
      waterOut.h_outflow = hl;
      rhol = Medium.bubbleDensity(sat);
      rhov = Medium.dewDensity(sat);
      Ml = Vl*rhol;
      Mv = Vv*rhov;
      Vtot = Vv + Vl;
      M = Ml + Mv;
      E = Ml*hl + Mv*inStream(steamIn.h_outflow) - p*Vtot;
//Energy and Mass Balances
      der(M) = steamIn.m_flow + waterOut.m_flow;
      der(E) = steamIn.m_flow*hv + waterOut.m_flow*hl - Q;
    initial equation
      if initOpt == Choices.Init.Options.noInit then
// do nothing
      elseif initOpt == Choices.Init.Options.fixedState then
        Vl = Vlstart;
      elseif initOpt == Choices.Init.Options.steadyState then
        der(Vl) = 0;
      else
        assert(false, "Unsupported initialisation option");
      end if;
      annotation(
        Icon(graphics = {Ellipse(extent = {{-90, 100}, {90, -80}}, lineColor = {0, 0, 255}, lineThickness = 0.5, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Line(points = {{44, -40}, {-50, -40}, {8, 10}, {-50, 60}, {44, 60}}, color = {0, 0, 255}, thickness = 0.5), Rectangle(extent = {{-48, -66}, {48, -100}}, lineColor = {0, 0, 255}, fillColor = {0, 0, 255}, fillPattern = FillPattern.Solid), Text(extent = {{-100, -115}, {100, -145}}, lineColor = {85, 170, 255}, textString = "%name")}),
        Diagram(graphics),
        Documentation(revisions = "<html>
<ul>
<li><i>10 Dec 2008</i>
  by <a>Luca Savoldelli</a>:<br>
     First release.</li>
</ul>
</html>"));
    end PrescribedPresureCondenser;

    model PID "PID controller with anti-windup"
      parameter Real Kp "Proportional gain (normalised units)";
      parameter SI.Time Ti "Integral time";
      parameter Boolean integralAction = true "Use integral action";
      parameter SI.Time Td = 0 "Derivative time";
      parameter Real Nd = 1 "Derivative action up to Nd / Td rad/s";
      parameter Real Ni = 1 "Ni*Ti is the time constant of anti-windup compensation";
      parameter Real b = 1 "Setpoint weight on proportional action";
      parameter Real c = 0 "Setpoint weight on derivative action";
      parameter Real PVmin "Minimum value of process variable for scaling";
      parameter Real PVmax "Maximum value of process variable for scaling";
      parameter Real CSmin "Minimum value of control signal for scaling";
      parameter Real CSmax "Maximum value of control signal for scaling";
      parameter Real PVstart = 0.5 "Start value of PV (scaled)";
      parameter Real CSstart = 0.5 "Start value of CS (scaled)";
      parameter Boolean holdWhenSimplified = false "Hold CSs at start value when homotopy=simplified";
      parameter Boolean steadyStateInit = false "Initialize in steady state";
      Real CSs_hom "Control signal scaled in per units, used when homotopy=simplified";
      Real P "Proportional action / Kp";
      Real I(start = CSstart/Kp) "Integral action / Kp";
      Real D "Derivative action / Kp";
      Real Dx(start = c*PVstart - PVstart) "State of approximated derivator";
      Real PVs "Process variable scaled in per unit";
      Real SPs "Setpoint variable scaled in per unit";
      Real CSs(start = CSstart) "Control signal scaled in per unit";
      Real CSbs(start = CSstart) "Control signal scaled in per unit before saturation";
      Real track "Tracking signal for anti-windup integral action";
      Modelica.Blocks.Interfaces.RealInput PV "Process variable signal" annotation(
        Placement(transformation(extent = {{-112, -52}, {-88, -28}}, rotation = 0)));
      Modelica.Blocks.Interfaces.RealOutput CS "Control signal" annotation(
        Placement(transformation(extent = {{88, -12}, {112, 12}}, rotation = 0)));
      Modelica.Blocks.Interfaces.RealInput SP "Set point signal" annotation(
        Placement(transformation(extent = {{-112, 28}, {-88, 52}}, rotation = 0)));
    equation
// Scaling
      SPs = (SP - PVmin)/(PVmax - PVmin);
      PVs = (PV - PVmin)/(PVmax - PVmin);
      CS = CSmin + CSs*(CSmax - CSmin);
// Controller actions
      P = b*SPs - PVs;
      if integralAction then
        assert(Ti > 0, "Integral time must be positive");
        Ti*der(I) = SPs - PVs + track;
      else
        I = 0;
      end if;
      if Td > 0 then
        Td/Nd*der(Dx) + Dx = c*SPs - PVs "State equation of approximated derivator";
        D = Nd*((c*SPs - PVs) - Dx) "Output equation of approximated derivator";
      else
        Dx = 0;
        D = 0;
      end if;
      if holdWhenSimplified then
        CSs_hom = CSstart;
      else
        CSs_hom = CSbs;
      end if;
      CSbs = Kp*(P + I + D) "Control signal before saturation";
      CSs = homotopy(smooth(0, if CSbs > 1 then 1 else if CSbs < 0 then 0 else CSbs), CSs_hom) "Saturated control signal";
      track = (CSs - CSbs)/(Kp*Ni);
    initial equation
      if steadyStateInit then
        if Ti > 0 then
          der(I) = 0;
        end if;
        if Td > 0 then
          D = 0;
        end if;
      end if;
      annotation(
        Diagram(graphics),
        Icon(graphics = {Rectangle(extent = {{-100, 100}, {100, -100}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Text(extent = {{-54, 40}, {52, -34}}, lineColor = {0, 0, 255}, textString = "PID"), Text(extent = {{-110, -108}, {110, -142}}, lineColor = {0, 0, 255}, lineThickness = 0.5, textString = "%name")}));
    end PID;

    model BraytonPlant
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
      Gas.Compressor compressor(redeclare package Medium = Media.Air, tablePhic = tablePhicC, tableEta = tableEtaC, pstart_in = 1.01325e5, pstart_out = 2.45e6, Tstart_in = 301.15, tablePR = tablePR, Table = ThermoPower.Choices.TurboMachinery.TableTypes.matrix, Tstart_out = 600.4, explicitIsentropicEnthalpy = true, Tdes_in = 301.15, Ndesign = 157.08) annotation(
        Placement(transformation(extent = {{-158, -90}, {-98, -30}}, rotation = 0)));
      Gas.Turbine turbine(redeclare package Medium = Media.FlueGas, pstart_in = 2.38e6, pstart_out = 1.05e5, tablePhic = tablePhicT, tableEta = tableEtaT, Table = ThermoPower.Choices.TurboMachinery.TableTypes.matrix, Tstart_out = 800, Tdes_in = 1400, Tstart_in = 1370, Ndesign = 157.08) annotation(
        Placement(transformation(extent = {{-6, -90}, {54, -30}}, rotation = 0)));
      Gas.CombustionChamber CombustionChamber1(gamma = 1, Cm = 1, pstart = 2.41e6, Tstart = 1370, V = 0.05, S = 0.05, initOpt = ThermoPower.Choices.Init.Options.steadyState, HH = 41.6e6) annotation(
        Placement(transformation(origin = {0, -2}, extent = {{-72, 20}, {-32, 60}})));
      Gas.SourcePressure SourceP1(redeclare package Medium = Media.Air, p0 = 1.01325e5, T = 301.15) annotation(
        Placement(transformation(extent = {{-188, -30}, {-168, -10}}, rotation = 0)));
      Gas.SinkPressure SinkP1(redeclare package Medium = Media.FlueGas, p0 = 1.52e5, T = 800) annotation(
        Placement(transformation(extent = {{94, -10}, {114, 10}}, rotation = 0)));
      Gas.SourceMassFlow SourceW1(redeclare package Medium = Media.NaturalGas, w0 = 6.06, p0 = 2500000, T = 300, use_in_w0 = true) annotation(
        Placement(transformation(extent = {{-100, 70}, {-80, 90}}, rotation = 0)));
      Gas.PressDrop PressDrop1(redeclare package Medium = Media.FlueGas, FFtype = ThermoPower.Choices.PressDrop.FFtypes.OpPoint, wnom = 306, rhonom = 6, dpnom = 26000, pstart = 2410000, Tstart = 1370) annotation(
        Placement(transformation(origin = {0, 8}, extent = {{-10, -10}, {10, 10}}, rotation = 270)));
      Gas.PressDrop PressDrop2(pstart = 2.45e6, FFtype = ThermoPower.Choices.PressDrop.FFtypes.OpPoint, A = 1, redeclare package Medium = Media.Air, dpnom = 0.19e5, wnom = 300, rhonom = 14, Tstart = 600) annotation(
        Placement(transformation(origin = {-104, 10}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
      Modelica.Mechanics.Rotational.Sensors.PowerSensor powerSensor annotation(
        Placement(transformation(extent = {{60, -70}, {80, -50}}, rotation = 0)));
      Modelica.Blocks.Continuous.FirstOrder gasFlowActuator(k = 1, T = 4, y_start = 500, initType = Modelica.Blocks.Types.Init.SteadyState) annotation(
        Placement(transformation(extent = {{-138, 92}, {-122, 108}}, rotation = 0)));
      Modelica.Blocks.Continuous.FirstOrder powerSensor1(k = 1, T = 1, y_start = 170e6, initType = Modelica.Blocks.Types.Init.SteadyState) annotation(
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
        Line(points = {{-80, 80}, {-80, 78}, {-52, 78}, {-52, 58}}, color = {159, 159, 223}, thickness = 0.5));
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
        Line(points = {{-72, 38}, {-78, 38}, {-78, 40}, {-84, 40}}, color = {159, 159, 223}, thickness = 0.5));
      connect(stateInletCC.inlet, PressDrop2.outlet) annotation(
        Line(points = {{-96, 40}, {-104, 40}, {-104, 20}}, color = {159, 159, 223}, thickness = 0.5));
      connect(stateOutletCC.inlet, CombustionChamber1.out) annotation(
        Line(points = {{-20, 40}, {-26, 40}, {-26, 38}, {-32, 38}}, color = {159, 159, 223}, thickness = 0.5));
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
    end BraytonPlant;

    model RankineCycle
      import ThermoPower;
      replaceable package FlueGas = ThermoPower.Media.FlueGas constrainedby Modelica.Media.Interfaces.PartialMedium "Flue gas model";
      replaceable package Water = ThermoPower.Water.StandardWater constrainedby Modelica.Media.Interfaces.PartialPureSubstance "Fluid model";
      PrescribedPresureCondenser condenser(p = 5390, redeclare package Medium = Water, initOpt = ThermoPower.Choices.Init.Options.fixedState) annotation(
        Placement(transformation(extent = {{100, -100}, {140, -60}}, rotation = 0)));
      PrescribedSpeedPump prescribedSpeedPump(n0 = 1500, nominalMassFlowRate = 55, q_nom = {0, 0.055, 0.1}, redeclare package FluidMedium = Water, head_nom = {450, 300, 0}, rho0 = 1000, nominalOutletPressure = 3000000, nominalInletPressure = 50000) annotation(
        Placement(transformation(extent = {{40, -180}, {0, -140}}, rotation = 0)));
      Modelica.Blocks.Continuous.FirstOrder temperatureActuator(k = 1, y_start = 750, T = 4, initType = Modelica.Blocks.Types.Init.SteadyState) annotation(
        Placement(transformation(extent = {{-280, 90}, {-260, 110}}, rotation = 0)));
      Modelica.Blocks.Continuous.FirstOrder powerSensor(k = 1, T = 1, y_start = 170e6, initType = Modelica.Blocks.Types.Init.SteadyState) annotation(
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
      HE economizer(redeclare package FluidMedium = Water, redeclare package FlueGasMedium = FlueGas, N_F = 6, exchSurface_G = 40095.9, exchSurface_F = 3439.389, extSurfaceTub = 3888.449, gasVol = 10, fluidVol = 28.977, metalVol = 8.061, rhomcm = 7900*578.05, lambda = 20, gasNomFlowRate = 500, fluidNomFlowRate = 55, gamma_G = 30, gamma_F = 3000, rhonom_G = 1, Kfnom_F = 150, FFtype_G = ThermoPower.Choices.Flow1D.FFtypes.OpPoint, FFtype_F = ThermoPower.Choices.Flow1D.FFtypes.Kfnom, N_G = 6, gasNomPressure = 101325, fluidNomPressure = 3000000, Tstart_G = 473.15, Tstart_M = 423.15, dpnom_G = 1000, dpnom_F = 20000) annotation(
        Placement(transformation(extent = {{-120, -80}, {-80, -120}}, rotation = 0)));
      Models.Evaporator evaporator(redeclare package FluidMedium = Water, redeclare package FlueGasMedium = FlueGas, gasVol = 10, fluidVol = 12.400, metalVol = 4.801, gasNomFlowRate = 500, fluidNomFlowRate = 55, N = 4, rhom = 7900, cm = 578.05, gamma = 85, exchSurface = 24402, gasNomPressure = 101325, fluidNomPressure = 3000000, Tstart = 623.15, FFtype_G = ThermoPower.Choices.Flow1D.FFtypes.OpPoint, dpnom_G = 1000, rhonom_G = 1) annotation(
        Placement(transformation(extent = {{-120, 0}, {-80, -40}}, rotation = 0)));
      HE superheater(redeclare package FluidMedium = Water, redeclare package FlueGasMedium = FlueGas, N_F = 7, exchSurface_G = 2314.8, exchSurface_F = 450.218, extSurfaceTub = 504.652, gasVol = 10, fluidVol = 4.468, metalVol = 1.146, rhomcm = 7900*578.05, lambda = 20, gasNomFlowRate = 500, gamma_G = 90, gamma_F = 6000, fluidNomFlowRate = 55, rhonom_G = 1, Kfnom_F = 150, FluidPhaseStart = ThermoPower.Choices.FluidPhase.FluidPhases.Steam, FFtype_G = ThermoPower.Choices.Flow1D.FFtypes.OpPoint, FFtype_F = ThermoPower.Choices.Flow1D.FFtypes.Kfnom, N_G = 7, gasNomPressure = 101325, fluidNomPressure = 3000000, Tstart_G = 723.15, Tstart_M = 573.15, dpnom_G = 1000, dpnom_F = 20000) annotation(
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
    end RankineCycle;


      model Evaporator
        "Fire tube boiler, fixed heat transfer coefficient, no radiative heat transfer"

        replaceable package FlueGasMedium = ThermoPower.Media.FlueGas
          constrainedby Modelica.Media.Interfaces.PartialMedium
          "Flue gas model";
        replaceable package FluidMedium = ThermoPower.Water.StandardWater
          constrainedby Modelica.Media.Interfaces.PartialPureSubstance
          "Fluid model";

        parameter Integer N=2 "Number of node of the gas side";

//Nominal parameter
        parameter SI.MassFlowRate gasNomFlowRate
          "Nominal flow rate through the gas side";
        parameter SI.MassFlowRate fluidNomFlowRate
          "Nominal flow rate through the fluid side";
        parameter SI.Pressure gasNomPressure
          "Nominal pressure in the gas side inlet";
        parameter SI.Pressure fluidNomPressure
          "Nominal pressure in the fluid side inlet";

//Physical Parameter
        parameter SI.Area exchSurface
          "Exchange surface between gas - metal tube";
        parameter SI.Volume gasVol "Gas volume";
        parameter SI.Volume fluidVol "Fluid volume";
        parameter SI.Volume metalVol "Volume of the metal part in the tubes";
        parameter SI.Density rhom "Metal density";
        parameter SI.SpecificHeatCapacity cm
          "Specific heat capacity of the metal";

//Start value
        parameter SI.Temperature Tstart "Average gas temperature start value"
          annotation (Dialog(tab="Initialization"));
        parameter SI.CoefficientOfHeatTransfer gamma
          "Constant heat transfer coefficient in the gas side";
        parameter Choices.Flow1D.FFtypes FFtype_G=ThermoPower.Choices.Flow1D.FFtypes.NoFriction
          "Friction Factor Type, gas side";
        parameter Real Kfnom_G=0
          "Nominal hydraulic resistance coefficient, gas side";
        parameter SI.PressureDifference dpnom_G=0
          "Nominal pressure drop, gas side (friction term only!)";
        parameter SI.Density rhonom_G=0 "Nominal inlet density, gas side";
        parameter Real Cfnom_G=0 "Nominal Fanning friction factor, gsa side";
        parameter Boolean gasQuasiStatic=false
          "Quasi-static model of the flue gas (mass, energy and momentum static balances";
        constant Real pi=Modelica.Constants.pi;
        Water.DrumEquilibrium water(
          cm=cm,
          redeclare package Medium = FluidMedium,
          Vd=fluidVol,
          Mm=metalVol*rhom,
          pstart=fluidNomPressure,
          Vlstart=fluidVol*0.8)
          annotation (Placement(transformation(extent={{-24,18},{24,66}},
                rotation=0)));
        Thermal.HT_DHTVolumes      adapter(N=N - 1)
          annotation (Placement(transformation(
              origin={0,-8},
              extent={{-10,-10},{10,10}},
              rotation=270)));
        Water.FlangeA waterIn(redeclare package Medium = FluidMedium) annotation (
           Placement(transformation(extent={{-20,80},{20,120}}, rotation=0)));
        Water.FlangeB waterOut(redeclare package Medium = FluidMedium)
          annotation (Placement(transformation(extent={{-20,-120},{20,-80}},
                rotation=0)));
        Gas.FlangeA gasIn(redeclare package Medium = FlueGasMedium) annotation (
            Placement(transformation(extent={{-120,-20},{-80,20}}, rotation=0)));
        Gas.FlangeB gasOut(redeclare package Medium = FlueGasMedium) annotation (
            Placement(transformation(extent={{80,-20},{120,20}}, rotation=0)));
        Gas.Flow1DFV
                   gasFlow(
          Dhyd=1,
          wnom=gasNomFlowRate,
          FFtype=ThermoPower.Choices.Flow1D.FFtypes.NoFriction,
          redeclare package Medium = FlueGasMedium,
          QuasiStatic=gasQuasiStatic,
          N=N,
          L=L,
          A=gasVol/L,
          omega=exchSurface/L,
          Tstartbar=Tstart,
          redeclare model HeatTransfer =
              Thermal.HeatTransferFV.ConstantHeatTransferCoefficient (gamma=gamma))
                            annotation (Placement(transformation(
              origin={0,-40},
              extent={{14,14},{-14,-14}},
              rotation=180)));

        Modelica.Blocks.Interfaces.RealOutput voidFraction annotation (Placement(
              transformation(extent={{96,50},{116,70}}, rotation=0)));
        final parameter SI.Distance L=1 "Tube length";
        Modelica.Blocks.Sources.RealExpression realExpression
          annotation (Placement(transformation(extent={{18,108},{38,128}})));
        Modelica.Blocks.Sources.RealExpression output1(y=water.Vv/water.Vd)
          annotation (Placement(transformation(extent={{54,52},{86,70}})));
      equation
        connect(water.feed, waterIn) annotation (Line(
            points={{-21.6,31.44},{-52,31.44},{-52,100},{0,100}},
            thickness=0.5,
            color={0,0,255}));
        connect(water.steam, waterOut) annotation (Line(
            points={{16.32,59.28},{40,59.28},{40,-70},{0,-70},{0,-100}},
            thickness=0.5,
            color={0,0,255}));
        connect(gasFlow.infl, gasIn) annotation (Line(
            points={{-14,-40},{-60,-40},{-60,0},{-100,0}},
            color={159,159,223},
            thickness=0.5));
        connect(gasFlow.outfl, gasOut) annotation (Line(
            points={{14,-40},{60,-40},{60,0},{100,0}},
            color={159,159,223},
            thickness=0.5));
        connect(output1.y, voidFraction) annotation (Line(points={{87.6,61},{96,61},{96,
                60},{106,60}}, color={0,0,127}));
        connect(adapter.DHT_port, gasFlow.wall) annotation (Line(points={{-1.9984e-15,
                -19},{-1.9984e-15,-32},{-8.88178e-16,-32},{-8.88178e-16,-33}}, color={
                255,127,0}));
        connect(adapter.HT_port, water.wall) annotation (Line(points={{2.19269e-15,4},
                {0,4},{0,20.4}}, color={191,0,0}));
        annotation (                   Icon(graphics={
              Rectangle(
                extent={{-100,100},{100,-100}},
                lineColor={0,0,255},
                fillColor={230,230,230},
                fillPattern=FillPattern.Solid),
              Line(
                points={{0,-80},{0,-40},{40,-20},{-40,20},{0,40},{0,80}},
                color={0,0,255},
                thickness=0.5),
              Text(
                extent={{-100,-115},{100,-145}},
                lineColor={85,170,255},
                textString="%name")}));
      end Evaporator;

  end Models;

  package Simulators
    extends Modelica.Icons.ExamplesPackage;

    model OpenLoopCombineCycle "Combined cycle simulation"
      extends Modelica.Icons.Example;
      import ThermoPower;
      // Brayton Cycle (GT) Parameters
      parameter Real tableEtaC[6, 4] = [0, 95, 100, 105; 1, 82.5e-2, 81e-2, 80.5e-2; 2, 84e-2, 82.9e-2, 82e-2; 3, 83.2e-2, 82.2e-2, 81.5e-2; 4, 82.5e-2, 81.2e-2, 79e-2; 5, 79.5e-2, 78e-2, 76.5e-2];
      parameter Real tablePhicC[6, 4] = [0, 95, 100, 105; 1, 38.3e-3, 43e-3, 46.8e-3; 2, 39.3e-3, 43.8e-3, 47.9e-3; 3, 40.6e-3, 45.2e-3, 48.4e-3; 4, 41.6e-3, 46.1e-3, 48.9e-3; 5, 42.3e-3, 46.6e-3, 49.3e-3];
      parameter Real tablePR[6, 4] = [0, 95, 100, 105; 1, 22.6, 27, 32; 2, 22, 26.6, 30.8; 3, 20.8, 25.5, 29; 4, 19, 24.3, 27.1; 5, 17, 21.5, 24.2];
      parameter Real tablePhicT[5, 4] = [1, 90, 100, 110; 2.36, 4.68e-3, 4.68e-3, 4.68e-3; 2.88, 4.68e-3, 4.68e-3, 4.68e-3; 3.56, 4.68e-3, 4.68e-3, 4.68e-3; 4.46, 4.68e-3, 4.68e-3, 4.68e-3];
      parameter Real tableEtaT[5, 4] = [1, 90, 100, 110; 2.36, 89e-2, 89.5e-2, 89.3e-2; 2.88, 90e-2, 90.6e-2, 90.5e-2; 3.56, 90.5e-2, 90.6e-2, 90.5e-2; 4.46, 90.2e-2, 90.3e-2, 90e-2];
      replaceable package FlueGas = ThermoPower.Media.FlueGas constrainedby Modelica.Media.Interfaces.PartialMedium "Flue gas model";
      replaceable package Water = ThermoPower.Water.StandardWater constrainedby Modelica.Media.Interfaces.PartialPureSubstance "Fluid model";
      // GT Components
      Modelica.Mechanics.Rotational.Sources.ConstantSpeed constantSpeed_GT(w_fixed = 157, phi(start = 0, fixed = true)) annotation(
        Placement(transformation(origin = {-220, -50}, extent = {{-10, -10}, {10, 10}})));
      Gas.Compressor compressor(redeclare package Medium = Media.Air, tablePhic = tablePhicC, tableEta = tableEtaC, pstart_in = 1.01325e5, pstart_out = 2.45e6, Tstart_in = 301.15, tablePR = tablePR, Table = ThermoPower.Choices.TurboMachinery.TableTypes.matrix, Tstart_out = 600.4, explicitIsentropicEnthalpy = true, Tdes_in = 301.15, Ndesign = 157.08) annotation(
        Placement(transformation(origin = {-286, 10}, extent = {{-158, -90}, {-98, -30}})));
      Gas.Turbine turbine(redeclare package Medium = FlueGas, pstart_in = 2.38e6, pstart_out = 1.05e5, tablePhic = tablePhicT, tableEta = tableEtaT, Table = ThermoPower.Choices.TurboMachinery.TableTypes.matrix, Tstart_out = 800, Tdes_in = 1400, Tstart_in = 1370, Ndesign = 157.08) annotation(
        Placement(transformation(origin = {-326, 10}, extent = {{-6, -90}, {54, -30}})));
      Gas.CombustionChamber CombustionChamber1(gamma = 1, Cm = 1, pstart = 2.41e6, Tstart = 1370, V = 0.05, S = 0.05, initOpt = ThermoPower.Choices.Init.Options.steadyState, HH = 41.6e6) annotation(
        Placement(transformation(origin = {-306, 14}, extent = {{-72, 20}, {-32, 60}})));
      Gas.SourcePressure SourceP1(redeclare package Medium = Media.Air, p0 = 1.01325e5, T = 301.15) annotation(
        Placement(transformation(origin = {-298, 20}, extent = {{-188, -30}, {-168, -10}})));
      Gas.SourceMassFlow SourceW1(redeclare package Medium = Media.NaturalGas, w0 = 6.06, p0 = 2500000, T = 300, use_in_w0 = true) annotation(
        Placement(transformation(origin = {-276, 18}, extent = {{-100, 70}, {-80, 90}})));
      Gas.PressDrop PressDrop1(redeclare package Medium = FlueGas, FFtype = ThermoPower.Choices.PressDrop.FFtypes.OpPoint, wnom = 306, rhonom = 6, dpnom = 26000, pstart = 2410000, Tstart = 1370) annotation(
        Placement(transformation(origin = {-326, 18}, extent = {{-10, -10}, {10, 10}}, rotation = 270)));
      Gas.PressDrop PressDrop2(pstart = 2.45e6, FFtype = ThermoPower.Choices.PressDrop.FFtypes.OpPoint, A = 1, redeclare package Medium = Media.Air, dpnom = 0.19e5, wnom = 300, rhonom = 14, Tstart = 600) annotation(
        Placement(transformation(origin = {-390, 20}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
      Modelica.Mechanics.Rotational.Sensors.PowerSensor powerSensor_GT annotation(
        Placement(transformation(origin = {-322, 10}, extent = {{60, -70}, {80, -50}})));
      Modelica.Blocks.Continuous.FirstOrder fuelFlowActuator(k = 1, T = 4, y_start = 500, initType = Modelica.Blocks.Types.Init.SteadyState) annotation(
        Placement(transformation(origin = {-294, 6}, extent = {{-138, 92}, {-122, 108}})));
      Modelica.Blocks.Continuous.FirstOrder powerSensor1_GT(k = 1, T = 1, y_start = 170e6, initType = Modelica.Blocks.Types.Init.SteadyState) annotation(
        Placement(transformation(origin = {-396, 106}, extent = {{146, -118}, {162, -102}})));
      Modelica.Blocks.Interfaces.RealOutput generatedPower_GT annotation(
        Placement(transformation(origin = {-404, -6}, extent = {{196, -10}, {216, 10}}), iconTransformation(extent = {{196, -10}, {216, 10}})));
      
      ThermoPower.PowerPlants.HRSG.Components.StateReader_gas stateInletCC(redeclare package Medium = Media.Air) annotation(
        Placement(transformation(origin = {-306, 14}, extent = {{-100, 30}, {-80, 50}})));
      ThermoPower.PowerPlants.HRSG.Components.StateReader_gas stateOutletCC(redeclare package Medium = Media.FlueGas) annotation(
        Placement(transformation(origin = {-306, 14}, extent = {{-24, 30}, {-4, 50}})));
      // ST Components
      Models.PrescribedPresureCondenser condenser(p = 5390, redeclare package Medium = Water, initOpt = ThermoPower.Choices.Init.Options.fixedState) annotation(
        Placement(transformation(origin = {-32, 0}, extent = {{100, -100}, {140, -60}})));
      Models.PrescribedSpeedPump prescribedSpeedPump(n0 = 1500, nominalMassFlowRate = 55, q_nom = {0, 0.055, 0.1}, redeclare package FluidMedium = Water, head_nom = {450, 300, 0}, rho0 = 1000, nominalOutletPressure = 3000000, nominalInletPressure = 50000) annotation(
        Placement(transformation(extent = {{40, -180}, {0, -140}})));
      Modelica.Blocks.Continuous.FirstOrder nPumpActuator(k = 1, initType = Modelica.Blocks.Types.Init.SteadyState, T = 2, y_start = 1500) annotation(
        Placement(transformation(origin = {20, -60}, extent = {{-280, -110}, {-260, -90}})));
      Modelica.Blocks.Interfaces.RealOutput generatedPower_ST annotation(
        Placement(transformation(origin = {-48, 10}, extent = {{290, 90}, {310, 110}}), iconTransformation(extent = {{290, 90}, {310, 110}})));
      Modelica.Blocks.Continuous.FirstOrder powerSensor_ST_ctrl(k = 1, T = 1, y_start = 170e6, initType = Modelica.Blocks.Types.Init.SteadyState) annotation(
        Placement(transformation(origin = {-86, 10}, extent = {{240, 90}, {260, 110}})));
      Modelica.Blocks.Interfaces.RealOutput voidFraction_ST annotation(
        Placement(transformation(origin = {-155, -185}, extent = {{435, 165}, {465, 135}}), iconTransformation(extent = {{290, -110}, {310, -90}})));
      Modelica.Blocks.Continuous.FirstOrder voidFractionSensor_ST(k = 1, T = 1, initType = Modelica.Blocks.Types.Init.SteadyState, y_start = 0.2) annotation(
        Placement(transformation(origin = {-86, 68}, extent = {{240, -110}, {260, -90}})));
      ThermoPower.Water.SteamTurbineStodola steamTurbine(wstart = 55, wnom = 55, Kt = 0.0104, redeclare package Medium = Water, PRstart = 30, pnom = 3000000) annotation(
        Placement(transformation(origin = {-48, -4}, extent = {{50, 30}, {100, 80}})));
      Modelica.Mechanics.Rotational.Sensors.PowerSensor powerSensor_ST annotation(
        Placement(transformation(origin = {-34, -2}, extent = {{138, 68}, {166, 40}})));
      Models.HE economizer(redeclare package FluidMedium = Water, redeclare package FlueGasMedium = FlueGas, N_F = 6, exchSurface_G = 40095.9, exchSurface_F = 3439.389, extSurfaceTub = 3888.449, gasVol = 10, fluidVol = 28.977, metalVol = 8.061, rhomcm = 7900*578.05, lambda = 20, gasNomFlowRate = 500, fluidNomFlowRate = 55, gamma_G = 30, gamma_F = 3000, rhonom_G = 1, Kfnom_F = 150, FFtype_G = ThermoPower.Choices.Flow1D.FFtypes.OpPoint, FFtype_F = ThermoPower.Choices.Flow1D.FFtypes.Kfnom, N_G = 6, gasNomPressure = 101325, fluidNomPressure = 3000000, Tstart_G = 473.15, Tstart_M = 423.15, dpnom_G = 1000, dpnom_F = 20000) annotation(
        Placement(transformation(extent = {{-120, -80}, {-80, -120}})));
      Models.Evaporator evaporator(redeclare package FluidMedium = Water, redeclare package FlueGasMedium = FlueGas, gasVol = 10, fluidVol = 12.400, metalVol = 4.801, gasNomFlowRate = 500, fluidNomFlowRate = 55, N = 4, rhom = 7900, cm = 578.05, gamma = 85, exchSurface = 24402, gasNomPressure = 101325, fluidNomPressure = 3000000, Tstart = 623.15, FFtype_G = ThermoPower.Choices.Flow1D.FFtypes.OpPoint, dpnom_G = 1000, rhonom_G = 1) annotation(
        Placement(transformation(extent = {{-120, 0}, {-80, -40}})));
      Models.HE superheater(redeclare package FluidMedium = Water, redeclare package FlueGasMedium = FlueGas, N_F = 7, exchSurface_G = 2314.8, exchSurface_F = 450.218, extSurfaceTub = 504.652, gasVol = 10, fluidVol = 4.468, metalVol = 1.146, rhomcm = 7900*578.05, lambda = 20, gasNomFlowRate = 500, gamma_G = 90, gamma_F = 6000, fluidNomFlowRate = 55, rhonom_G = 1, Kfnom_F = 150, FluidPhaseStart = ThermoPower.Choices.FluidPhase.FluidPhases.Steam, FFtype_G = ThermoPower.Choices.Flow1D.FFtypes.OpPoint, FFtype_F = ThermoPower.Choices.Flow1D.FFtypes.Kfnom, N_G = 7, gasNomPressure = 101325, fluidNomPressure = 3000000, Tstart_G = 723.15, Tstart_M = 573.15, dpnom_G = 1000, dpnom_F = 20000) annotation(
        Placement(transformation(extent = {{-120, 80}, {-80, 40}})));
      ThermoPower.PowerPlants.HRSG.Components.StateReader_gas stateGasInletEvaporator(redeclare package Medium = FlueGas) annotation(
        Placement(transformation(extent = {{-150, -30}, {-130, -10}})));
      ThermoPower.PowerPlants.HRSG.Components.StateReader_gas stateGasInletEconomizer(redeclare package Medium = FlueGas) annotation(
        Placement(transformation(extent = {{-150, -110}, {-130, -90}})));
      ThermoPower.PowerPlants.HRSG.Components.StateReader_gas stateGasOutlet(redeclare package Medium = FlueGas) annotation(
        Placement(transformation(extent = {{-70, -110}, {-50, -90}})));
      ThermoPower.PowerPlants.HRSG.Components.StateReader_water stateWaterSuperheater_in(redeclare package Medium = Water) annotation(
        Placement(transformation(origin = {-100, 20}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
      ThermoPower.PowerPlants.HRSG.Components.StateReader_water stateWaterSuperheater_out(redeclare package Medium = Water) annotation(
        Placement(transformation(origin = {-100, 100}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
      ThermoPower.PowerPlants.HRSG.Components.StateReader_water stateWaterEvaporator_in(redeclare package Medium = Water) annotation(
        Placement(transformation(origin = {-100, -60}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
      ThermoPower.PowerPlants.HRSG.Components.StateReader_water stateWaterEconomizer_in(redeclare package Medium = Water) annotation(
        Placement(transformation(origin = {-100, -140}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
      ThermoPower.Gas.SinkPressure sinkP_gas(T = 400, redeclare package Medium = FlueGas) annotation(
        Placement(transformation(extent = {{-40, -110}, {-20, -90}})));
      Modelica.Mechanics.Rotational.Sources.ConstantSpeed constantSpeed_ST(w_fixed = 157, phi(start = 0, fixed = true)) annotation(
        Placement(transformation(origin = {-20, -2}, extent = {{200, 44}, {180, 64}})));
      inner System system(allowFlowReversal = false, initOpt = ThermoPower.Choices.Init.Options.steadyState) annotation(
        Placement(transformation(extent = {{240, 160}, {260, 180}})));
      Modelica.Blocks.Sources.Step fuelFlowRateStep(height = 0.9, startTime = 500, offset = 6.39) annotation(
        Placement(transformation(origin = {-72, 0}, extent = {{-440, 96}, {-420, 116}})));
      Modelica.Blocks.Sources.Step voidFractionSetPoint(offset = 0.2, height = 0, startTime = 0) annotation(
        Placement(transformation(origin = {-12, -46}, extent = {{-360, -120}, {-340, -100}})));
      Models.PID voidFractionController(PVmin = 0.1, PVmax = 0.9, CSmax = 2500, PVstart = 0.1, CSstart = 0.5, steadyStateInit = true, CSmin = 500, Kp = -2, Ti = 300) annotation(
        Placement(transformation(origin = {-12, -50}, extent = {{-300, -120}, {-280, -100}})));
      ThermoPower.PowerPlants.HRSG.Components.StateReader_gas stateTurbineExhaust(redeclare package Medium = FlueGas) annotation(
        Placement(transformation(origin = {-194, 60}, extent = {{-10, -10}, {10, 10}})));
    equation
// GT Connections
      connect(SourceW1.flange, CombustionChamber1.inf) annotation(
        Line(points = {{-356, 98}, {-356, 85}, {-358, 85}, {-358, 74}}, color = {159, 159, 223}));
      connect(SourceP1.flange, compressor.inlet) annotation(
        Line(points = {{-466, 0}, {-438, 0}, {-438, -26}}, color = {159, 159, 223}));
      connect(PressDrop1.outlet, turbine.inlet) annotation(
        Line(points = {{-326, 8}, {-326, -26}}, color = {159, 159, 223}));
      connect(compressor.outlet, PressDrop2.inlet) annotation(
        Line(points = {{-390, -26}, {-390, 10}}, color = {159, 159, 223}));
      connect(compressor.shaft_b, turbine.shaft_a) annotation(
        Line(points = {{-396, -50}, {-320, -50}}));
      connect(powerSensor_GT.flange_a, turbine.shaft_b) annotation(
        Line(points = {{-262, -50}, {-284, -50}}));
      connect(fuelFlowActuator.u, fuelFlowRateStep.y) annotation(
        Line(points = {{-433.6, 106}, {-491, 106}}, color = {0, 0, 127}));
      connect(fuelFlowActuator.y, SourceW1.in_w0) annotation(
        Line(points = {{-415.2, 106}, {-374.2, 106}, {-374.2, 103}, {-372.2, 103}}, color = {0, 0, 127}));
      connect(powerSensor_GT.power, powerSensor1_GT.u) annotation(
        Line(points = {{-260, -61}, {-260, -32.5}, {-252, -32.5}, {-252, -4}}, color = {0, 0, 127}));
      connect(powerSensor1_GT.y, generatedPower_GT) annotation(
        Line(points = {{-233.2, -4}, {-215.7, -4}, {-215.7, -6}, {-198.2, -6}}, color = {0, 0, 127}));
      connect(CombustionChamber1.ina, stateInletCC.outlet) annotation(
        Line(points = {{-378, 54}, {-384, 54}, {-384, 56}, {-390, 56}}, color = {159, 159, 223}));
      connect(stateInletCC.inlet, PressDrop2.outlet) annotation(
        Line(points = {{-402, 54}, {-410, 54}, {-410, 34}}, color = {159, 159, 223}));
      connect(stateOutletCC.inlet, CombustionChamber1.out) annotation(
        Line(points = {{-326, 54}, {-332, 54}, {-332, 52}, {-338, 52}}, color = {159, 159, 223}));
      connect(stateOutletCC.outlet, PressDrop1.inlet) annotation(
        Line(points = {{-314, 54}, {-306, 54}, {-306, 32}}, color = {159, 159, 223}));
      connect(constantSpeed_GT.flange, powerSensor_GT.flange_b) annotation(Line(points = {{-210, -50}, {-240, -50}}));
// Bridge: GT exhaust to ST HRSG
      connect(turbine.outlet, stateTurbineExhaust.inlet) annotation(
        Line(points = {{-278, -26}, {-278, 61}, {-200, 61}, {-200, 60}}, color = {159, 159, 223}));
      connect(stateTurbineExhaust.outlet, superheater.gasIn) annotation(
        Line(origin = {-1, 0}, points = {{-188, 60}, {-120, 60}}, color = {159, 159, 223}));
// ST Connections
      connect(prescribedSpeedPump.inlet, condenser.waterOut) annotation(
        Line(points = {{40, -160}, {88, -160}, {88, -100}}));
      connect(generatedPower_ST, powerSensor_ST_ctrl.y) annotation(
        Line(points = {{252, 110}, {175, 110}}, color = {0, 0, 127}));
      connect(nPumpActuator.u, voidFractionController.CS) annotation(
        Line(points = {{-262, -160}, {-292, -160}}, color = {0, 0, 127}));
      connect(voidFractionController.SP, voidFractionSetPoint.y) annotation(
        Line(points = {{-312, -156}, {-351, -156}}, color = {0, 0, 127}));
      connect(voidFractionController.PV, voidFraction_ST) annotation(
        Line(points = {{-312, -164}, {-326, -164}, {-326, -234}, {295, -234}, {295, -35}}, color = {0, 0, 127}));
      connect(voidFraction_ST, voidFractionSensor_ST.y) annotation(
        Line(points = {{295, -35}, {280.5, -35}, {280.5, -32}, {175, -32}}, color = {0, 0, 127}));
      connect(powerSensor_ST.flange_a, steamTurbine.shaft_b) annotation(
        Line(points = {{104, 52}, {91, 52}, {91, 51}, {43, 51}}));
      connect(condenser.steamIn, steamTurbine.outlet) annotation(
        Line(points = {{88, -60}, {88, 71}, {47, 71}}));
      connect(prescribedSpeedPump.outlet, stateWaterEconomizer_in.inlet) annotation(
        Line(points = {{0, -160}, {-100, -160}, {-100, -146}}));
      connect(stateWaterEconomizer_in.outlet, economizer.waterIn) annotation(
        Line(points = {{-100, -134}, {-100, -120}}));
      connect(economizer.waterOut, stateWaterEvaporator_in.inlet) annotation(
        Line(points = {{-100, -80}, {-100, -66}}));
      connect(stateWaterEvaporator_in.outlet, evaporator.waterIn) annotation(
        Line(points = {{-100, -54}, {-100, -40}}));
      connect(economizer.gasIn, stateGasInletEconomizer.outlet) annotation(
        Line(points = {{-120, -100}, {-128, -100}, {-134, -100}}));
      connect(stateGasInletEconomizer.inlet, evaporator.gasOut) annotation(
        Line(points = {{-146, -100}, {-160, -100}, {-160, -50}, {-40, -50}, {-40, -20}, {-80, -20}}));
      connect(sinkP_gas.flange, stateGasOutlet.outlet) annotation(
        Line(points = {{-40, -100}, {-54, -100}}));
      connect(stateGasOutlet.inlet, economizer.gasOut) annotation(
        Line(points = {{-66, -100}, {-74, -100}, {-80, -100}}));
      connect(evaporator.gasIn, stateGasInletEvaporator.outlet) annotation(
        Line(points = {{-120, -20}, {-134, -20}}));
      connect(stateGasInletEvaporator.inlet, superheater.gasOut) annotation(
        Line(points = {{-146, -20}, {-160, -20}, {-160, 30}, {-40, 30}, {-40, 60}, {-80, 60}}));
      connect(evaporator.waterOut, stateWaterSuperheater_in.inlet) annotation(
        Line(points = {{-100, 0}, {-100, 14}}));
      connect(stateWaterSuperheater_in.outlet, superheater.waterIn) annotation(
        Line(points = {{-100, 26}, {-100, 40}}));
      connect(superheater.waterOut, stateWaterSuperheater_out.inlet) annotation(
        Line(points = {{-100, 80}, {-100, 94}}));
      connect(stateWaterSuperheater_out.outlet, steamTurbine.inlet) annotation(
        Line(points = {{-100, 106}, {-100, 120}, {7, 120}, {7, 71}}));
      connect(powerSensor_ST_ctrl.u, powerSensor_ST.power) annotation(
        Line(points = {{152, 110}, {152, 108.5}, {108, 108.5}, {108, 109}, {107.5, 109}, {107.5, 67}, {107, 67}}, color = {0, 0, 127}));
      connect(voidFractionSensor_ST.u, evaporator.voidFraction) annotation(
        Line(points = {{152, -32}, {-78.8, -32}}, color = {0, 0, 127}));
      connect(nPumpActuator.y, prescribedSpeedPump.nPump) annotation(
        Line(points = {{-239, -160}, {-239, -160}, {-239, -158}, {-138, -158}, {-138, -194}, {160, -194}, {160, -148}, {34.4, -148}}, color = {0, 0, 127}));
      connect(constantSpeed_ST.flange, powerSensor_ST.flange_b) annotation(
        Line(points = {{160, 52}, {132, 52}}));
      annotation(
        experiment(StopTime = 1000, Tolerance = 1e-06),
        Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-520, 180}, {320, -240}}, initialScale = 0.1)),
        Icon(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -100}, {100, 100}}, initialScale = 0.1), graphics = {Rectangle(extent = {{-100, 100}, {100, -100}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Text(extent = {{-88, 84}, {100, -96}}, lineColor = {0, 0, 255}, textString = "CC")}),
        Documentation(info = "<html><p>Combined cycle power plant simulation model.</p></html>"));
    end OpenLoopCombineCycle;

    model CloseLoopCombineCycle "Combined cycle simulation"
      extends Modelica.Icons.Example;
      import ThermoPower;
      // Brayton Cycle (GT) Parameters
      parameter Real tableEtaC[6, 4] = [0, 95, 100, 105; 1, 82.5e-2, 81e-2, 80.5e-2; 2, 84e-2, 82.9e-2, 82e-2; 3, 83.2e-2, 82.2e-2, 81.5e-2; 4, 82.5e-2, 81.2e-2, 79e-2; 5, 79.5e-2, 78e-2, 76.5e-2];
      parameter Real tablePhicC[6, 4] = [0, 95, 100, 105; 1, 38.3e-3, 43e-3, 46.8e-3; 2, 39.3e-3, 43.8e-3, 47.9e-3; 3, 40.6e-3, 45.2e-3, 48.4e-3; 4, 41.6e-3, 46.1e-3, 48.9e-3; 5, 42.3e-3, 46.6e-3, 49.3e-3];
      parameter Real tablePR[6, 4] = [0, 95, 100, 105; 1, 22.6, 27, 32; 2, 22, 26.6, 30.8; 3, 20.8, 25.5, 29; 4, 19, 24.3, 27.1; 5, 17, 21.5, 24.2];
      parameter Real tablePhicT[5, 4] = [1, 90, 100, 110; 2.36, 4.68e-3, 4.68e-3, 4.68e-3; 2.88, 4.68e-3, 4.68e-3, 4.68e-3; 3.56, 4.68e-3, 4.68e-3, 4.68e-3; 4.46, 4.68e-3, 4.68e-3, 4.68e-3];
      parameter Real tableEtaT[5, 4] = [1, 90, 100, 110; 2.36, 89e-2, 89.5e-2, 89.3e-2; 2.88, 90e-2, 90.6e-2, 90.5e-2; 3.56, 90.5e-2, 90.6e-2, 90.5e-2; 4.46, 90.2e-2, 90.3e-2, 90e-2];
      replaceable package FlueGas = ThermoPower.Media.FlueGas constrainedby Modelica.Media.Interfaces.PartialMedium "Flue gas model";
      replaceable package Water = ThermoPower.Water.StandardWater constrainedby Modelica.Media.Interfaces.PartialPureSubstance "Fluid model";
      // GT Components
      Modelica.Mechanics.Rotational.Sources.ConstantSpeed constantSpeed_GT(w_fixed = 157, phi(start = 0, fixed = true)) annotation(
        Placement(transformation(origin = {-220, -50}, extent = {{-10, -10}, {10, 10}})));
      Gas.Compressor compressor(redeclare package Medium = Media.Air, tablePhic = tablePhicC, tableEta = tableEtaC, pstart_in = 1.01325e5, pstart_out = 2.45e6, Tstart_in = 301.15, tablePR = tablePR, Table = ThermoPower.Choices.TurboMachinery.TableTypes.matrix, Tstart_out = 600.4, explicitIsentropicEnthalpy = true, Tdes_in = 301.15, Ndesign = 157.08) annotation(
        Placement(transformation(origin = {-286, 10}, extent = {{-158, -90}, {-98, -30}})));
      Gas.Turbine turbine(redeclare package Medium = FlueGas, pstart_in = 2.38e6, pstart_out = 1.05e5, tablePhic = tablePhicT, tableEta = tableEtaT, Table = ThermoPower.Choices.TurboMachinery.TableTypes.matrix, Tstart_out = 800, Tdes_in = 1400, Tstart_in = 1370, Ndesign = 157.08) annotation(
        Placement(transformation(origin = {-326, 10}, extent = {{-6, -90}, {54, -30}})));
      Gas.CombustionChamber CombustionChamber1(gamma = 1, Cm = 1, pstart = 2.41e6, Tstart = 1370, V = 0.05, S = 0.05, initOpt = ThermoPower.Choices.Init.Options.steadyState, HH = 41.6e6) annotation(
        Placement(transformation(origin = {-306, 14}, extent = {{-72, 20}, {-32, 60}})));
      Gas.SourcePressure SourceP1(redeclare package Medium = Media.Air, p0 = 1.01325e5, T = 301.15) annotation(
        Placement(transformation(origin = {-298, 20}, extent = {{-188, -30}, {-168, -10}})));
      Gas.SourceMassFlow SourceW1(redeclare package Medium = Media.NaturalGas, w0 = 6.06, p0 = 2500000, T = 300, use_in_w0 = true) annotation(
        Placement(transformation(origin = {-276, 18}, extent = {{-100, 70}, {-80, 90}})));
      Gas.PressDrop PressDrop1(redeclare package Medium = FlueGas, FFtype = ThermoPower.Choices.PressDrop.FFtypes.OpPoint, wnom = 306, rhonom = 6, dpnom = 26000, pstart = 2410000, Tstart = 1370) annotation(
        Placement(transformation(origin = {-326, 18}, extent = {{-10, -10}, {10, 10}}, rotation = 270)));
      Gas.PressDrop PressDrop2(pstart = 2.45e6, FFtype = ThermoPower.Choices.PressDrop.FFtypes.OpPoint, A = 1, redeclare package Medium = Media.Air, dpnom = 0.19e5, wnom = 300, rhonom = 14, Tstart = 600) annotation(
        Placement(transformation(origin = {-390, 20}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
      Modelica.Mechanics.Rotational.Sensors.PowerSensor powerSensor_GT annotation(
        Placement(transformation(origin = {-322, 10}, extent = {{60, -70}, {80, -50}})));
      Modelica.Blocks.Continuous.FirstOrder fuelFlowActuator(k = 1, T = 4, y_start = 500, initType = Modelica.Blocks.Types.Init.SteadyState) annotation(
        Placement(transformation(origin = {-283.25, 57.5}, extent = {{-120.75, 80.5}, {-106.75, 94.5}})));
      Modelica.Blocks.Continuous.FirstOrder powerSensor1_GT(k = 1, T = 1, y_start = 170e6, initType = Modelica.Blocks.Types.Init.SteadyState) annotation(
        Placement(transformation(origin = {-396, 106}, extent = {{146, -118}, {162, -102}})));
      Modelica.Blocks.Interfaces.RealOutput generatedPower_GT annotation(
        Placement(transformation(origin = {-404, -6}, extent = {{196, -10}, {216, 10}}), iconTransformation(extent = {{196, -10}, {216, 10}})));
      
      ThermoPower.PowerPlants.HRSG.Components.StateReader_gas stateInletCC(redeclare package Medium = Media.Air) annotation(
        Placement(transformation(origin = {-306, 14}, extent = {{-100, 30}, {-80, 50}})));
      ThermoPower.PowerPlants.HRSG.Components.StateReader_gas stateOutletCC(redeclare package Medium = Media.FlueGas) annotation(
        Placement(transformation(origin = {-306, 14}, extent = {{-24, 30}, {-4, 50}})));
      // ST Components
      Models.PrescribedPresureCondenser condenser(p = 5390, redeclare package Medium = Water, initOpt = ThermoPower.Choices.Init.Options.fixedState) annotation(
        Placement(transformation(origin = {-32, 0}, extent = {{100, -100}, {140, -60}})));
      Models.PrescribedSpeedPump prescribedSpeedPump(n0 = 1500, nominalMassFlowRate = 55, q_nom = {0, 0.055, 0.1}, redeclare package FluidMedium = Water, head_nom = {450, 300, 0}, rho0 = 1000, nominalOutletPressure = 3000000, nominalInletPressure = 50000) annotation(
        Placement(transformation(extent = {{40, -180}, {0, -140}})));
      Modelica.Blocks.Continuous.FirstOrder nPumpActuator(k = 1, initType = Modelica.Blocks.Types.Init.SteadyState, T = 2, y_start = 1500) annotation(
        Placement(transformation(origin = {20, -60}, extent = {{-280, -110}, {-260, -90}})));
      Modelica.Blocks.Interfaces.RealOutput generatedPower_ST annotation(
        Placement(transformation(origin = {-48, 10}, extent = {{290, 90}, {310, 110}}), iconTransformation(extent = {{290, 90}, {310, 110}})));
      Modelica.Blocks.Continuous.FirstOrder powerSensor_ST_ctrl(k = 1, T = 1, y_start = 170e6, initType = Modelica.Blocks.Types.Init.SteadyState) annotation(
        Placement(transformation(origin = {-86, 10}, extent = {{240, 90}, {260, 110}})));
      Modelica.Blocks.Interfaces.RealOutput voidFraction_ST annotation(
        Placement(transformation(origin = {-155, -185}, extent = {{435, 165}, {465, 135}}), iconTransformation(extent = {{290, -110}, {310, -90}})));
      Modelica.Blocks.Continuous.FirstOrder voidFractionSensor_ST(k = 1, T = 1, initType = Modelica.Blocks.Types.Init.SteadyState, y_start = 0.2) annotation(
        Placement(transformation(origin = {-86, 68}, extent = {{240, -110}, {260, -90}})));
      ThermoPower.Water.SteamTurbineStodola steamTurbine(wstart = 55, wnom = 55, Kt = 0.0104, redeclare package Medium = Water, PRstart = 30, pnom = 3000000) annotation(
        Placement(transformation(origin = {-48, -4}, extent = {{50, 30}, {100, 80}})));
      Modelica.Mechanics.Rotational.Sensors.PowerSensor powerSensor_ST annotation(
        Placement(transformation(origin = {-34, -2}, extent = {{138, 68}, {166, 40}})));
      Models.HE economizer(redeclare package FluidMedium = Water, redeclare package FlueGasMedium = FlueGas, N_F = 6, exchSurface_G = 40095.9, exchSurface_F = 3439.389, extSurfaceTub = 3888.449, gasVol = 10, fluidVol = 28.977, metalVol = 8.061, rhomcm = 7900*578.05, lambda = 20, gasNomFlowRate = 500, fluidNomFlowRate = 55, gamma_G = 30, gamma_F = 3000, rhonom_G = 1, Kfnom_F = 150, FFtype_G = ThermoPower.Choices.Flow1D.FFtypes.OpPoint, FFtype_F = ThermoPower.Choices.Flow1D.FFtypes.Kfnom, N_G = 6, gasNomPressure = 101325, fluidNomPressure = 3000000, Tstart_G = 473.15, Tstart_M = 423.15, dpnom_G = 1000, dpnom_F = 20000) annotation(
        Placement(transformation(extent = {{-120, -80}, {-80, -120}})));
      Models.Evaporator evaporator(redeclare package FluidMedium = Water, redeclare package FlueGasMedium = FlueGas, gasVol = 10, fluidVol = 12.400, metalVol = 4.801, gasNomFlowRate = 500, fluidNomFlowRate = 55, N = 4, rhom = 7900, cm = 578.05, gamma = 85, exchSurface = 24402, gasNomPressure = 101325, fluidNomPressure = 3000000, Tstart = 623.15, FFtype_G = ThermoPower.Choices.Flow1D.FFtypes.OpPoint, dpnom_G = 1000, rhonom_G = 1) annotation(
        Placement(transformation(extent = {{-120, 0}, {-80, -40}})));
      Models.HE superheater(redeclare package FluidMedium = Water, redeclare package FlueGasMedium = FlueGas, N_F = 7, exchSurface_G = 2314.8, exchSurface_F = 450.218, extSurfaceTub = 504.652, gasVol = 10, fluidVol = 4.468, metalVol = 1.146, rhomcm = 7900*578.05, lambda = 20, gasNomFlowRate = 500, gamma_G = 90, gamma_F = 6000, fluidNomFlowRate = 55, rhonom_G = 1, Kfnom_F = 150, FluidPhaseStart = ThermoPower.Choices.FluidPhase.FluidPhases.Steam, FFtype_G = ThermoPower.Choices.Flow1D.FFtypes.OpPoint, FFtype_F = ThermoPower.Choices.Flow1D.FFtypes.Kfnom, N_G = 7, gasNomPressure = 101325, fluidNomPressure = 3000000, Tstart_G = 723.15, Tstart_M = 573.15, dpnom_G = 1000, dpnom_F = 20000) annotation(
        Placement(transformation(extent = {{-120, 80}, {-80, 40}})));
      ThermoPower.PowerPlants.HRSG.Components.StateReader_gas stateGasInletEvaporator(redeclare package Medium = FlueGas) annotation(
        Placement(transformation(extent = {{-150, -30}, {-130, -10}})));
      ThermoPower.PowerPlants.HRSG.Components.StateReader_gas stateGasInletEconomizer(redeclare package Medium = FlueGas) annotation(
        Placement(transformation(extent = {{-150, -110}, {-130, -90}})));
      ThermoPower.PowerPlants.HRSG.Components.StateReader_gas stateGasOutlet(redeclare package Medium = FlueGas) annotation(
        Placement(transformation(extent = {{-70, -110}, {-50, -90}})));
      ThermoPower.PowerPlants.HRSG.Components.StateReader_water stateWaterSuperheater_in(redeclare package Medium = Water) annotation(
        Placement(transformation(origin = {-100, 20}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
      ThermoPower.PowerPlants.HRSG.Components.StateReader_water stateWaterSuperheater_out(redeclare package Medium = Water) annotation(
        Placement(transformation(origin = {-100, 100}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
      ThermoPower.PowerPlants.HRSG.Components.StateReader_water stateWaterEvaporator_in(redeclare package Medium = Water) annotation(
        Placement(transformation(origin = {-100, -60}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
      ThermoPower.PowerPlants.HRSG.Components.StateReader_water stateWaterEconomizer_in(redeclare package Medium = Water) annotation(
        Placement(transformation(origin = {-100, -140}, extent = {{-10, -10}, {10, 10}}, rotation = 90)));
      ThermoPower.Gas.SinkPressure sinkP_gas(T = 400, redeclare package Medium = FlueGas) annotation(
        Placement(transformation(extent = {{-40, -110}, {-20, -90}})));
      Modelica.Mechanics.Rotational.Sources.ConstantSpeed constantSpeed_ST(w_fixed = 157, phi(start = 0, fixed = true)) annotation(
        Placement(transformation(origin = {-20, -2}, extent = {{200, 44}, {180, 64}})));
      inner System system(allowFlowReversal = false, initOpt = ThermoPower.Choices.Init.Options.steadyState) annotation(
        Placement(transformation(extent = {{240, 160}, {260, 180}})));
      Modelica.Blocks.Sources.Ramp powerSetPoint(duration = 50, startTime = 200, height = 5e6, offset = 170e6) annotation(
        Placement(transformation(origin = {-76, 44}, extent = {{-440, 96}, {-420, 116}})));
      Models.PID powerController(PVmin = 0, PVmax = 350e6, CSmax = 15, CSmin = 2, PVstart = 0.4857, CSstart = 0.3377, steadyStateInit = true, Kp = 5.385, Ti = 20) annotation(
        Placement(transformation(origin = {-152, 40}, extent = {{-300, 96}, {-280, 116}})));
      Modelica.Blocks.Sources.Step voidFractionSetPoint(offset = 0.2, height = 0, startTime = 0) annotation(
        Placement(transformation(origin = {-12, -46}, extent = {{-360, -120}, {-340, -100}})));
      Models.PID voidFractionController(PVmin = 0.1, PVmax = 0.9, CSmax = 2500, PVstart = 0.1, CSstart = 0.5, steadyStateInit = true, CSmin = 500, Kp = -2, Ti = 300) annotation(
        Placement(transformation(origin = {-12, -50}, extent = {{-300, -120}, {-280, -100}})));
      ThermoPower.PowerPlants.HRSG.Components.StateReader_gas stateTurbineExhaust(redeclare package Medium = FlueGas) annotation(
        Placement(transformation(origin = {-198, 60}, extent = {{-10, -10}, {10, 10}})));
    equation
// GT Connections
      connect(prescribedSpeedPump.inlet, condenser.waterOut) annotation(
        Line(points = {{-356, 98}, {-356, 85}, {-358, 85}, {-358, 74}}, color = {159, 159, 223}));
      connect(SourceP1.flange, compressor.inlet) annotation(
        Line(points = {{-466, 0}, {-438, 0}, {-438, -26}}, color = {159, 159, 223}));
      connect(PressDrop1.outlet, turbine.inlet) annotation(
        Line(points = {{-326, 8}, {-326, -26}}, color = {159, 159, 223}));
      connect(compressor.outlet, PressDrop2.inlet) annotation(
        Line(points = {{-390, -26}, {-390, 10}}, color = {159, 159, 223}));
      connect(compressor.shaft_b, turbine.shaft_a) annotation(
        Line(points = {{-396, -50}, {-320, -50}}));
      connect(powerSensor_GT.flange_a, turbine.shaft_b) annotation(
        Line(points = {{-262, -50}, {-284, -50}}));
      connect(fuelFlowActuator.u, powerController.CS) annotation(
        Line(points = {{-405, 145}, {-432, 145}, {-432, 146}}, color = {0, 0, 127}));
      connect(powerController.SP, powerSetPoint.y) annotation(
        Line(points = {{-452, 150}, {-495, 150}}, color = {0, 0, 127}));
      connect(powerController.PV, generatedPower_GT) annotation(
        Line(points = {{-452, 142}, {-452, 142}, {-480, 142}, {-480, 170}, {-180, 170}, {-180, -6}}, color = {0, 0, 127}));
      connect(fuelFlowActuator.y, SourceW1.in_w0) annotation(
        Line(points = {{-389, 145}, {-374.2, 145}, {-374.2, 103}, {-372.2, 103}}, color = {0, 0, 127}));
      connect(SourceW1.flange, CombustionChamber1.inf) annotation(
        Line(points = {{-344, 98}, {-344, 85}, {-346, 85}, {-346, 74}}, color = {159, 159, 223}));
      connect(powerSensor_GT.power, powerSensor1_GT.u) annotation(
        Line(points = {{-260, -61}, {-260, -32.5}, {-252, -32.5}, {-252, -4}}, color = {0, 0, 127}));
      connect(powerSensor1_GT.y, generatedPower_GT) annotation(
        Line(points = {{-233.2, -4}, {-215.7, -4}, {-215.7, -6}, {-198.2, -6}}, color = {0, 0, 127}));
      connect(CombustionChamber1.ina, stateInletCC.outlet) annotation(
        Line(points = {{-378, 54}, {-384, 54}, {-384, 56}, {-390, 56}}, color = {159, 159, 223}));
      connect(stateInletCC.inlet, PressDrop2.outlet) annotation(
        Line(points = {{-402, 54}, {-410, 54}, {-410, 34}}, color = {159, 159, 223}));
      connect(stateOutletCC.inlet, CombustionChamber1.out) annotation(
        Line(points = {{-326, 54}, {-332, 54}, {-332, 52}, {-338, 52}}, color = {159, 159, 223}));
      connect(stateOutletCC.outlet, PressDrop1.inlet) annotation(
        Line(points = {{-314, 54}, {-306, 54}, {-306, 32}}, color = {159, 159, 223}));
      connect(constantSpeed_GT.flange, powerSensor_GT.flange_b) annotation(Line(points = {{-210, -50}, {-240, -50}}));
// Bridge: GT exhaust to ST HRSG
      connect(turbine.outlet, stateTurbineExhaust.inlet) annotation(
        Line(points = {{-278, -26}, {-278, 61}, {-204, 61}, {-204, 60}}, color = {159, 159, 223}));
      connect(stateTurbineExhaust.outlet, superheater.gasIn) annotation(
        Line(points = {{-192, 60}, {-121, 60}}, color = {159, 159, 223}));
// ST Connections
      connect(generatedPower_ST, powerSensor_ST_ctrl.y) annotation(
        Line(points = {{252, 110}, {175, 110}}, color = {0, 0, 127}));
      connect(nPumpActuator.u, voidFractionController.CS) annotation(
        Line(points = {{-262, -160}, {-292, -160}}, color = {0, 0, 127}));
      connect(voidFractionController.SP, voidFractionSetPoint.y) annotation(
        Line(points = {{-312, -156}, {-351, -156}}, color = {0, 0, 127}));
      connect(voidFractionController.PV, voidFraction_ST) annotation(
        Line(points = {{-312, -164}, {-326, -164}, {-326, -234}, {295, -234}, {295, -35}}, color = {0, 0, 127}));
      connect(voidFraction_ST, voidFractionSensor_ST.y) annotation(
        Line(points = {{295, -35}, {280.5, -35}, {280.5, -32}, {175, -32}}, color = {0, 0, 127}));
      connect(powerSensor_ST.flange_a, steamTurbine.shaft_b) annotation(
        Line(points = {{104, 52}, {91, 52}, {91, 51}, {43, 51}}));
      connect(condenser.steamIn, steamTurbine.outlet) annotation(
        Line(points = {{88, -60}, {88, 71}, {47, 71}}));
      connect(prescribedSpeedPump.outlet, stateWaterEconomizer_in.inlet) annotation(
        Line(points = {{0, -160}, {-100, -160}, {-100, -146}}));
      connect(stateWaterEconomizer_in.outlet, economizer.waterIn) annotation(
        Line(points = {{-100, -134}, {-100, -120}}));
      connect(economizer.waterOut, stateWaterEvaporator_in.inlet) annotation(
        Line(points = {{-100, -80}, {-100, -66}}));
      connect(stateWaterEvaporator_in.outlet, evaporator.waterIn) annotation(
        Line(points = {{-100, -54}, {-100, -40}}));
      connect(economizer.gasIn, stateGasInletEconomizer.outlet) annotation(
        Line(points = {{-120, -100}, {-128, -100}, {-134, -100}}));
      connect(stateGasInletEconomizer.inlet, evaporator.gasOut) annotation(
        Line(points = {{-146, -100}, {-160, -100}, {-160, -50}, {-40, -50}, {-40, -20}, {-80, -20}}));
      connect(sinkP_gas.flange, stateGasOutlet.outlet) annotation(
        Line(points = {{-40, -100}, {-54, -100}}));
      connect(stateGasOutlet.inlet, economizer.gasOut) annotation(
        Line(points = {{-66, -100}, {-74, -100}, {-80, -100}}));
      connect(evaporator.gasIn, stateGasInletEvaporator.outlet) annotation(
        Line(points = {{-120, -20}, {-134, -20}}));
      connect(stateGasInletEvaporator.inlet, superheater.gasOut) annotation(
        Line(points = {{-146, -20}, {-160, -20}, {-160, 30}, {-40, 30}, {-40, 60}, {-80, 60}}));
      connect(evaporator.waterOut, stateWaterSuperheater_in.inlet) annotation(
        Line(points = {{-100, 0}, {-100, 14}}));
      connect(stateWaterSuperheater_in.outlet, superheater.waterIn) annotation(
        Line(points = {{-100, 26}, {-100, 40}}));
      connect(superheater.waterOut, stateWaterSuperheater_out.inlet) annotation(
        Line(points = {{-100, 80}, {-100, 94}}));
      connect(stateWaterSuperheater_out.outlet, steamTurbine.inlet) annotation(
        Line(points = {{-100, 106}, {-100, 120}, {7, 120}, {7, 71}}));
      connect(powerSensor_ST_ctrl.u, powerSensor_ST.power) annotation(
        Line(points = {{152, 110}, {152, 108.5}, {108, 108.5}, {108, 109}, {107.5, 109}, {107.5, 67}, {107, 67}}, color = {0, 0, 127}));
      connect(voidFractionSensor_ST.u, evaporator.voidFraction) annotation(
        Line(points = {{152, -32}, {-78.8, -32}}, color = {0, 0, 127}));
      connect(nPumpActuator.y, prescribedSpeedPump.nPump) annotation(
        Line(points = {{-239, -160}, {-239, -160}, {-239, -158}, {-138, -158}, {-138, -194}, {160, -194}, {160, -148}, {34.4, -148}}, color = {0, 0, 127}));
      connect(constantSpeed_ST.flange, powerSensor_ST.flange_b) annotation(
        Line(points = {{160, 52}, {132, 52}}));
      annotation(
        experiment(StopTime = 1000, Tolerance = 1e-06),
        Diagram(coordinateSystem(preserveAspectRatio = false, extent = {{-520, 180}, {320, -240}}, initialScale = 0.1)),
        Icon(coordinateSystem(preserveAspectRatio = false, extent = {{-100, -100}, {100, 100}}, initialScale = 0.1), graphics = {Rectangle(extent = {{-100, 100}, {100, -100}}, lineColor = {0, 0, 255}, fillColor = {255, 255, 255}, fillPattern = FillPattern.Solid), Text(extent = {{-88, 84}, {100, -96}}, lineColor = {0, 0, 255}, textString = "CC")}),
        Documentation(info = "<html><p>Combined cycle power plant simulation model.</p></html>"));
    end CloseLoopCombineCycle;
  end Simulators;
end CombineCycle;

within ;
model BraytonCycle_Dynamic "Dynamic Brayton Cycle with Fuel Step Changes"
  
  // Use Modelica 4.0 units
  import SI = Modelica.Units.SI;
  
  // Design parameters (base case)
  parameter SI.Temperature T1 = 288.15 "Compressor inlet temperature (15°C)";
  parameter SI.Pressure P1 = 101325 "Compressor inlet pressure";
  parameter Real PR = 18 "Pressure ratio";
  parameter Real eta_c = 0.88 "Compressor isentropic efficiency";
  
  parameter SI.Temperature T3_nominal = 1673.15 "Nominal turbine inlet temperature (1400°C)";
  parameter Real eta_t = 0.90 "Turbine isentropic efficiency";
  parameter Real eta_m = 0.98 "Mechanical efficiency";
  
  parameter SI.MassFlowRate m_air = 600 "Air mass flow rate [kg/s]";
  parameter SI.MassFlowRate m_fuel_nominal = 12.5 "Nominal fuel mass flow rate [kg/s]";
  parameter Real LHV = 50e6 "Lower heating value of fuel [J/kg]";
  parameter Real pressure_loss_cc = 0.05 "Combustion chamber pressure loss";
  
  // Gas properties
  parameter Real cp_air = 1005 "Specific heat of air [J/(kg.K)]";
  parameter Real gamma_air = 1.4 "Ratio of specific heats for air";
  parameter Real cp_exhaust = 1150 "Specific heat of exhaust [J/(kg.K)]";
  parameter Real gamma_exhaust = 1.33 "Ratio of specific heats for exhaust";
  
  // Dynamic fuel input with step changes
  SI.MassFlowRate m_fuel "Actual fuel mass flow rate";
  SI.Temperature T3 "Turbine inlet temperature (varies with fuel)";
  
  // State variables - temperatures
  SI.Temperature T2 "Compressor outlet temperature";
  SI.Temperature T2s "Compressor isentropic outlet temperature";
  SI.Temperature T4 "Turbine outlet temperature";
  SI.Temperature T4s "Turbine isentropic outlet temperature";
  
  // State variables - pressures
  SI.Pressure P2 "Compressor outlet pressure";
  SI.Pressure P3 "Turbine inlet pressure";
  SI.Pressure P4 "Turbine outlet pressure";
  
  // Power variables
  SI.Power W_c "Compressor power";
  SI.Power W_t "Turbine power";
  SI.Power W_net "Net power output";
  SI.Power Q_fuel "Fuel thermal input";
  
  // Performance metrics
  Real eta_thermal "Thermal efficiency";
  SI.MassFlowRate m_exhaust "Exhaust mass flow";
  Real expansion_ratio "Turbine expansion ratio";
  Real work_ratio "Work ratio (net/gross)";
  Real load_percentage "Load as percentage of nominal";
  
  // Outputs for easy access
  output SI.Power netPower = W_net "Net power output [W]";
  output Real thermalEfficiency = eta_thermal "Thermal efficiency";
  output SI.Temperature T_exhaust = T4 "Exhaust temperature [K]";
  output SI.Temperature T_compressor_out = T2 "Compressor outlet temperature [K]";
  output SI.Power compressorPower = W_c "Compressor power [W]";
  output SI.Power turbinePower = W_t "Turbine power [W]";
  output SI.MassFlowRate fuelFlow = m_fuel "Fuel flow rate [kg/s]";
  output Real loadPercent = load_percentage "Load percentage";
  
equation
  // Dynamic fuel input: Step changes at different times
  // 0-200s: 80% load (10 kg/s fuel)
  // 200-400s: 100% load (12.5 kg/s fuel)
  // 400-600s: 120% load (15 kg/s fuel)
  // 600-800s: 100% load (12.5 kg/s fuel)
  // 800-1000s: 60% load (7.5 kg/s fuel)
  
  if time < 200 then
    m_fuel = 10.0;  // 80% load
  elseif time < 400 then
    m_fuel = 12.5;  // 100% load (nominal)
  elseif time < 600 then
    m_fuel = 15.0;  // 120% load
  elseif time < 800 then
    m_fuel = 12.5;  // 100% load
  else
    m_fuel = 7.5;   // 60% load
  end if;
  
  // Calculate turbine inlet temperature based on fuel flow
  // More fuel = higher temperature (simplified combustion model)
  // Energy balance: m_air*cp_air*T2 + m_fuel*LHV*eta_cc = (m_air+m_fuel)*cp_exhaust*T3
  // Simplified: T3 varies proportionally with fuel flow
  T3 = T2 + (m_fuel / m_fuel_nominal) * (T3_nominal - T2);
  
  // Calculate load percentage
  load_percentage = (m_fuel / m_fuel_nominal) * 100;
  
  // Compressor calculations (constant speed assumption)
  P2 = P1 * PR;
  T2s = T1 * (PR ^ ((gamma_air - 1) / gamma_air));
  T2 = T1 + (T2s - T1) / eta_c;
  W_c = m_air * cp_air * (T2 - T1);
  
  // Combustion chamber
  P3 = P2 * (1 - pressure_loss_cc);
  m_exhaust = m_air + m_fuel;
  Q_fuel = m_fuel * LHV;
  
  // Turbine calculations
  P4 = P1 * 1.02;
  expansion_ratio = P3 / P4;
  T4s = T3 / (expansion_ratio ^ ((gamma_exhaust - 1) / gamma_exhaust));
  T4 = T3 - eta_t * (T3 - T4s);
  W_t = m_exhaust * cp_exhaust * (T3 - T4);
  
  // Overall performance
  W_net = (W_t - W_c) * eta_m;
  eta_thermal = W_net / Q_fuel;
  work_ratio = W_net / W_t;
  
  annotation (
    Icon(coordinateSystem(preserveAspectRatio=false), graphics={
      Rectangle(extent={{-100,100},{100,-100}}, lineColor={0,0,0}, fillColor={255,255,255}, fillPattern=FillPattern.Solid),
      Ellipse(extent={{-60,60},{60,-60}}, lineColor={0,0,0}, fillColor={255,128,0}, fillPattern=FillPattern.Solid),
      Polygon(points={{-20,30},{20,0},{-20,-30},{-20,30}}, lineColor={0,0,0}, fillColor={255,255,255}, fillPattern=FillPattern.Solid),
      Text(extent={{-100,140},{100,100}}, lineColor={0,0,0}, textString="%name")}),
    Diagram(coordinateSystem(preserveAspectRatio=false)),
    Documentation(info="<html>
<h4>Dynamic Brayton Cycle Model</h4>
<p>This model simulates a gas turbine with varying fuel input to observe dynamic response.</p>
<p><b>Load Steps:</b></p>
<ul>
<li>0-200s: 80% load (10 kg/s fuel)</li>
<li>200-400s: 100% load (12.5 kg/s fuel)</li>
<li>400-600s: 120% load (15 kg/s fuel)</li>
<li>600-800s: 100% load (12.5 kg/s fuel)</li>
<li>800-1000s: 60% load (7.5 kg/s fuel)</li>
</ul>
<p>The model calculates turbine inlet temperature based on fuel flow rate.</p>
</html>"),
    experiment(StartTime=0, StopTime=1000, Interval=1, Tolerance=1e-6));
end BraytonCycle_Dynamic;

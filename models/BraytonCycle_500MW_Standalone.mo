within ;
model BraytonCycle_500MW_Standalone "Standalone Brayton Cycle Model for 500MW CCGT"
  
  // Use Modelica 4.0 units
  import SI = Modelica.Units.SI;
  
  // Design parameters
  parameter SI.Temperature T1 = 288.15 "Compressor inlet temperature (15°C)";
  parameter SI.Pressure P1 = 101325 "Compressor inlet pressure";
  parameter Real PR = 18 "Pressure ratio";
  parameter Real eta_c = 0.88 "Compressor isentropic efficiency";
  
  parameter SI.Temperature T3 = 1673.15 "Turbine inlet temperature (1400°C)";
  parameter Real eta_t = 0.90 "Turbine isentropic efficiency";
  parameter Real eta_m = 0.98 "Mechanical efficiency";
  
  parameter SI.MassFlowRate m_air = 600 "Air mass flow rate [kg/s]";
  parameter SI.MassFlowRate m_fuel = 12.5 "Fuel mass flow rate [kg/s]";
  parameter Real LHV = 50e6 "Lower heating value of fuel [J/kg]";
  parameter Real pressure_loss_cc = 0.05 "Combustion chamber pressure loss";
  
  // Gas properties
  parameter Real cp_air = 1005 "Specific heat of air [J/(kg.K)]";
  parameter Real gamma_air = 1.4 "Ratio of specific heats for air";
  parameter Real cp_exhaust = 1150 "Specific heat of exhaust [J/(kg.K)]";
  parameter Real gamma_exhaust = 1.33 "Ratio of specific heats for exhaust";
  
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
  SI.SpecificEnthalpy h_exhaust "Exhaust specific enthalpy available";
  
  // Outputs for easy access
  output SI.Power netPower = W_net "Net power output [W]";
  output Real thermalEfficiency = eta_thermal "Thermal efficiency";
  output SI.Temperature T_exhaust = T4 "Exhaust temperature [K]";
  output SI.Temperature T_compressor_out = T2 "Compressor outlet temperature [K]";
  output SI.Power compressorPower = W_c "Compressor power [W]";
  output SI.Power turbinePower = W_t "Turbine power [W]";
  
equation
  // Compressor calculations
  P2 = P1 * PR;
  T2s = T1 * (PR ^ ((gamma_air - 1) / gamma_air));
  T2 = T1 + (T2s - T1) / eta_c;
  W_c = m_air * cp_air * (T2 - T1);
  
  // Combustion chamber
  P3 = P2 * (1 - pressure_loss_cc);
  m_exhaust = m_air + m_fuel;
  Q_fuel = m_fuel * LHV;
  
  // Turbine calculations
  P4 = P1 * 1.02; // Slightly above atmospheric
  expansion_ratio = P3 / P4;
  T4s = T3 / (expansion_ratio ^ ((gamma_exhaust - 1) / gamma_exhaust));
  T4 = T3 - eta_t * (T3 - T4s);
  W_t = m_exhaust * cp_exhaust * (T3 - T4);
  
  // Overall performance
  W_net = (W_t - W_c) * eta_m;
  eta_thermal = W_net / Q_fuel;
  work_ratio = W_net / W_t;
  
  // Available exhaust heat (down to 120°C for HRSG)
  h_exhaust = m_exhaust * cp_exhaust * (T4 - 393.15);
  
  annotation (
    Icon(coordinateSystem(preserveAspectRatio=false), graphics={
      Rectangle(extent={{-100,100},{100,-100}}, lineColor={0,0,0}, fillColor={255,255,255}, fillPattern=FillPattern.Solid),
      Ellipse(extent={{-60,60},{60,-60}}, lineColor={0,0,0}, fillColor={255,128,0}, fillPattern=FillPattern.Solid),
      Text(extent={{-80,20},{80,-20}}, lineColor={0,0,0}, textString="GT"),
      Text(extent={{-100,140},{100,100}}, lineColor={0,0,0}, textString="%name")}),
    Diagram(coordinateSystem(preserveAspectRatio=false)),
    Documentation(info="<html>
<h4>Standalone Brayton Cycle Model for 500MW CCGT</h4>
<p>This is a simplified analytical model that calculates the steady-state 
performance of a Brayton cycle (gas turbine) without requiring ThermoPower library components.</p>

<h4>Main Components (Modeled):</h4>
<ul>
<li><b>Compressor:</b> Compresses ambient air with pressure ratio of 18:1</li>
<li><b>Combustion Chamber:</b> Burns natural gas fuel to heat the compressed air</li>
<li><b>Turbine:</b> Expands hot gases to produce power</li>
</ul>

<h4>Design Parameters:</h4>
<ul>
<li>Air mass flow: 600 kg/s</li>
<li>Fuel mass flow: 12.5 kg/s natural gas</li>
<li>Compression ratio: 18:1</li>
<li>Turbine inlet temperature: 1400°C (1673 K)</li>
<li>Compressor isentropic efficiency: 88%</li>
<li>Turbine isentropic efficiency: 90%</li>
<li>Mechanical efficiency: 98%</li>
</ul>

<h4>Expected Performance:</h4>
<ul>
<li>Gas turbine net output: ~275 MW</li>
<li>Gas turbine efficiency: ~44%</li>
<li>Exhaust temperature: ~642°C</li>
<li>Available for HRSG: ~368 MW thermal</li>
</ul>

<h4>Usage:</h4>
<p>This model can be opened directly in OpenModelica without requiring the ThermoPower library.
Simply load the file and simulate. All thermodynamic calculations are included.</p>

<h4>Outputs:</h4>
<ul>
<li>netPower: Net electrical power output [W]</li>
<li>thermalEfficiency: Thermal efficiency [fraction]</li>
<li>T_exhaust: Exhaust gas temperature [K]</li>
<li>compressorPower: Power consumed by compressor [W]</li>
<li>turbinePower: Power generated by turbine [W]</li>
</ul>

<p>For the complete 500MW Combined Cycle, this gas turbine can be integrated with 
an HRSG and steam turbine to achieve ~63% combined cycle efficiency.</p>
</html>"),
    experiment(StartTime=0, StopTime=1, Interval=1, Tolerance=1e-6));
end BraytonCycle_500MW_Standalone;

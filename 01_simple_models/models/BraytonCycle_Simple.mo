within ;
model BraytonCycleSimple "Simplified Brayton Cycle for efficiency calculation"
  
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
  
  // State variables and outputs
  SI.Temperature T2 "Compressor outlet temperature";
  SI.Temperature T2s "Compressor isentropic outlet temperature";
  SI.Pressure P2 "Compressor outlet pressure";
  SI.Pressure P3 "Turbine inlet pressure";
  SI.Pressure P4 "Turbine outlet pressure";
  SI.Temperature T4 "Turbine outlet temperature";
  SI.Temperature T4s "Turbine isentropic outlet temperature";
  
  SI.Power W_c "Compressor power";
  SI.Power W_t "Turbine power";
  SI.Power W_net "Net power output";
  SI.Power Q_fuel "Fuel thermal input";
  
  Real eta_thermal "Thermal efficiency";
  SI.MassFlowRate m_exhaust "Exhaust mass flow";
  Real expansion_ratio "Turbine expansion ratio";
  
  // Outputs for easy access
  output SI.Power netPower = W_net "Net power output";
  output Real thermalEfficiency = eta_thermal "Thermal efficiency";
  output SI.Temperature T_exhaust = T4 "Exhaust temperature";
  
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
  
  annotation (
    Icon(coordinateSystem(preserveAspectRatio=false)),
    Diagram(coordinateSystem(preserveAspectRatio=false)),
    Documentation(info="<html>
<h4>Simplified Brayton Cycle Model</h4>
<p>This is a simplified analytical model that calculates the steady-state 
performance of a Brayton cycle without using complex component models.</p>
<p>It provides the same thermodynamic calculations as a detailed simulation 
but runs much faster for parameter studies.</p>
</html>"),
    experiment(StartTime=0, StopTime=1, Interval=1));
end BraytonCycleSimple;

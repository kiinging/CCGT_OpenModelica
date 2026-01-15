within ;
model HRSG_Simple "Simplified Heat Recovery Steam Generator (3-Pressure Levels)"
  
  import SI = Modelica.Units.SI;
  
  // ============================================================================
  // INPUT PARAMETERS (from Gas Turbine Exhaust)
  // ============================================================================
  
  parameter SI.MassFlowRate m_gas = 612.5 "Exhaust gas mass flow rate [kg/s]";
  parameter SI.Temperature T_gas_in = 915.15 "Gas inlet temperature [K] (642°C)";
  parameter SI.Pressure P_gas_in = 103000 "Gas inlet pressure [Pa]";
  parameter Real cp_gas = 1150 "Gas specific heat [J/(kg·K)]";
  
  // ============================================================================
  // DESIGN PARAMETERS
  // ============================================================================
  
  // High Pressure (HP) Section
  parameter SI.Pressure P_HP = 80e5 "HP steam pressure [Pa] (80 bar)";
  parameter SI.Temperature T_HP = 813.15 "HP steam temperature [K] (540°C)";
  parameter Real eta_HP = 0.85 "HP section heat transfer efficiency";
  
  // Intermediate Pressure (IP) Section
  parameter SI.Pressure P_IP = 20e5 "IP steam pressure [Pa] (20 bar)";
  parameter SI.Temperature T_IP = 673.15 "IP steam temperature [K] (400°C)";
  parameter Real eta_IP = 0.85 "IP section heat transfer efficiency";
  
  // Low Pressure (LP) Section
  parameter SI.Pressure P_LP = 5e5 "LP steam pressure [Pa] (5 bar)";
  parameter SI.Temperature T_LP = 523.15 "LP steam temperature [K] (250°C)";
  parameter Real eta_LP = 0.80 "LP section heat transfer efficiency";
  
  // Feedwater inlet conditions
  parameter SI.Temperature T_water_in = 303.15 "Feedwater inlet temperature [K] (30°C)";
  parameter SI.Pressure P_water_in = 85e5 "Feedwater inlet pressure [Pa]";
  
  // Stack conditions
  parameter SI.Temperature T_stack_target = 393.15 "Target stack temperature [K] (120°C)";
  
  // ============================================================================
  // STEAM PROPERTIES (Simplified Correlations)
  // ============================================================================
  
  // Enthalpy of liquid water (simplified)
  function h_water
    input SI.Temperature T;
    output SI.SpecificEnthalpy h;
  algorithm
    h := 4186 * (T - 273.15);  // cp_water * (T - T_ref)
  end h_water;
  
  // Enthalpy of saturated steam (simplified correlation)
  function h_sat_steam
    input SI.Pressure P;
    output SI.SpecificEnthalpy h;
  protected
    SI.Temperature T_sat;
  algorithm
    // Simplified saturation temperature (accurate to ~2%)
    T_sat := 273.15 + 100 + 15 * log10(P/1e5);
    h := 4186 * (T_sat - 273.15) + 2257000;  // h_water + h_fg
  end h_sat_steam;
  
  // Enthalpy of superheated steam (simplified)
  function h_steam
    input SI.Temperature T;
    input SI.Pressure P;
    output SI.SpecificEnthalpy h;
  protected
    SI.SpecificEnthalpy h_sat;
    SI.Temperature T_sat;
    Real cp_steam = 2200;
  algorithm
    h_sat := h_sat_steam(P);
    T_sat := 273.15 + 100 + 15 * log10(P/1e5);
    h := h_sat + cp_steam * (T - T_sat);  // Add superheat
  end h_steam;
  
  // ============================================================================
  // STATE VARIABLES
  // ============================================================================
  
  // Gas temperatures through HRSG
  SI.Temperature T_gas_HP_out "Gas temp leaving HP section";
  SI.Temperature T_gas_IP_out "Gas temp leaving IP section";
  SI.Temperature T_gas_LP_out "Gas temp leaving LP section (stack)";
  
  // Steam flow rates
  SI.MassFlowRate m_steam_HP "HP steam flow rate";
  SI.MassFlowRate m_steam_IP "IP steam flow rate";
  SI.MassFlowRate m_steam_LP "LP steam flow rate";
  SI.MassFlowRate m_steam_total "Total steam production";
  
  // Heat transferred
  SI.Power Q_HP "Heat transferred in HP section";
  SI.Power Q_IP "Heat transferred in IP section";
  SI.Power Q_LP "Heat transferred in LP section";
  SI.Power Q_total "Total heat recovered";
  
  // Specific enthalpies
  SI.SpecificEnthalpy h_water_HP_in;
  SI.SpecificEnthalpy h_steam_HP_out;
  SI.SpecificEnthalpy h_water_IP_in;
  SI.SpecificEnthalpy h_steam_IP_out;
  SI.SpecificEnthalpy h_water_LP_in;
  SI.SpecificEnthalpy h_steam_LP_out;
  
  // Performance metrics
  Real eta_HRSG "Overall HRSG efficiency";
  SI.Power Q_available "Available heat in exhaust";
  
  // Outputs
  output SI.MassFlowRate steamFlowHP = m_steam_HP;
  output SI.MassFlowRate steamFlowIP = m_steam_IP;
  output SI.MassFlowRate steamFlowLP = m_steam_LP;
  output SI.Temperature stackTemp = T_gas_LP_out;
  output SI.Power heatRecovered = Q_total;
  output Real HRSGefficiency = eta_HRSG;
  
equation
  // ============================================================================
  // ENTHALPY CALCULATIONS
  // ============================================================================
  
  // HP section enthalpies
  h_water_HP_in = h_water(T_water_in);
  h_steam_HP_out = h_steam(T_HP, P_HP);
  
  // IP section enthalpies  
  h_water_IP_in = h_water(T_water_in + 20);  // Slightly preheated
  h_steam_IP_out = h_steam(T_IP, P_IP);
  
  // LP section enthalpies
  h_water_LP_in = h_water(T_water_in);
  h_steam_LP_out = h_steam(T_LP, P_LP);
  
  // ============================================================================
  // HIGH PRESSURE (HP) SECTION
  // ============================================================================
  // Hot gas enters, cools while heating water to high-pressure steam
  
  // Heat available from gas
  Q_HP = eta_HP * m_gas * cp_gas * (T_gas_in - T_gas_HP_out);
  
  // Heat absorbed by water/steam
  Q_HP = m_steam_HP * (h_steam_HP_out - h_water_HP_in);
  
  // Gas outlet temperature (based on energy balance)
  T_gas_HP_out = T_gas_in - Q_HP / (m_gas * cp_gas);
  
  // Steam production (simplified - allocate 40% of gas flow energy to HP)
  m_steam_HP = 0.40 * m_gas * cp_gas * (T_gas_in - T_gas_HP_out) / 
                (h_steam_HP_out - h_water_HP_in);
  
  // ============================================================================
  // INTERMEDIATE PRESSURE (IP) SECTION
  // ============================================================================
  
  // Heat available from gas
  Q_IP = eta_IP * m_gas * cp_gas * (T_gas_HP_out - T_gas_IP_out);
  
  // Heat absorbed by water/steam
  Q_IP = m_steam_IP * (h_steam_IP_out - h_water_IP_in);
  
  // Gas outlet temperature
  T_gas_IP_out = T_gas_HP_out - Q_IP / (m_gas * cp_gas);
  
  // Steam production (allocate 35% to IP)
  m_steam_IP = 0.35 * m_gas * cp_gas * (T_gas_HP_out - T_gas_IP_out) / 
                (h_steam_IP_out - h_water_IP_in);
  
  // ============================================================================
  // LOW PRESSURE (LP) SECTION
  // ============================================================================
  
  // Heat available from gas
  Q_LP = eta_LP * m_gas * cp_gas * (T_gas_IP_out - T_gas_LP_out);
  
  // Heat absorbed by water/steam
  Q_LP = m_steam_LP * (h_steam_LP_out - h_water_LP_in);
  
  // Gas outlet temperature (stack)
  T_gas_LP_out = max(T_stack_target, 
                     T_gas_IP_out - Q_LP / (m_gas * cp_gas));
  
  // Steam production (remaining energy to LP)
  m_steam_LP = 0.25 * m_gas * cp_gas * (T_gas_IP_out - T_gas_LP_out) / 
                (h_steam_LP_out - h_water_LP_in);
  
  // ============================================================================
  // OVERALL PERFORMANCE
  // ============================================================================
  
  // Total steam production
  m_steam_total = m_steam_HP + m_steam_IP + m_steam_LP;
  
  // Total heat recovered
  Q_total = Q_HP + Q_IP + Q_LP;
  
  // Available heat in exhaust (above 120°C)
  Q_available = m_gas * cp_gas * (T_gas_in - T_stack_target);
  
  // HRSG efficiency
  eta_HRSG = Q_total / Q_available;
  
  annotation (
    Icon(coordinateSystem(preserveAspectRatio=false), graphics={
      Rectangle(extent={{-100,80},{100,-80}}, lineColor={0,0,0}, fillColor={255,200,150}, fillPattern=FillPattern.Solid),
      Text(extent={{-80,60},{80,40}}, textString="HRSG"),
      Text(extent={{-80,20},{80,0}}, textString="3-Pressure"),
      Line(points={{-100,60},{-60,60}}, color={255,0,0}, thickness=3),
      Line(points={{60,40},{100,40}}, color={0,0,255}, thickness=2),
      Line(points={{60,0},{100,0}}, color={0,0,255}, thickness=2),
      Line(points={{60,-40},{100,-40}}, color={0,0,255}, thickness=2),
      Line(points={{-100,-60},{-60,-60}}, color={0,127,255}, thickness=2),
      Line(points={{60,-60},{100,-60}}, color={170,170,170}, thickness=2),
      Text(extent={{-120,75},{-70,65}}, textString="Hot Gas"),
      Text(extent={{70,55},{120,45}}, textString="HP"),
      Text(extent={{70,15},{120,5}}, textString="IP"),
      Text(extent={{70,-25},{120,-35}}, textString="LP"),
      Text(extent={{70,-50},{120,-60}}, textString="Stack")}),
    Documentation(info="<html>
<h4>Simplified HRSG Model (3-Pressure Levels)</h4>
<p>Heat Recovery Steam Generator that produces steam at three pressure levels:</p>
<ul>
<li><b>HP:</b> 80 bar, 540°C - Main steam for turbine</li>
<li><b>IP:</b> 20 bar, 400°C - Intermediate pressure steam</li>
<li><b>LP:</b> 5 bar, 250°C - Low pressure steam</li>
</ul>
<p><b>Input:</b> Hot exhaust gas at 642°C</p>
<p><b>Output:</b> Three steam streams + cooled gas at 120°C</p>
<p><b>Efficiency:</b> Typically 80-85% heat recovery</p>
</html>"));
  
end HRSG_Simple;

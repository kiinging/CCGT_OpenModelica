within ;
model SteamTurbine_Simple "Simplified Steam Turbine (HP-IP-LP)"
  
  import SI = Modelica.Units.SI;
  
  // ============================================================================
  // INPUT PARAMETERS (from HRSG)
  // ============================================================================
  
  // High Pressure (HP) Steam Input (FROM HRSG)
  parameter SI.MassFlowRate m_HP = 33.5 "HP steam mass flow [kg/s] (from HRSG)";
  parameter SI.Temperature T_HP_in = 813.15 "HP steam inlet temp [K] (540°C)";
  parameter SI.Pressure P_HP_in = 80e5 "HP steam inlet pressure [Pa] (80 bar)";
  
  // Intermediate Pressure (IP) Steam Input (FROM HRSG)
  parameter SI.MassFlowRate m_IP = 28.4 "IP steam mass flow [kg/s] (from HRSG)";
  parameter SI.Temperature T_IP_in = 673.15 "IP steam inlet temp [K] (400°C)";
  parameter SI.Pressure P_IP_in = 20e5 "IP steam inlet pressure [Pa] (20 bar)";
  
  // Low Pressure (LP) Steam Input (FROM HRSG)
  parameter SI.MassFlowRate m_LP = 33.4 "LP steam mass flow [kg/s] (from HRSG)";
  parameter SI.Temperature T_LP_in = 523.15 "LP steam inlet temp [K] (250°C)";
  parameter SI.Pressure P_LP_in = 5e5 "LP steam inlet pressure [Pa] (5 bar)";
  
  // ============================================================================
  // DESIGN PARAMETERS
  // ============================================================================
  
  // Condenser pressure (vacuum)
  parameter SI.Pressure P_condenser = 5000 "Condenser pressure [Pa] (0.05 bar)";
  
  // Turbine efficiencies
  parameter Real eta_HP = 0.88 "HP turbine isentropic efficiency";
  parameter Real eta_IP = 0.90 "IP turbine isentropic efficiency";
  parameter Real eta_LP = 0.87 "LP turbine isentropic efficiency";
  parameter Real eta_mechanical = 0.98 "Mechanical efficiency";
  
  // Steam properties (simplified)
  parameter Real cp_steam = 2200 "Steam specific heat [J/(kg·K)]";
  parameter Real gamma_steam = 1.3 "Ratio of specific heats";
  
  // ============================================================================
  // STEAM PROPERTY FUNCTIONS (Simplified)
  // ============================================================================
  
  function h_steam
    "Enthalpy of superheated steam"
    input SI.Temperature T;
    input SI.Pressure P;
    output SI.SpecificEnthalpy h;
  protected
    SI.Temperature T_sat;
    SI.SpecificEnthalpy h_fg = 2257000;
  algorithm
    T_sat := 273.15 + 100 + 15 * log10(P/1e5);  // Saturation temp
    h := 4186 * (T_sat - 273.15) + h_fg + 2200 * (T - T_sat);
  end h_steam;
  
  function h_satwater
    "Enthalpy of saturated water"
    input SI.Pressure P;
    output SI.SpecificEnthalpy h;
  protected
    SI.Temperature T_sat;
  algorithm
    T_sat := 273.15 + 100 + 15 * log10(P/1e5);
    h := 4186 * (T_sat - 273.15);
  end h_satwater;
  
  // ============================================================================
  // STATE VARIABLES
  // ============================================================================
  
  // HP Turbine
  SI.Temperature T_HP_out "HP turbine outlet temperature";
  SI.Pressure P_HP_out "HP turbine outlet pressure";
  SI.SpecificEnthalpy h_HP_in;
  SI.SpecificEnthalpy h_HP_out;
  SI.SpecificEnthalpy h_HP_out_s "Isentropic outlet enthalpy";
  SI.Power W_HP "HP turbine power";
  
  // IP Turbine
  SI.Temperature T_IP_out "IP turbine outlet temperature";
  SI.Pressure P_IP_out "IP turbine outlet pressure";
  SI.SpecificEnthalpy h_IP_in;
  SI.SpecificEnthalpy h_IP_out;
  SI.SpecificEnthalpy h_IP_out_s "Isentropic outlet enthalpy";
  SI.Power W_IP "IP turbine power";
  SI.MassFlowRate m_IP_total "IP turbine total flow (IP + HP exhaust)";
  
  // LP Turbine
  SI.Temperature T_LP_out "LP turbine outlet temperature";
  SI.SpecificEnthalpy h_LP_in;
  SI.SpecificEnthalpy h_LP_out;
  SI.SpecificEnthalpy h_LP_out_s "Isentropic outlet enthalpy";
  SI.Power W_LP "LP turbine power";
  SI.MassFlowRate m_LP_total "LP turbine total flow (all streams)";
  
  // Overall performance
  SI.Power W_gross "Gross turbine power";
  SI.Power W_net "Net turbine power (after mechanical losses)";
  SI.Power Q_input "Total thermal input to steam cycle";
  Real eta_steam_cycle "Steam cycle efficiency";
  
  // Outputs
  output SI.Power turbinePower = W_net;
  output Real steamCycleEfficiency = eta_steam_cycle;
  output SI.Temperature condenserTemp = T_LP_out;
  output SI.MassFlowRate totalSteamFlow = m_LP_total;
  
equation
  // ============================================================================
  // HP TURBINE (80 bar → 20 bar)
  // ============================================================================
  
  // Inlet enthalpy
  h_HP_in = h_steam(T_HP_in, P_HP_in);
  
  // Outlet pressure (exhausts to IP pressure)
  P_HP_out = P_IP_in;
  
  // Isentropic expansion
  // Simplified: T_out_s / T_in = (P_out / P_in)^((gamma-1)/gamma)
  h_HP_out_s = h_HP_in - cp_steam * T_HP_in * 
                (1 - (P_HP_out/P_HP_in)^((gamma_steam-1)/gamma_steam));
  
  // Actual outlet enthalpy (with efficiency)
  h_HP_out = h_HP_in - eta_HP * (h_HP_in - h_HP_out_s);
  
  // Outlet temperature
  T_HP_out = T_HP_in - (h_HP_in - h_HP_out) / cp_steam;
  
  // Power generation
  W_HP = m_HP * (h_HP_in - h_HP_out);
  
  // ============================================================================
  // IP TURBINE (20 bar → 5 bar)
  // ============================================================================
  
  // Combined flow: Fresh IP steam + HP turbine exhaust
  m_IP_total = m_IP + m_HP;
  
  // Mixed inlet enthalpy
  h_IP_in = (m_IP * h_steam(T_IP_in, P_IP_in) + m_HP * h_HP_out) / m_IP_total;
  
  // Outlet pressure (exhausts to LP pressure)
  P_IP_out = P_LP_in;
  
  // Isentropic expansion
  h_IP_out_s = h_IP_in - cp_steam * (T_IP_in + T_HP_out)/2 * 
                (1 - (P_IP_out/P_IP_in)^((gamma_steam-1)/gamma_steam));
  
  // Actual outlet enthalpy
  h_IP_out = h_IP_in - eta_IP * (h_IP_in - h_IP_out_s);
  
  // Outlet temperature
  T_IP_out = (T_IP_in + T_HP_out)/2 - (h_IP_in - h_IP_out) / cp_steam;
  
  // Power generation
  W_IP = m_IP_total * (h_IP_in - h_IP_out);
  
  // ============================================================================
  // LP TURBINE (5 bar → 0.05 bar condenser)
  // ============================================================================
  
  // Combined flow: Fresh LP steam + IP turbine exhaust
  m_LP_total = m_LP + m_IP_total;
  
  // Mixed inlet enthalpy
  h_LP_in = (m_LP * h_steam(T_LP_in, P_LP_in) + m_IP_total * h_IP_out) / m_LP_total;
  
  // Isentropic expansion to condenser
  h_LP_out_s = h_LP_in - cp_steam * (T_LP_in + T_IP_out)/2 * 
                (1 - (P_condenser/P_LP_in)^((gamma_steam-1)/gamma_steam));
  
  // Actual outlet enthalpy
  h_LP_out = h_LP_in - eta_LP * (h_LP_in - h_LP_out_s);
  
  // Outlet temperature
  T_LP_out = 273.15 + 100 + 15 * log10(P_condenser/1e5);  // ~33°C at 0.05 bar
  
  // Power generation
  W_LP = m_LP_total * (h_LP_in - h_LP_out);
  
  // ============================================================================
  // OVERALL PERFORMANCE
  // ============================================================================
  
  // Gross power
  W_gross = W_HP + W_IP + W_LP;
  
  // Net power (after mechanical losses)
  W_net = W_gross * eta_mechanical;
  
  // Total thermal input
  Q_input = m_HP * h_HP_in + m_IP * h_steam(T_IP_in, P_IP_in) + 
            m_LP * h_steam(T_LP_in, P_LP_in) - 
            m_LP_total * h_satwater(P_condenser);
  
  // Steam cycle efficiency (Rankine cycle)
  eta_steam_cycle = W_net / Q_input;
  
  annotation (
    Icon(coordinateSystem(preserveAspectRatio=false), graphics={
      Ellipse(extent={{-80,80},{80,-80}}, lineColor={0,0,0}, fillColor={0,128,0}, fillPattern=FillPattern.Solid),
      Polygon(points={{-40,40},{0,0},{-40,-40},{-40,40}}, lineColor={255,255,255}, fillColor={255,255,255}, fillPattern=FillPattern.Solid),
      Polygon(points={{40,40},{0,0},{40,-40},{40,40}}, lineColor={255,255,255}, fillColor={255,255,255}, fillPattern=FillPattern.Solid),
      Text(extent={{-60,20},{60,-20}}, textString="ST"),
      Line(points={{-100,40},{-80,40}}, color={0,0,255}, thickness=2),
      Line(points={{-100,0},{-80,0}}, color={0,0,255}, thickness=2),
      Line(points={{-100,-40},{-80,-40}}, color={0,0,255}, thickness=2),
      Line(points={{80,0},{100,0}}, color={170,170,170}, thickness=2),
      Line(points={{0,-80},{0,-100}}, color={0,128,0}, thickness=3),
      Text(extent={{-120,55},{-85,45}}, textString="HP"),
      Text(extent={{-120,15},{-85,5}}, textString="IP"),
      Text(extent={{-120,-25},{-85,-35}}, textString="LP"),
      Text(extent={{-30,-85},{30,-95}}, textString="Power")}),
    Documentation(info="<html>
<h4>Simplified Steam Turbine Model</h4>
<p>Three-section steam turbine (HP-IP-LP) for Rankine cycle:</p>
<ul>
<li><b>HP Turbine:</b> 80 bar → 20 bar, 88% efficiency</li>
<li><b>IP Turbine:</b> 20 bar → 5 bar, 90% efficiency (includes HP exhaust)</li>
<li><b>LP Turbine:</b> 5 bar → 0.05 bar, 87% efficiency (includes all flows)</li>
</ul>
<p><b>Inputs:</b> Three steam streams from HRSG</p>
<p><b>Output:</b> ~120 MW electrical power</p>
<p><b>Exhaust:</b> Low-pressure steam to condenser</p>
</html>"));
  
end SteamTurbine_Simple;

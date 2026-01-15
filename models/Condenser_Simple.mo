within ;
model Condenser_Simple "Simplified Steam Condenser"
  
  import SI = Modelica.Units.SI;
  
  // ============================================================================
  // INPUT PARAMETERS
  // ============================================================================
  
  parameter SI.MassFlowRate m_steam_in = 612 "Steam inlet mass flow [kg/s]";
  parameter SI.Temperature T_steam_in = 306.15 "Steam inlet temperature [K] (33°C)";
  parameter SI.Pressure P_condenser = 5000 "Condenser pressure [Pa] (0.05 bar vacuum)";
  
  // Cooling water parameters
  parameter SI.Temperature T_cooling_in = 288.15 "Cooling water inlet temp [K] (15°C)";
  parameter SI.Temperature T_cooling_out = 298.15 "Cooling water outlet temp [K] (25°C)";
  parameter Real cp_water = 4186 "Water specific heat [J/(kg·K)]";
  
  // ============================================================================
  // STEAM PROPERTIES
  // ============================================================================
  
  // Latent heat of vaporization at condenser pressure
  parameter SI.SpecificEnthalpy h_fg = 2430000 "Latent heat at 0.05 bar [J/kg]";
  
  // Enthalpy of saturated liquid
  parameter SI.SpecificEnthalpy h_cond_water = 137000 "Condensate enthalpy [J/kg]";
  
  // Enthalpy of incoming steam
  parameter SI.SpecificEnthalpy h_steam_in = 2567000 "Inlet steam enthalpy [J/kg]";
  
  // ============================================================================
  // STATE VARIABLES
  // ============================================================================
  
  SI.Power Q_rejected "Heat rejected to cooling water";
  SI.MassFlowRate m_cooling "Cooling water mass flow rate";
  SI.Temperature T_condensate "Condensate outlet temperature";
  SI.MassFlowRate m_condensate "Condensate flow rate (= steam in)";
  Real vacuum_level "Vacuum level in condenser [%]";
  
  // Outputs
  output SI.Power heatRejected = Q_rejected;
  output SI.MassFlowRate coolingWaterFlow = m_cooling;
  output SI.MassFlowRate condensateFlow = m_condensate;
  output SI.Temperature condensateTemp = T_condensate;
  
equation
  // ============================================================================
  // MASS BALANCE
  // ============================================================================
  
  // All steam condenses to liquid
  m_condensate = m_steam_in;
  
  // ============================================================================
  // ENERGY BALANCE
  // ============================================================================
  
  // Heat released by steam condensing
  Q_rejected = m_steam_in * (h_steam_in - h_cond_water);
  
  // Heat absorbed by cooling water
  Q_rejected = m_cooling * cp_water * (T_cooling_out - T_cooling_in);
  
  // Cooling water flow rate (from energy balance)
  m_cooling = Q_rejected / (cp_water * (T_cooling_out - T_cooling_in));
  
  // ============================================================================
  // CONDENSER CONDITIONS
  // ============================================================================
  
  // Condensate temperature (saturation temp at condenser pressure)
  T_condensate = 273.15 + 100 + 15 * log10(P_condenser/1e5);  // ~33°C
  
  // Vacuum level (how much below atmospheric)
  vacuum_level = (1 - P_condenser/101325) * 100;  // ~95% vacuum
  
  annotation (
    Icon(coordinateSystem(preserveAspectRatio=false), graphics={
      Rectangle(extent={{-100,60},{100,-60}}, lineColor={0,0,0}, fillColor={200,220,255}, fillPattern=FillPattern.Solid),
      Line(points={{-100,40},{-60,40}}, color={170,170,170}, thickness=2),
      Line(points={{60,-40},{100,-40}}, color={0,127,255}, thickness=2),
      Line(points={{-100,-20},{-60,-20}}, color={0,127,255}, thickness=1),
      Line(points={{60,20},{100,20}}, color={0,127,255}, thickness=1),
      Text(extent={{-80,50},{80,30}}, textString="CONDENSER"),
      Text(extent={{-120,55},{-70,45}}, textString="Steam"),
      Text(extent={{70,-25},{120,-35}}, textString="Water"),
      Ellipse(extent={{-40,20},{-20,0}}, lineColor={0,127,255}, fillColor={0,127,255}, fillPattern=FillPattern.Solid),
      Ellipse(extent={{-20,-10},{0,-30}}, lineColor={0,127,255}, fillColor={0,127,255}, fillPattern=FillPattern.Solid),
      Ellipse(extent={{0,20},{20,0}}, lineColor={0,127,255}, fillColor={0,127,255}, fillPattern=FillPattern.Solid),
      Ellipse(extent={{20,-10},{40,-30}}, lineColor={0,127,255}, fillColor={0,127,255}, fillPattern=FillPattern.Solid)}),
    Documentation(info="<html>
<h4>Simplified Condenser Model</h4>
<p>Condenses exhaust steam from LP turbine back to liquid water.</p>
<p><b>Operating Conditions:</b></p>
<ul>
<li>Pressure: 0.05 bar (95% vacuum)</li>
<li>Temperature: ~33°C</li>
<li>Steam flow: ~612 kg/s</li>
<li>Cooling water: ~18,000 kg/s</li>
</ul>
<p><b>Heat Rejection:</b> ~250 MW to cooling tower</p>
<p>The vacuum improves steam cycle efficiency by allowing maximum expansion.</p>
</html>"));
  
end Condenser_Simple;

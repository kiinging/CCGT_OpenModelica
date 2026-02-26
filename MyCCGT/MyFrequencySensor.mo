within MyCCGT;

model MyFrequencySensor
  ThermoPower.Electrical.PowerConnection port;
  Modelica.Blocks.Interfaces.RealOutput f "Hz";
equation
  port.P = 0;  // don't draw power
  f = der(port.theta) / (2*Modelica.Constants.pi);
end MyFrequencySensor;

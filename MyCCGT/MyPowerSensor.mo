within MyCCGT;

model MyPowerSensor
  ThermoPower.Electrical.PowerConnection port_a;
  ThermoPower.Electrical.PowerConnection port_b;

  Modelica.Blocks.Interfaces.RealOutput W "Power (W)";
  Modelica.Blocks.Interfaces.RealOutput P "Power (W) alias";

equation
  port_a.P + port_b.P = 0;
  port_a.theta = port_b.theta;

  W = -port_a.P;
  P = W;
end MyPowerSensor;

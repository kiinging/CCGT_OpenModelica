model test_BraytonCycle
  extends Modelica.Icons.Example;

  BraytonCycle plant annotation(
    Placement(transformation(extent = {{20, -20}, {60, 20}}, rotation = 0)));

  Modelica.Blocks.Sources.Step fuelFlowRate(
    height = 0.3,
    startTime = 500,
    offset = 2.13) annotation(
    Placement(transformation(extent = {{-40, -10}, {-20, 10}}, rotation = 0)));

  inner ThermoPower.System system annotation(
    Placement(transformation(extent = {{80, 80}, {100, 100}})));

equation
  connect(plant.fuelFlowRate, fuelFlowRate.y) annotation(
    Line(points = {{20, 0}, {-19, 0}}, color = {0, 0, 127}));

  annotation(
    experiment(StopTime = 1000, Tolerance = 1e-006, Interval=2),
    Documentation(info = "<html><p>Open-loop transient.</p></html>"));
end test_BraytonCycle;

model GA_Individual "GA optimisation wrapper — 3 design variables for M701F"
  // ===== Primary GA decision variables =====
  parameter Real ga_p_cond = 5390 "Condenser pressure (Pa)";
  parameter Real ga_p_drum = 8e6  "Steam drum / HRSG pressure (Pa)";
  parameter Real ga_pr_scale = 1.0 "PR map scale factor (1.0 = baseline M701F PR=21)";

  // ===== Derived parameters (auto-computed from decision variables) =====
  // Water saturation temperature approximation (valid 30-150 bar, error < 2 K)
  parameter Real ga_tsat = 361.0 + 59.5 * (ga_p_drum / 1e5) ^ 0.3;
  // Steam turbine pressure ratio
  parameter Real ga_pr_start = ga_p_drum / ga_p_cond;
  // Pump head scaling (proportional to discharge pressure)
  parameter Real ga_head_scale = (ga_p_drum - 50000) / (8e6 - 50000);
  // Compressor / GT pressure estimates
  parameter Real ga_pr_design = 21.0 * ga_pr_scale;
  parameter Real ga_p_comp_out = ga_pr_design * 101325;
  parameter Real ga_p_cc = ga_p_comp_out * 0.98;
  parameter Real ga_p_turb_in = ga_p_cc * 0.99;
  parameter Real ga_t_comp_out = 305.15 * ga_pr_design ^ 0.325;

  // ===== Scaled PR map =====
  parameter Real tablePR_ga[6, 4] = [
    0,  95,                    100,                    105;
    1,  17.6 * ga_pr_scale,    21.1 * ga_pr_scale,     25.0 * ga_pr_scale;
    2,  17.2 * ga_pr_scale,    20.7 * ga_pr_scale,     24.0 * ga_pr_scale;
    3,  16.2 * ga_pr_scale,    19.9 * ga_pr_scale,     22.6 * ga_pr_scale;
    4,  14.8 * ga_pr_scale,    19.0 * ga_pr_scale,     21.1 * ga_pr_scale;
    5,  13.3 * ga_pr_scale,    16.8 * ga_pr_scale,     18.9 * ga_pr_scale
  ];

  extends ThermoPower.CombineCycle.Simulators.OpenLoopCombineCycle_M701F(
    // PR map
    tablePR = tablePR_ga,
    // Condenser
    condenser(p = ga_p_cond),
    // HRSG steam pressure
    evaporator(fluidNomPressure = ga_p_drum, Tstart = ga_tsat),
    economizer(fluidNomPressure = ga_p_drum),
    superheater(fluidNomPressure = ga_p_drum),
    // Steam turbine
    steamTurbine(pnom = ga_p_drum, PRstart = ga_pr_start),
    // Feedwater pump
    prescribedSpeedPump(
      nominalOutletPressure = ga_p_drum,
      head_nom = {1100 * ga_head_scale, 750 * ga_head_scale, 0}
    ),
    // GT pressure start values (help convergence)
    compressor(pstart_out = ga_p_comp_out, Tstart_out = ga_t_comp_out, Tdes_in = 288.15),
    PressDrop2(pstart = ga_p_comp_out, Tstart = ga_t_comp_out),
    CombustionChamber1(pstart = ga_p_cc),
    PressDrop1(pstart = ga_p_cc),
    turbine(pstart_in = ga_p_turb_in),
    // Run at constant 19.72 kg/s fuel (501 MW operating point)
    fuelFlowRateStep(offset = 19.72, height = 0, startTime = 1e6)
  );
  annotation(experiment(StopTime = 500, Tolerance = 1e-6));
end GA_Individual;

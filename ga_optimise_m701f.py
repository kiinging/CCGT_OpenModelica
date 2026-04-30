#!/usr/bin/env python3
"""
GA Optimisation of M701F CCGT Thermal Efficiency
=================================================
Uses DEAP genetic algorithm + OMPython to optimise:
  x1: Condenser pressure (Pa)     [3000, 15000]
  x2: Steam drum pressure (Pa)    [4e6, 14e6]
  x3: PR scale factor             [0.6, 1.3]

Fitness: Combined cycle thermal efficiency
  eta_cc = (P_GT + P_ST) / (m_fuel * LHV) * 100  [%]

The model is compiled ONCE. Each evaluation runs the pre-compiled
executable with -override flags, so only the simulation itself
(~30-60 s) is needed per evaluation — no recompilation.

Model: OpenLoopCombineCycle_M701F (M701F working model)
  - TIT=1580K, PR=21, exhaust 903K, 748 kg/s air
  - Fuel: natural gas, LHV=47.1 MJ/kg, 17.22 kg/s (baseline before step)
  - Single-pressure HRSG at 80 bar
"""

import os
import sys
import time
import random
import csv
import json
import logging
import numpy as np

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

from deap import base, creator, tools

# ============================================================
# Configuration
# ============================================================

# --- Project paths ---
PROJECT_DIR = os.path.normpath(
    r"c:\Users\user\OneDrive\Documents"
    r"\CCGT_OpenModelica-main - M701F working model"
    r"\CCGT_OpenModelica-main"
)
THERMOPOWER_PKG = os.path.join(
    PROJECT_DIR, "ThermoPower", "ThermoPower", "package.mo"
)
WORK_DIR = os.path.join(PROJECT_DIR, "ga_workspace")
RESULTS_DIR = os.path.join(PROJECT_DIR, "ga_results")

# --- GA hyperparameters ---
POP_SIZE = 20
N_GEN = 10
CX_PROB = 0.7
MUT_PROB = 0.3
TOURN_K = 3
N_ELITE = 2
RANDOM_SEED = 42

# --- Parameter bounds [low, high] --- PRACTICAL TROPICAL CONSTRAINTS
#   x1: condenser pressure (Pa)   — limited by 28°C cooling water + 10°C approach
#   x2: steam drum pressure (Pa)  — limited by existing ST mechanical design
#   x3: PR scale factor           — limited by compressor surge/choke margins
BOUNDS = [
    (4500.0,   8000.0),     # 4.5-8 kPa (tropical cooling water limit)
    (6.0e6,    10.0e6),     # 60-100 bar (existing ST design range)
    (0.9,      1.1),        # PR 18.9-23.1 (compressor design margin)
]
PARAM_LABELS = ["Condenser P", "Drum P", "PR Scale"]
BASELINE = [5390.0, 8.0e6, 1.0]

# --- Thermodynamic constants (M701F specific) ---
FUEL_FLOW = 19.72    # kg/s  (open-loop steady-state fuel for 331 MW GT / 501 MW total)
HHV       = 47.1e6   # J/kg  (natural gas LHV, as in CombustionChamber1.HH)
Q_FUEL    = FUEL_FLOW * HHV   # 928.8 MW total fuel heat input

# --- Simulation settings ---
STOP_TIME   = 600    # s — sufficient for full steady state
SAMPLE_TIME = 599   # s — extract results near end of simulation


# ============================================================
# Utility helpers
# ============================================================

def fwd(path):
    """Convert Windows path to forward-slash for OpenModelica."""
    return path.replace("\\", "/")


# ============================================================
# OpenModelica Runner
# ============================================================

class OMCRunner:
    """Manages the OMC session for batch GA simulations.

    Workflow:
      1. start()  — load ThermoPower, load GA_Individual.mo, compile once
      2. evaluate(p_cond, p_drum, pr_scale) — run with -override, read results
      3. stop()   — close session
    """

    def __init__(self):
        self.omc = None
        self.compiled = False
        self.eval_count = 0
        self.failed_count = 0

    # ---- lifecycle ----

    def start(self):
        """Start OMC session, load library, compile GA model."""
        from OMPython import OMCSessionZMQ

        os.makedirs(WORK_DIR, exist_ok=True)
        os.makedirs(RESULTS_DIR, exist_ok=True)

        logging.info("Starting OpenModelica session...")
        self.omc = OMCSessionZMQ()

        # Working directory
        self.omc.sendExpression(f'cd("{fwd(WORK_DIR)}")')

        # Load ThermoPower library
        logging.info(f"Loading ThermoPower library...")
        ok = self.omc.sendExpression(f'loadFile("{fwd(THERMOPOWER_PKG)}")')
        if not ok:
            err = self.omc.sendExpression('getErrorString()')
            raise RuntimeError(f"Failed to load ThermoPower: {err}")
        logging.info("  ThermoPower loaded OK.")

        # Load GA wrapper model
        ga_mo = os.path.join(WORK_DIR, "GA_Individual.mo")
        if not os.path.exists(ga_mo):
            raise FileNotFoundError(f"GA model not found: {ga_mo}")
        ok = self.omc.sendExpression(f'loadFile("{fwd(ga_mo)}")')
        if not ok:
            err = self.omc.sendExpression('getErrorString()')
            raise RuntimeError(f"Failed to load GA_Individual: {err}")
        logging.info("  GA_Individual model loaded OK.")

        # Compile by running the first simulation (baseline values)
        logging.info("Compiling model (first simulation with baseline)...")
        logging.info("  This may take 2-5 minutes — please wait...")
        t0 = time.time()
        result = self.omc.sendExpression(
            f'simulate(GA_Individual, stopTime={STOP_TIME}, tolerance=1e-6, '
            f'simflags="-lv=-LOG_SUCCESS")'
        )
        dt = time.time() - t0
        result_str = str(result)

        if 'resultFile' not in result_str:
            err = self.omc.sendExpression('getErrorString()')
            logging.error(f"Compilation/simulation FAILED:\n{err[:500]}")
            raise RuntimeError("Failed to compile/simulate GA_Individual")

        self.compiled = True

        # Verify baseline results
        p_gt = self._read_val('generatedPower_GT')
        p_st = self._read_val('generatedPower_ST')
        if p_gt is not None and p_st is not None:
            eta = (p_gt + p_st) / Q_FUEL * 100
            logging.info(
                f"  Baseline OK ({dt:.0f}s): "
                f"GT={p_gt/1e6:.1f} MW, ST={p_st/1e6:.1f} MW, "
                f"Total={( p_gt+p_st)/1e6:.1f} MW, eta={eta:.2f}%"
            )
        else:
            logging.warning("  Baseline compiled but could not read results.")

        logging.info("Model compiled. Ready for GA optimisation.\n")

    def stop(self):
        """Close OMC session."""
        if self.omc:
            try:
                self.omc.sendExpression('quit()')
            except Exception:
                pass
            self.omc = None

    # ---- evaluation ----

    def evaluate(self, condenser_p, drum_p, pr_scale):
        """Run simulation with given design variables.

        Returns thermal efficiency (%) or 0.0 on failure.
        """
        self.eval_count += 1
        eid = self.eval_count

        override = (
            f"ga_p_cond={condenser_p:.2f},"
            f"ga_p_drum={drum_p:.1f},"
            f"ga_pr_scale={pr_scale:.6f}"
        )

        try:
            result = self.omc.sendExpression(
                f'simulate(GA_Individual, stopTime={STOP_TIME}, tolerance=1e-6, '
                f'simflags="-override {override} -lv=-LOG_SUCCESS")'
            )
            result_str = str(result)

            if 'resultFile' not in result_str:
                self.failed_count += 1
                logging.warning(
                    f"  #{eid}: FAILED | P_cond={condenser_p:.0f}Pa "
                    f"P_drum={drum_p/1e5:.0f}bar PR_s={pr_scale:.3f}"
                )
                return 0.0

            p_gt = self._read_val('generatedPower_GT')
            p_st = self._read_val('generatedPower_ST')

            if p_gt is None or p_st is None:
                self.failed_count += 1
                logging.warning(f"  #{eid}: FAILED (null results)")
                return 0.0

            # Physical feasibility
            if p_gt <= 0 or p_st <= 0:
                self.failed_count += 1
                logging.warning(
                    f"  #{eid}: INFEASIBLE — GT={p_gt/1e6:.1f}MW "
                    f"ST={p_st/1e6:.1f}MW"
                )
                return 0.0

            eta = (p_gt + p_st) / Q_FUEL * 100
            pr_d = 21.0 * pr_scale

            logging.info(
                f"  #{eid}: eta={eta:.2f}% | "
                f"GT={p_gt/1e6:.1f} ST={p_st/1e6:.1f} "
                f"Tot={( p_gt+p_st)/1e6:.1f}MW | "
                f"Pcond={condenser_p/1000:.1f}kPa "
                f"Pdrum={drum_p/1e5:.0f}bar PR={pr_d:.1f}"
            )
            return eta

        except Exception as e:
            self.failed_count += 1
            logging.error(f"  #{eid}: EXCEPTION — {e}")
            return 0.0

    def _read_val(self, var_name):
        """Read a variable value from the most recent simulation result."""
        try:
            v = self.omc.sendExpression(f'val({var_name}, {SAMPLE_TIME})')
            return float(v) if v is not None else None
        except Exception:
            return None


# ============================================================
# DEAP GA Setup
# ============================================================

# Maximise thermal efficiency
creator.create("FitnessMax", base.Fitness, weights=(1.0,))
creator.create("Individual", list, fitness=creator.FitnessMax)

toolbox = base.Toolbox()


def random_individual():
    """Create a random individual within parameter bounds."""
    return creator.Individual([
        random.uniform(*BOUNDS[0]),
        random.uniform(*BOUNDS[1]),
        random.uniform(*BOUNDS[2]),
    ])


def cx_blend_alpha(ind1, ind2, alpha=0.5):
    """BLX-alpha crossover for real-valued chromosomes."""
    for i in range(len(ind1)):
        lo = min(ind1[i], ind2[i])
        hi = max(ind1[i], ind2[i])
        span = hi - lo
        ind1[i] = random.uniform(lo - alpha * span, hi + alpha * span)
        ind2[i] = random.uniform(lo - alpha * span, hi + alpha * span)
        ind1[i] = float(np.clip(ind1[i], BOUNDS[i][0], BOUNDS[i][1]))
        ind2[i] = float(np.clip(ind2[i], BOUNDS[i][0], BOUNDS[i][1]))
    return ind1, ind2


def mut_gaussian(individual, sigma_frac=0.1, indpb=0.5):
    """Gaussian mutation with sigma as fraction of parameter range."""
    for i in range(len(individual)):
        if random.random() < indpb:
            sigma = sigma_frac * (BOUNDS[i][1] - BOUNDS[i][0])
            individual[i] += random.gauss(0, sigma)
            individual[i] = float(
                np.clip(individual[i], BOUNDS[i][0], BOUNDS[i][1])
            )
    return (individual,)


toolbox.register("individual", random_individual)
toolbox.register("population", tools.initRepeat, list, toolbox.individual)
toolbox.register("mate", cx_blend_alpha)
toolbox.register("mutate", mut_gaussian)
toolbox.register("select", tools.selTournament, tournsize=TOURN_K)


# ============================================================
# Plotting
# ============================================================

def plot_convergence(gen_log, save_path):
    """Generate convergence plot showing best/avg/worst per generation."""
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.plot(gen_log['gen'], gen_log['best'], 'b-o',
            lw=2, ms=6, label='Best')
    ax.plot(gen_log['gen'], gen_log['avg'], 'g--s',
            lw=1.5, ms=5, label='Average')
    ax.plot(gen_log['gen'], gen_log['worst'], 'r:^',
            lw=1, ms=4, label='Worst (valid)')
    ax.set_xlabel('Generation', fontsize=13)
    ax.set_ylabel('Thermal Efficiency (%)', fontsize=13)
    ax.set_title(
        'GA Convergence — M701F CCGT Thermal Efficiency Optimisation',
        fontsize=14
    )
    ax.legend(fontsize=11, loc='lower right')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-0.5, max(gen_log['gen']) + 0.5)
    plt.tight_layout()
    plt.savefig(save_path, dpi=150)
    plt.close()


def plot_parameters(csv_path, gen_log, save_path):
    """Plot parameter values coloured by fitness across generations."""
    try:
        data = np.genfromtxt(csv_path, delimiter=',', skip_header=1)
        if len(data) == 0:
            return

        fig, axes = plt.subplots(1, 3, figsize=(16, 5))
        col_labels = ['Condenser P (kPa)', 'Drum P (bar)', 'PR Scale']
        col_scales = [1/1000, 1/1e5, 1]
        col_indices = [2, 3, 4]   # CSV columns
        fit_col = 5
        gen_col = 0

        vmax = max(gen_log['best']) if gen_log['best'] else 65

        for ax, label, scale, ci in zip(axes, col_labels, col_scales,
                                         col_indices):
            gens = data[:, gen_col]
            vals = data[:, ci] * scale
            fits = data[:, fit_col]
            sc = ax.scatter(gens, vals, c=fits, cmap='RdYlGn',
                           s=20, alpha=0.6, vmin=0, vmax=vmax,
                           edgecolors='none')
            ax.set_xlabel('Generation', fontsize=11)
            ax.set_ylabel(label, fontsize=11)
            ax.grid(True, alpha=0.2)

        fig.colorbar(sc, ax=axes, label='Thermal Efficiency (%)',
                     shrink=0.8, pad=0.02)
        fig.suptitle('Parameter Evolution Across Generations',
                     fontsize=14, y=1.02)
        plt.tight_layout()
        plt.savefig(save_path, dpi=150, bbox_inches='tight')
        plt.close()
    except Exception as e:
        logging.warning(f"Could not generate parameter plot: {e}")


# ============================================================
# Main GA Loop
# ============================================================

def main():
    """Run the complete GA optimisation."""

    # ---- Logging setup ----
    os.makedirs(RESULTS_DIR, exist_ok=True)
    log_file = os.path.join(RESULTS_DIR, "ga_log.txt")
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s  %(message)s",
        handlers=[
            logging.FileHandler(log_file, mode='w', encoding='utf-8'),
            logging.StreamHandler(sys.stdout),
        ]
    )

    logging.info("=" * 72)
    logging.info("  GA OPTIMISATION OF M701F CCGT THERMAL EFFICIENCY")
    logging.info("=" * 72)
    logging.info(f"Population : {POP_SIZE}")
    logging.info(f"Generations: {N_GEN}")
    logging.info(f"Max evals  : ~{POP_SIZE + N_GEN * (POP_SIZE - N_ELITE)}")
    logging.info(f"Bounds     : P_cond  [{BOUNDS[0][0]/1e3:.0f}, "
                 f"{BOUNDS[0][1]/1e3:.0f}] kPa")
    logging.info(f"             P_drum  [{BOUNDS[1][0]/1e5:.0f}, "
                 f"{BOUNDS[1][1]/1e5:.0f}] bar")
    logging.info(f"             PR_scale[{BOUNDS[2][0]:.1f}, "
                 f"{BOUNDS[2][1]:.1f}] "
                 f"(PR {21*BOUNDS[2][0]:.1f}-{21*BOUNDS[2][1]:.1f})")
    logging.info(f"Fuel input : {FUEL_FLOW} kg/s x "
                 f"{HHV/1e6:.1f} MJ/kg = {Q_FUEL/1e6:.1f} MW")
    logging.info("")

    # ---- Start OMC ----
    runner = OMCRunner()
    runner.start()

    def evaluate_individual(ind):
        eta = runner.evaluate(ind[0], ind[1], ind[2])
        return (eta,)

    toolbox.register("evaluate", evaluate_individual)

    # ---- Seed RNG ----
    random.seed(RANDOM_SEED)
    np.random.seed(RANDOM_SEED)

    # ---- Initial population ----
    pop = toolbox.population(n=POP_SIZE)
    pop[0] = creator.Individual(BASELINE[:])   # ensure baseline is included

    # ---- Tracking ----
    hof = tools.HallOfFame(10)
    csv_path = os.path.join(RESULTS_DIR, "ga_all_evaluations.csv")
    csv_file = open(csv_path, 'w', newline='')
    csv_w = csv.writer(csv_file)
    csv_w.writerow([
        "gen", "ind", "condenser_p_Pa", "drum_p_Pa", "pr_scale",
        "efficiency_pct", "total_MW"
    ])

    gen_log = {'gen': [], 'best': [], 'avg': [], 'worst': []}
    t_start = time.time()

    # ================================================================
    #  Generation 0 — evaluate initial population
    # ================================================================
    logging.info(f"\n{'-' * 60}")
    logging.info(f"  Generation 0 / {N_GEN}")
    logging.info(f"{'-' * 60}")

    fitnesses = list(map(toolbox.evaluate, pop))
    for ind, fit in zip(pop, fitnesses):
        ind.fitness.values = fit
    hof.update(pop)

    valid = [f[0] for f in fitnesses if f[0] > 0]
    best_f = max(f[0] for f in fitnesses) if fitnesses else 0
    avg_f  = float(np.mean(valid)) if valid else 0
    worst_f = min(valid) if valid else 0
    n_fail = sum(1 for f in fitnesses if f[0] == 0)

    gen_log['gen'].append(0)
    gen_log['best'].append(best_f)
    gen_log['avg'].append(avg_f)
    gen_log['worst'].append(worst_f)

    for i, ind in enumerate(pop):
        eta = ind.fitness.values[0]
        mw = eta / 100 * Q_FUEL / 1e6
        csv_w.writerow([
            0, i, f"{ind[0]:.1f}", f"{ind[1]:.0f}",
            f"{ind[2]:.4f}", f"{eta:.4f}", f"{mw:.1f}"
        ])
    csv_file.flush()

    elapsed = time.time() - t_start
    logging.info(
        f"\n  Gen 0: best={best_f:.2f}%  avg={avg_f:.2f}%  "
        f"failed={n_fail}  [{elapsed/60:.1f} min]"
    )

    # ================================================================
    #  Evolution loop
    # ================================================================
    for gen in range(1, N_GEN + 1):
        elapsed = time.time() - t_start
        rate = elapsed / gen if gen > 0 else 60
        eta_remain = rate * (N_GEN - gen + 1)

        logging.info(f"\n{'-' * 60}")
        logging.info(
            f"  Generation {gen} / {N_GEN}  |  "
            f"ETA: ~{eta_remain/60:.0f} min remaining"
        )
        logging.info(f"{'-' * 60}")

        # Selection
        offspring = toolbox.select(pop, len(pop) - N_ELITE)
        offspring = list(map(toolbox.clone, offspring))

        # Crossover
        for c1, c2 in zip(offspring[::2], offspring[1::2]):
            if random.random() < CX_PROB:
                toolbox.mate(c1, c2)
                del c1.fitness.values
                del c2.fitness.values

        # Mutation
        for mut in offspring:
            if random.random() < MUT_PROB:
                toolbox.mutate(mut)
                del mut.fitness.values

        # Evaluate new/modified individuals
        invalids = [ind for ind in offspring if not ind.fitness.valid]
        logging.info(f"  Evaluating {len(invalids)} new individuals...")
        fitnesses = list(map(toolbox.evaluate, invalids))
        for ind, fit in zip(invalids, fitnesses):
            ind.fitness.values = fit

        # Elitism — carry forward best from previous gen
        elite = tools.selBest(pop, N_ELITE)
        elite = list(map(toolbox.clone, elite))
        offspring.extend(elite)
        pop[:] = offspring

        hof.update(pop)

        valid = [ind.fitness.values[0] for ind in pop
                 if ind.fitness.values[0] > 0]
        best_f = max(ind.fitness.values[0] for ind in pop)
        avg_f  = float(np.mean(valid)) if valid else 0
        worst_f = min(valid) if valid else 0
        n_fail = sum(1 for ind in pop if ind.fitness.values[0] == 0)

        gen_log['gen'].append(gen)
        gen_log['best'].append(best_f)
        gen_log['avg'].append(avg_f)
        gen_log['worst'].append(worst_f)

        # Log all individuals to CSV
        for i, ind in enumerate(pop):
            eta = ind.fitness.values[0]
            mw = eta / 100 * Q_FUEL / 1e6
            csv_w.writerow([
                gen, i, f"{ind[0]:.1f}", f"{ind[1]:.0f}",
                f"{ind[2]:.4f}", f"{eta:.4f}", f"{mw:.1f}"
            ])
        csv_file.flush()

        elapsed = time.time() - t_start
        b = hof[0]
        logging.info(
            f"\n  Gen {gen}: best={best_f:.2f}%  avg={avg_f:.2f}%  "
            f"failed={n_fail}"
        )
        logging.info(
            f"  Overall best: eta={b.fitness.values[0]:.2f}%  "
            f"P_cond={b[0]/1000:.1f}kPa  P_drum={b[1]/1e5:.0f}bar  "
            f"PR={21*b[2]:.1f} (s={b[2]:.3f})"
        )
        logging.info(
            f"  Evals: {runner.eval_count}  Failed: {runner.failed_count}  "
            f"Time: {elapsed/60:.1f} min"
        )

        # Save checkpoint
        ckpt = {
            'generation': gen,
            'best_fitness': b.fitness.values[0],
            'best_params': {
                'condenser_p_Pa': b[0],
                'drum_p_Pa': b[1],
                'pr_scale': b[2],
                'pr_design': 21.0 * b[2],
            },
            'gen_stats': gen_log,
            'total_evals': runner.eval_count,
            'elapsed_min': elapsed / 60,
        }
        with open(os.path.join(RESULTS_DIR, "ga_checkpoint.json"), 'w') as f:
            json.dump(ckpt, f, indent=2)

    # ================================================================
    #  Final results
    # ================================================================
    csv_file.close()
    total_time = time.time() - t_start

    logging.info(f"\n{'=' * 72}")
    logging.info("  OPTIMISATION COMPLETE")
    logging.info(f"{'=' * 72}")
    logging.info(
        f"Total time: {total_time/60:.1f} min  |  "
        f"{runner.eval_count} evaluations  |  "
        f"{runner.failed_count} failed"
    )

    # Top 5
    logging.info(f"\n{'-' * 50}")
    logging.info("  TOP 5 RESULTS")
    logging.info(f"{'-' * 50}")
    for rank, ind in enumerate(hof[:5], 1):
        eta_val = ind.fitness.values[0]
        mw = eta_val / 100 * Q_FUEL / 1e6
        pr = 21.0 * ind[2]
        logging.info(
            f"  #{rank}  eta = {eta_val:.2f}%  |  {mw:.1f} MW  |  "
            f"P_cond={ind[0]/1000:.2f} kPa  "
            f"P_drum={ind[1]/1e5:.0f} bar  "
            f"PR={pr:.1f}"
        )

    # Save summary
    best = hof[0]
    summary = os.path.join(RESULTS_DIR, "ga_best_result.txt")
    with open(summary, 'w') as f:
        f.write("GA Optimisation of M701F CCGT - Best Result\n")
        f.write("=" * 50 + "\n\n")
        eta_best = best.fitness.values[0]
        mw_best = eta_best / 100 * Q_FUEL / 1e6
        f.write(f"Optimal thermal efficiency:  {eta_best:.2f}%\n")
        f.write(f"Total power output:          {mw_best:.1f} MW\n\n")
        f.write("Optimal parameters:\n")
        f.write(f"  Condenser pressure:   {best[0]:.0f} Pa  "
                f"({best[0]/1000:.2f} kPa)\n")
        f.write(f"  Steam drum pressure:  {best[1]:.0f} Pa  "
                f"({best[1]/1e5:.1f} bar)\n")
        f.write(f"  PR scale factor:      {best[2]:.4f}  "
                f"(design PR = {21*best[2]:.1f})\n\n")
        f.write(f"Baseline:  P_cond=5.39 kPa  P_drum=80 bar  PR=21.0\n")
        f.write(f"Fuel:      {FUEL_FLOW} kg/s x "
                f"{HHV/1e6:.1f} MJ/kg = {Q_FUEL/1e6:.1f} MW\n\n")
        f.write(f"GA config: pop={POP_SIZE}  gen={N_GEN}  seed={RANDOM_SEED}\n")
        f.write(f"Evaluations: {runner.eval_count}  "
                f"Failed: {runner.failed_count}\n")
        f.write(f"Total time:  {total_time/60:.1f} minutes\n")
    logging.info(f"\nSummary saved to: {summary}")

    # Convergence plot
    conv_path = os.path.join(RESULTS_DIR, "ga_convergence.png")
    plot_convergence(gen_log, conv_path)
    logging.info(f"Convergence plot: {conv_path}")

    # Parameter evolution plot
    param_path = os.path.join(RESULTS_DIR, "ga_parameter_evolution.png")
    plot_parameters(csv_path, gen_log, param_path)
    logging.info(f"Parameter plot:   {param_path}")

    # Cleanup
    runner.stop()
    logging.info(f"\nAll results in: {RESULTS_DIR}")
    logging.info("Done.")

    return best


if __name__ == "__main__":
    best = main()

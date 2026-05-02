#!/usr/bin/env python3
"""
Humidity-Only Derating Comparison
==================================
Compares two tropical M701F models at the SAME temperature (32°C / 305.15 K):
  Case A: Media.TropicalAir (2.4% H2O by mass) — humid tropical (80% RH)
  Case B: Media.Air          (1.5% H2O by mass) — dry tropical baseline

This isolates the effect of humidity on CCGT power output.

Usage:  python simulate_humidity_comparison.py
Requires: OMPython, OpenModelica
"""

import os
import sys
import time

# --- Paths ---
PROJECT_DIR = os.path.normpath(
    r"c:\Users\user\OneDrive\Documents\FYP1"
    r"\CCGT_OpenModelica-main - M701F working model"
    r"\CCGT_OpenModelica-main"
)
THERMOPOWER_PKG = os.path.join(
    PROJECT_DIR, "ThermoPower", "ThermoPower", "package.mo"
)
DRY_TROPICAL_MO = os.path.join(
    PROJECT_DIR, "ga_workspace", "DryTropical_M701F.mo"
)
WORK_DIR = os.path.join(PROJECT_DIR, "ga_workspace")

# Simulation settings
STOP_TIME = 2100       # seconds
SAMPLE_TIME = 2000     # read steady-state at this time
FUEL_FLOW = 17.22      # kg/s
LHV = 47.1e6           # J/kg


def fwd(path):
    return path.replace("\\", "/")


def simulate_model(omc, model_name, label):
    """Simulate a model and extract steady-state power outputs."""
    print(f"\n{'='*60}")
    print(f"  Simulating: {model_name}")
    print(f"  ({label})")
    print(f"{'='*60}")

    t0 = time.time()
    result = omc.sendExpression(
        f'simulate({model_name}, '
        f'stopTime={STOP_TIME}, tolerance=1e-6, '
        f'simflags="-lv=-LOG_SUCCESS")'
    )
    dt = time.time() - t0
    result_str = str(result)

    if 'resultFile' not in result_str:
        err = omc.sendExpression('getErrorString()')
        print(f"  FAILED! Error:\n{err[:2000]}")
        return None

    # Read steady-state values
    p_gt = omc.sendExpression(f'val(generatedPower_GT, {SAMPLE_TIME})')
    p_st = omc.sendExpression(f'val(generatedPower_ST, {SAMPLE_TIME})')

    if p_gt is not None and p_st is not None:
        p_gt = float(p_gt)
        p_st = float(p_st)
        p_total = p_gt + p_st
        eta = p_total / (FUEL_FLOW * LHV) * 100

        print(f"\n  Results ({dt:.0f}s simulation, read at t={SAMPLE_TIME}s):")
        print(f"    GT Power:    {p_gt/1e6:.1f} MW")
        print(f"    ST Power:    {p_st/1e6:.1f} MW")
        print(f"    Total Power: {p_total/1e6:.1f} MW")
        print(f"    Efficiency:  {eta:.2f}%")
        return {'gt': p_gt, 'st': p_st, 'total': p_total, 'eta': eta, 'time': dt}
    else:
        print(f"  Could not read results (simulation took {dt:.0f}s)")
        return None


def main():
    from OMPython import OMCSessionZMQ

    os.makedirs(WORK_DIR, exist_ok=True)

    print("Starting OpenModelica session...")
    omc = OMCSessionZMQ()
    omc.sendExpression(f'cd("{fwd(WORK_DIR)}")')

    # Load ThermoPower library
    print("Loading ThermoPower library...")
    ok = omc.sendExpression(f'loadFile("{fwd(THERMOPOWER_PKG)}")')
    if not ok:
        err = omc.sendExpression('getErrorString()')
        print(f"FAILED to load ThermoPower:\n{err}")
        return
    print("  ThermoPower loaded OK.")

    # Load dry-tropical standalone model
    print("Loading DryTropical_M701F model...")
    ok = omc.sendExpression(f'loadFile("{fwd(DRY_TROPICAL_MO)}")')
    if not ok:
        err = omc.sendExpression('getErrorString()')
        print(f"FAILED to load DryTropical:\n{err}")
        return
    print("  DryTropical model loaded OK.\n")

    # --- Case B: Dry tropical (32°C, 1.5% H2O — standard Air) ---
    dry = simulate_model(
        omc,
        "OpenLoopCombineCycle_M701F_DryTropical",
        "Dry Tropical: 32 C, Media.Air (1.5% H2O)"
    )

    # --- Case A: Humid tropical (32°C, 2.4% H2O — TropicalAir) ---
    humid = simulate_model(
        omc,
        "ThermoPower.CombineCycle.Simulators.OpenLoopCombineCycle_M701F",
        "Humid Tropical: 32 C, Media.TropicalAir (2.4% H2O)"
    )

    # --- Comparison ---
    if dry and humid:
        print(f"\n{'='*65}")
        print(f"  HUMIDITY-ONLY DERATING: Dry vs Humid (both at 32 C)")
        print(f"{'='*65}")
        print(f"  Air medium:      Media.Air (1.5%)   TropicalAir (2.4%)")
        print(f"  H2O mass frac:   0.015              0.024")
        print(f"  Temperature:     305.15 K            305.15 K")
        print(f"{'='*65}")
        print(f"                   Dry Tropical  Humid Tropical  Delta")
        print(f"  GT Power:     {dry['gt']/1e6:10.1f} MW  {humid['gt']/1e6:10.1f} MW  {(humid['gt']-dry['gt'])/1e6:+.1f} MW")
        print(f"  ST Power:     {dry['st']/1e6:10.1f} MW  {humid['st']/1e6:10.1f} MW  {(humid['st']-dry['st'])/1e6:+.1f} MW")
        print(f"  Total Power:  {dry['total']/1e6:10.1f} MW  {humid['total']/1e6:10.1f} MW  {(humid['total']-dry['total'])/1e6:+.1f} MW")
        print(f"  Efficiency:   {dry['eta']:10.2f}%   {humid['eta']:10.2f}%   {humid['eta']-dry['eta']:+.2f}%")
        print(f"")
        derate_mw = dry['total'] - humid['total']
        derate_pct = derate_mw / dry['total'] * 100
        print(f"  Humidity-only derating: {derate_pct:.2f}% ({derate_mw/1e6:.1f} MW)")
        print(f"  (from {0.015*100:.1f}% to {0.024*100:.1f}% H2O by mass)")
        print(f"{'='*65}")

    # Cleanup
    try:
        omc.sendExpression('quit()')
    except:
        pass

    print("\nDone.")


if __name__ == "__main__":
    main()

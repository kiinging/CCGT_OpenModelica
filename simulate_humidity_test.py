#!/usr/bin/env python3
"""
Quick simulation of the M701F open-loop model with TropicalAir humidity.
Compares ISO vs Tropical power output to quantify derating.

Usage:  python simulate_humidity_test.py
Requires: OMPython (pip install OMPython), OpenModelica installed
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
WORK_DIR = os.path.join(PROJECT_DIR, "ga_workspace")

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
        f'simulate(ThermoPower.CombineCycle.Simulators.{model_name}, '
        f'stopTime=2100, tolerance=1e-6, '
        f'simflags="-lv=-LOG_SUCCESS")'
    )
    dt = time.time() - t0
    result_str = str(result)

    if 'resultFile' not in result_str:
        err = omc.sendExpression('getErrorString()')
        print(f"  FAILED! Error:\n{err[:1000]}")
        return None

    # Read steady-state values at t=2000 s
    p_gt = omc.sendExpression(f'val(generatedPower_GT, 2000)')
    p_st = omc.sendExpression(f'val(generatedPower_ST, 2000)')

    if p_gt is not None and p_st is not None:
        p_gt = float(p_gt)
        p_st = float(p_st)
        p_total = p_gt + p_st
        fuel = 17.22  # kg/s
        lhv = 47.1e6  # J/kg
        eta = p_total / (fuel * lhv) * 100

        print(f"\n  Results ({dt:.0f}s simulation):")
        print(f"    GT Power:    {p_gt/1e6:.1f} MW")
        print(f"    ST Power:    {p_st/1e6:.1f} MW")
        print(f"    Total Power: {p_total/1e6:.1f} MW")
        print(f"    Efficiency:  {eta:.2f}%")
        return {'gt': p_gt, 'st': p_st, 'total': p_total, 'eta': eta}
    else:
        print(f"  Could not read results (simulation took {dt:.0f}s)")
        return None


def main():
    from OMPython import OMCSessionZMQ

    os.makedirs(WORK_DIR, exist_ok=True)

    print("Starting OpenModelica session...")
    omc = OMCSessionZMQ()
    omc.sendExpression(f'cd("{fwd(WORK_DIR)}")')

    print("Loading ThermoPower library...")
    ok = omc.sendExpression(f'loadFile("{fwd(THERMOPOWER_PKG)}")')
    if not ok:
        err = omc.sendExpression('getErrorString()')
        print(f"FAILED to load ThermoPower:\n{err}")
        return

    err = omc.sendExpression('getErrorString()')
    if err and err.strip():
        print(f"  Warnings: {err[:300]}")
    print("  ThermoPower loaded OK.\n")

    # --- Simulate ISO model ---
    iso = simulate_model(
        omc,
        "OpenLoopCombineCycle_M701F_ISO",
        "ISO conditions: 15°C, Media.ISOAir (0.63% H2O, 60% RH)"
    )

    # --- Simulate Tropical model (now with TropicalAir) ---
    trop = simulate_model(
        omc,
        "OpenLoopCombineCycle_M701F",
        "Tropical: 32°C, Media.TropicalAir (2.4% H2O)"
    )

    # --- Compare ---
    if iso and trop:
        print(f"\n{'='*60}")
        print(f"  DERATING COMPARISON: ISO vs Tropical")
        print(f"{'='*60}")
        print(f"                    ISO          Tropical     Delta")
        print(f"  GT Power:     {iso['gt']/1e6:8.1f} MW   {trop['gt']/1e6:8.1f} MW   {(trop['gt']-iso['gt'])/1e6:+.1f} MW")
        print(f"  ST Power:     {iso['st']/1e6:8.1f} MW   {trop['st']/1e6:8.1f} MW   {(trop['st']-iso['st'])/1e6:+.1f} MW")
        print(f"  Total Power:  {iso['total']/1e6:8.1f} MW   {trop['total']/1e6:8.1f} MW   {(trop['total']-iso['total'])/1e6:+.1f} MW")
        print(f"  Efficiency:   {iso['eta']:8.2f}%    {trop['eta']:8.2f}%    {trop['eta']-iso['eta']:+.2f}%")
        print(f"\n  Total derating: {(iso['total']-trop['total'])/iso['total']*100:.1f}% "
              f"({(iso['total']-trop['total'])/1e6:.1f} MW)")
        print(f"    (includes both temperature + humidity effects)")

    # Cleanup
    try:
        omc.sendExpression('quit()')
    except:
        pass

    print("\nDone.")


if __name__ == "__main__":
    main()

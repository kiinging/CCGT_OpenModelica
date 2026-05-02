"""Quick test: verify OMPython can load ThermoPower and the GA model."""
import os
import time
from OMPython import OMCSessionZMQ

WORK = r"c:\Users\user\OneDrive\Documents\CCGT_OpenModelica-main - M701F working model\CCGT_OpenModelica-main\ga_workspace"
PKG  = r"c:\Users\user\OneDrive\Documents\CCGT_OpenModelica-main - M701F working model\CCGT_OpenModelica-main\ThermoPower\ThermoPower\package.mo"
GA   = os.path.join(WORK, "GA_Individual.mo")

# M701F fuel parameters
FUEL_FLOW = 19.72   # kg/s (open-loop steady-state for 331 MW GT / 501 MW total)
HHV       = 47.1e6  # J/kg (natural gas LHV used in M701F model)
Q_FUEL    = FUEL_FLOW * HHV

def fwd(p):
    return p.replace("\\", "/")

os.makedirs(WORK, exist_ok=True)
print("Starting OMC session...")
omc = OMCSessionZMQ()
omc.sendExpression(f'cd("{fwd(WORK)}")')

print("Loading ThermoPower library...")
t0 = time.time()
ok = omc.sendExpression(f'loadFile("{fwd(PKG)}")')
print(f"  loadFile => {ok}  ({time.time()-t0:.1f}s)")
err = omc.sendExpression('getErrorString()')
if err and err.strip() and err.strip() != '""':
    print(f"  Warnings/errors: {str(err)[:300]}")

print("Loading GA_Individual model...")
ok2 = omc.sendExpression(f'loadFile("{fwd(GA)}")')
print(f"  loadFile => {ok2}")
err2 = omc.sendExpression('getErrorString()')
if err2 and err2.strip() and err2.strip() != '""':
    print(f"  Warnings/errors: {str(err2)[:500]}")

print("\nRunning baseline simulation (this will compile — may take 2-5 min)...")
t0 = time.time()
result = omc.sendExpression(
    'simulate(GA_Individual, stopTime=300, tolerance=1e-6, '
    'simflags="-lv=-LOG_SUCCESS")'
)
dt = time.time() - t0
result_str = str(result)

if 'resultFile' in result_str:
    print(f"  Simulation OK ({dt:.0f}s)")
    p_gt = omc.sendExpression('val(generatedPower_GT, 280)')
    p_st = omc.sendExpression('val(generatedPower_ST, 280)')
    if p_gt is not None and p_st is not None:
        p_gt = float(p_gt)
        p_st = float(p_st)
        eta = (p_gt + p_st) / Q_FUEL * 100
        print(f"  GT power:  {p_gt/1e6:.1f} MW")
        print(f"  ST power:  {p_st/1e6:.1f} MW")
        print(f"  Total:     {(p_gt+p_st)/1e6:.1f} MW")
        print(f"  Efficiency:{eta:.2f}%")
    else:
        print("  WARNING: Could not read power values")
else:
    print(f"  FAILED! Result: {result_str[:300]}")
    err = omc.sendExpression('getErrorString()')
    print(f"  Errors: {str(err)[:500]}")

print("\nTest: override simulation (should reuse compiled model)...")
t0 = time.time()
result2 = omc.sendExpression(
    'simulate(GA_Individual, stopTime=300, tolerance=1e-6, '
    'simflags="-override ga_p_cond=4000,ga_p_drum=10e6,ga_pr_scale=0.9 '
    '-lv=-LOG_SUCCESS")'
)
dt2 = time.time() - t0
result2_str = str(result2)

if 'resultFile' in result2_str:
    p_gt2 = float(omc.sendExpression('val(generatedPower_GT, 280)'))
    p_st2 = float(omc.sendExpression('val(generatedPower_ST, 280)'))
    eta2 = (p_gt2 + p_st2) / Q_FUEL * 100
    print(f"  Override sim OK ({dt2:.0f}s)")
    print(f"  GT={p_gt2/1e6:.1f}MW  ST={p_st2/1e6:.1f}MW  eta={eta2:.2f}%")
    if dt2 < dt * 0.7:
        print(f"  OK: Override was faster — reused compiled model!")
    else:
        print(f"  Note: Override sim took similar time — may have recompiled")
else:
    print(f"  Override sim FAILED: {result2_str[:300]}")

omc.sendExpression('quit()')
print("\nSetup test complete.")

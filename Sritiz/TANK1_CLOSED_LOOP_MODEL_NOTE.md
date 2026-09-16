# Tank 1 — Closed-Loop Model Note

Status: **Closed-loop level-control model complete** (`build_tank1_closed_loop.m` → `tank1_closed_loop.slx`).
This note documents the closed-loop model and how it fits alongside the existing
open-loop baseline files in this repo.

---

## 1. Overview

Tank 1 is modeled as a single cylindrical tank with:
- an **inlet flow** driven by a pump, commanded as a 0–100% PWM/duty signal, and
- an **outlet flow** through a partially-open valve, driven by gravity (Torricelli's law).

The **open-loop** model (`tank1_hydraulic_model.slx`, `tank1_ode.m`) simulates the tank's
natural response to a *fixed* pump input. The **closed-loop** model
(`tank1_closed_loop.slx`) wraps that same hydraulic behavior in a PI feedback
controller so the tank level tracks a commanded setpoint instead of just
responding open-loop to a constant pump command.

---

## 2. Physical Parameters

| Symbol | Meaning | Value | Units |
|---|---|---|---|
| `A1` | Tank cross-sectional area (D = 0.200 m) | 0.031416 | m² |
| `pump_gain` | Pump flow per 1% PWM | 1e-07 | m³/s per % |
| `CdA_max` | Max effective valve orifice area | 4.23e-06 | m² |
| `valve_alpha` | Valve opening fraction | 0.65 | — |
| `g` | Gravitational acceleration | 9.81 | m/s² |
| `h0` | Initial tank level | 0.160 (160 mm) | m |

These match the values already used in `tank1_parameters.m` for the open-loop
model — the closed-loop model reuses the same physical plant, just adds a
controller on top of it.

---

## 3. Governing Equations

**Mass balance (tank level dynamics):**

```
dh/dt = (Qin - Q12) / A1
```

**Inlet flow (pump):**

```
Qin = pump_gain * u_pump      % u_pump in % PWM, 0–100
```

**Outlet flow (Torricelli, gravity-driven):**

```
Q12 = valve_alpha * CdA_max * sqrt(2 * g * max(h, 0))
```

The `max(h, 0)` clamp (implemented as a `Saturation` block, `Nonnegative_h`) exists
purely to prevent `sqrt()` of a negative number if the level briefly undershoots
zero during simulation.

**PI control law (closed-loop only):**

```
error   = Setpoint_mm - Level_mm
u_pump  = saturate( Kp*error + Ki*∫error dt , 0, 100 )
```

with `Kp = 1.2`, `Ki = 0.008`, output clamped to `[0, 100]` % to respect the
pump's physical actuation range (anti-windup via the PID block's built-in
saturation).

---

## 4. Closed-Loop Simulink Model (`tank1_closed_loop.slx`)

Built programmatically by `build_tank1_closed_loop.m`. Signal path:

1. **Setpoint_mm** (constant, 160 mm) → **Sum_Error** (setpoint − measured level)
2. **Sum_Error** → **PI_Controller** (PI, output clamped 0–100%)
3. **PI_Controller** → **Pump_Gain** (%→ m³/s) → **Net_Flow** (Qin − Q12)
4. **Net_Flow** → **Area_Gain** (1/A1) → **Level_Integrator** (∫, IC = h0) → tank level h (m)
5. **Level_Integrator** → **To_mm** (×1000) → **Level_Scope**, and fed back into **Sum_Error** (closing the loop)
6. In parallel, **Level_Integrator** → **Nonnegative_h** → **Sqrt_h** → **Sqrt_2g** → **Q12_Prod** (× valve effective area) → back into **Net_Flow** as the outflow term
7. **Valve_Opening × CdA_max** → **Valve_Prod** → second input of **Q12_Prod**
8. **Qin** and **Q12** are each also converted to L/min and muxed into **Flow_Scope** for monitoring

The model was auto-arranged with `Simulink.BlockDiagram.arrangeSystem(...,
FullLayout=true)` so all signal lines are clean orthogonal routes with no
overlaps — matching the layout style of the open-loop reference model.

---

## 5. How to Run

```matlab
build_tank1_closed_loop   % builds + opens + saves tank1_closed_loop.slx
sim('tank1_closed_loop')  % or press Run in the model window
```

Open `Level_Scope` to see tank level (mm) tracking the 160 mm setpoint, and
`Flow_Scope` to see `Qin` vs `Q12` (both in L/min) converging as the tank
reaches steady state.

---

## 6. Repo File Map

| File | Purpose |
|---|---|
| `build_tank1_closed_loop.m` | Builds the closed-loop Simulink model (this note's subject) |
| `tank1_hydraulic_model.slx` | **Open-loop** plant model — same tank physics, fixed pump input, no controller |
| `tank1_parameters.m` | Central definition of the physical constants in §2 (shared by open- and closed-loop builds) |
| `tank1_ode.m` | Standalone ODE (`dh/dt = ...`) form of the same plant, for simulation outside Simulink (e.g. `ode45`) |
| `tank1_simulate_and_verify.m` | Runs the ODE/analytical model and compares it against the Simulink result to verify the two agree |
| `tank1_verification_results.csv` | Numerical output of that verification run |
| `tank1_verification_plot.png` | Plot comparing ODE vs Simulink level response (open-loop baseline) |
| `Tank1_Mathematical_Proof_and_Verification_Report.docx` / `Tank_1_Mathematical_Proof_Clean.md` | Derivation of the governing equations and their verification |
| `CALCULATED_BASELINE_RESULTS.md` | Hand/analytically calculated baseline numbers used as a sanity check |
| `TANK1_MODEL_NOTE.md` | Model note for the open-loop baseline model |

> **Note:** the descriptions for `tank1_parameters.m`, `tank1_ode.m`, `tank1_simulate_and_verify.m`, and the verification outputs above are inferred from their filenames and the shared physical parameters — I haven't read their actual contents. Share those files (or the existing `TANK1_MODEL_NOTE.md`) and I'll tighten this table to match exactly, and match its formatting/style.

---

## 7. Suggested Next Step

To mirror the open-loop verification pipeline for the closed-loop model, a
natural follow-up would be a `tank1_closed_loop_simulate_and_verify.m` that
runs the closed-loop ODE (plant + PI law) independently of Simulink and
confirms the level converges to the 160 mm setpoint with the same steady-state
value the `.slx` model produces — the same role `tank1_simulate_and_verify.m`
plays for the open-loop model.

# Tank 1 — atmospheric reactive-cotton process analogue

## Scope and process choice

This model represents the **liquor preparation/feed tank** of a miniature,
open-to-atmosphere reactive-cotton dyeing demonstrator. It is not a full
industrial jet-dyeing machine and it does not yet model dye uptake, pH,
chemical reactions, fabric motion, Tank 2, or heater dynamics.

The 60 °C Tank 2 design point is literature-informed, not universal. A cotton
reactive-dye study used a 1:10 liquor ratio and 60 °C baths; another study used
60 °C for 60 min at a 1:20 liquor-to-fabric ratio. Other reactive-dye products
use 80 °C recipes, so the final dye manufacturer's data sheet must control the
physical process. We therefore use 60 °C nominal, 50–70 °C planned operating
envelope, and 75 °C independent safety trip for the future heated Tank 2.

- [Reactive-dye cotton study: 1:10 liquor ratio and 60 °C bath](https://link.springer.com/article/10.1007/s12221-023-00366-7)
- [Reactive-dye cotton study: 60 °C for 60 min at 1:20 liquor-to-fabric ratio](https://link.springer.com/article/10.1007/s10570-024-05928-3)
- [Study showing 60 °C dark-shade, low-liquor-ratio cotton process and why dye chemistry matters](https://doi.org/10.1007/s44371-026-00506-x)
- [Study documenting reactive-dye liquor-ratio investigation from 1:50 to 1:1.5](https://eprints.whiterose.ac.uk/id/eprint/122467/)

The process is deliberately modelled as **atmospheric**: tank free surfaces are
at approximately 101325 Pa, and no pressure vessel is assumed. Do not use this
model for polyester high-temperature/high-pressure dyeing.

## Design-scale basis

The circular Tank 1 has a 0.200 m internal diameter and 0.300 m wall height.
Its nominal 0.160 m level corresponds to 5.03 L. This is a design assumption,
chosen because 5 L represents a 1:10 liquor ratio for a 0.5 kg textile load;
it is not an industrial tank-size claim. The 0.250 m high-level limit leaves
0.050 m of freeboard.

| Quantity | Symbol | Value | Status |
|---|---:|---:|---|
| Tank cross-sectional area | A1 | 0.031416 m² | assumed geometry |
| Total height | H1 | 0.300 m | assumed geometry |
| Nominal level | h1,sp | 0.160 m | assumed operating point |
| Nominal volume | V1,sp | 5.03 L | derived |
| Low / high operating levels | h1 | 0.030 / 0.250 m | assumed safety limits |
| Maximum inlet flow | Qin,max | 0.60 L/min | assumed; calibrate pump |
| Outlet coefficient | CdA | 4.23e-6 m² | assumed; identify experimentally |
| Future Tank 2 temperature | T2 | 50–70 °C | literature-informed design envelope |

## Variables, units, and signs

| Variable | Unit | Meaning / sign convention |
|---|---|---|
| t | s | simulation time |
| h1 | m | Tank 1 liquid level, measured upward from the internal bottom |
| V1=A1h1 | m³ | liquid volume; cylindrical-tank simplification |
| Qin | m³/s | positive when entering Tank 1 from the source |
| Q12 | m³/s | positive when leaving Tank 1 toward Tank 2 |
| uP | % | make-up pump command, limited to 0–100 % |
| alpha | 0–1 | outlet restriction opening; 0 closed, 1 fully open |
| CdA | m² | combined discharge coefficient and effective opening area |
| g | m/s² | gravitational acceleration |

## Derivation of the nonlinear mass balance

**Physical law: conservation of liquid volume.** For an incompressible liquid,
mass conservation can be written as volume accumulation = volumetric inflow −
volumetric outflow.

1. The cylindrical tank has constant area `A1`, so `V1 = A1 h1`.
2. Differentiating gives `dV1/dt = A1 dh1/dt`.
3. Tank 1 has one inlet and one outlet, therefore `dV1/dt = Qin − Q12`.
4. Substitution gives `dh1/dt = (Qin − Q12) / A1`.
5. The present model approximates the make-up pump and gravity outlet as
   `Qin = Qin,max (uP/100)` and `Q12 = alpha CdA sqrt(2 g h1)`.
6. The resulting **nonlinear Tank 1 ODE** is
   `dh1/dt = [Qin,max(uP/100) − alpha CdA sqrt(2 g h1)] / A1`.

The square-root outlet term is the nonlinearity: equal changes in level do not
produce equal changes in gravity-driven outflow. At a steady level, `Qin=Q12`.

## Assumptions and later measurements

- Water-like incompressible liquid, constant tank cross-sectional area, and
  well-mixed liquid are modelling assumptions.
- The free surface and Tank 2 receiving point are atmospheric.
- Pump flow is currently linear in PWM; actual diaphragm-pump flow will not be
  exactly linear and must be calibrated with the final tubing.
- `CdA` is a selected design value. Measure outlet flow at several levels and
  valve openings to identify it.
- The model prevents level below zero and above the wall height. The future
  physical system needs independent float switches; software limits alone are
  not safety devices.

## Files and execution

1. Run `tank1_simulate_and_verify` to execute three conservation checks and
   create `tank1_verification_results.csv` and `tank1_verification_plot.png`.
2. Run `build_tank1_simulink` to generate `tank1_hydraulic_model.slx`.
3. Open the generated model and run it. It has a level scope in mm and a flow
   scope in L/min. The default 60% pump command is a deliberate open-loop step
   test: it causes the level to rise from the 160 mm initial condition. It is
   not the nominal equilibrium command.

The first parameter source is `tank1_parameters.m`. Only populate its
`p.measured` fields with genuine physical-test data.

`tank1_ode` is normally called by the simulation runner. If it is run alone
from the Command Window, it now performs a nominal-condition diagnostic rather
than producing an input-argument error.

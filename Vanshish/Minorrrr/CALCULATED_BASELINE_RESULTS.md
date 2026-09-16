# Tank 1 calculated baseline results

These values are analytical checks of the exact equations used by the MATLAB
model. They validate the parameter arithmetic and expected physical direction
of response; they are **not measured hardware results**.

| Check | Result | Interpretation |
|---|---:|---|
| Tank area | 0.031416 m² | Derived from 0.200 m internal diameter |
| Nominal Tank 1 volume | 5.027 L | At the 0.160 m level setpoint |
| High-level volume | 7.854 L | At the 0.250 m safety level |
| Balanced transfer flow | 0.292 L/min | With 65% outlet opening at 0.160 m level |
| Pump command for balance | 48.7% | Under the assumed linear 0.60 L/min pump map |
| Fill test result | 136.4 mm after 10 min | Starts at 60 mm, 40% pump, outlet closed; level rises |
| Drain test result | 2.61 mm after 30 min | Starts at 160 mm, pump off, 65% outlet; level falls nonlinearly |

For the balanced condition, inlet and outlet flows are both 0.292 L/min, so
`dh1/dt = (Qin - Q12)/A1 = 0`. This is the required steady-state check.

## MATLAB execution status

The supplied MATLAB runner could not be executed on this computer because the
installed MATLAB launcher returned `System Error: File system inconsistency`
before it initialized. `tank1_simulate_and_verify.m` remains the authoritative
simulation/verification script and will create a CSV and PNG once MATLAB starts
normally. `build_tank1_simulink.m` will then generate the `.slx` diagram.

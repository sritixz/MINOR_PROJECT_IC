# Hardware Commissioning Guide

## Purpose
Use the simulation to plan tests; use this procedure to identify parameters from the installed tank. Do not describe simulated values as measured hardware results.

## Instrumentation
- ESP32 logger: time, pump PWM, heater duty, controller mode, sensor validity, alarms.
- HC-SR04: level in millimetres after conversion from distance.
- TIFSS0118: flow in L/min using pulse-period measurement.
- PT100/MAX31865: primary tank-temperature measurement.
- K-type/MAX6675: independent high-temperature interlock.

## Test Sequence
1. Verify the heater safety chain with water present: low-water, sensor-invalid, and high-temperature trips must set heater command to zero.
2. With heater off, record 60 s at pump PWM 10, 20, 30, 40, 50, 60, 70, and 80 percent. Hold the valve position fixed.
3. Run a level step with the same valve setting. Log level, flow, and PWM until the response settles.
4. Hold level stable, apply a conservative heater-duty step, and log tank and inlet temperatures. Stop immediately on a safety trip.
5. Save the log as `data/hardware_commissioning.csv` using the template column names.

## Run the Analysis
In MATLAB, set Current Folder to this project and run:

```matlab
run_hardware_commissioning
```

It produces `results/hardware_validation.png`, `results/hardware_validation_report.md`, and `results/identified_parameters.mat`.

## Assumptions
- Water properties use 997 kg/m^3 and 4180 J/(kg K).
- Pump flow and outlet behaviour are identified for the installed plumbing and valve position.
- Heater effectiveness is held at 0.85 while the script estimates aggregate heat loss `UA`.
- The model is valid only in the logged operating range.

## What the Results Imply
- Small pump-flow error supports the PWM-to-flow model.
- Small level-dynamics error supports the gravity-outlet model.
- Small temperature error supports the thermal model for that water volume and ambient condition.
- Large errors mean recalibration, different valve/plumbing, sensor error, unmodelled reservoir warming, or actuator limits. Investigate before tuning more aggressively.

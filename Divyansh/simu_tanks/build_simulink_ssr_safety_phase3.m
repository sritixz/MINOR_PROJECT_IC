function build_simulink_ssr_safety_phase3()
% Phase 3: time-proportional SSR and independent heater safety interlocks.
root = fileparts(mfilename('fullpath'));
model = 'tank_ssr_safety_phase3';
modelFile = fullfile(root, [model '.slx']);

if bdIsLoaded(model), close_system(model, 0); end
if isfile(modelFile), delete(modelFile); end

load_system('simulink');
new_system(model);
open_system(model);
set_param(model, 'StopTime', '3600', 'Solver', 'ode45');

add_block('simulink/Sources/Constant', [model '/Temperature SP'], ...
    'Value', '28.5', 'Position', [25 45 90 75]);
add_block('simulink/Math Operations/Sum', [model '/Temperature Error'], ...
    'Inputs', '+-', 'Position', [125 42 150 78]);
add_block('simulink/Continuous/PID Controller', [model '/Temperature PI'], ...
    'P', '0.04', 'I', '0.0008', 'D', '0', 'Position', [185 35 265 85]);
add_block('simulink/Discontinuities/Saturation', [model '/Heater Duty Limit'], ...
    'UpperLimit', '0.10', 'LowerLimit', '0', 'Position', [300 42 365 78]);
add_block('simulink/Math Operations/Gain', [model '/Duty x 10 s'], ...
    'Gain', '10', 'Position', [400 42 460 78]);
add_block('simulink/Sources/Repeating Sequence', [model '/SSR 10 s Window'], ...
    'rep_seq_t', '[0 9.999 10]', 'rep_seq_y', '[0 9.999 0]', ...
    'Position', [400 100 500 130]);
add_block('simulink/Logic and Bit Operations/Relational Operator', [model '/SSR Switching'], ...
    'Operator', '<=', 'Position', [535 55 585 105]);
add_block('simulink/Sources/Step', [model '/Heater Stuck On Fault'], ...
    'Time', '1000', 'Before', '0', 'After', '1', 'Position', [525 145 600 175]);
add_block('simulink/Math Operations/Sum', [model '/Normal or Stuck Heater'], ...
    'Inputs', '++', 'Position', [635 65 660 115]);
add_block('simulink/Discontinuities/Saturation', [model '/SSR State 0 or 1'], ...
    'UpperLimit', '1', 'LowerLimit', '0', 'Position', [690 75 755 105]);

add_block('simulink/Sources/Step', [model '/Water Level Fault'], ...
    'Time', '2600', 'Before', '0.08', 'After', '0.01', 'Position', [525 245 600 275]);
add_block('simulink/Sources/Constant', [model '/Minimum Water Level'], ...
    'Value', '0.03', 'Position', [620 285 690 315]);
add_block('simulink/Logic and Bit Operations/Relational Operator', [model '/Water Permit'], ...
    'Operator', '>=', 'Position', [720 245 770 295]);

add_block('simulink/Discrete/Zero-Order Hold', [model '/MAX6675 0.22 s Conversion'], ...
    'SampleTime', '0.22', 'Position', [995 160 1095 190]);
add_block('simulink/Discontinuities/Quantizer', [model '/K-Type 0.25 C Resolution'], ...
    'QuantizationInterval', '0.25', 'Position', [1130 160 1235 190]);
add_block('simulink/Sources/Constant', [model '/High Temperature Limit'], ...
    'Value', '35', 'Position', [1125 220 1200 250]);
add_block('simulink/Logic and Bit Operations/Relational Operator', [model '/High Temperature Trip'], ...
    'Operator', '>=', 'Position', [1265 165 1315 215]);
add_block('simulink/Logic and Bit Operations/Logical Operator', [model '/Temperature Permit'], ...
    'Operator', 'NOT', 'Position', [1350 165 1400 215]);
add_block('simulink/Math Operations/Product', [model '/Safety Gate'], ...
    'Inputs', '3', 'Position', [795 75 835 115]);

add_block('simulink/Math Operations/Gain', [model '/100 W Heater'], ...
    'Gain', '100', 'Position', [875 80 940 110]);
add_block('simulink/Math Operations/Gain', [model '/Effective Heater Power'], ...
    'Gain', '0.85/(997*4180*0.0015)', 'Position', [975 80 1090 110]);
add_block('simulink/Math Operations/Sum', [model '/Thermal Energy Balance'], ...
    'Inputs', '+-', 'Position', [1125 70 1150 115]);
add_block('simulink/Math Operations/Sum', [model '/T minus Ambient'], ...
    'Inputs', '+-', 'Position', [1010 285 1035 325]);
add_block('simulink/Sources/Constant', [model '/Ambient 25 C'], ...
    'Value', '25', 'Position', [890 340 955 370]);
add_block('simulink/Math Operations/Gain', [model '/Ambient Heat Loss'], ...
    'Gain', '2/(997*4180*0.0015)', 'Position', [1080 290 1175 320]);
add_block('simulink/Continuous/Integrator', [model '/Tank Temperature'], ...
    'InitialCondition', '25', 'Position', [1190 75 1220 105]);
add_block('simulink/Discrete/Zero-Order Hold', [model '/MAX31865 21 ms Conversion'], ...
    'SampleTime', '0.021', 'Position', [995 385 1095 415]);
add_block('simulink/Discontinuities/Quantizer', [model '/PT100 0.03125 C Resolution'], ...
    'QuantizationInterval', '0.03125', 'Position', [1135 385 1245 415]);

add_block('simulink/Signal Routing/Mux', [model '/Safety Traces'], ...
    'Inputs', '5', 'Position', [1460 80 1465 270]);
add_block('simulink/Sinks/Scope', [model '/SSR Safety Scope'], ...
    'Position', [1520 125 1580 185]);
add_block('simulink/Sinks/To Workspace', [model '/Safety Results'], ...
    'VariableName', 'safetyResults', 'SaveFormat', 'Structure With Time', ...
    'Position', [1520 225 1620 255]);

add_line(model, 'Temperature SP/1', 'Temperature Error/1');
add_line(model, 'Temperature Error/1', 'Temperature PI/1');
add_line(model, 'Temperature PI/1', 'Heater Duty Limit/1');
add_line(model, 'Heater Duty Limit/1', 'Duty x 10 s/1');
add_line(model, 'SSR 10 s Window/1', 'SSR Switching/1');
add_line(model, 'Duty x 10 s/1', 'SSR Switching/2');
add_line(model, 'SSR Switching/1', 'Normal or Stuck Heater/1');
add_line(model, 'Heater Stuck On Fault/1', 'Normal or Stuck Heater/2');
add_line(model, 'Normal or Stuck Heater/1', 'SSR State 0 or 1/1');
add_line(model, 'SSR State 0 or 1/1', 'Safety Gate/1');
add_line(model, 'Water Level Fault/1', 'Water Permit/1');
add_line(model, 'Minimum Water Level/1', 'Water Permit/2');
add_line(model, 'Water Permit/1', 'Safety Gate/2');
add_line(model, 'Safety Gate/1', '100 W Heater/1');
add_line(model, '100 W Heater/1', 'Effective Heater Power/1');
add_line(model, 'Effective Heater Power/1', 'Thermal Energy Balance/1');
add_line(model, 'Tank Temperature/1', 'T minus Ambient/1');
add_line(model, 'Ambient 25 C/1', 'T minus Ambient/2');
add_line(model, 'T minus Ambient/1', 'Ambient Heat Loss/1');
add_line(model, 'Ambient Heat Loss/1', 'Thermal Energy Balance/2');
add_line(model, 'Thermal Energy Balance/1', 'Tank Temperature/1');
add_line(model, 'Tank Temperature/1', 'MAX6675 0.22 s Conversion/1');
add_line(model, 'MAX6675 0.22 s Conversion/1', 'K-Type 0.25 C Resolution/1');
add_line(model, 'K-Type 0.25 C Resolution/1', 'High Temperature Trip/1');
add_line(model, 'High Temperature Limit/1', 'High Temperature Trip/2');
add_line(model, 'High Temperature Trip/1', 'Temperature Permit/1');
add_line(model, 'Temperature Permit/1', 'Safety Gate/3');
add_line(model, 'Tank Temperature/1', 'MAX31865 21 ms Conversion/1');
add_line(model, 'MAX31865 21 ms Conversion/1', 'PT100 0.03125 C Resolution/1');
add_line(model, 'PT100 0.03125 C Resolution/1', 'Temperature Error/2');
add_line(model, 'Tank Temperature/1', 'Safety Traces/1');
add_line(model, 'K-Type 0.25 C Resolution/1', 'Safety Traces/2');
add_line(model, 'SSR State 0 or 1/1', 'Safety Traces/3');
add_line(model, 'Safety Gate/1', 'Safety Traces/4');
add_line(model, 'Water Level Fault/1', 'Safety Traces/5');
add_line(model, 'Safety Traces/1', 'SSR Safety Scope/1');
add_line(model, 'Safety Traces/1', 'Safety Results/1');

set_param([model '/SSR Safety Scope'], 'OpenAtSimulationStart', 'on');
save_system(model, modelFile);
sim(model);
open_system(model);
end

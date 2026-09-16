function build_simulink_thermal_sensor_comparison()
% Compare the video MAX6675/K-type path with a PT100/MAX31865 controller sensor.
root = fileparts(mfilename('fullpath'));
model = 'tank_thermal_sensor_comparison';
modelFile = fullfile(root, [model '.slx']);

if bdIsLoaded(model)
    close_system(model, 0);
end
if isfile(modelFile)
    delete(modelFile);
end

load_system('simulink');
new_system(model);
open_system(model);
set_param(model, 'StopTime', '3600', 'Solver', 'ode45');

add_block('simulink/Sources/Constant', [model '/Temperature SP'], ...
    'Value', '28.5', 'Position', [30 55 95 85]);
add_block('simulink/Math Operations/Sum', [model '/Temperature Error'], ...
    'Inputs', '+-', 'Position', [140 52 165 88]);
add_block('simulink/Continuous/PID Controller', [model '/Temperature PI'], ...
    'P', '0.04', 'I', '0.0008', 'D', '0', 'Position', [205 47 285 93]);
add_block('simulink/Discontinuities/Saturation', [model '/Heater Duty Limit'], ...
    'UpperLimit', '0.10', 'LowerLimit', '0', 'Position', [330 52 395 88]);
add_block('simulink/Math Operations/Gain', [model '/100 W Heater (average SSR)'], ...
    'Gain', '100', 'Position', [445 52 550 88]);
add_block('simulink/Math Operations/Gain', [model '/Effective Heater Power'], ...
    'Gain', '0.85/(997*4180*0.0015)', 'Position', [595 52 710 88]);
add_block('simulink/Math Operations/Sum', [model '/Thermal Energy Balance'], ...
    'Inputs', '+-', 'Position', [755 86 780 126]);
add_block('simulink/Math Operations/Sum', [model '/T minus Ambient'], ...
    'Inputs', '+-', 'Position', [705 160 730 200]);
add_block('simulink/Math Operations/Gain', [model '/Ambient Heat Loss'], ...
    'Gain', '2/(997*4180*0.0015)', 'Position', [755 165 850 195]);
add_block('simulink/Sources/Constant', [model '/Ambient 25 C'], ...
    'Value', '25', 'Position', [600 205 665 235]);
add_block('simulink/Continuous/Integrator', [model '/Tank Temperature'], ...
    'InitialCondition', '25', 'Position', [890 90 920 120]);

add_block('simulink/Discrete/Zero-Order Hold', [model '/MAX6675 0.22 s Conversion'], ...
    'SampleTime', '0.22', 'Position', [980 150 1080 180]);
add_block('simulink/Discontinuities/Quantizer', [model '/K-Type 0.25 C Resolution'], ...
    'QuantizationInterval', '0.25', 'Position', [1120 150 1225 180]);
add_block('simulink/Discrete/Zero-Order Hold', [model '/MAX31865 21 ms Conversion'], ...
    'SampleTime', '0.021', 'Position', [980 230 1080 260]);
add_block('simulink/Discontinuities/Quantizer', [model '/PT100 0.03125 C Resolution'], ...
    'QuantizationInterval', '0.03125', 'Position', [1120 230 1235 260]);

add_block('simulink/Signal Routing/Mux', [model '/Thermal Traces'], ...
    'Inputs', '4', 'Position', [1280 75 1285 220]);
add_block('simulink/Sinks/Scope', [model '/Thermal Scope'], ...
    'Position', [1340 115 1400 175]);
add_block('simulink/Sinks/To Workspace', [model '/Thermal Results'], ...
    'VariableName', 'thermalResults', 'SaveFormat', 'Structure With Time', ...
    'Position', [1340 205 1440 235]);

% PI is closed around the high-resolution RTD path. The MAX6675 path remains
% visible for comparison and is intended for an independent high-limit check.
add_line(model, 'Temperature SP/1', 'Temperature Error/1');
add_line(model, 'Temperature Error/1', 'Temperature PI/1');
add_line(model, 'Temperature PI/1', 'Heater Duty Limit/1');
add_line(model, 'Heater Duty Limit/1', '100 W Heater (average SSR)/1');
add_line(model, '100 W Heater (average SSR)/1', 'Effective Heater Power/1');
add_line(model, 'Effective Heater Power/1', 'Thermal Energy Balance/1');
add_line(model, 'Tank Temperature/1', 'T minus Ambient/1');
add_line(model, 'Ambient 25 C/1', 'T minus Ambient/2');
add_line(model, 'T minus Ambient/1', 'Ambient Heat Loss/1');
add_line(model, 'Ambient Heat Loss/1', 'Thermal Energy Balance/2');
add_line(model, 'Thermal Energy Balance/1', 'Tank Temperature/1');
add_line(model, 'Tank Temperature/1', 'MAX6675 0.22 s Conversion/1');
add_line(model, 'MAX6675 0.22 s Conversion/1', 'K-Type 0.25 C Resolution/1');
add_line(model, 'Tank Temperature/1', 'MAX31865 21 ms Conversion/1');
add_line(model, 'MAX31865 21 ms Conversion/1', 'PT100 0.03125 C Resolution/1');
add_line(model, 'PT100 0.03125 C Resolution/1', 'Temperature Error/2');
add_line(model, 'Tank Temperature/1', 'Thermal Traces/1');
add_line(model, 'K-Type 0.25 C Resolution/1', 'Thermal Traces/2');
add_line(model, 'PT100 0.03125 C Resolution/1', 'Thermal Traces/3');
add_line(model, 'Heater Duty Limit/1', 'Thermal Traces/4');
add_line(model, 'Thermal Traces/1', 'Thermal Scope/1');
add_line(model, 'Thermal Traces/1', 'Thermal Results/1');

set_param([model '/Thermal Scope'], 'OpenAtSimulationStart', 'on');
save_system(model, modelFile);
sim(model);
open_system(model);
end

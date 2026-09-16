function build_simulink_phase1()
% Build the Phase 1 hardware-aligned hydraulic model in Simulink.
root = fileparts(mfilename('fullpath'));
model = 'tank_phase1';
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
set_param(model, 'StopTime', '900', 'Solver', 'ode45');

add_block('simulink/Sources/From Workspace', [model '/Pump PWM Profile'], ...
    'VariableName', 'pumpProfile', 'Position', [35 80 155 110]);
add_block('simulink/Sources/Constant', [model '/Manual Valve'], ...
    'Value', '0.55', 'Position', [35 175 105 205]);
add_block('simulink/Math Operations/Gain', [model '/Pump Model'], ...
    'Gain', '7.0e-7', 'Position', [205 80 275 110]);
add_block('simulink/Math Operations/Math Function', [model '/sqrt level'], ...
    'Operator', 'sqrt', 'Position', [205 160 275 190]);
add_block('simulink/Math Operations/Gain', [model '/Gravity Outlet Gain'], ...
    'Gain', '5.0e-5*sqrt(2*9.81)', 'Position', [315 160 410 190]);
add_block('simulink/Math Operations/Product', [model '/Manual Valve Outlet'], ...
    'Inputs', '2', 'Position', [450 155 485 195]);
add_block('simulink/Math Operations/Sum', [model '/Tank Flow Balance'], ...
    'Inputs', '+-', 'Position', [520 90 545 140]);
add_block('simulink/Math Operations/Gain', [model '/Tank Area'], ...
    'Gain', '1/(pi*0.20^2/4)', 'Position', [580 100 650 130]);
add_block('simulink/Continuous/Integrator', [model '/Tank Level h'], ...
    'InitialCondition', '0.08', 'Position', [690 100 720 130]);
add_block('simulink/Math Operations/Gain', [model '/Level to mm'], ...
    'Gain', '1000', 'Position', [770 100 830 130]);
add_block('simulink/Math Operations/Gain', [model '/Qin to Lmin'], ...
    'Gain', '60000', 'Position', [315 60 375 90]);
add_block('simulink/Math Operations/Gain', [model '/Qout to Lmin'], ...
    'Gain', '60000', 'Position', [520 180 580 210]);
add_block('simulink/Signal Routing/Mux', [model '/Commissioning Signals'], ...
    'Inputs', '4', 'Position', [875 100 880 220]);
add_block('simulink/Sinks/Scope', [model '/Phase 1 Scope'], ...
    'Position', [955 130 1015 190]);

add_line(model, 'Pump PWM Profile/1', 'Pump Model/1');
add_line(model, 'Pump Model/1', 'Tank Flow Balance/1');
add_line(model, 'Pump Model/1', 'Qin to Lmin/1');
add_line(model, 'Tank Level h/1', 'sqrt level/1');
add_line(model, 'sqrt level/1', 'Gravity Outlet Gain/1');
add_line(model, 'Gravity Outlet Gain/1', 'Manual Valve Outlet/1');
add_line(model, 'Manual Valve/1', 'Manual Valve Outlet/2');
add_line(model, 'Manual Valve Outlet/1', 'Tank Flow Balance/2');
add_line(model, 'Manual Valve Outlet/1', 'Qout to Lmin/1');
add_line(model, 'Tank Flow Balance/1', 'Tank Area/1');
add_line(model, 'Tank Area/1', 'Tank Level h/1');
add_line(model, 'Tank Level h/1', 'Level to mm/1');
add_line(model, 'Level to mm/1', 'Commissioning Signals/1');
add_line(model, 'Pump PWM Profile/1', 'Commissioning Signals/2');
add_line(model, 'Qin to Lmin/1', 'Commissioning Signals/3');
add_line(model, 'Qout to Lmin/1', 'Commissioning Signals/4');
add_line(model, 'Commissioning Signals/1', 'Phase 1 Scope/1');

modelWorkspace = get_param(model, 'ModelWorkspace');
assignin(modelWorkspace, 'pumpProfile', timeseries([20; 40; 60], [0; 300; 600]));
set_param([model '/Phase 1 Scope'], 'OpenAtSimulationStart', 'on');
save_system(model, modelFile);
sim(model);
open_system(model);
end

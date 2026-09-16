function build_simulink_combined_phase4()
% Phase 4: combined level and temperature control with volume coupling.
root = fileparts(mfilename('fullpath'));
model = 'tank_combined_phase4';
modelFile = fullfile(root, [model '.slx']);
if bdIsLoaded(model), close_system(model, 0); end
if isfile(modelFile), delete(modelFile); end
load_system('simulink'); new_system(model); open_system(model);
set_param(model, 'StopTime', '3600', 'Solver', 'ode45');

% Level loop: HC-SR04-equivalent measurement, PI, pump, gravity outlet.
add_block('simulink/Sources/Constant',[model '/Level SP m'],'Value','0.12','Position',[25 45 85 75]);
add_block('simulink/Math Operations/Sum',[model '/Level Error'],'Inputs','+-','Position',[120 42 145 78]);
add_block('simulink/Continuous/PID Controller',[model '/Level PI'],'P','1500','I','0.5','D','0','Position',[180 35 250 85]);
add_block('simulink/Discontinuities/Saturation',[model '/Pump PWM Limit'],'UpperLimit','100','LowerLimit','0','Position',[285 42 350 78]);
add_block('simulink/Math Operations/Gain',[model '/Pump Flow'],'Gain','7.0e-7','Position',[390 42 455 78]);
add_block('simulink/Math Operations/Sum',[model '/Level Flow Balance'],'Inputs','+-','Position',[630 80 655 120]);
add_block('simulink/Math Operations/Gain',[model '/Tank Area'],'Gain','1/(pi*0.20^2/4)','Position',[690 85 755 115]);
add_block('simulink/Continuous/Integrator',[model '/Tank Level'],'InitialCondition','0.08','Position',[790 85 820 115]);
add_block('simulink/Discrete/Zero-Order Hold',[model '/HC-SR04 Sample'],'SampleTime','0.25','Position',[865 85 940 115]);
add_block('simulink/Discontinuities/Quantizer',[model '/HC-SR04 1 mm Resolution'],'QuantizationInterval','0.001','Position',[970 85 1060 115]);
add_block('simulink/Math Operations/Math Function',[model '/sqrt Level'],'Operator','sqrt','Position',[430 150 500 180]);
add_block('simulink/Math Operations/Gain',[model '/Gravity Outlet Gain'],'Gain','0.55*5e-5*sqrt(2*9.81)','Position',[535 150 625 180]);

% Temperature loop: PT100 feedback, 10 s SSR window, and water-volume coupling.
add_block('simulink/Sources/Constant',[model '/Temperature SP C'],'Value','26','Position',[25 275 90 305]);
add_block('simulink/Math Operations/Sum',[model '/Temperature Error'],'Inputs','+-','Position',[120 272 145 308]);
add_block('simulink/Continuous/PID Controller',[model '/Temperature PI'],'P','0.08','I','0.001','D','0','Position',[180 265 250 315]);
add_block('simulink/Discontinuities/Saturation',[model '/Heater Duty Limit'],'UpperLimit','0.10','LowerLimit','0','Position',[285 272 350 308]);
add_block('simulink/Math Operations/Gain',[model '/Duty x 10 s'],'Gain','10','Position',[390 272 455 308]);
add_block('simulink/Sources/Repeating Sequence',[model '/SSR 10 s Window'],'rep_seq_t','[0 9.999 10]','rep_seq_y','[0 9.999 0]','Position',[390 335 490 365]);
add_block('simulink/Logic and Bit Operations/Relational Operator',[model '/SSR Switching'],'Operator','<=','Position',[525 280 575 330]);
add_block('simulink/Signal Attributes/Data Type Conversion',[model '/SSR State Numeric'],'OutDataTypeStr','double','Position',[585 285 600 315]);
add_block('simulink/Math Operations/Gain',[model '/100 W Heater'],'Gain','100*0.85','Position',[610 285 690 315]);
add_block('simulink/Math Operations/Sum',[model '/Thermal Power Balance'],'Inputs','+-','Position',[730 285 755 325]);
add_block('simulink/Math Operations/Sum',[model '/T minus Ambient'],'Inputs','+-','Position',[610 395 635 435]);
add_block('simulink/Sources/Constant',[model '/Ambient 25 C'],'Value','25','Position',[535 450 600 480]);
add_block('simulink/Math Operations/Gain',[model '/Heat Loss UA'],'Gain','2','Position',[680 400 745 430]);
add_block('simulink/Math Operations/Gain',[model '/Thermal Capacity'],'Gain','997*4180*(pi*0.20^2/4)','Position',[850 375 945 405]);
add_block('simulink/Math Operations/Product',[model '/dT from Power and Volume'],'Inputs','*/','Position',[990 300 1025 340]);
add_block('simulink/Continuous/Integrator',[model '/Tank Temperature'],'InitialCondition','25','Position',[1065 300 1095 330]);
add_block('simulink/Discrete/Zero-Order Hold',[model '/MAX31865 Sample'],'SampleTime','0.021','Position',[1140 300 1215 330]);
add_block('simulink/Discontinuities/Quantizer',[model '/PT100 0.03125 C Resolution'],'QuantizationInterval','0.03125','Position',[1250 300 1360 330]);

add_block('simulink/Signal Routing/Mux',[model '/Combined Traces'],'Inputs','6','Position',[1410 65 1415 340]);
add_block('simulink/Sinks/Scope',[model '/Combined Scope'],'Position',[1470 155 1530 215]);
add_block('simulink/Sinks/To Workspace',[model '/Combined Results'],'VariableName','combinedResults','SaveFormat','Structure With Time','Position',[1470 255 1570 285]);

add_line(model,'Level SP m/1','Level Error/1'); add_line(model,'Level Error/1','Level PI/1');
add_line(model,'Level PI/1','Pump PWM Limit/1'); add_line(model,'Pump PWM Limit/1','Pump Flow/1');
add_line(model,'Pump Flow/1','Level Flow Balance/1'); add_line(model,'Level Flow Balance/1','Tank Area/1');
add_line(model,'Tank Area/1','Tank Level/1'); add_line(model,'Tank Level/1','HC-SR04 Sample/1');
add_line(model,'HC-SR04 Sample/1','HC-SR04 1 mm Resolution/1'); add_line(model,'HC-SR04 1 mm Resolution/1','Level Error/2');
add_line(model,'Tank Level/1','sqrt Level/1'); add_line(model,'sqrt Level/1','Gravity Outlet Gain/1');
add_line(model,'Gravity Outlet Gain/1','Level Flow Balance/2');
add_line(model,'Temperature SP C/1','Temperature Error/1'); add_line(model,'Temperature Error/1','Temperature PI/1');
add_line(model,'Temperature PI/1','Heater Duty Limit/1'); add_line(model,'Heater Duty Limit/1','Duty x 10 s/1');
add_line(model,'SSR 10 s Window/1','SSR Switching/1'); add_line(model,'Duty x 10 s/1','SSR Switching/2');
add_line(model,'SSR Switching/1','SSR State Numeric/1'); add_line(model,'SSR State Numeric/1','100 W Heater/1'); add_line(model,'100 W Heater/1','Thermal Power Balance/1');
add_line(model,'Tank Temperature/1','T minus Ambient/1'); add_line(model,'Ambient 25 C/1','T minus Ambient/2');
add_line(model,'T minus Ambient/1','Heat Loss UA/1'); add_line(model,'Heat Loss UA/1','Thermal Power Balance/2');
add_line(model,'Thermal Power Balance/1','dT from Power and Volume/1'); add_line(model,'Tank Level/1','Thermal Capacity/1');
add_line(model,'Thermal Capacity/1','dT from Power and Volume/2'); add_line(model,'dT from Power and Volume/1','Tank Temperature/1');
add_line(model,'Tank Temperature/1','MAX31865 Sample/1'); add_line(model,'MAX31865 Sample/1','PT100 0.03125 C Resolution/1');
add_line(model,'PT100 0.03125 C Resolution/1','Temperature Error/2');
add_line(model,'Tank Level/1','Combined Traces/1'); add_line(model,'HC-SR04 1 mm Resolution/1','Combined Traces/2');
add_line(model,'Pump PWM Limit/1','Combined Traces/3'); add_line(model,'Tank Temperature/1','Combined Traces/4');
add_line(model,'PT100 0.03125 C Resolution/1','Combined Traces/5'); add_line(model,'SSR State Numeric/1','Combined Traces/6');
add_line(model,'Combined Traces/1','Combined Scope/1'); add_line(model,'Combined Traces/1','Combined Results/1');
set_param([model '/Combined Scope'],'OpenAtSimulationStart','on'); save_system(model,modelFile); sim(model); open_system(model);
end

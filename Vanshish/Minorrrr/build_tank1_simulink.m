function build_tank1_simulink()
%BUILD_TANK1_SIMULINK Create a basic open-loop Tank 1 Simulink model.
% It uses standard continuous Simulink blocks and tank1_parameters.m.
p = tank1_parameters();
mdl = 'tank1_hydraulic_model';
if bdIsLoaded(mdl), close_system(mdl,0); end
if isfile([mdl '.slx'])
    error('%s.slx already exists. Rename or archive it before rebuilding.',mdl);
end
new_system(mdl); open_system(mdl);

add_block('simulink/Sources/Constant',[mdl '/Pump PWM (%)'], ...
    'Value','60','Position',[35 70 105 100]);
add_block('simulink/Math Operations/Gain',[mdl '/Pump flow Qin (m3_s)'], ...
    'Gain',num2str(p.assumed.pump.Qin_max_m3_s/100,16),'Position',[145 70 245 100]);
add_block('simulink/Sources/Constant',[mdl '/Valve opening'], ...
    'Value',num2str(p.assumed.valve.alpha_nominal,16),'Position',[35 225 105 255]);
add_block('simulink/Sources/Constant',[mdl '/CdA max'], ...
    'Value',num2str(p.assumed.valve.CdA_max_m2,16),'Position',[145 225 215 255]);
add_block('simulink/Math Operations/Product',[mdl '/Valve coefficient'], ...
    'Inputs','**','Position',[260 220 300 260]);
add_block('simulink/Continuous/Integrator',[mdl '/Tank level h (m)'], ...
    'InitialCondition',num2str(p.assumed.geometry.h_sp_m,16), ...
    'LimitOutput','on','LowerSaturationLimit','0', ...
    'UpperSaturationLimit',num2str(p.assumed.geometry.H_total_m,16), ...
    'Position',[610 120 640 150]);
add_block('simulink/Discontinuities/Saturation',[mdl '/Nonnegative level'], ...
    'LowerLimit','0','UpperLimit',num2str(p.assumed.geometry.H_total_m,16), ...
    'Position',[350 190 420 220]);
add_block('simulink/Math Operations/Math Function',[mdl '/sqrt(h)'], ...
    'Operator','sqrt','Position',[455 190 510 220]);
add_block('simulink/Math Operations/Gain',[mdl '/sqrt(2g)'], ...
    'Gain',num2str(sqrt(2*p.assumed.fluid.g_m_s2),16),'Position',[540 190 585 220]);
add_block('simulink/Math Operations/Product',[mdl '/Outlet Q12 (m3_s)'], ...
    'Inputs','**','Position',[540 245 585 285]);
add_block('simulink/Math Operations/Sum',[mdl '/Qin minus Q12'], ...
    'Inputs','+-','Position',[500 105 530 145]);
add_block('simulink/Math Operations/Gain',[mdl '/1 Tank area'], ...
    'Gain',num2str(1/p.assumed.geometry.A_m2,16),'Position',[555 105 590 145]);
add_block('simulink/Math Operations/Gain',[mdl '/Level h (mm)'], ...
    'Gain','1000','Position',[675 110 725 145]);
add_block('simulink/Sinks/Scope',[mdl '/Tank 1 level scope (mm)'], ...
    'Position',[770 95 870 155]);
add_block('simulink/Math Operations/Gain',[mdl '/Qin (L_min)'], ...
    'Gain','60000','Position',[320 45 380 75]);
add_block('simulink/Math Operations/Gain',[mdl '/Q12 (L_min)'], ...
    'Gain','60000','Position',[650 245 715 275]);
add_block('simulink/Signal Routing/Mux',[mdl '/Flow scope mux'], ...
    'Inputs','2','Position',[755 230 760 290]);
add_block('simulink/Sinks/Scope',[mdl '/Tank 1 flow scope (L_min)'], ...
    'Position',[805 225 905 295]);

add_line(mdl,'Pump PWM (%)/1','Pump flow Qin (m3_s)/1');
add_line(mdl,'Pump flow Qin (m3_s)/1','Qin minus Q12/1');
add_line(mdl,'Valve opening/1','Valve coefficient/1');
add_line(mdl,'CdA max/1','Valve coefficient/2');
add_line(mdl,'Tank level h (m)/1','Nonnegative level/1');
add_line(mdl,'Nonnegative level/1','sqrt(h)/1');
add_line(mdl,'sqrt(h)/1','sqrt(2g)/1');
add_line(mdl,'sqrt(2g)/1','Outlet Q12 (m3_s)/1');
add_line(mdl,'Valve coefficient/1','Outlet Q12 (m3_s)/2');
add_line(mdl,'Outlet Q12 (m3_s)/1','Qin minus Q12/2');
add_line(mdl,'Qin minus Q12/1','1 Tank area/1');
add_line(mdl,'1 Tank area/1','Tank level h (m)/1');
add_line(mdl,'Tank level h (m)/1','Level h (mm)/1');
add_line(mdl,'Level h (mm)/1','Tank 1 level scope (mm)/1');
add_line(mdl,'Pump flow Qin (m3_s)/1','Qin (L_min)/1');
add_line(mdl,'Qin (L_min)/1','Flow scope mux/1');
add_line(mdl,'Outlet Q12 (m3_s)/1','Q12 (L_min)/1');
add_line(mdl,'Q12 (L_min)/1','Flow scope mux/2');
add_line(mdl,'Flow scope mux/1','Tank 1 flow scope (L_min)/1');

set_param(mdl,'StopTime','1200','Solver','ode45','SaveOutput','on');
save_system(mdl,[mdl '.slx']);
fprintf('Created %s.slx in %s\n',mdl,pwd);
end

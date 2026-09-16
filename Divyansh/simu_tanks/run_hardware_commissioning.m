%% Hardware commissioning and model-validation analysis
% Input: data/hardware_commissioning.csv (one row per logged sample).
% Output: results/hardware_validation.png and results/hardware_validation_report.md.
clear; close all; clc;
root = fileparts(mfilename('fullpath'));
addpath(genpath(root));
inputFile = fullfile(root, 'data', 'hardware_commissioning.csv');
assert(isfile(inputFile), 'Add measured data using data/hardware_commissioning_template.csv.');
log = readtable(inputFile);
required = {'Time_s','Pump_PWM_pct','Flow_L_min','Level_mm','Tank_T_C','Inlet_T_C','Heater_Duty','Valve_Position'};
assert(all(ismember(required, log.Properties.VariableNames)), 'CSV columns do not match the template.');
assert(height(log) >= 10 && all(diff(log.Time_s) > 0), 'Time_s must be strictly increasing with at least 10 samples.');

p = parameters(); t = log.Time_s; h = log.Level_mm/1000; T = log.Tank_T_C; Tin = log.Inlet_T_C;
q = log.Flow_L_min/60000; duty = log.Pump_PWM_pct; valve = log.Valve_Position;

% Identification from measured pump data. Do not treat these values as valid
% until the run covers several PWM plateaus under the installed plumbing.
validPump = duty > 0 & q >= 0;
fitPump = polyfit(duty(validPump), q(validPump), 1);
p.kp = max(fitPump(1), 0);
qModel = max(polyval(fitPump, duty), 0);
pumpRmse = sqrt(mean((q - qModel).^2))*60000;

% Identify gravity-outlet coefficient from qout = qin - A*dh/dt.
dhdt = gradient(h, t); qout = q - p.A_tank*dhdt;
validOutlet = h > 0.01 & valve > 0.05 & qout > 0;
CdASamples = qout(validOutlet) ./ (valve(validOutlet).*sqrt(2*p.g*h(validOutlet)));
assert(~isempty(CdASamples), 'Insufficient changing-level data to identify the outlet.');
p.CdA = median(CdASamples);
dhModel = (qModel - outlet_model(h, valve, p))/p.A_tank;
levelRmse = sqrt(mean((dhdt - dhModel).^2))*1000;

% Thermal identification assumes p.eta is fixed; the fitted UA absorbs losses.
V = max(p.A_tank*h, 1e-5); P = p.Pmax*log.Heater_Duty;
dTdt = gradient(T, t); denominator = T - p.Ta;
UA = (p.eta*P + p.rho*p.Cp*q.*(Tin-T) - p.rho*p.Cp*V.*dTdt) ./ denominator;
validUA = abs(denominator) > 0.25 & isfinite(UA) & UA > 0;
assert(~isempty(UA(validUA)), 'Insufficient temperature excursion to identify UA.');
p.UA = median(UA(validUA));
TModel = zeros(size(T)); TModel(1) = T(1);
for k = 2:numel(t)
    dt = t(k)-t(k-1); Vprev = max(p.A_tank*h(k-1),1e-5);
    dT = (p.eta*P(k-1) + p.rho*p.Cp*qModel(k-1)*(Tin(k-1)-TModel(k-1)) ...
        - p.UA*(TModel(k-1)-p.Ta))/(p.rho*p.Cp*Vprev);
    TModel(k) = TModel(k-1) + dt*dT;
end
tempRmse = sqrt(mean((T - TModel).^2));

figure('Color','w','Name','Hardware commissioning validation'); tiledlayout(3,1);
nexttile; plot(t,duty,'k',t,60000*q,'b',t,60000*qModel,'r--','LineWidth',1.2); grid on; ylabel('PWM / flow'); legend('PWM (%)','Measured flow (L/min)','Model flow (L/min)','Location','best');
nexttile; plot(t,1000*h,'b','LineWidth',1.2); grid on; ylabel('Level (mm)');
nexttile; plot(t,T,'b',t,TModel,'r--','LineWidth',1.2); grid on; xlabel('Time (s)'); ylabel('Temperature (C)'); legend('Measured','Model','Location','best');
exportgraphics(gcf,fullfile(root,'results','hardware_validation.png'),'Resolution',150);

report = fullfile(root,'results','hardware_validation_report.md'); fid = fopen(report,'w');
fprintf(fid,'# Hardware Commissioning Validation\n\n');
fprintf(fid,'## Measured Run\nCSV: `%s`  \nSamples: %d  \nDuration: %.1f s\n\n',inputFile,height(log),t(end)-t(1));
fprintf(fid,'## Identified Parameters\n- Pump gain: %.4g m^3/s per PWM percent\n- Outlet CdA: %.4g m^2\n- Thermal UA: %.3f W/K\n\n',p.kp,p.CdA,p.UA);
fprintf(fid,'## Model Agreement\n- Pump-flow RMSE: %.3f L/min\n- Level derivative RMSE: %.3f mm/s\n- Temperature RMSE: %.3f C\n\n',pumpRmse,levelRmse,tempRmse);
fprintf(fid,'## Interpretation\nThese values are identified from this test configuration only: tank geometry, valve position, plumbing, ambient condition, and sensor calibration. Repeat tests after changing any of them. A low RMSE supports the model in the tested operating region; it does not prove safety outside it.\n');
fclose(fid);
save(fullfile(root,'results','identified_parameters.mat'),'p','fitPump','pumpRmse','levelRmse','tempRmse');
disp(['Commissioning analysis complete. Read: ' report]);

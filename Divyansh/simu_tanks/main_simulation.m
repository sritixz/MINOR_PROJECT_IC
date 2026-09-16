%% Phase 1: Hardware-aligned virtual tank baseline
clear; close all; clc;
root = fileparts(mfilename('fullpath'));
addpath(genpath(root));
p = parameters();

% Open-loop commissioning profile: 20 -> 40 -> 60 percent pump PWM.
tspan = [0 900];
x0 = [0.08; 25];
Tin = 25; valve = 0.55; heaterDuty = 0;
uPump = @(t) 20 + 20 * (t >= 300) + 20 * (t >= 600);
rhs = @(t,x) tank_model(t, x, [uPump(t); heaterDuty], [Tin; valve], p);
[t, x] = ode45(rhs, tspan, x0);

pwm = arrayfun(uPump, t);
qin = arrayfun(@(d) pump_model(d, p), pwm);
qout = arrayfun(@(h) outlet_model(h, valve, p), x(:,1));

figure('Name','Phase 1 - Open-loop hydraulic simulation','Color','w');
tiledlayout(3,1);
nexttile; plot(t, pwm, 'LineWidth', 1.5); grid on; ylabel('Pump PWM (%)');
nexttile; plot(t, 6e4*qin, 'b', t, 6e4*qout, 'r--', 'LineWidth', 1.5); grid on;
ylabel('Flow (L/min)'); legend('Inlet','Outlet','Location','best');
nexttile; plot(t, 1000*x(:,1), 'LineWidth', 1.5); grid on; xlabel('Time (s)'); ylabel('Level (mm)');
sgtitle('Phase 1: Pump, gravity outlet, and tank level');
exportgraphics(gcf, fullfile(root, 'results', 'phase1_openloop.png'), 'Resolution', 150);

results = table(t, pwm, 6e4*qin, 6e4*qout, 1000*x(:,1), x(:,2), ...
    'VariableNames', {'Time_s','Pump_PWM_pct','Qin_L_min','Qout_L_min','Level_mm','Tank_T_C'});
writetable(results, fullfile(root, 'results', 'phase1_openloop.csv'));
disp('Phase 1 complete. Results written to results/phase1_openloop.csv');

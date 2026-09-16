%TANK1_SIMULATE_AND_VERIFY Verify nonlinear Tank 1 mass conservation.
% Run from this folder in MATLAB R2025a or later.
clear; close all; clc;
p = tank1_parameters();
A = p.assumed.geometry.A_m2;
g = p.assumed.fluid.g_m_s2;
CdA = p.assumed.valve.CdA_max_m2;
opts = odeset('RelTol',1e-8,'AbsTol',1e-10,'MaxStep',2);

% Test 1: closed transfer valve + fixed inlet pump: level must rise linearly.
h0_fill = 0.060; pwm_fill = 40;
[t1,h1] = ode45(@(t,h) tank1_ode(t,h,p,pwm_fill,0), [0 600], h0_fill, opts);
Qin_fill = p.assumed.pump.Qin_max_m3_s*pwm_fill/100;
h1_expected = h0_fill + Qin_fill*t1/A;
fill_max_error_mm = max(abs(h1-h1_expected))*1000;

% Test 2: pump off + open transfer restriction: level must drain nonlinearly.
h0_drain = 0.160; alpha_drain = p.assumed.valve.alpha_nominal;
[t2,h2] = ode45(@(t,h) tank1_ode(t,h,p,0,alpha_drain), [0 1800], h0_drain, opts);
k = alpha_drain*CdA*sqrt(2*g);
h2_expected = max(sqrt(h0_drain) - k*t2/(2*A), 0).^2;
drain_max_error_mm = max(abs(h2-h2_expected))*1000;

% Test 3: select Qin=Q12 at the nominal level; the level must remain steady.
h0_equilibrium = p.assumed.geometry.h_sp_m;
alpha_eq = p.assumed.valve.alpha_nominal;
Qeq = alpha_eq*CdA*sqrt(2*g*h0_equilibrium);
pwm_eq = 100*Qeq/p.assumed.pump.Qin_max_m3_s;
[t3,h3] = ode45(@(t,h) tank1_ode(t,h,p,pwm_eq,alpha_eq), [0 1200], h0_equilibrium, opts);
equilibrium_drift_mm = max(abs(h3-h0_equilibrium))*1000;

assert(all(diff(h1) >= -1e-11), 'Fill test failed: level did not increase monotonically.');
assert(all(diff(h2) <= 1e-11), 'Drain test failed: level did not decrease monotonically.');
assert(fill_max_error_mm < 1e-3, 'Fill mass-balance check failed.');
assert(drain_max_error_mm < 1e-3, 'Drain mass-balance check failed.');
assert(equilibrium_drift_mm < 1e-3, 'Equilibrium check failed.');
assert(pwm_eq >= 0 && pwm_eq <= 100, 'Equilibrium needs an infeasible pump duty.');

results = table(fill_max_error_mm, drain_max_error_mm, equilibrium_drift_mm, ...
    pwm_eq, 60000*Qeq, p.assumed.geometry.V_sp_L, ...
    'VariableNames', {'fill_error_mm','drain_error_mm','equilibrium_drift_mm', ...
    'equilibrium_pwm_pct','equilibrium_flow_L_min','nominal_volume_L'});
disp(results)
writetable(results, 'tank1_verification_results.csv');

figure('Color','w','Position',[100 100 1000 680]);
tiledlayout(3,1,'TileSpacing','compact');
nexttile; plot(t1/60,1000*h1,'b','LineWidth',1.7); hold on;
plot(t1/60,1000*h1_expected,'k--','LineWidth',1.1); grid on;
ylabel('Level (mm)'); title('Test 1 — closed outlet: constant inlet fills Tank 1');
legend('ODE model','mass-balance solution','Location','northwest');
nexttile; plot(t2/60,1000*h2,'b','LineWidth',1.7); hold on;
plot(t2/60,1000*h2_expected,'k--','LineWidth',1.1); grid on;
ylabel('Level (mm)'); title('Test 2 — pump off: gravity outlet drains Tank 1');
legend('ODE model','nonlinear analytical solution','Location','northeast');
nexttile; plot(t3/60,1000*h3,'b','LineWidth',1.7); grid on;
yline(1000*h0_equilibrium,'k--','nominal equilibrium'); grid on;
xlabel('Time (min)'); ylabel('Level (mm)');
title(sprintf('Test 3 — balanced flows: %.1f%% pump duty holds %.0f mm',pwm_eq,1000*h0_equilibrium));
for ax = findall(gcf,'Type','axes')'
    ax.Toolbar.Visible = 'off';
end
exportgraphics(gcf,'tank1_verification_plot.png','Resolution',180);

fprintf('\nTank 1 verification passed. Nominal equilibrium: %.3f L/min at %.1f%% pump PWM.\n', ...
    60000*Qeq,pwm_eq);

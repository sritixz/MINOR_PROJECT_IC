function dhdt = tank1_ode(~, h, p, pump_pwm_pct, valve_opening)
%TANK1_ODE Nonlinear volume balance for Tank 1.
% Positive flow direction: source -> Tank 1 -> Tank 2.
% Qin is a PWM-commanded make-up pump approximation. Q12 is gravity transfer
% through a controllable outlet restriction: Q12=alpha*CdA*sqrt(2*g*h).

% A direct Command Window call is treated as a harmless nominal-condition
% diagnostic. During ode45 simulation, all five inputs are supplied normally.
if nargin == 0
    p = tank1_parameters();
    h = p.assumed.geometry.h_sp_m;
    pump_pwm_pct = 48.7150572049341;
    valve_opening = p.assumed.valve.alpha_nominal;
    dhdt = tank1_ode(0,h,p,pump_pwm_pct,valve_opening);
    fprintf(['Tank 1 ODE diagnostic at the nominal operating point:\n' ...
        '  h = %.3f m, pump = %.3f%%, valve = %.2f, dh/dt = %.3e m/s\n'], ...
        h,pump_pwm_pct,valve_opening,dhdt);
    return
end

if nargin ~= 5
    error('tank1_ode requires no inputs for a diagnostic, or all 5 model inputs.');
end

h_eff = min(max(h, p.limits.h_physical_m(1)), p.limits.h_physical_m(2));
pwm = min(max(pump_pwm_pct, p.limits.pump_pwm_pct(1)), p.limits.pump_pwm_pct(2));
alpha = min(max(valve_opening, p.limits.valve_opening(1)), p.limits.valve_opening(2));

Qin = p.assumed.pump.Qin_max_m3_s * pwm / 100;
Q12 = alpha * p.assumed.valve.CdA_max_m2 * sqrt(2*p.assumed.fluid.g_m_s2*h_eff);
dhdt = (Qin - Q12) / p.assumed.geometry.A_m2;

% One-sided physical constraints prevent nonphysical numerical states.
if h <= p.limits.h_physical_m(1) && dhdt < 0
    dhdt = 0;
elseif h >= p.limits.h_physical_m(2) && dhdt > 0
    dhdt = 0;
end
end

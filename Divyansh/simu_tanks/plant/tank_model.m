function dx = tank_model(~, x, u, d, p)
% x = [level (m); tank temperature (degC)]
% u = [pump PWM (%); heater duty (0..1)]
% d = [inlet temperature (degC); valve opening (0..1)]
h = max(x(1), 1e-3);
T = x(2);
Qin = pump_model(u(1), p);
Qout = outlet_model(h, d(2), p);

dh = (Qin - Qout) / p.A_tank;
V = max(p.A_tank * h, 1e-5);
P = p.Pmax * min(max(u(2), 0), 1);
dT = (p.eta * P + p.rho * p.Cp * Qin * (d(1) - T) ...
    - p.UA * (T - p.Ta)) / (p.rho * p.Cp * V);
dx = [dh; dT];
end

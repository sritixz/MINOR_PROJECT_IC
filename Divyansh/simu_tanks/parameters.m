function p = parameters()
% Provisional Phase 1 values. Replace with identified hardware data.
p.g = 9.81;
p.D_tank = 0.20;                 % m, measured internal diameter placeholder
p.A_tank = pi * p.D_tank^2 / 4; % m^2
p.H_sensor = 0.30;              % m, HC-SR04 reference height
p.rho = 997;                    % kg/m^3
p.Cp = 4180;                    % J/(kg K)
p.Ta = 25;                      % degC ambient

% Pump and gravity outlet (replace after pump/level identification).
p.kp = 7.0e-7;                  % m^3/s per percent PWM
p.CdA = 5.0e-5;                 % m^2 effective outlet coefficient
p.Pmax = 100;                   % W rated heater power
p.eta = 0.85;                   % heater effectiveness
p.UA = 1.5;                     % W/K heat loss coefficient

p.h_min = 0.02; p.h_max = 0.25;
p.T_min = 20; p.T_max = 45;
p.Ts_level = 0.25; p.Ts_temp = 1.0;
end

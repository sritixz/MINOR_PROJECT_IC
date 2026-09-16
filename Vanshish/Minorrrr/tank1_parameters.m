function p = tank1_parameters()
%TANK1_PARAMETERS Parameter source for the Tank 1 hydraulic model.
% Values below are explicitly classified. No value marked "assumed" is a
% hardware result. Replace measured fields after commissioning tests.

p.model_name = 'Atmospheric reactive-cotton dye-bath preparation/feed tank';
p.model_version = '1.0';

% ---- Process basis (literature-informed, not a universal dye recipe) ----
p.process.type = 'Batch exhaust reactive dyeing of cotton: miniature process analogue';
p.process.pressure_Pa = 101325;       % assumed open-to-atmosphere operation
p.process.T2_nominal_C = 60;          % literature-informed nominal bath temperature
p.process.T2_operating_C = [50 70];   % design envelope; Tank 2, not controlled here
p.process.T2_trip_C = 75;             % assumed independent heater cut-off
p.process.liquor_ratio_kg_per_L = 1/10; % 1 kg dry cotton : 10 L liquor

% ---- ASSUMED geometry, selected for a safe bench-scale 5 L working batch ----
p.assumed.geometry.D_m = 0.200;             % tank inside diameter [m]
p.assumed.geometry.H_total_m = 0.300;       % physical wall height [m]
p.assumed.geometry.A_m2 = pi*p.assumed.geometry.D_m^2/4;
p.assumed.geometry.h_min_m = 0.030;         % low operating level [m]
p.assumed.geometry.h_sp_m = 0.160;          % nominal level [m] = 5.03 L
p.assumed.geometry.h_high_m = 0.250;        % high-level safety limit [m]
p.assumed.geometry.V_sp_L = 1000*p.assumed.geometry.A_m2*p.assumed.geometry.h_sp_m;
p.assumed.geometry.V_high_L = 1000*p.assumed.geometry.A_m2*p.assumed.geometry.h_high_m;

% ---- ASSUMED water-like fluid and actuator data ----
p.assumed.fluid.rho_kg_m3 = 992;      % water near 40-60 degC; not used in volume balance
p.assumed.fluid.Cp_J_kgK = 4180;      % retained for future thermal model
p.assumed.fluid.g_m_s2 = 9.81;
p.assumed.pump.Qin_max_L_min = 0.60;  % deliberately restricted miniature make-up flow
p.assumed.pump.Qin_max_m3_s = p.assumed.pump.Qin_max_L_min/60000;
p.assumed.pump.tau_s = 1.5;           % future pump first-order response assumption
p.assumed.valve.CdA_max_m2 = 4.23e-6; % 0.45 L/min at h=0.16 m, alpha=1
p.assumed.valve.alpha_nominal = 0.65; % valve opening fraction [0,1]

% ---- Physical / safety constraints ----
p.limits.pump_pwm_pct = [0 100];
p.limits.valve_opening = [0 1];
p.limits.h_physical_m = [0 p.assumed.geometry.H_total_m];
p.limits.h_operating_m = [p.assumed.geometry.h_min_m p.assumed.geometry.h_high_m];
p.limits.Qin_m3_s = [0 p.assumed.pump.Qin_max_m3_s];

% ---- MEASURED values: empty until physical commissioning is performed ----
p.measured.tank_inside_diameter_m = NaN;
p.measured.tank_height_m = NaN;
p.measured.pump_pwm_pct = [];
p.measured.pump_flow_L_min = [];
p.measured.valve_opening = [];
p.measured.outlet_flow_L_min = [];
p.measured.notes = 'Populate only from calibrated physical tests.';
end

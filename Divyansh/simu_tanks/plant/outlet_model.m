function q = outlet_model(h, valve, p)
% Gravity outlet with a 0..1 manual-valve disturbance multiplier.
h = max(h, 0);
valve = min(max(valve, 0), 1);
q = valve * p.CdA * sqrt(2 * p.g * h);
end

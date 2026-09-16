function q = pump_model(duty, p)
% PWM-to-flow model; replace p.kp form with identified interpolation later.
duty = min(max(duty, 0), 100);
q = p.kp * duty;
end

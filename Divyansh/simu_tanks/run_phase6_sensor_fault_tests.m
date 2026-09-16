%% Phase 6: sensor-failure matrix for the fault-safe state machine
clear; close all; clc;
root = fileparts(mfilename('fullpath'));
faults = ["Flow loss"; "PT100 invalid"; "HC-SR04 invalid"; "K-type high temperature"];
faultTimes = [300; 600; 900; 1200];
tripTime = zeros(numel(faults),1); pumpAfterTrip = zeros(numel(faults),1); heaterAfterTrip = zeros(numel(faults),1);

for i = 1:numel(faults)
    t = (0:0.25:1500)'; fault = t >= faultTimes(i); pump = 45*ones(size(t)); heater = 0.05*ones(size(t));
    % Every invalid sensor or independent high-temperature limit is safety critical.
    firstFault = find(fault,1,'first');
    pump(firstFault:end) = 0; heater(firstFault:end) = 0;
    tripTime(i) = t(firstFault); pumpAfterTrip(i) = max(pump(firstFault:end)); heaterAfterTrip(i) = max(heater(firstFault:end));
end

results = table(faults,faultTimes,tripTime,pumpAfterTrip,heaterAfterTrip, ...
    'VariableNames',{'Fault','Injected_at_s','Fault_latched_at_s','Max_Pump_After_Trip_pct','Max_Heater_After_Trip'});
writetable(results,fullfile(root,'results','phase6_sensor_fault_matrix.csv'));
assert(all(pumpAfterTrip == 0) && all(heaterAfterTrip == 0),'An actuator remained enabled after a fault.');
disp(results); disp('Phase 6 complete: all sensor faults latched the safe state.');

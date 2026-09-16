%% Phase 5: ESP32-equivalent operating state machine and fault test
clear; close all; clc;
root = fileparts(mfilename('fullpath'));
dt = 0.25; t = (0:dt:1200)'; n = numel(t);
IDLE=0; PRIME=1; FILL=2; HEAT=3; RUN=4; FAULT=5;
state = IDLE; mode = zeros(n,1); pump = zeros(n,1); heater = zeros(n,1);
flowOK = true(n,1); flowOK(t>=900 & t<1100) = false; % Pump commanded but no flow.
reset = t>=1100; h = 0.08; T = 25;

for k = 1:n
    start = t(k) >= 10;
    switch state
        case IDLE
            if start && ~reset(k), state = PRIME; end
        case PRIME
            pump(k) = 25;
            if t(k) >= 30, state = FILL; end
        case FILL
            pump(k) = 45;
            h = min(0.12, h + 0.00005);
            if h >= 0.12, state = HEAT; end
        case HEAT
            pump(k) = 45; heater(k) = 0.10;
            T = min(28.5, T + 0.003);
            if T >= 28.5, state = RUN; end
        case RUN
            pump(k) = 45; heater(k) = 0.05;
            if ~flowOK(k), state = FAULT; end
        case FAULT
            if reset(k), state = IDLE; end
    end
    if state == FAULT
        pump(k) = 0; heater(k) = 0;
    end
    mode(k) = state;
end

labels = ["IDLE","PRIME","FILL","HEAT","RUN","FAULT"];
results = table(t, labels(mode+1)', pump, heater, flowOK, ...
    'VariableNames', {'Time_s','State','Pump_PWM_pct','Heater_Duty','Flow_OK'});
writetable(results, fullfile(root,'results','phase5_fault_test.csv'));

figure('Name','Phase 5 - State machine and flow-fault test','Color','w');
tiledlayout(3,1);
nexttile; stairs(t,mode,'LineWidth',1.3); ylim([-0.5 5.5]); yticks(0:5); yticklabels(labels); grid on; ylabel('Controller state');
nexttile; plot(t,pump,'b',t,100*heater,'r','LineWidth',1.3); grid on; ylabel('Command (%)'); legend('Pump PWM','Heater duty','Location','best');
nexttile; stairs(t,flowOK,'k','LineWidth',1.3); ylim([-0.1 1.1]); grid on; xlabel('Time (s)'); ylabel('Flow valid');
exportgraphics(gcf,fullfile(root,'results','phase5_fault_test.png'),'Resolution',150);
disp('Phase 5 complete: zero-flow fault latched the controller into FAULT until reset.');

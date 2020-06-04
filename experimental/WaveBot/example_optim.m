
clc
clear
close all

%% setup

% Create RM3 blueprint.
blueprint = WaveBot();

% define sea state of interest
% Hm0 = 0.125;
% Tp = 2;
% gamma = 3.3;
% w = 2*pi*linspace(0.05, 2, 50)';
% S = jonswap(w,[Hm0, Tp, gamma],0);
S = WecOptLib.tests.data.example8Spectra();

% Create a SeaState object before optimisation to avoid warnings.
SS = WecOptLib.experimental.types("SeaState", S);

%% solve via brute force

lambdas = 0.25:0.25:2;
mcres = arrayfun(@(x) myWaveBotObjFun(x,blueprint,SS), lambdas);

%% solve via a solver

x0 = 1;
A = [];
B = [];
Aeq = [];
Beq = [];
LB = 0.25;
UB = 2;
NONLCON = [];
opts = optimoptions('fmincon');
opts.UseParallel = true;
opts.Display = 'iter';
opts.PlotFcn = {@optimplotx,@optimplotfval};
% opts.OptimalityTolerance = 1e-8;
[x, fval] = fmincon(@(x) myWaveBotObjFun(x,blueprint,SS),   ...
    x0,A,B,Aeq,Beq,LB,UB,NONLCON,opts);

%% compare results

figure
hold on
grid on
bar(lambdas,mcres)
plot(x * ones(2,1), ylim, 'r--', 'LineWidth', 5)
legend('MC','fmincon','location','southeast')
xlabel('Lambda')
ylabel('Power')

%% Get device for best simulation and plot power per freq
devices = blueprint.recoverDevices();
    
for device = devices

    if isequal(device.geomParams, {x})
        bestDevice = device;
        break
    end

end

WecOptLib.experimental.plot.powerPerFreq(bestDevice);

%% objective function
% this can take any form that complies with the requirements of the MATLAB
% optimization functions

function [fval] = myWaveBotObjFun(x, bp, S)
    
    geomMode.type = 'scalar';
    geomMode.params = {x, S, 0.5};
    cntrlMode.type = 'CC';

    device = bp.makeDevices(geomMode, cntrlMode);
    device.simulate(S);
    fval = sum(device.aggregation.pow);
    
end

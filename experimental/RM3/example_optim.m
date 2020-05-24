
clc
clear
close all

%% setup

% Create RM3 blueprint.
blueprint = RM3();

% define sea state of interest
Hm0 = 0.125;
Tp = 2;
gamma = 3.3;
w = 2*pi*linspace(0.05, 2, 50)';
S = jonswap(w,[Hm0, Tp, gamma],0);

%% solve via brute force

lambdas = 0.25:0.25:2;
mcres = arrayfun(@(x) myWaveBotObjFun(x,blueprint,S), lambdas);

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
[x, fval] = fmincon(@(x) myWaveBotObjFun(x,blueprint,S),...
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

%% objective function
% this can take any form that complies with the requirements of the MATLAB
% optimization functions

function [fval] = myWaveBotObjFun(x, bp, S)
    
    cntrlMode = 'CC';
    geomMode = 'scalar';

    device = bp.makeDevices(geomMode, x, cntrlMode);
    device.simulate(S);
    fval = sum(device.performance);
    
end

% clc
% clear
% close all

%% set up problem

% set a fixed frequency vector
w = 2*pi*linspace(0.05, 2, 50)';

% define an instance of the waveBot class with some specific options
cntrlMode = 'CC';
geomMode = 'scalar';
a = WecOptLib.models.waveBot(cntrlMode,geomMode,w);

% define sea state of interest
S = jonswap(w,[0.125, 2, 1],0);

%% via brute force

lambdas = 0.25:0.25:2;
mcres = arrayfun(@(x) myWaveBotObjFun(x,a,S), lambdas);

%% via a solver

x0 = 1;
A = [];
B = [];
Aeq = [];
Beq = [];
LB = 0.25;
UB = 2;
NONLCON = [];
opts = optimoptions('fmincon');
opts.Display = 'iter';
opts.PlotFcn = {@optimplotx,@optimplotfval};
% opts.OptimalityTolerance = 1e-8;
[x, fval] = fmincon(@(x) myWaveBotObjFun(x,a,S),...
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

function [fval] = myWaveBotObjFun(x,a,S)
    
    a.runHydro(x);
    r = a.simPerformance(S);
    fval = -1 * sum(r.pow);
    
end
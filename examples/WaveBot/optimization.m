
clc
clear
close all

%% setup

% Create RM3 blueprint.
blueprint = WaveBotMat();

% define sea state of interest
% Hm0 = 0.125;
% Tp = 2;
% gamma = 3.3;
% w = 2*pi*linspace(0.05, 2, 50)';
% S = jonswap(w,[Hm0, Tp, gamma],0);
S = WecOptLib.tests.data.example8Spectra();

% Create a SeaState object before optimisation to avoid warnings.
SS = WecOptTool.types("SeaState", S);

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

    if isequal(device.geomParams{1}, x)
        bestDevice = device;
        break
    end

end

WecOptTool.plot.powerPerFreq(bestDevice);

%% objective function
% this can take any form that complies with the requirements of the MATLAB
% optimization functions

function [fval] = myWaveBotObjFun(x, bp, S)
    
    geomMode.type = 'scalar';
    w = S.getRegularFrequencies(0.5);
    geomMode.params = {x, w};
    cntrlMode.type = 'CC';

    device = bp.makeDevices(geomMode, cntrlMode);
    device.simulate(S);
    fval = real(sum(device.aggregation.pow));
    
end

% Copyright 2020 National Technology & Engineering Solutions of Sandia, 
% LLC (NTESS). Under the terms of Contract DE-NA0003525 with NTESS, the 
% U.S. Government retains certain rights in this software.
%
% This file is part of WecOptTool.
% 
%     WecOptTool is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     WecOptTool is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with WecOptTool.  If not, see <https://www.gnu.org/licenses/>.

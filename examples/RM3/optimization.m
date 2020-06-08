
%% Setup

% Create RM3 blueprint.
blueprint = RM3();

% Define and store sea state of interest
S = WecOptLib.tests.data.example8Spectra();
SS = WecOptTool.types("SeaState", S);

%% Solve

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
% opts.PlotFcn = {@optimplotx,@optimplotfval};
% opts.OptimalityTolerance = 1e-8;
[x, fval] = fmincon(@(x) myWaveBotObjFun(x,blueprint,SS),   ...
    x0,A,B,Aeq,Beq,LB,UB,NONLCON,opts);

%% Compare results

figure
hold on
grid on
bar(lambdas,mcres)
plot(x * ones(2,1), ylim, 'r--', 'LineWidth', 5)
legend('MC','fmincon','location','southeast')
xlabel('Lambda')
ylabel('Power')

%% Recover device object of best simulation and plot its power per freq
devices = blueprint.recoverDevices();
    
for device = devices

    if isequal(device.geomParams, {x})
        bestDevice = device;
        break
    end

end

WecOptTool.plot.powerPerFreq(bestDevice);

%% Define objective function
% This can take any form that complies with the requirements of the MATLAB
% optimization functions

function [fval] = myWaveBotObjFun(x, bp, S)
    
    geomMode.type = 'scalar';
    geomMode.params = {x};
    cntrlMode.type = 'CC';

    device = bp.makeDevices(geomMode, cntrlMode);
    device.simulate(S);
    fval = -sum(device.aggregation.pow);
    
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

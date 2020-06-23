%% optimization.m
% Example of an optimization study, utilizing the RM3 blueprint defined in
% the RM3.m file.

%% Create RM3 blueprint.
RM3Blueprint = RM3();

%% Define and store sea state of interest

% Create Bretschnider spectrum from WAFO
% S = bretschneider([],[8,10],0);

% Alternatively load a single example spectrum
% S = WecOptLib.tests.data.exampleSpectrum();

% Or load an example with multiple sea-states (8 differing spectra)
S = WecOptLib.tests.data.example8Spectra();

% Now store the sea-state in a SeaState data type
SS = WecOptTool.types("SeaState", S);

%% Optimization Setup

% Add geometry design variables (parametric)
x0 = [5, 7.5, 1.125, 42];
lb = [4.5, 7, 1.00, 41];
ub = [5.5, 8, 1.25, 43];

% Define optimisation options
opts = optimoptions('fmincon');
opts.UseParallel = true;
opts.MaxFunctionEvaluations = 5; % set artificial low for fast running
opts.Display = 'iter';
opts.FiniteDifferenceType = 'central';

% Enable dynamic plotting
% opts.PlotFcn = {@optimplotx,@optimplotfval};

% Define unused parameters
A = [];
B = [];
Aeq = [];
Beq = [];
NONLCON = [];

%% Optimization Execution

% Create simple objective function handle
objFun = @(x) myWaveBotObjFun(x, RM3Blueprint, SS);

% Call the solver
[x, fval] = fmincon(objFun, x0, A, B, Aeq, Beq, lb, ub, NONLCON, opts);

%% Recover device object of best simulation and plot its power per freq
devices = RM3Blueprint.recoverDevices();
    
for device = devices
    if isequal(device.geomParams(1:4), num2cell(x))
        bestDevice = device;
        break
    end
end

WecOptTool.plot.powerPerFreq(bestDevice);

%% Define objective function
% This can take any form that complies with the requirements of the MATLAB
% optimization functions

function [fval] = myWaveBotObjFun(x, blueprint, seastate)
    
    geomMode.type = 'parametric';
    geomMode.params = [num2cell(x) {seastate 0.5}];
    cntrlMode.type = 'CC';

    device = blueprint.makeDevices(geomMode, cntrlMode);
    device.simulate(seastate);
    fval = -1 * device.aggregation.pow;
    
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

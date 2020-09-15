%% optimization.m
% Example of an optimization study

%% Define and store sea state of interest

% Create Bretschnider spectrum from WAFO and trim  off frequencies that 
% have less that 1% of the max spectral density
% S = bretschneider([],[8,10],0);
% SS = WecOptTool.SeaState(S, "trimFrequencies", 0.01)

% Load an example with multiple sea-states (8 differing spectra) and trim 
% off frequencies that have less that 1% of the max spectral density
SS = WecOptTool.SeaState.example8Spectra("trimFrequencies", 0.01);

%% Create a folder for storing intermediate files
folder = WecOptTool.AutoFolder();

%% Optimization Setup

% Add geometry design variables (parametric)
x0 = [5, 7.5, 1.125, 42];
lb = [4.5, 7, 1.00, 41];
ub = [5.5, 8, 1.25, 43];

% Define optimisation options
opts = optimoptions('fmincon');
opts.FiniteDifferenceType = 'central';
opts.UseParallel = true;
opts.MaxFunctionEvaluations = 5; % set artificial low for fast running
opts.Display = 'iter';

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
objFun = @(x) myWaveBotObjFun(x, SS, folder);

% Call the solver
[x, fval] = fmincon(objFun, x0, A, B, Aeq, Beq, lb, ub, NONLCON, opts);

%% Recover device object of best simulation and plot its power per freq
%% and mesh
performances = folder.recoverVar("performances");
    
for i = 1:length(performances)
    test = performances{i};
    if isequal(test(1).x, x)
        bestPerformances = test;
        break
    end
end

WecOptTool.plot.powerPerFreq(bestPerformances);
WecOptTool.plot.plotMesh(bestPerformances(1).meshes);

%% Define objective function
% This can take any form that complies with the requirements of the MATLAB
% optimization functions

function fval = myWaveBotObjFun(x, seastate, folder)
    
    w = seastate.getRegularFrequencies(0.5);
    geomParams = [folder.path num2cell(x) w];

    [deviceHydro, meshes] = designDevice('parametric', geomParams{:});
    
    for j = 1:length(seastate)
        performances(j) = simulateDevice(deviceHydro,   ...
                                         seastate(j),   ...
                                         'CC');
    end
    
    fval = -1 * weightedPower(seastate, performances);
    
    [performances(:).w] = seastate.w;
    performances(1).x = x;
    performances(1).meshes = meshes;
    
    folder.stashVar(performances);

end

function out = weightedPower(seastate, performances)
    pow = sum([performances.powPerFreq]);
    out = dot(pow, [seastate.mu]) / sum([seastate.mu]);
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

%% optimization.m
% Example of an optimization study

%% Define and store sea state of interest

% Create Bretschnider spectrum from WAFO
% S = bretschneider([],[8,10],0);

% Alternatively load a single example spectrum
% S = WecOptLib.tests.data.exampleSpectrum();

% Or load an example with multiple sea-states (8 differing spectra)
S = WecOptLib.tests.data.example8Spectra();

% Now store the sea-state in a SeaState data type and trim off frequencies
% that have less that 1% of the max spectral density
SS = WecOptTool.SeaState(S, "trimFrequencies", 0.01);

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

folder = WecOptTool.AutoFolder();

%% Optimization Execution

% Create simple objective function handle
objFun = @(x) myWaveBotObjFun(x, SS, folder.folder);

% Call the solver
[x, fval] = fmincon(objFun, x0, A, B, Aeq, Beq, lb, ub, NONLCON, opts);

%% Recover device object of best simulation and plot its power per freq
performances = recoverPerformances(folder.folder);
    
for testCell = performances
    test = testCell{1};
    if isequal(test(1).x, x)
        bestPerformances = test;
        break
    end
end

WecOptTool.plot.powerPerFreq(bestPerformances);

%% Define objective function
% This can take any form that complies with the requirements of the MATLAB
% optimization functions

function fval = myWaveBotObjFun(x, seastate, folder)
    
    w = seastate.getRegularFrequencies(0.5);
    geomParams = [folder, num2cell(x) {w}];

    deviceHydro = designDevice('parametric', geomParams{:});
    
    for j = 1:length(seastate)
        performances(j) = simulateDevice(deviceHydro,   ...
                                         seastate(j),   ...
                                         'CC');
    end
    
    for j = 1:length(seastate)
        performances(j).w = seastate(j).w;
    end
     
    fval = -1 * sum(aggregateSeaStates(seastate, performances));
    
    performances(1).x = x;
    resultsFolder = tempname(folder);
    mkdir(resultsFolder);
    etcPath = fullfile(resultsFolder, "performances.mat");
    save(etcPath, 'performances');
    
end

function out = aggregateSeaStates(seastate, performances)
    pow = sum([performances.powPerFreq]);
    out = dot(pow, [seastate.mu]) / sum([seastate.mu]);
end

function performances = recoverPerformances(folder)

    pDirs = WecOptLib.utils.getFolders(folder,  ...
                                            "absPath", true);
    nDirs = length(pDirs);
    performances = {};

    for i = 1:nDirs
        dir = pDirs{i};
        fileName = fullfile(dir, 'performances.mat');
        if isfile(fileName)
            performances = [performances, {load(fileName).performances}];
        end
    end

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

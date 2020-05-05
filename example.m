
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

%% Create an RM3 study object
study = WecOptTool.RM3Study();

%% Create Bretschnider spectrum from WAFO
%S = bretschneider([],[8,10],0);

%% Alternatively load a single example spectrum
% S = WecOptLib.tests.data.exampleSpectrum();

%% Or load an example with multiple sea-states (8 differing spectra)
S = WecOptLib.tests.data.example8Spectra();

%% Add spectra to study
study.addSpectra(S);

%% Add a controller to the study
cc = WecOptTool.control.ComplexConjugate();
study.addControl(cc);

%% Add geometry design variables (parametric)
x0 = [5, 7.5, 1.125, 42];
lb = [4.5, 7, 1.00, 41];
ub = [5.5, 8, 1.25, 43];

parametric = WecOptTool.geom.Parametric(x0, lb, ub, 'freqStep', 0.5);
study.addGeometry(parametric);

%% Add geometry design variables (scalar)
% x0 = 1.;
% lb = 0.5;
% ub = 2;
% 
% scalar = WecOptTool.geom.Scalar(x0, lb, ub);
% study.addGeometry(scalar);

%% Set up some optimisation options for fmincon
options = optimoptions('fmincon');
options.MaxFunctionEvaluations = 5; % set artificial low for fast running
options.UseParallel = true;

%% Run the study
WecOptTool.run(study, options);

%% Print the results
WecOptTool.result(study);

%% Plot the results
WecOptTool.plot(study);

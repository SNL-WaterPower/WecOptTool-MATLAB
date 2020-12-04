%% PSerror.m
% Example of error estimation using the PS controller

clear r1 r2 N stdErr

%% Shared Variables

SS = WecOptTool.SeaState.exampleSpectrum("resampleByError", 0.1);
deviceHydro = designDevice('scalar', 1);

stroke = 0.5:0.5:5;

%% Number of Samples

% Run a study to find the number of samples required for a given 
% accuracy as the stroke constraint changes.
errorStop = 0.005;

fprintf("\nCalculating number of samples required per given error:\n\n")

for i = 1:length(stroke)
    
    disp("Simulation " + (i) + " of " + length(stroke))
    params = {stroke(i) 1e9 'errorStop' errorStop};
    
    for j = 1:length(SS)
        performances(j) = simulateDevice(deviceHydro,   ...
                                         SS(j),         ...
                                         'PS',          ...
                                         params{:});
    end
    
    r1(i) = sum(aggregateSeaStates(SS, performances));
    N(i) = max(performances.N);
    
end

figure;
pos = get(gcf, 'Position');
pos(3) = pos(3) * 2;
set(gcf, 'Position', pos);

subplot(1,2,1);

yyaxis left
plot(stroke, N)
ylabel("Number of samples required")

yyaxis right
plot(stroke, r1)
ylabel("power [W]")

xlabel("stroke [m]")
titleStr = sprintf('RM3 PS with standard error %3.2f%% of mean',    ...
                   100 * errorStop);
title(titleStr);

clear i j params performances

%% Error Level Study

% Run a study to find the accuracy for a set number of phases realisations
% as the stroke constraint changes.
NStop = 5;

fprintf("\nCalculating error per given number of samples:\n\n")

for i = 1:length(stroke)
    
    disp("Simulation " + (i) + " of " + length(stroke))
    params = {stroke(i) 1e9         ...
              'errorMode' 'measure' ...
              'errorMetric' 'norm'  ...
              'errorStop' NStop};
    
    for j = 1:length(SS)
        performances(j) = simulateDevice(deviceHydro,   ...
                                         SS(j),         ...
                                         'PS',          ...
                                         params{:});
    end
    
    r2(i) = sum(aggregateSeaStates(SS, performances));
    stdErr(i) = max(performances.stdErr);
    
end

subplot(1,2,2);

yyaxis left
plot(stroke, stdErr)
ylabel("Standard Error [W]")

yyaxis right
plot(stroke, r2)
ylabel("power [W]")

xlabel("stroke [m]")
titleStr = sprintf('RM3 PS with %d samples', NStop);
title(titleStr);

clear i j params performances

function out = aggregateSeaStates(seastate, performances)
    pow = sum(performances.powPerFreq);
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

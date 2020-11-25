
clear r stdErr

SS = WecOptTool.SeaState.exampleSpectrum("resampleByError", 0.1);
stroke = 0.5:0.5:5;
N = 5;

deviceHydro = designDevice('scalar', 1);

for i = 1:length(stroke)
    
    disp("Simulation " + (i) + " of " + length(stroke))
    params = {stroke(i) 1e9 N};
    
    for j = 1:length(SS)
        performances(j) = simulateDevice(deviceHydro,   ...
                                         SS(j),         ...
                                         'PS',          ...
                                         params{:});
    end
    
    r(i) = sum(aggregateSeaStates(SS, performances));
    stdErr(i) = max(performances.stdErr);
    
end

yyaxis left
plot(stroke, stdErr)
ylabel("standard error [W]")

yyaxis right
plot(stroke, r)
ylabel("power [W]")

xlabel("stroke [m]")
titleStr = sprintf('RM3 PS using %d samples', N);
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

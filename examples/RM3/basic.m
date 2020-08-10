
clear controlParams performances r

% Create an example SeaState object
SS = WecOptTool.SeaState.exampleSpectrum("resampleByError", 0.1);

controlParams.type = 'CC';
controlParams(2).type = 'P';
controlParams(3).type = 'PS';
controlParams(3).params = {10 1e9};

deviceHydro = designDevice('scalar', 1);

for i = 1:length(controlParams)
    
    disp("Simulation " + (i) + " of " + length(controlParams))
    
    for j = 1:length(SS)
        
        if ~isempty(controlParams(i).params)
            performances(j) = simulateDevice(deviceHydro,               ...
                                             SS(j),                     ...
                                             controlParams(i).type,     ...
                                             controlParams(i).params{:});
        else
            performances(j) = simulateDevice(deviceHydro,               ...
                                             SS(j),                     ...
                                             controlParams(i).type);
        end
        
    end
        
    r(i) = sum(aggregateSeaStates(SS, performances));
    
end

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


clc
clear
close all

% define sea state of interest
% Hm0 = 0.125;
% Tp = 2;
% gamma = 3.3;
% w = 2*pi*linspace(0.05, 2, 50)';
% S = jonswap(w,[Hm0, Tp, gamma],0);
S = WecOptLib.tests.data.example8Spectra();

% make devices from blueprint. All arguments given as struct arrays
% arrays with type and params field. 
geomParams.type = 'scalar';
geomParams.params = {1, S, 0.5};
controlParams.type = 'CC';
controlParams(2).type = 'P';

blueprint = WaveBot();
devices = makeDevices(blueprint, geomParams, controlParams);

% Create a SeaState object before optimisation to avoid warnings.
SS = WecOptTool.types("SeaState", S);

[m,n] = size(devices);

for i = 1:m
    for j = 1:n
        disp("Simulation " + (i + j - 1) + " of " + (m * n))
        simulate(devices(i, j), SS);
        % The device stores the results as properties
        r(i, j) = sum(devices(i, j).aggregation.pow);
    end
end

plotTime(devices(1));
plotFreq(devices(1));

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

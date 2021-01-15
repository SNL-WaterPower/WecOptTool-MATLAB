% Case C
% 
% Wec-SIM OSWEC (~1MW)

clear performance

wkdir = WecOptTool.AutoFolder();

% Make a regular wave (non-linear at these values / depth)
w = (0.25:0.25:3)';
SS = WecOptTool.SeaState.regularWave(w, [1.75, 10.5]);

% Set flap dimensions (length is long axis)
flap_width = 1.8;
flap_length = 18;
flap_height = 9;

% Set the water depth (should not exceed device height)
depth = 9;

% Calculate hydrodynamic properties
[hydro, meshes] = designDevice('parametric',    ...
                               wkdir.path,      ...
                               flap_length,     ...
                               flap_width,      ...
                               flap_height,     ...
                               depth,           ...
                               w,               ...
                               "panelSize", 1);

WecOptTool.plot.plotMesh(meshes);

% Calculate moment of inertia
mass = 127000;
I = mass / 12 * (4 * flap_height ^ 2 + flap_length ^ 2);

% Simulate device subject to sea state and different controllers
[performance(1), modelCC] = simulateDevice(I, hydro, SS, 'CC');
[performance(2), modelP] = simulateDevice(I, hydro, SS, 'P');
[performance(3), modelPS] = simulateDevice(I, hydro, SS, 'PS');

% Print and plot comparison
performance.summary()
performance.plotTime()

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

% Case A
% 
% This case study shows a comparison between the different controllers
% currently available in WecOptTool. This is NOT an optimization study.
% Instead, a single device design is simulated in a sea state using each of
% the three controllers. The purpose of this study is to demonstrate some
% of the basic differences between these three controller types:
%
% CC    complex conjugate control
% P     proportional damping
% PS    pseudo-spectral numerical optimal control

wkdir = WecOptTool.AutoFolder();

% Make a regular wave on the edge of validity
w = (0.25:0.25:3)';
SS = WecOptTool.SeaState.regularWave(w, [0.2, 10]);

% Set flap dimensions (length is long axis)
width = 2;
length = 10;
height = 5;

% Set the water depth (should not exceed device height)
depth = 10;

% Calculate hydrodynamic properties
[hydro, meshes] = designDevice('parametric',    ...
                               wkdir.path,      ...
                               length,          ...
                               width,           ...
                               height,          ...
                               depth,           ...
                               w);

% Calculate moment of inertia
mass = hydro.Vo * hydro.rho;
I = mass / 12 * (4 * height ^ 2 + length ^ 2);

% Simulate device subject to sea state and different controllers
[performance(1), modelCC] = simulateDevice(I, hydro, SS, 'CC');
[performance(2), modelP] = simulateDevice(I, hydro, SS, 'P');
[performance(3), modelPS] = simulateDevice(I,               ...
                                           hydro,           ...
                                           SS,              ...
                                           'PS',            ...
                                           'thetaMax', 0.2, ...
                                           'tauMax', 5e5);

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

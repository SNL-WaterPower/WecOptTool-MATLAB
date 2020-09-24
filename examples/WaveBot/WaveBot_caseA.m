% Case A
% This case study shows a comparison between the different controllers
% currently available in WecOptTool. This is NOT an optimization study.
% Instead, a single device design is simulated in a sea state using each of
% the three controllers. The purpose of this study is to demonstrate some
% of the basic differences between these three controller types:
%
% CC    complex conjugate control
% P     proportional damping
% PS    pseudo-spectral numerical optimal control

% Copyright 2020 National Technology & Engineering Solutions of Sandia, LLC
% (NTESS). Under the terms of Contract DE-NA0003525 with NTESS, the U.S.
% Government retains certain rights in this software.
%
% This file is part of WecOptTool.
%
%     WecOptTool is free software: you can redistribute it and/or modify it
%     under the terms of the GNU General Public License as published by the
%     Free Software Foundation, either version 3 of the License, or (at
%     your option) any later version.
%
%     WecOptTool is distributed in the hope that it will be useful, but
%     WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%     General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with WecOptTool.  If not, see <https://www.gnu.org/licenses/>.

clear controlParams r

%% define sea state of interest

dw = 0.3142;
nf = 50;
w = dw * (1:nf)';
A = 0.125/2;
wp = w(6);
fp = wp/(2*pi);
Tp = 1/fp; 
SS = WecOptTool.SeaState.regularWave(w,[A,Tp]);

%% Create device and define controllers

controlType{1} = 'CC';
controlType{2} = 'P';
controlType{3} = 'PS';

% constraints for PS, zmax: max stroke (inactive); fmax: max PTO force 
zmax = 1e10;
fmax = 2e3;

% make a WaveBot using the 'base' dimensions
designType = 'scalar';
scalarVal = 1;
folder = WecOptTool.AutoFolder();
deviceHydro = designDevice(designType, folder.path, scalarVal, w);

%% Run simulations

for ii = 1:length(controlType) 
    disp("Simulation " + (ii) + " of " + length(controlType))
    rng(3) % run same wave phasing for each case
    r(ii) = simulateDevice(deviceHydro,SS,controlType{ii},...
        'interpMethod','nearest','Zmax',zmax,'Fmax',fmax);
    r(ii).name = controlType{ii};
end

%% plot results

r.plotFreq()
delete(findobj(gcf, 'Type', 'Legend'))
ax = findobj(gcf, 'Type', 'axes');
legend(ax(end))
% export_fig('../gfx/WaveBot_caseA_freq.pdf','-transparent')

r.plotTime(0:0.01:10)
legend(subplot(6,1,1),'CC','P','PS')
% export_fig('../gfx/WaveBot_caseA_time.pdf','-transparent')

%% report results

summary(r)

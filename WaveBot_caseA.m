% Case A
% This case shows a comparison between the different controllers currently
% available in WecOptTool. This is NOT an optimization study. Instead, a
% single device design is simulated in a sea state using each of the three
% controllers.

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

clc
clear
close all

%% set up one device and run BEM solver

geomMode = 'scalar';
lambda = 1;
dw = 0.3142;
nf = 50;
w = dw * (1:nf)';
a = WecOptLib.models.WaveBot('CC',geomMode,w);
a.runHydro(lambda);

%% Duplicate object and change controllers

% three devices with same hydrodynamics
b = [a, copy(a), copy(a)];

% device with complex conjugate control
b(1).controlType = 'CC';

% device with proportional control
b(2).controlType = 'P';

% device with pseudo-spectral control
b(3).controlType = 'PS';
b(3).delta_Fmax = [0,1e3];
b(3).delta_Zmax = 1e4;

%% define sea state of interest

Hm0 = 0.125;
Tp = (2*pi)/dw/6;
gamma = 3.3;
S = jonswap(b(1).w,[Hm0, Tp, gamma],0);

% make this a regular wave instead
[~,idx] = min(abs(S.w - 2*pi/Tp));
Sn = S;
Sn.S = Sn.S * 0;
Sn.S(idx) = S.S(idx);
S = Sn;
clear Sn

%% simulate performance for each device

for ii = 1:length(b)
    rng(3) % run same wave phasing for each case
    r(ii) = b(ii).simPerformance(S,'nearest');
end

%% plot results

r.plotFreq()
delete(findobj(gcf, 'Type', 'Legend'))
ax = findobj(gcf, 'Type', 'axes');
legend(ax(end))
export_fig('../gfx/WaveBot_caseA_freq.pdf','-transparent')

r.plotTime(0:0.01:10)
legend(subplot(6,1,1),'CC','P','PS')
export_fig('../gfx/WaveBot_caseA_time.pdf','-transparent')

%% report results

summary(r)

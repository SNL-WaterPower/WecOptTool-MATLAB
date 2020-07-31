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
%
% This case study is detailed in the following paper:
% 
% @Article{WecDesignOptimizationTool,
%   author       = {Ryan G. Coe and Giorgio Bacelli and Sterling Olson and 
%                   Vincent S. Neary and Matthew B. R. Topper},
%   title        = {A WEC design optimization tool},
%   date         = {2020-07-07},
%   journaltitle = {submitted to Journal of Ocean Engineering and Marine 
%                   Energy},
% }

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
clear controlParams r
close all

%% define sea state of interest

dw = 0.3142;
nf = 50;
w = dw * (1:nf)';
A = 0.125/2;
wp = w(6);
fp = wp/(2*pi);
Tp = 1/fp; 
SS = WecOptTool.SeaState.regularWave(w,[A,Tp]);
w = SS.getRegularFrequencies(0.3);

%%
controlParams.type = 'CC';
controlParams(2).type = 'P';
controlParams(3).type = 'PS';
controlParams(3).params = {1e10 2e3}; % {zmax, Fmax}

folder = WecOptTool.AutoFolder();
% w = SS.getRegularFrequencies(0.3);
deviceHydro = designDevice('scalar', folder.path, 1, w);

%%

for ii = 1:length(controlParams)
    
    disp("Simulation " + (ii) + " of " + length(controlParams))
    rng(3) % run same wave phasing for each case
    
    if ~isempty(controlParams(ii).params)
        r(ii) = simulateDevice(deviceHydro,                 ...
                               SS,                          ...
                               controlParams(ii).type,      ...
                               controlParams(ii).params{:});
    else
        r(ii) = simulateDevice(deviceHydro,                 ...
                               SS,                          ...
                               controlParams(ii).type);
    end
    
    r(ii).name = controlParams(ii).type;
    
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

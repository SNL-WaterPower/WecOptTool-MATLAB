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

clear r
for ii = 1:length(controlType) 
    disp("Simulation " + (ii) + " of " + length(controlType))
    rng(3) % run same wave phasing for each case
    r(ii) = simulateDevice(deviceHydro,SS,controlType{ii},  ...
                           'interpMethod', 'nearest',       ...
                           'Zmax', zmax,                    ...
                           'Fmax', fmax);
    r(ii).name = controlType{ii};
end

%% plot freq. domain results

r.plotFreq('Interpreter', 'latex')

fig = gcf;
fig.Position = fig.Position .* [1 1 1.5 0.5];
delete(findobj(fig, 'Type', 'Legend'))

% Rewrite legend
ax = findobj(gcf, 'Type', 'axes');
l1 = legend(ax(end), '$F_e$', '$u$', '$F_u$');
set(l1, 'Interpreter', 'latex')

% label x-axis with integer multiples of fundamental freq.
intf = 1:2:8;
xt = [0 (1:2:8) * 2 * pi / Tp];
xtl{1} = 0;
xtl{2} = sprintf('$\\omega_0$');

for ii = 1:length(intf) - 1
    xtl{ii+2} = sprintf('%i $\\omega_0$', intf(ii+1));
end

for ii = 1:length(ax)
    set(ax(ii), 'XTick', xt)
    set(ax(ii), 'XTickLabel', xtl)
    set(ax(ii), 'TickLabelInterpreter', 'latex');
end

for ii = [2,4,6]
    set(ax(ii), 'XTickLabel', [])
end

% export_fig('WaveBot_caseA_freq.pdf','-transparent')

%% plot time domain results

fs = 15;
r.plotTime(0:0.01:10, 'Interpreter', 'latex', 'FontSize', fs);
fig = gcf;
ax = findall(fig, 'type', 'axes');

% thicker lines
lh = findobj(fig, 'Type', 'line');
for ii = 1:numel(lh)
    lh(ii).LineWidth=2;
end

% plot PTO force limits and add annotations
hp(1) = plot(ax(2), xlim, fmax * ones(2,1), 'k--');
hp(2) = plot(ax(2), xlim, -1 * fmax * ones(2,1), 'k--');
uistack(hp,'bottom');
annotation(fig,                                     ...
           'textarrow',                             ...
           [0.648214285714286 0.573214285714286],   ...
           [0.361904761904762 0.328571428571429],   ...
           'String', '$F_u^{\textrm{{max}}}$',      ...
           'Interpreter', 'latex',                  ...
           'FontSize', 18);
annotation(fig,                                     ...
           'arrow',                                 ...
           [0.648214285714286 0.528571428571429],   ...
           [0.36031746031746 0.288888888888889]);

% Rewrite y-axis labels
ylabel(ax(1), '$P$ [W]', 'Interpreter', 'latex', 'FontSize', fs)
ylabel(ax(2), '$F_u$ [N]', 'Interpreter', 'latex', 'FontSize', fs)
ylabel(ax(3), '$u$ [m/s]', 'Interpreter', 'latex', 'FontSize', fs)
ylabel(ax(4), '$z$ [m]', 'Interpreter', 'latex', 'FontSize', fs)
ylabel(ax(5), '$F_e$ [N]', 'Interpreter', 'latex', 'FontSize', fs)
ylabel(ax(6), '$\eta$ [m]', 'Interpreter', 'latex', 'FontSize', fs)

% export_fig('WaveBot_caseA_time.pdf','-transparent')

%% report results in a table

summary(r)

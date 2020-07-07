% Case B
% This case performs three optimization studies (one using each of the
% three control types: P, CC, and PS). The objective function is a simple
% ratio of average power and a polynomial of submerged hull volume. The
% goal behind this study is to illustrate how the different control types
% result in different optimal designs.
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
clear
close all

%% set up device types

geomMode = 'parametric';
dw = 0.3142;
nf = 50;
w = dw * (1:nf)';
a = WecOptLib.models.WaveBot('CC',geomMode,w);

%% define sea state of interest

A = 0.125/2;
wp = a.w(6);
fp = wp/(2*pi);
Tp = 1/fp; 
S = WecOptLib.utils.regularWave(w,[A,Tp],0);

%% create set of devices (running hydrodynamics)

rmin = 0.25;
rmax = 2;
x = sort([linspace(rmin,rmax,19), 0.88]);

c = repmat(a,[size(x,2),3]);

for jj = 1:length(x)
    c(jj,1) = copy(a);
    y = [x(jj), 0.35, 0.16, 0.53];
    c(jj,1).runHydro(y);
end

%% replicate devices for different controllers

% P
c(:,2) = copy(c(:,1));
for jj = 1:size(c,1)
    c(jj,2).controlType = 'P';
end

% PS
c(:,3) = copy(c(:,1));
for jj = 1:size(c,1)
    c(jj,3).controlType = 'PS';
    c(jj,3).delta_Fmax = 3e10;
    c(jj,3).delta_Zmax = 0.6;
end

%% simulate performance

for ii = 1:size(c,2)        % for each control type
    for jj = 1:size(c,1)    % for each geometry
        rng(3)
        r(jj,ii) = c(jj,ii).simPerformance(S);
        r(jj,ii).name = [c(jj,ii).controlType, '_', num2str(x(jj))];
    end
end

%% set up optimization problems

x0 = 2;
A = [];
B = [];
Aeq = [];
Beq = [];
LB = min(x);
UB = max(x);
NONLCON = [];
opts = optimset('fminbnd');
opts.UseParallel = true;
opts.Display = 'iter';
opts.PlotFcn = {@optimplotx,@optimplotfval};

%% run optimization solver (for each control type)

for ii = 1:size(c,2)
    [x_opt(ii), fval(ii), exitflag(ii), output(ii)] = ...
        fminbnd(@(x) myWaveBotObjFun(x,c(1,ii),S),...
        LB,UB,opts);
end

%%

fig = figure('Name','WaveBot_caseB');
fig.Position = fig.Position .* [1, 1, 1, 1.5];

mys = {'log','linear','log','log'};
for ii = 1:4
    ax(ii) = subplot(4,1,ii);
    set(ax(ii),'yscale',mys{ii})
    grid on
    hold on
end

mkrs = {'.','o','s'};

for ii = 1:size(r,2)
    
    SMRY = summary(r(:,ii));
    pow = abs(SMRY.AvgPow);
    vol = arrayfun(@(x) r(x,ii).wec.hydro.Vo, 1:length(x))';
    pos = SMRY.MaxPos;
    obfn = pow ./ (0.88 + x(:)).^3;
    obfn = obfn;
    
    semilogy(ax(1), x, pow, 'Marker', mkrs{ii})
    plot(ax(2), x, vol, 'Marker', mkrs{ii})
    semilogy(ax(3), x, pos, 'Marker', mkrs{ii})
    semilogy(ax(4), x, obfn, 'Marker', mkrs{ii})
end

% plot vertical lines for optimal designs
for ii = 1:length(ax)
    set(ax(ii),'ColorOrderIndex',1)
    for jj = 1:length(x_opt)
        plot(ax(ii),x_opt(jj)*ones(2,1),ylim(ax(ii)),'-.')
    end
end

ylabel(ax(1),'Avg. pow [W]')
ylabel(ax(2),'Vol. [m^3]')
ylabel(ax(3),'Pos. amp. [m]')
ylabel(ax(4),'Obj. fun. [W/m^3]')

set(ax(1:3),'XTickLabel',[])

l1 = legend(ax(1),'CC','P','PS');
set(l1,'location','southeast')
xlabel('Outer radius, $r_1$ [m]', 'interpreter','latex')
linkaxes(ax,'x')
xlim([0.25, max(x)])

export_fig('../gfx/WaveBot_caseB_results.pdf','-transparent')

%%

fig = figure('name','WaveBot_caseB_geometrities');
fig.Position = fig.Position .*[1,1,1.5,0.75];
ax = gca;
c(:,1).plot(ax)
delete(get(gca,'legend'));
ylim([-0.6, 0])
xlim([0, rmax])
export_fig('../gfx/WaveBot_caseB_geometries.pdf','-transparent')

%% objective function

function [fval] = myWaveBotObjFun(x,wecDevice,S)
    
    localWec = copy(wecDevice); % TODO - is this necessary?
    
    % create device and simulate performance the parametric input is 
    % [r1, r2, d1, d2] (all positive); here we specify only r1
    localWec.runHydro([x, 0.35, 0.16, 0.53]);
    simRes = localWec.simPerformance(S);
    
    % objective function value
    p_bar = sum(real(simRes.pow));     % average power
    fval = 1 * p_bar ./ (0.88 + x).^3; % r1 = 0.88 is the as-built WaveBot
    
end

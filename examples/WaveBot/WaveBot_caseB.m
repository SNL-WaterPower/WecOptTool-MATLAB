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
%
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

%% set up device types
controlType{1} = 'CC';
controlType{2} = 'P';
controlType{3} = 'PS';
controlParams(3).params = {1e10 2e3}; % {zmax, Fmax}
zmax = 1e10;
fmax = 2e3;

folder = WecOptTool.AutoFolder();
% w = SS.getRegularFrequencies(0.3);

%% create set of devices (running hydrodynamics)
rmin = 0.25;
rmax = 2;
r0 = 0.88;
radii = sort([linspace(rmin,rmax,19), r0]);

deviceHydro = designDevice('parametric', folder.path, ...
                           radii(1), 0.35, 0.16, 0.53, w);

                       
deviceHydro = repmat(deviceHydro, length(radii), 1 );
for i = 2:length(radii)    
    radius = radii(i);
    deviceHydro(i) = designDevice('parametric', folder.path, ...
                               radius, 0.35, 0.16, 0.53, w);
                           
end


%% simulate performance
for ii = 1:length(controlType) 
     disp("Simulation " + (ii) + " of " + length(controlType))
    for jj = 1:length(radii)       
        rng(3) % run same wave phasing for each case
        r(jj,ii) = simulateDevice(deviceHydro(jj),SS,controlType{ii},...
                                  'interpMethod','nearest','Zmax',zmax,...
                                  'Fmax',fmax);
        r(jj,ii).name = [controlType{ii}, '_', num2str(radii(jj))];
    end
end


 %% set up optimization problems

x0 = 2;
A = [];
B = [];
Aeq = [];
Beq = [];
LB = min(radii);
UB = max(radii);
NONLCON = [];
opts = optimset('fminbnd');
opts.UseParallel = true;
opts.Display = 'iter';
opts.PlotFcn = {@optimplotx,@optimplotfval};

%% run optimization solver (for each control type)

for ii = 1:length(controlType) 
    [x_opt(ii), fval(ii), exitflag(ii), output(ii)] = ...
        fminbnd(@(x) myWaveBotObjFun(x,w,                     ...
                                     SS, controlType{ii},     ...
                                     zmax,fmax, folder.path), ...
        LB,UB,opts);
      
end

%% Plotting

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
    vol = arrayfun(@(x) deviceHydro(x).Vo, 1:length(radii))';
    pos = SMRY.MaxPos;
    obfn = pow ./ (0.88 + radii(:)).^3;
    obfn = obfn;
    
    semilogy(ax(1), radii, pow, 'Marker', mkrs{ii})
    plot(ax(2), radii, vol, 'Marker', mkrs{ii})
    semilogy(ax(3), radii, pos, 'Marker', mkrs{ii})
    semilogy(ax(4), radii, obfn, 'Marker', mkrs{ii})
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
xlim([0.25, max(radii)])

%export_fig('../gfx/WaveBot_caseB_results.pdf','-transparent')

fig = figure('name','WaveBot_caseB_geometrities');
fig.Position = fig.Position .*[1,1,1.5,0.75];
ax = gca;
plotXSection(radii,ax);
delete(get(gca,'legend'));
ylim([-0.6, 0])
xlim([0, rmax])
%export_fig('../gfx/WaveBot_caseB_geometries.pdf','-transparent')


%% objective function

function [fval] = myWaveBotObjFun(x,w,SS, controlType,zmax,fmax, folderPath)        
    
    % create device and simulate performance the parametric input is 
    % [r1, r2, d1, d2] (all positive); here we specify only r1
    deviceHydro = designDevice('parametric', folderPath, ...
                               x, 0.35, 0.16, 0.53, w);
                           
    simRes = simulateDevice(deviceHydro,               ...
                            SS,                        ...
                            controlType,           ...
                            'interpMethod','nearest',  ...
                            'Zmax',zmax,               ...
                            'Fmax',fmax);
    if controlType == 'PS'
        pow =simRes.pow(:,1);
    else
        pow = simRes.pow;
    end
    
    % objective function value
    p_bar = sum(real(pow));     % average power
    fval = 1 * p_bar ./ (0.88 + x).^3; % r1 = 0.88 is the as-built WaveBot
    
end


function plotXSection(radii,ax)
    % plots geometry cross section
    %
    % Args.
    %   ax  (optional) axes handle (e.g., ax = gca)


    if nargin < 2
        figure('name','WaveBot Geometry')
        ax = gca;
    end
    plot(ax,[0, 0.88, 0.88, 0.35, 0],...
            [0.2, 0.2, -0.16, -0.53, -0.53],'.--',...
            'DisplayName','original')
    
    hold on
    grid on

    for ii = 1:length(radii)
        radius = radii(ii);
        xCoords =  [0, radius, radius, 0.35, 0];
        yCoords = [0.2, 0.2, -0.16, -0.53, -0.53];
        plot(ax,xCoords, yCoords, 'o-','DisplayName',num2str(ii))
    end

    legend('location','southeast')
    xlabel('$r$ [m]','interpreter','latex')
    ylabel('$z$ [m]','interpreter','latex')
    ylim([-Inf, 0])
    axis equal
end

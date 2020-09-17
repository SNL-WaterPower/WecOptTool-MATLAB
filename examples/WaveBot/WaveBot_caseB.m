% Case B
% This case performs three optimization studies (one using each of the
% three control types: P, CC, and PS). The objective function is a simple
% ratio of average power and a polynomial of submerged hull volume. The
% goal behind this study is to illustrate how the different control types
% result in different optimal designs.

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

%% set up device types

controlType{1} = 'CC';
controlType{2} = 'P';
controlType{3} = 'PS';
zmax = 0.6;
fmax = 1e10;

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

clear r
for ii = 1:length(controlType)      
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

clear fval x_opt exitflag output optSimres
for ii = 1:length(controlType)
    disp("Simulation " + (ii) + " of " + length(controlType))    
    [x_opt(ii), fval(ii), exitflag(ii), output(ii)] = ...
        fminbnd(@(x) myWaveBotObjFun(x,w,SS,controlType{ii},zmax,fmax,...
        folder.path),LB,UB,opts);
    [~, optSimres(ii), optHydro(ii)] = ...
        myWaveBotObjFun(x_opt(ii),w,SS,controlType{ii},zmax,fmax,folder.path);
end

%% plot results

fig = figure('Name','WaveBot_caseB');
fig.Position = fig.Position .* [1, 1, 1, 1.5];

mys = {'log','linear','log','log'};
for ii = 1:4
    ax(ii) = subplot(4,1,ii);
    set(ax(ii),'yscale',mys{ii})
    grid on
    hold on
end

mkrs = {'^','o','s'};

% plot Monte-Carlo results
for ii = 1:size(r,2)
    
    SMRY = summary(r(:,ii));
    pow = abs(SMRY.AvgPow);
    vol = arrayfun(@(x) deviceHydro(x).Vo, 1:length(radii))';
    pos = SMRY.MaxPos;
    obfn = pow ./ (0.88 + radii(:)).^3;
    
    semilogy(ax(1), radii, pow, 'Marker', mkrs{ii},'LineWidth',1.5)
    plot(ax(2), radii, vol, 'Marker', mkrs{ii},'LineWidth',1.5)
    semilogy(ax(3), radii, pos, 'Marker', mkrs{ii},'LineWidth',1.5)
    semilogy(ax(4), radii, obfn, 'Marker', mkrs{ii},'LineWidth',1.5)
end


for jj = 1:length(ax)
    set(ax(jj),'ColorOrderIndex',1)
end

% plot optimal solutions
for ii = 1:length(optSimres)
    
    SMRY = summary(optSimres(ii));
    pow = abs(SMRY.AvgPow);
    vol = optHydro(ii).Vo;
    pos = SMRY.MaxPos;
    obfn = -1*fval(ii);
    
    stem(ax(1), x_opt(ii), pow, 'Marker', mkrs{ii},...
        'LineWidth',2,'MarkerSize',10)
    stem(ax(2), x_opt(ii), vol, 'Marker', mkrs{ii},...
        'LineWidth',2,'MarkerSize',10)
    stem(ax(3), x_opt(ii), pos, 'Marker', mkrs{ii},...
        'LineWidth',2,'MarkerSize',10)
    stem(ax(4), x_opt(ii), obfn, 'Marker', mkrs{ii},...
        'LineWidth',2,'MarkerSize',10)
end

fs = 15;

ylabel(ax(1),'Avg. pow [W]','interpreter','latex','FontSize',fs)
ylabel(ax(2),'Vol. [m$^3$]','interpreter','latex','FontSize',fs)
ylabel(ax(3),'Pos. amp. [m]','interpreter','latex','FontSize',fs)
ylabel(ax(4),'$-1\cdot{}$Obj. fun. [W/m$^3$]','interpreter','latex','FontSize',fs)

set(ax(1:3),'XTickLabel',[])

l1 = legend(ax(1),'CC','P','PS');
set(l1,'location','southeast')
xlabel('Outer radius, $r_1$ [m]','interpreter','latex','FontSize',fs)
linkaxes(ax,'x')
xlim([0.25, max(radii)])

annotation(gcf,'textarrow',[0.808928571428571 0.728571428571429],...
        [0.49047619047619 0.434920634920635],'String','$z^{\textrm{{max}}}$',...
        'Interpreter','latex',...
        'FontSize',18);
h = plot(ax(3),[0,1e10],zmax * ones(2,1),'k--');
uistack(h,'bottom');

% export_fig('WaveBot_caseB_results.pdf','-transparent')

%% plot geometries

fig = figure('name','WaveBot_caseB_geometrities');
fig.Position = fig.Position .*[1,1,1.5,0.75];
hold on
grid on
ax = gca;

lstr = ['CC','P','PS'];
% Plot Optimal Solution X-section
for ii = 1:length(controlType)
    radiusOpt = x_opt(ii);
    xCoords =  [0, radiusOpt, radiusOpt, 0.35, 0];
    yCoords = [0.2, 0.2, -0.16, -0.53, -0.53]; 
    p(ii) = plot(ax, xCoords, yCoords, 'Marker', mkrs{ii},...
                            'LineWidth',2,'MarkerSize',10,...
                            'DisplayName', lstr(ii));
end


for ii = 1:length(radii)
    baseN = length(controlType);
    radius = radii(ii);
    xCoords =  [0, radius, radius, 0.35, 0];
    yCoords = [0.2, 0.2, -0.16, -0.53, -0.53];
    if ii+baseN == 8
        p(ii+baseN) = plot(ax,xCoords, yCoords, 'ks-',...
            'DisplayName','Original');
    else
        p(ii+baseN) = plot(ax,xCoords, yCoords, 'bo-', ...
                                       'DisplayName',num2str(ii));
    end
end
%legend('CC','P','PS', 'Parametric geometries')
%l1 = legend(p,'CC');%,'P','PS', ...
    %'Original geometry (Coe et al. 2016)', ...
    %'WecOptTool study geometries'});
l1 = legend([p(1), p(2), p(3), p(4), p(8)],...
    'CC','P','PS', ...
    'Original geometry (Coe et al. 2016)', ...
    'WecOptTool study geometries');
set(l1,'location','southeast')

xlabel('$r$ [m]','interpreter','latex')
ylabel('$z$ [m]','interpreter','latex')
axis equal
ylim([-0.6, 0])
xlim([0, rmax])

% export_fig('WaveBot_caseB_geometries.pdf','-transparent')

%% objective function

function [fval, simRes, deviceHydro] = myWaveBotObjFun(x,w,SS,controlType,zmax,fmax,folderPath)        
    
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
    if strcmp(controlType,'PS')
        pow =simRes.pow(:,1);
    else
        pow = simRes.pow;
    end
    
    % objective function value
    p_bar = sum(real(pow));             % average power
    fval = 1 * p_bar ./ (0.88 + x).^3;  % r1 = 0.88 is as-built WaveBot
end

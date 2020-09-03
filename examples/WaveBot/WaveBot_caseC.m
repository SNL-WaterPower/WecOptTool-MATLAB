% Case C
% This case performs a single multiobjective optimization study using a PS
% controller with a constrained maximum force. The free design variables
% are:
%
% r 		outer radius of the hull
% FuMax 	maximum PTO force
%
% The multi-objective study finds the Pareto front for the following
% responses:
%
% Pbar      average absorbed power
% volFun    (r_0 + r)^3, where r_0 = 0.88
% xMax      maximum displacement
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

% clc
% clear
% close all
% clear controlParams r

%% define sea state of interest
dw = 0.3142;
nf = 50;
w = dw * (1:nf)';
A = 0.125/2;
wp = w(6);
fp = wp/(2*pi);
Tp = 1/fp; 
SS = WecOptTool.SeaState.regularWave(w,[A,Tp]);


%% create set of devices (running hydrodynamics)
rmin = 0.25;
rmax = 2;
r0 = 0.88;
radii = sort([linspace(rmin,rmax,19), r0]);
zlim = 1e4; % (inactive)
folder = WecOptTool.AutoFolder();

%% set up optimization problem

nvars = 2;
A = [];
B = [];
Aeq = [];
Beq = [];
LB = [min(radii), 1e2];
UB = [max(radii), 1e3];
NONLCON = [];
opts = optimoptions('paretosearch');
opts.UseParallel = true;
opts.Display = 'iter';
opts.PlotFcn = @psplotparetof;
% opts.MaxFunctionEvaluations = 50;
% opts.OptimalityTolerance = 1e-8;


%% run optimization solver

rng(3)
[x,fval,exitflag,output,residuals] = paretosearch(@(x) myWaveBotObjFun(x,w,SS, zlim,folder.path),nvars,...
    A,B,Aeq,Beq,LB,UB,NONLCON,opts);

% Optimized Values
radiiOpt = x(:,1);
fmaxOpt = x(:,2);
% Optimized results
pBar = fval(:,1);
vol   = fval(:,2);
zmax  = fval(:,3);

%% Plot 3D

figure
% Plot 3D grid 
xv = linspace(min(pBar),max(pBar));         
yv = linspace(min(vol),max(vol));  
[X,Y] = meshgrid(xv, yv);
Z = griddata(pBar, vol, zmax, X, Y);        
mesh(-X,Y,Z)
hold on
scatter3(-pBar, vol, zmax, 'filled');
scatter3(-pBar(knee_idx), vol(knee_idx), zmax(knee_idx),150,'marker','+','MarkerEdgeColor','k','LineWidth',2);

grid on
cb = colorbar;
cb.Label.Interpreter = 'latex';
cb.Label.String = ('Pos. mag., $z^{\textrm{max}}$ [m]');
xlabel('Neg. avg. power, $ - \bar{P}$ [W]', 'interpreter','latex')
ylabel('Vol. fun, $(r_0 + r)^3$ [m$^3$]', 'interpreter','latex')
zlabel('Pos. mag., $z^{\textrm{max}}$ [m]', 'interpreter','latex')
%set(gca,'Zscale','log')
%set(gca,'Xscale','log')

%% PLot 2D
clear ax

knee_idx = 36;

fig = figure();
fig.Position = fig.Position .* [1 1 1.5 1]*1;

tiledlayout(3,4,'TileSpacing','compact','Padding','compact')
axb = nexttile([3,2]);

hold on
grid on
scatter(axb, pBar,vol,75,zmax,...
    'filled',...
    'MarkerEdgeColor','k',...
    'MarkerFaceAlpha',0.5);

scatter(axb, pBar(knee_idx),vol(knee_idx),200,'marker','+','MarkerEdgeColor','k','LineWidth',1.5);


xlabel('Avg. power, $ \bar{P}$ [W]', 'interpreter','latex')
ylabel('Vol. fun, $(r_0 + r)^3$ [m$^3$]', 'interpreter','latex')

cb = colorbar;
cb.Label.Interpreter = 'latex';
cb.Label.String = ('Max. PTO stroke, $z^{\textrm{max}}$ [m]');
cb.Location = 'northoutside';
% set(cb,'YDir','reverse')

set(gca,'Yscale','log')

ylim([min(vol), Inf])

% Create textarrow
annotation(fig,'textarrow',[0.0813492063492065 0.113095238095238],...
    [0.81825396825397 0.554761904761905],'TextEdgeColor',[0 0 0],...
    'TextBackgroundColor',[1 1 1],...
    'String',{'Smaller stroke,','larger vol.'},...
    'HorizontalAlignment','center');

% Create textarrow
annotation(fig,'textarrow',[0.0726190476190479 0.0821428571428572],...
    [0.276984126984128 0.104761904761905],'TextEdgeColor',[0 0 0],...
    'TextBackgroundColor',[1 1 1],...
    'String',{'Larger stroke,','smaller vol.'},...
    'HorizontalAlignment','center');

rlbs = {'$\bar{P}$','$(r_0 + r)^3$','$z^{\textrm{max}}$'};
xlbs = {'Outer radius, $r$ [m]','Max. PTO force, $F_u^{max}$ [N]'};

for kk = 1:2*3
    ax(kk) = nexttile();
end
ax = reshape(ax,[2,3]);

for ii = 1:size(x,2)
    for jj = 1:size(fval,2)
        hold(ax(ii,jj),'on')
        scatter(ax(ii,jj),x(:,ii),fval(:,jj),[],zmax,...
            'filled',...
            'MarkerEdgeColor','k',...
            'MarkerFaceAlpha',0.25);
%         hold on
%         plot(ax(ii,jj),x(knee_idx,ii),fval(knee_idx,jj),'k+','MarkerSize',10)
        scatter(ax(ii,jj),x(knee_idx,ii),fval(knee_idx,jj),200,'marker','+',...
            'MarkerEdgeColor','k','LineWidth',1.5);
        
%         scatter(ax(ii,jj),x(knee_idx,ii),fval(knee_idx,jj),[],zmax(knee_idx),...
%             'marker','*');
        
        
        if jj ~= size(fval,2)
            set(ax(ii,jj),'XTickLabel',[])
        end
        
        if ii == 1
            ylabel(ax(ii,jj),rlbs{jj}, 'interpreter','latex')
        end
    end
    xlabel(ax(ii,jj),xlbs{ii}, 'interpreter','latex')
end


exportgraphics(fig, 'WaveBot_caseC_results.pdf','ContentType','vector')

%% objective function

function [fval] = myWaveBotObjFun(x,w,SS,zmax,folderPath)        
    
    r1 =x(1);
    fmax =x(2);
    
    % create device and simulate performance the parametric input is 
    % [r1, r2, d1, d2] (all positive); here we specify only r1
    
    deviceHydro = designDevice('parametric', folderPath, ...
                               r1, 0.35, 0.16, 0.53, w);
                           
    simRes = simulateDevice(deviceHydro,               ...
                            SS,                        ...
                            'PS',           ...
                            'interpMethod','nearest',  ...
                            'Zmax',zmax,               ...
                            'Fmax',fmax);
    % objective function value
    SMRY = summary(simRes);
    
    pow =simRes.pow(:,1);
    p_bar = sum(real(pow));       % average power
    
    fval(1) = 1 * p_bar;
    fval(2) = (0.88 + r1).^3;% r1 = 0.88 is the as-built WaveBot
    fval(3) = SMRY.MaxPos;                        
                        
    
end


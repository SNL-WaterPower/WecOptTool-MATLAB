% Case C This case performs a singke multiobjective optimization study
% using a PS controller with a constrained maximum force. The free design
% variables are:
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

clc
clear
close all

%% set up device types

geomMode = 'parametric';
dw = 0.3142;
nf = 2;
w = dw * (1:nf)';
a = WecOptLib.models.WaveBot('PS',geomMode,w);
a.delta_Fmax = 10e3;                                          % TODO
a.delta_Zmax = 1e10;                                          % TODO

%% define sea state of interest

Hm0 = 0.125;
Tp = (2*pi)/dw;
gamma = 3.3;
S = jonswap(a(1).w,[Hm0, Tp, gamma],0);

% make this a regular wave instead
[~,idx] = min(abs(S.w - 2*pi/Tp));                  % TODO - remove
Sn = S;
Sn.S = Sn.S * 0;
Sn.S(idx) = S.S(idx);
S = Sn;
clear Sn


%% set up optimization problem

x0 = 2;
A = [];
B = [];
Aeq = [];
Beq = [];
LB = [0.35, 0.5e3];
UB = [3, 50e3];
NONLCON = [];
opts = optimoptions('paretosearch');
opts.UseParallel = false;
opts.Display = 'iter';
opts.PlotFcn = @psplotparetof;
% opts.MaxFunctionEvaluations = 50;
% opts.OptimalityTolerance = 1e-8;

%% run optimization solver

nvars = 2;
rng(3)
[x,fval,exitflag,output,residuals] = paretosearch(@(x) myWaveBotObjFun(x,a,S),nvars,...
    A,B,Aeq,Beq,LB,UB,NONLCON,opts);

%%

figure
scatter3(-fval(:,1),fval(:,2),fval(:,3),fval(:,3)*50)
grid on
xlabel('Neg. avg. power, $ - \bar{P}$ [W]', 'interpreter','latex')
ylabel('Vol. fun, $(r_0 + r)^3$ [m$^3$]', 'interpreter','latex')
zlabel('Pos. mag., $z^{\textrm{max}}$ [m]', 'interpreter','latex')
set(gca,'Zscale','log')
set(gca,'Xscale','log')

export_fig('../gfx/WaveBot_caseC_results_3D.pdf','-transparent')

view([0 -1 0])
export_fig('../gfx/WaveBot_caseC_results_powVsPos.pdf','-transparent')

view([0 0 1])
export_fig('../gfx/WaveBot_caseC_results_powVsVol.pdf','-transparent')

%%

rlbs = {'$\bar{P}$','$(r_0 + r)^3$','$z^{\textrm{max}}$'};
xlbs = {'Outer radius, $r$ [m]','Max. PTO force, $F_u^{max}$ [N]'};

figure

for ii = 1:size(x,2)
    for jj = 1:size(fval,2)
        idx = sub2ind([2,3],ii,jj);
        ax(ii,jj) = subplot(3,2,idx);
        grid on
        hold on
        scatter(x(:,ii),fval(:,jj))
        
        if jj ~= size(fval,2)
            set(ax(ii,jj),'XTickLabel',[])
        end
        
        if ii == 1
            ylabel(ax(ii,jj),rlbs{jj}, 'interpreter','latex')
        else
%             set(ax(ii,jj),'YTickLabel',[])
        end
    end
    xlabel(ax(ii,jj),xlbs{ii}, 'interpreter','latex')
end


%% objective function

function [fval] = myWaveBotObjFun(x,wecDevice,S)
    
    localWec = copy(wecDevice); % TODO - is this necessary?
    
    % create device and simulate performance the parametric input is 
    % [r1, r2, d1, d2] (all positive); here we specify only r1
    localWec.runHydro([x(1), 0.35, 0.16, 0.53]);
    
    localWec.delta_Fmax = x(2);                                          % TODO
    simRes = localWec.simPerformance(S);
    
    % objective function value
    p_bar = sum(real(simRes.pow));      % average power
    fval(1) = 1 * p_bar;
    fval(2) = (0.88 + x(1)).^3;
    fval(3) = sum(abs(simRes.pos(1)));
    
end

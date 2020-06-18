% Case B
% This case performs three optimization studies (one using each of the
% three control types: P, CC, and PS). The objective function is a simple
% ratio of average power and a polynomial of submerged hull volume. The
% goal behind this study is to illustrate how the different control types
% result in different optimal designs.

clc
clear
close all

%% set up device types

geomMode = 'parametric';
dw = 0.3142;
nf = 2;
w = dw * (1:nf)';
a = WecOptLib.models.WaveBot('CC',geomMode,w);

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

%%

rmax = 3;
x = linspace(0.35,rmax,20);

c = repmat(a,[size(x,2),3]);

for jj = 1:length(x)
    c(jj,1) = copy(a);
    y = [x(jj), 0.35, 0.16, 0.53];
    c(jj,1).runHydro(y);
end

%%

% P
c(:,2) = copy(c(:,1));
for jj = 1:size(c,1)
    c(jj,2).controlType = 'P';
end

% PS
c(:,3) = copy(c(:,1));
for jj = 1:size(c,1)
    c(jj,3).controlType = 'PS';
    c(jj,3).delta_Fmax = 10e3;
end

%%

for ii = 1:size(c,2)
    for jj = 1:size(c,1)
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
opts.UseParallel = false;
opts.Display = 'iter';
opts.PlotFcn = {@optimplotx,@optimplotfval};
% opts.MaxFunctionEvaluations = 50;
% opts.OptimalityTolerance = 1e-8;

%% run optimization solver (for each control type)

for ii = 1:size(c,2)
%     [x_opt(ii), fval(ii), exitflag(ii), output(ii)] = ...
%         fminbnd(@(x) myWaveBotObjFun(x,c(1,ii),S),...
%         x0,A,B,Aeq,Beq,LB,UB,NONLCON,opts);
    [x_opt(ii), fval(ii), exitflag(ii), output(ii)] = ...
        fminbnd(@(x) myWaveBotObjFun(x,c(1,ii),S),...
        LB,UB,opts);
end

%%

figure('position',[0,0,50,100]*10)

ax(1) = subplot(4,1,1);
set(ax(1),'Yscale','log')
hold on
grid on

ax(2) = subplot(4,1,2);
set(ax(2),'Yscale','linear')
hold on
grid on

ax(3) = subplot(4,1,3);
set(ax(3),'Yscale','log')
hold on
grid on

ax(4) = subplot(4,1,4);
set(ax(4),'Yscale','linear')
hold on
grid on

mkrs = {'.','o','s'};

for ii = 1:size(r,2)
    pow = abs(summary(r(:,ii)).AvgPow);
    semilogy(ax(1), x, abs(summary(r(:,ii)).AvgPow), 'Marker', mkrs{ii})
    
    vol = arrayfun(@(x) r(x,ii).wec.hydro.Vo, 1:length(x))';
    plot(ax(2), x, vol, 'Marker', mkrs{ii})
    
    vel = abs(arrayfun(@(x) r(x,ii).pos(1), 1:length(x)))';
    semilogy(ax(3), x, vel, 'Marker', mkrs{ii})
    
    obfn = pow ./ (0.88 + x(:)).^3;
    obfn = obfn / max(obfn);
    plot(ax(4), x, obfn, 'Marker', mkrs{ii})
end

for ii = 1:length(ax)
    set(ax(ii),'ColorOrderIndex',1)
    for jj = 1:length(x_opt)
        
        plot(ax(ii),x_opt(jj)*ones(2,1),ylim(ax(ii)),'-.')
    end
end

ylabel(ax(1),'Avg. pow [W]')
ylabel(ax(2),'Vol. [m^3]')
ylabel(ax(3),'Pos. amp. [m]')
ylabel(ax(4),'Obj. fun. (normalized)')

set(ax(1:3),'XTickLabel',[])

l1 = legend(ax(1),'CC','P','PS');
set(l1,'location','southeast')
xlabel('Outer radius, $r_1$ [m]', 'interpreter','latex')
linkaxes(ax,'x')
xlim([0.25,max(x)])
export_fig('../gfx/WaveBot_caseB_results.pdf','-transparent')

%%

figure('position',[0,0,100,14]*10)
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
    p_bar = sum(real(simRes.pow));      % average power
    fval = 1 * p_bar ./ (0.88 + x).^3; % r1 = 0.88 is the as-built WaveBot
    
end

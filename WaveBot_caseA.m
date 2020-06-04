% Case A
% This case shows a comparison between the different controllers currently
% available in WecOptTool. This is NOT an optimization study. Instead, a
% single device design is simulated in a sea state using each of the three
% controllers.

clc
clear
close all

%% set up problem

% set a fixed frequency vector
Hm0 = 0.125;
Tp = 2;
gamma = 3.3;
w = 2*pi*linspace(0.05, 2, 50)';

geomMode = 'scalar';
a(1) = WecOptLib.models.WaveBot('CC',geomMode,w);
a(2) = WecOptLib.models.WaveBot('P',geomMode,w);
a(3) = WecOptLib.models.WaveBot('PS',geomMode,w);
a(3).delta_Fmax = 100;

%% run hydrodynamics

arrayfun(@(x) x.runHydro(1), a)

%%

% define sea state of interest
S = jonswap(a(1).w,[Hm0, Tp, gamma],0);

% make this a regular wave instead
% [~,idx] = min(abs(S.w - 2*pi/Tp));
% Sn = S;
% Sn.S = Sn.S * 0;
% Sn.S(idx) = S.S(idx);
% S = Sn;
% clear Sn

%% simulate performance

for ii = 1:length(a)
    rng(3)
    r(ii) = a(ii).simPerformance(S);
end

%% plot results

for ii = 1:length(r)
    r(ii).plotFreq
end
r.plotTime(0:0.01:100)
legend('CC','P','PS')

%% report results

summary(r)

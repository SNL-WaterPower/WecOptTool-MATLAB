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
a = WecOptLib.models.WaveBot('P',geomMode,w);

%% run hydrodynamics

a.runHydro(1)

%%

% define sea state of interest
S = jonswap(a(1).w,[Hm0, Tp, gamma],0);

% make this a regular wave instead
[~,idx] = min(abs(S.w - 2*pi/Tp));
Sn = S;
Sn.S = Sn.S * 0;
Sn.S(idx) = S.S(idx);
S = Sn;
clear Sn

%% simulate performance

rng(3)
r = a.simPerformance(S);

%% plot results

r(1).plotFreq
r.plotTime(0:0.01:100)

%% report results

summary(r)

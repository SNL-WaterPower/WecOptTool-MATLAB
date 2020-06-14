% Case A
% This case shows a comparison between the different controllers currently
% available in WecOptTool. This is NOT an optimization study. Instead, a
% single device design is simulated in a sea state using each of the three
% controllers.

clc
clear
close all

%% set up one device and run BEM solver

geomMode = 'scalar';
lambda = 1;
dw = 0.3142;
nf = 50;
w = dw * (1:nf)';
a = WecOptLib.models.WaveBot('CC',geomMode,w);
a.runHydro(lambda);

%% Duplicate object and change controllers

% three devices with same hydrodynamics
b = [a, copy(a), copy(a)];

% device with complex conjugate control
b(1).controlType = 'CC';

% device with proportional control
b(2).controlType = 'P';

% device with pseudo-spectral control
b(3).controlType = 'PS';
b(3).delta_Fmax = 100000;
b(3).delta_Zmax = [-0.01, 0.1];

%% define sea state of interest

Hm0 = 0.125;
Tp = 1/0.3300;
gamma = 3.3;
S = jonswap(a(1).w,[Hm0, Tp, gamma],0);

% make this a regular wave instead
[~,idx] = min(abs(S.w - 2*pi/Tp));
Sn = S;
Sn.S = Sn.S * 0;
Sn.S(idx) = S.S(idx);
S = Sn;
clear Sn

%% simulate performance for each device

for ii = 1:length(b)
    rng(3) % run same wave phasing for each case
    r(ii) = b(ii).simPerformance(S);
end

%% plot results

r(ii).plotFreq(fig)
r.plotTime(0:0.01:10)
legend('CC','P','PS')

%% report results

summary(r)

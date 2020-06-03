
clc
clear
close all

% define sea state of interest
% Hm0 = 0.125;
% Tp = 2;
% gamma = 3.3;
% w = 2*pi*linspace(0.05, 2, 50)';
% S = jonswap(w,[Hm0, Tp, gamma],0);
S = WecOptLib.tests.data.example8Spectra();

% make devices from blueprint. All arguments can be given as cell
% arrays (or scalars) which produces an mxn device array.
geomParams.type = 'parametric';
geomParams.params = {5 7.5 1.125 42 S, 0.5};
controlParams.type = 'CC';
controlParams(2).type = 'P';

blueprint = RM3();
devices = makeDevices(blueprint, geomParams, controlParams);

% Create a SeaState object before optimisation to avoid warnings.
SS = WecOptLib.experimental.types("SeaState", S);

[m,n] = size(devices);

for i = 1:m
    for j = 1:n
        simulate(devices(i, j), SS);
        % The device stores the results as properties
        r(i, j) = sum(devices(i, j).aggregation.pow);
    end
end

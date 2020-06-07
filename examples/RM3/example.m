
clear geomParams controlParams

% define sea state of interest
S = WecOptLib.tests.data.exampleSpectrum();

% make devices from blueprint. All arguments given as struct arrays
% arrays with type and params field. 
geomParams.type = 'scalar';
geomParams.params = {1};
controlParams.type = 'CC';
controlParams(2).type = 'P';
controlParams(3).type = 'PS';
controlParams(3).params = {10 1e9};

blueprint = RM3();
devices = makeDevices(blueprint, geomParams, controlParams);

% Create a SeaState object before optimisation to avoid warnings.
SS = WecOptTool.types("SeaState", S);

[m,n] = size(devices);

for i = 1:m
    for j = 1:n
        disp("Simulation " + (i + j - 1) + " of " + (m * n))
        simulate(devices(i, j), SS);
        % The device stores the results as properties
        r(i, j) = sum(devices(i, j).aggregation.pow);
    end
end

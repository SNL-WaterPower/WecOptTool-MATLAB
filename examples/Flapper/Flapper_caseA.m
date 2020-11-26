% Case A
% 
% This case study shows a comparison between the different controllers
% currently available in WecOptTool. This is NOT an optimization study.
% Instead, a single device design is simulated in a sea state using each of
% the three controllers. The purpose of this study is to demonstrate some
% of the basic differences between these three controller types:
%
% CC    complex conjugate control
% P     proportional damping
% PS    pseudo-spectral numerical optimal control

wkdir = WecOptTool.AutoFolder();

% Make a regular wave on the edge of validity
w = (0.25:0.25:3)';
SS = WecOptTool.SeaState.regularWave(w, [0.2, 10]);

% Set flap dimensions (length is long axis)
width = 2;
length = 10;
height = 5;

% Set the water depth (should not exceed device height)
depth = 10;

% Calculate hydrodynamic properties
[hydro, meshes] = designDevice('parametric',    ...
                               wkdir.path,      ...
                               length,          ...
                               width,           ...
                               height,          ...
                               depth,           ...
                               w);

% Calculate moment of inertia
mass = hydro.Vo * hydro.rho;
I = mass / 12 * (4 * height ^ 2 + length ^ 2);

% Simulate device subject to sea state and different controllers
[performance(1), modelCC] = simulateDevice(I, hydro, SS, 'CC');
[performance(2), modelP] = simulateDevice(I, hydro, SS, 'P');
[performance(3), modelPS] = simulateDevice(I,               ...
                                           hydro,           ...
                                           SS,              ...
                                           'PS',            ...
                                           'thetaMax', 0.2, ...
                                           'tauMax', 5e5);

% Print and plot comparison
performance.summary()
performance.plotTime()

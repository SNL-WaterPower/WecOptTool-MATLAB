
% maximum absorbed power for a pitching device in a single frequency 
% ("regular") wave is Pmax = J lambda / pi, where J is the wave power flux 
% (units power/length), and lambda is the wave length.

wkdir = WecOptTool.AutoFolder();

% Make a regular wave on the edge of validity
w = (0.1:0.1:3)';
SS = WecOptTool.SeaState.regularWave(w, [0.2, 10]);
w = SS.getRegularFrequencies(0.3);

% Half mesh simulation (long axis along x)
width = 2;
length = 10;
height = 5;
depth = 40;

[hydro, meshes] = designDevice('parametric',    ...
                               wkdir.path,      ...
                               length,          ...
                               width,           ...
                               height,          ...
                               depth,           ...
                               w);

mass = hydro.Vo * hydro.rho;
I = mass / 12 * (4 * height ^ 2 + length ^ 2);
scaling = height / 2 / depth;
                          
[performance, model] = simulateDevice(I, scaling, hydro, SS, 'CC');
performance.summary()

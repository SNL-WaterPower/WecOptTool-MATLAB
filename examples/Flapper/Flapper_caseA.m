
wkdir = WecOptTool.AutoFolder();

SS = WecOptTool.SeaState.exampleSpectrum();
w = SS.getRegularFrequencies(0.3);

% Half mesh simulation
[hydro, mesh] = evalFun(2., w, wkdir);
[performance, model] = simulateDevice(hydro, SS, 'CC');
performance.summary()


function [hydro, meshes] = evalFun(width, w, wkdir)

    height = 5;
    length = 10;
    [hydro, meshes] = designDevice('parametric',    ...
                                   wkdir.path,      ...
                                   length,          ...
                                   width,           ...
                                   height,          ...
                                   w);

end

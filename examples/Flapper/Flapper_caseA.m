
wkdir = WecOptTool.AutoFolder();
my_widths = [2];

for ii = 1:length(my_widths)
    [hydro, meshes] = evalFun(my_widths(ii), wkdir);
    WecOptTool.plot.plotMesh(meshes);
    plot(w, squeeze(hydro.B(1, 1, :)));
end

function [hydro, meshes] = evalFun(width, wkdir)
    
    dw = 0.3142;
    nf = 50;
    w = dw * (1:nf)';

    height = 5;
    length = 10;
    [hydro, meshes] = designDevice('parametric',    ...
                                   wkdir.path,      ...
                                   length,          ...
                                   width,           ...
                                   height,          ...
                                   w);

end

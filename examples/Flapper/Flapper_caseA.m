
my_widths = linspace(1,2.5,5);

for ii = 1:length(my_widths)
    [~, meshes] = evalFun(my_widths(ii));
    WecOptTool.plot.plotMesh(meshes);
end

function [hydro, meshes] = evalFun(width)
    
    wkdir = WecOptTool.AutoFolder();
    
    dw = 0.3142;
    nf = 50;
    w = dw * (1:nf)';

    height = 5;
    depth = 10;
    [hydro, meshes] = designDevice('parametric',    ...
                                   wkdir.path,      ...
                                   width,           ...
                                   height,          ...
                                   depth,           ...
                                   w);

end

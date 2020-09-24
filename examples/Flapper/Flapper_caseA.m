
%% Test

f(1, "bob", 5, "barry", 6)


%%

% my_widths = linspace(1,10,10);
my_widths = 5;

for ii = 1:length(my_widths)
    [pow(ii),hydro(ii)] = evalFun(my_widths(ii));
end

function [pow,wkdir] = evalFun(width)
    
    wkdir = WecOptTool.AutoFolder();
    
    dw = 0.3142;
    nf = 50;
    w = dw * (1:nf)';

    height = 5;
    depth = 10;
    designDevice('parametric',wkdir.path,width,height,depth,w)

    hydro = NaN;
    pow = NaN;
end

%%

% gmesh command line call to set all arguments and generate matlab format
% output:
% gmsh flapper_base2.geo -setnumber lc 0.2 -setnumber width 5 -setnumber thick 1 -setnumber height 6 -0 -o test.m

% This is the structure of the matlab function for making the mesh
function f(input, names, values)
    arguments
        input
    end
    arguments (Repeating)
        names
        values
    end
    
    input
    
    for i = 1:length(names)
        names{i}
        values{i}
    end
    
end

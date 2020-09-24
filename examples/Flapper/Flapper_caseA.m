

clc
clear
close all

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

% gmesh command line call to set all arguments and generate matlab format
% output:
% gmsh flapper_base2.geo -setnumber lc 0.2 -setnumber width 5 -setnumber thick 1 -setnumber height 6 -0 -o test.m

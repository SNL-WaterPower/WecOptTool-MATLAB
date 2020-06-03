
% Copyright 2020 National Technology & Engineering Solutions of Sandia, 
% LLC (NTESS). Under the terms of Contract DE-NA0003525 with NTESS, the 
% U.S. Government retains certain rights in this software.
%
% This file is part of WecOptTool.
% 
%     WecOptTool is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     WecOptTool is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with WecOptTool.  If not, see <https://www.gnu.org/licenses/>.

function tests = resampleSpectraTest()
   tests = functiontests(localfunctions);
end


function testCheck_dw(testCase)
    S=struct();
    wMin=0.001;
    wMax=2*pi;
    w=linspace(wMin,wMax)';
    S.w = w;       
    S.S = sin(w);
    
    dw=0.3;
    
    resampledS = WecOptLib.utils.resampleSpectra(S, dw);    
    
    verifyTrue(testCase, all(round(diff(resampledS.w),2)==dw));    
    
end

function testCheck_minMaxW(testCase)
    S=struct();
    wMin=0.001;
    wMax=2*pi;
    w=linspace(wMin,wMax)';
    S.w = w;       
    S.S = sin(w);
    
    dw=0.3;
    NSuperHarmonics =1;
    
    resampledS = WecOptLib.utils.resampleSpectra(S, dw, NSuperHarmonics );    
    
    resampledMin = min(resampledS.w);
    resampledMax = max(resampledS.w);
    
    verifyTrue(testCase, and( resampledMin <= wMin , ...
                              resampledMin >  wMin-dw ...
                             ));    
    verifyTrue(testCase, and( resampledMax >= wMax , ...
                              resampledMax <  wMax*NSuperHarmonics + dw ...
                             ));  
    
end

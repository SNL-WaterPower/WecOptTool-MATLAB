
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

function tests = removeSpectraTailsTest()
   tests = functiontests(localfunctions);
end


function testCheck_generatedSpectra(testCase)
    S=struct();
    wMin=1;
    wMax=100;
    w=linspace(wMin,wMax)';
    S.w = w;
    spectra = zeros(length(w),1);
    oneThird = floor(length(spectra)/3);
    spectra(oneThird:2*oneThird, 1) = 1;
    expectedLength= length(spectra(oneThird:2*oneThird,1));        
    S.S = spectra;
    
    % Remove the tails
    noTailsS = WecOptLib.utils.removeSpectraTails(S);
    lengthS = length(noTailsS.S);
    verifyTrue(testCase, expectedLength==lengthS);
end













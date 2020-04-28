
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

function w = seaStatesGlobalW(SS, step)
%seaStatesGlobalW Takes a set of sea states and returns a frequency range
% based on the the global min and  max frequency and a given step size.
WecOptLib.utils.checkSpectrum(SS);
checkStepType(step)
checkStepValue(step)

w = SS(1).w;
gMin = min(w);
gMax = max(w);

if length(SS) > 1
    for i =2:length(SS)

     w = SS(i).w;
     wMin = min(w);
     wMax = max(w);

     if wMin < gMin
         gMin = wMin;
     end

     if wMax > gMax
         gMax = wMax;
     end

    end
end

% Round to nearest step
gMin = floor(gMin / step) * step;
gMax = ceil(gMax / step) * step;
 
w = gMin:step:gMax;
end

function [] = checkStepType(step)
msg = 'step must be of type double (float)';
ID = 'WecOptLib:utilityFailure:stepType';
try
    assert(isa(step,'double'),ID,msg);
catch ME
    throw(ME)
end
end


function [] = checkStepValue(step)
msg = 'step must be greater than 0';
ID = 'WecOptLib:utilityFailure:stepValue';
try
    assert(step >0,ID,msg);
catch ME
    throw(ME)
end
end

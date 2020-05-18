function err = MAPError(wOriginal, SOriginal, wModified, SModified)
    % Returns the mean absolute percentage error given an original and
    % modified spectrum to the original spectrum frequencies
    %
    % Parameters
    %-----------
    
  
    SInterpolated = interp1(wModified, SModified, wOriginal,'linear', 0);
    
    N = length(SOriginal);
    
    if any(SOriginal == 0)
        shiftZeroFrequencies=0.000001;
        SOriginal     = SOriginal     + shiftZeroFrequencies;
        SInterpolated = SInterpolated + shiftZeroFrequencies;
    end
    
    err =  100/N * sum( abs(1 - SInterpolated ./ SOriginal ))   ;
end


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




% Copyright 2020 Sandia National Labs
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
%     along with Foobar.  If not, see <https://www.gnu.org/licenses/>.

function [powPerFreq, freqs] = damping(obj, RM3)
    % DAMPING Damping control
    %   Returns power per frequency and frequency bins
    %
    % References:
    %    Falnes, J., Ocean Waves and Oscillating Systems, 
    %      Cambridge University Press, 2002
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
 
    % Frequencies
    freqs = RM3.w;

    % Max Power for a given Damping Coeffcient [Falnes 2002 (p.51-52)]
    P_max = @(b) -0.5*b*sum(abs(RM3.F0./(RM3.Zi+b)).^2);
    % Optimize the linear damping coeffcient(B)
    B_opt = fminsearch(P_max, max(real(RM3.Zi)));
    
    % Power per frequency at optimial damping?
    powPerFreq = 0.5*B_opt *(abs(RM3.F0 ./ (RM3.Zi + B_opt)).^2);
        
end

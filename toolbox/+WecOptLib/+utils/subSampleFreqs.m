
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

function [new_w, new_S] = subSampleFreqs(S, npoints)
%subSampleFreq - subsamples sea state and interpolates to three harmonics
%    gets a subsampling of a given seastate by linear interpolation
%    Inputs:
%        S = seastate.  must have S.S and S.w
%        npoints = number of points to subsample
%    Outputs:
%        newS = new density values
%        neww = new frequency values

if(nargin < 2)
    npoints = 120;
end
ind_sp = find(S.S > 0.01 * max(S.S),1,'last');

new_w = linspace(S.w(1), S.w(ind_sp) * 3, npoints)';
new_S = interp1(S.w, S.S, new_w,'linear',0);

end
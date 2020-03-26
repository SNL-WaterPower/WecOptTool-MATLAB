
% Copyright 2005-2020, NumPy Developers.
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

function result = isClose(a, b, varargin)
    %ISCLOSE
    
    defaultAtol = 1e-08;
    defaultRtol = 1e-05;
    
    p = inputParser;
    
    addParameter(p, 'rtol', defaultRtol);
    addParameter(p, 'atol', defaultAtol);
    parse(p, varargin{:});
    
    result = abs(a - b) <= (p.Results.atol + p.Results.rtol * abs(b));
    
end


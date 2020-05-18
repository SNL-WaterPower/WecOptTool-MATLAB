function [] = assertEqualLength(x, y)
    % Returns an error if x and y are not of equal lengths
    %
    % Parameters
    %-----------
    % x: 
    %    first value with a length
    % y: 
    %    second value with a length
    %
    % Returns
    % -------
    % Error if length(x) is not equal to length(y), otherwise retuns 
    % nothing

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

    msg = ['x and y must be of equal length'];
    ID = 'WecOptLib:errorCheckFailure:unequalLengths';
    try
        assert(length(x)==length(y),ID,msg);
    catch ME
        throw(ME)
    end
    
end

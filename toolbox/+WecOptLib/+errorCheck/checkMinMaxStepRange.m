function [] = checkMinMaxStepRange(xMin, xMax, dx)
    % Checks that xMax is greater than xMin by at least dx
    %
    % Parameters
    %-----------
    % xMin: 
    %    Then minimum of a range of values
    % xMax: 
    %    Then maximum of a range of values    
    % dx:
    %    The step size of a range of values
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
    
    msg = 'xMax must be greater than xMin by at least dx';
    ID = 'WecOptLib:errorCheckFailure:wMinMaxRange';
    try    
        assert((xMax-xMin)/dx > 1,ID,msg);
    catch ME
        throw(ME)
    end
end
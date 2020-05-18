function [] = assertPositiveFloat(x)
    % Checks that x is a positive float
    %
    % Parameters
    %-----------
    % x: numeric
    %    The value expected to be a positive float
    %
    % Returns
    % -------
    % Error if x is not a positive float otherwise retuns 
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
        
    msgPos = sprintf('%f must be a positive',x);
    msgFloat = sprintf('%f must be a float ',x);
    ID = 'WecOptLib:errorCheckFailure:positiveFloat';   
    try
        assert(all(x>=0),ID,msgPos);
    catch ME
        throw(ME)
    end
    try
        assert(isa(x,'numeric'),ID,msgFloat);
    catch ME
        throw(ME)
    end  
end
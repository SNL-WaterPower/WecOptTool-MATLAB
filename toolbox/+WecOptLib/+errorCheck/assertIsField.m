function [] = assertIsField(SS, field)
    % Returns an error if x and y are not of equal lengths
    %
    % Parameters
    %-----------
    % SS: struct
    %    struct to check
    % field: string 
    %    field which should be in SS
    %
    % Returns
    % -------
    % Error if "field" is not a field of struct SS, otherwise pass 

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
    
    msg = sprintf('%s must be a field of SS',field);
    ID = 'WecOptLib:errorCheckFailure:fieldNotFound';
    try
        assert(isfield(SS,field),ID,msg);
    catch ME
        throw(ME)
    end
    
end

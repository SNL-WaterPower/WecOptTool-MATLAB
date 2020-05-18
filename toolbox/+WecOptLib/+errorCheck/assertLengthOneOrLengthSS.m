function [] = assertLengthOneOrLengthSS(x,SS)
    % Checks that a passed type is either singular or of a length rqual
    % to a sea states struct. This is useful when wanting to ensure that
    % either one value has been specified for all sea states or that a
    % value has been supplied for each sea state.
    %
    % Parameters
    % ----------
    % x: numeric or vector
    %    Value to check length
    % SS: struct
    %    length to compare x against
    %
    % Returns
    % -------
    % Error is length(x) is not equal to 1 or length of SS. Otherwise
    % returns nothing.

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
    msg = 'x must be of length 1 or length of SS';
    ID = 'WecOptLib:errorCheckFailure:incorrectLength';
    try
        lenX = length(x);
        lenSS = length(SS);    
        assert(or(lenX==1, lenX==lenSS),ID,msg);
    catch ME
        throw(ME)
    end
end


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

function result(study)
    % Displays the results from the optimized study
    % 
    % Args:
    %     study (:mat:class:`+WecOptTool.RM3Study`):
    %         executed RM3Study object
    
    disp('Optimal solution is:')
    
    if strcmp(study.geomMode, 'parametric')
        
        %  r1 - Floar radius [m]
        %  r2 - Reaction plate radius [m]
        %  d1 - Float Draft [m]
        %  d2 - Reaction Plate depth [m]
        
        disp("    r1: " + study.out.sol(1) + " [m]");
        disp("    r2: " + study.out.sol(2) + " [m]");
        disp("    d1: " + study.out.sol(3) + " [m]");
        disp("    d2: " + study.out.sol(4) + " [m]");
        
    elseif strcmp(study.geomMode, 'scalar')
        
        disp("    lambda " + study.out.sol(1));
    
    end
    
    disp('')
    disp("Optimal function value is: "...
        + (-study.out.fval) + " [W]")
    
end

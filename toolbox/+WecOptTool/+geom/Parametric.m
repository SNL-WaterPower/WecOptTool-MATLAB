
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

classdef Parametric < WecOptTool.geom.AbsGeom
    % Vary device geometry parametrically.
    %
    % For the RM3 study the design variables are
    %
    %     * ``r1``: the radius of the surface float
    %     * ``r2``: the radius of the heave plate
    %     * ``d1``: the draft of the surface float
    %     * ``d2``: the depth of the heave plate,
    %
    % The resulting design array is given as ``x = [r1, r2, d1, d2]``.
    %
    % Args:
    %     x0 (double[4]): optimisation initial guess
    %     upperBound (double[4]): optimisation upper bound
    %     lowerBound (double[4]): optimisation lower bound
    
    properties
        geomMode = 'parametric'
        geomLowerBound
        geomUpperBound
        geomX0
    end
    
    methods
    
        function obj = Parametric(x0, upperBound, lowerBound)
             
            obj = obj@WecOptTool.geom.AbsGeom();
            obj.geomLowerBound = upperBound;
            obj.geomUpperBound = lowerBound;
            obj.geomX0 = x0;
        
        end
    
    end

end


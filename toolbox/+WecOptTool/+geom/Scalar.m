
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

classdef Scalar < WecOptTool.geom.AbsGeom
    % Vary device geometry by a global scalar value.
    %
    % The entire RM3 device model is scaled using a multiple of the
    % base RM3 device dimensions.
    %
    % Args:
    %     x0 (double): optimisation initial guess
    %     upperBound (double): optimisation upper bound
    %     lowerBound (double): optimisation lower bound
    
    properties
        geomMode = 'scalar'
        geomLowerBound
        geomUpperBound
        geomX0
    end
    
    methods
    
        function obj = Scalar(x0, upperBound, lowerBound)
             
            obj = obj@WecOptTool.geom.AbsGeom();
            obj.geomLowerBound = upperBound;
            obj.geomUpperBound = lowerBound;
            obj.geomX0 = x0;
        
        end
    
    end

end



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

classdef ProportionalDamping < WecOptTool.control.AbsControl
    % Provides proportional damping control
    %
    % Resistive damping (i.e., a proportional feedback on velocity). See 
    % `Falnes2002`_ for technical details.
    % 
    % .. _Falnes2002:
    %     https://www.cambridge.org/core/books/ocean-waves-and-\
    %     oscillating-systems/8A3366809DE5C1F916FF87F36C55C459
    
    properties
        controlType = 'P'
        controlParams
    end
    
end

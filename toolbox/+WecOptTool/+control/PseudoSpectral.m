
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

classdef PseudoSpectral < WecOptTool.control.AbsControl
    % Provides psuedo spectra control
    %
    % Seeks optimal power absorption subject to constraints. See 
    % `Bacelli2014`_ for technical details.
    %
    % Args:
    %     deltaZmax (float, optional):
    %         maximum relative oscillation amplitude [m]
    %     deltaFmax (float, optional): maximum PTO force [N]
    %
    % Note:
    %     deltaZmax and deltaFmax must be provided together.
    % 
    % .. _Bacelli2014:
    %     https://ieeexplore.ieee.org/abstract/document/6987295
    
    properties
        controlType = 'PS'
        controlParams
    end
    
    methods
    
        function obj = PseudoSpectral(deltaZmax, deltaFmax)
             
            obj = obj@WecOptTool.control.AbsControl();
            
            if nargin == 1
                msg = ['Arguments deltaZmax, deltaFmax must be ' ...
                       'provided together'];
                error(msg);
            elseif nargin == 2
                obj.controlParams = [deltaZmax, deltaFmax];
            end
        
        end
    
    end

end

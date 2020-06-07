classdef (Abstract) Device < handle
    % Abstract class for creating new Device objects,  which are
    % created by :mat:class:`+WecOptTool.+base.Blueprint` subclasses.
    %
    % Devices should populate the hydro, motions and performances 
    % properties with :mat:class:`+WecOptTool.+types.Hydro`, 
    % :mat:class:`+WecOptTool.+types.Motion` and 
    % :mat:class:`+WecOptTool.+types.Performance` data types, and 
    % should implement the simulate method, which evaluates the 
    % performance of the device for a given 
    % :mat:class:`+WecOptTool.+types.SeaState` object.
    %
    % The aggregation property is for added aggregated results from
    % simulations over multiple sea-states, and should be optional.
    %
    % --
    %
    % See also WecOptTool.base.Blueprint, WecOptTool.types.Hydro,
    %   WecOptTool.types.Motion, WecOptTool.types.Performance,
    %   WecOptTool.types.SeaState
    %
    % --
    
    % Copyright 2020 National Technology & Engineering Solutions of Sandia, 
    % LLC (NTESS). Under the terms of Contract DE-NA0003525 with NTESS, the 
    % U.S. Government retains certain rights in this software.
    %
    % This file is part of WecOptTool.
    % 
    %     WecOptTool is free software: you can redistribute it and/or 
    %     modify it under the terms of the GNU General Public License as 
    %     published by the Free Software Foundation, either version 3 of 
    %     the License, or (at your option) any later version.
    % 
    %     WecOptTool is distributed in the hope that it will be useful,
    %     but WITHOUT ANY WARRANTY; without even the implied warranty of
    %     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    %     GNU General Public License for more details.
    % 
    %     You should have received a copy of the GNU General Public 
    %     License along with WecOptTool.  If not, see 
    %     <https://www.gnu.org/licenses/>.
    
    properties
        hydro
        motions
        performances
        aggregation
    end
    
    methods (Abstract)
        simulate(obj, S)
    end
    
end

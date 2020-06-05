classdef (Abstract) Device < handle
    % Abstract class for creating new Device structures which will be
    % creted by BluePrint subclasses (as per the Abstract Factor Pattern).
    %
    % Devices should provide access to the three main data types through
    % the hydro, motions and performances properties and should implement
    % one method (simulate) which evalutates the performance of the device
    % per sea-state.
    %
    % The aggregation property is for added aggregated results from
    % simulations over multiple sea-states, and is optional.
    
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

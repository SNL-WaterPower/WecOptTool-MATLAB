classdef Performance < WecOptTool.base.Data
    % Data type for storage of the controlled WEC performance.
    %
    % This data type defines a set of parameters that are common to 
    % analysis of controlled WEC performance.
    %
    % The following parameters must be provided within the input struct 
    % (any additional parameters given will also be stored within the 
    % created object:
    %
    %     * powPerFreq
    %
    % The following parameters are added automatically upon instantiation
    % of the object:
    %
    %     * pow
    %
    % Once created, the parameters in the object are read only, but the
    % object can be converted to a struct, and then modified.
    %
    % Arguments:
    %    input (struct):
    %        A struct (not array) whose fields represent the parameters
    %        to be stored.
    %
    % Attributes:
    %     powPerFreq (array of float):
    %         The exported power of the WEC per wave frequency
    %     pow (float):
    %         The total exported power of the WEC.
    %
    % Methods:
    %    struct(): convert to struct
    %
    % Note:
    %    To create an array of Performance objects see the
    %    :mat:func:`+WecOptTool.types` function.
    %
    % --
    %
    %  Performance Properties:
    %     powPerFreq - The exported power of the WEC per wave frequency
    %     pow - The total exported power of the WEC
    %
    %  Performance Methods:
    %    struct - convert to struct
    %
    % See also WecOptTool.types
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
        pow
    end
    
    properties (GetAccess=protected)
        meta = struct("name", {"powPerFreq"},         ...
                      "validation", {@isnumeric});
    end
    
    methods

        function pow = get.pow(obj)
            pow = sum(obj.powPerFreq);
        end
        
    end
    
end
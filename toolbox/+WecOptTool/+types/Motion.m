classdef Motion < WecOptTool.base.Data
    % Data type for storage of equations of motion
    %
    % This data type defines a set of parameters that are common to the
    % the description of the equations of motion of the wave energy
    % converter using the electric analogue. For a detailed explanation
    % of the parameters in this class see [Falnes]_.
    %
    % The following parameters must be provided within the input struct 
    % (any additional parameters given will also be stored within the 
    % created object:
    %
    %     * w
    %     * Zi
    %     * F0
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
    %     w (array of float):
    %         The wave angular frequencies which describe the motion.
    %     Zi (array of float):
    %         The intrinsic mechanical impedance.
    %     F0 (array of float):
    %         The excitation forces.
    %
    % Methods:
    %    struct(): convert to struct
    %
    % Note:
    %    To create an array of Motion objects see the
    %    :mat:func:`+WecOptTool.types` function.
    %
    % --
    %
    %  Motion Properties:
    %     w - The wave angular frequencies which describe the motion.
    %     Zi - The intrinsic mechanical impedance.
    %     F0 - The excitation forces.
    %
    %  Motion Methods:
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
    
    properties (GetAccess=protected)
        meta = struct("name", {"w", "Zi", "F0"},         ...
                      "validation", {@isnumeric, @isnumeric, @isnumeric});
    end
    
end

classdef Mesh < WecOptTool.base.Data
    % Data type for storage of compuational mesh information
    %
    % This data type defines a set of parameters that are common to the
    % output of meshing routines required for the calculation of floating 
    % body hydrodynamics. It is based upon the mesh description required
    % as input to `NEMOH 
    % <https://lheea.ec-nantes.fr/logiciels-et-brevets/nemoh-mesh-192932.kjsp/>`_.
    %
    % The following parameters must be provided within the input struct 
    % (any additional parameters given will also be stored within the 
    % created object:
    %
    %     * name
    %     * zG
    %     * xzSymmetric
    %     * nodes
    %     * panels
    %
    % Once created, the parameters in the object are read only, but the
    % object can be converted to a struct, and then modified.
    %
    % Warning:
    %     Currently the centre of mass of each body must lie on the z-axis
    %
    % Arguments:
    %    input (struct):
    %        A struct (not array) whose fields represent the parameters
    %        to be stored.
    %
    % Attributes:
    %     name (string):
    %         The name of the mesh, appended with "_{x}", where {x} is the
    %         the body number.
    %     zG (float):
    %         The (negative) vertical coordinate of the body centre of
    %         gravity.
    %     xzSymmetric (bool):
    %         true if a symmetry about the (xOz) plane is used
    %     nodes (table):
    %         Description of the mesh nodes given as a table. The table
    %         columns are ID: The node ID (sequential from 1), and x, y, z
    %         which represent the coordinates of the node. Each row in 
    %         the table represents one node.
    %     panels (array of int):
    %         Connectivity of nodes. The values in the second dimension
    %         indicate the nodes in the panel, given anticlockwise looking
    %         from the fluid into the body. Shape (height(nodes), 4).
    %
    % Methods:
    %    struct(): convert to struct
    %
    % Note:
    %    To create an array of Mesh objects see the
    %    :mat:func:`+WecOptTool.types` function.
    %
    % --
    %
    %  Mesh Properties:
    %     name - The name of the mesh, appended with "_{x}", where {x} is 
    %            the the body number.
    %     zG - The (negative) vertical coordinate of the body centre of
    %          gravity.
    %     xzSymmetric- true if a symmetry about the (xOz) plane is used
    %     nodes - Description of the mesh nodes given as a table. The 
    %             table columns are ID: The node ID (sequential from 1), 
    %             and x, y, z which represent the coordinates of the node. 
    %             Each row in the table represents one node.
    %     panels - Connectivity of nodes. The values in the second 
    %              dimension indicate the nodes in the panel, given 
    %              anticlockwise looking from the fluid into the body. 
    %              Shape (height(nodes), 4).
    %
    %  Mesh Methods:
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
        meta = struct("name", {"xzSymmetric",       ...
                               "nodes",             ...
                               "panels",            ...
                               "name",              ...
                               "zG"},               ...
                      "validation", {@islogical,        ...
                                     @istable,          ...
                                     @isnumeric,        ...
                                     @ischarorstring,   ...
                                     @isnumeric});
    end
    
end

function result = ischarorstring(x)
    result = ischar(x) || isstring(x);
end

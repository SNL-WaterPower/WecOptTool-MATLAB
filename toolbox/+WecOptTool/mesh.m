function mesh = mesh(meshName, folder, varargin)
    % Make a mesh using shortcuts to the ``makeMesh`` method of the 
    % defined Mesher concrete classes in the :mat:mod:`+WecOptTool.+mesh` 
    % package.
    %
    % Arguments:
    %     meshName (string):
    %         Meshing routine to use. Current options are:
    %              
    %              * AxiMesh (:mat:class:`+WecOptTool.+mesh.AxiMesh`)
    %
    %     folder (string):
    %         Path to the folder to store output files
    %     varargin:
    %         Arguments to pass to the meshing routine. See the
    %         ``makeMesh`` method of the chosen mesher class for details.
    %
    % Returns:
    %    :mat:class:`+WecOptTool.+types.Mesh`: A populated Mesh object
    %
    % --
    %
    % See also WecOptTool.mesh.AxiMesh
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
    
    fullQName = "WecOptTool.mesh." + meshName;
    meshHandle = str2func(fullQName);
    mesher = meshHandle(folder);
    mesh = mesher.makeMesh(varargin{:});

end

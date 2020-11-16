function [hydro, meshes] = designDevice(geomType, varargin)
    
%     arguments
%         geomType (1,1) string
%         varargin (1,:) cell
%     end
    
    switch geomType
        case 'parametric'
            [hydro, meshes] = getHydroParametric(varargin{:});
        otherwise
            error('WecOptTool:UnknownGeometryType', ...
                  'Invalid geometry type')
    end
    
end

function [hydro, meshes] = getHydroParametric(folder,   ...
                                              length,   ...
                                              width,    ...
                                              height,   ...
                                              depth,    ...
                                              w)
                                          
          
    
    arguments
        folder
        length
        width
        height
        depth
        w
    end

    meshes = WecOptTool.mesh("Gmsh",                    ...
                             folder,                    ...
                             "Flapper_half_base.geo",   ...
                             1,                         ...
                             "lc", 0.5,                 ...
                             "length", length,          ...
                             "width", width,            ...
                             "height", height,          ...
                             "depth", depth,            ...
                             "xzSymmetric", true);
    
    % Solve for roll only
    meshes.roll = true;
    meshes.rotationPoint = [0, 0, -10];
    hydro = WecOptTool.solver("NEMOH",              ...
                              folder,               ...
                              meshes,               ...
                              w,                    ...
                              "waterDepth", depth,  ...
                              "waveDirection", 90);
    
    % Move torque application from free surface to CoM
    scaling = height / 2 / depth;
    hydro.ex = hydro.ex * scaling;
                          
end


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

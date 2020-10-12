function [hydro, meshes] = designDevice(geomType, varargin)
    
%     arguments
%         geomType (1,1) string
%         varargin (1,:) cell
%     end
    
    switch geomType
        case 'parametric'
            [hydro, meshes] = getHydroParametric(varargin{:});
        otherwise
            error('WecOptTool:UnknownGeometryType',...
                'Invalid geometry type')
    end
    
end

function [hydro, meshes] = getHydroParametric(folder,   ...
                                              length,   ...
                                              width,    ...
                                              height,   ...
                                              w)
    
    if w(1) == 0
        w = w(2:end);
    end
    
    meshes = WecOptTool.mesh("Gmsh",                ...
                             folder,                ...
                             "Flapper_base.geo",    ...
                             "base",                ...
                             1,                     ...
                             "lc", 0.5,             ...
                             "length", length,      ...
                             "width", width,        ...
                             "height", height);
    
    % Solve for roll only
    meshes.roll = true;
    meshes.rotationPoint = [0, 0, -10];
    hydro = WecOptTool.solver("NEMOH",      ...
                              folder,       ...
                              meshes,       ...
                              w,            ...
                              "waterDepth", 10);
    
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

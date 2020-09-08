function hydro = designDevice(geomType, varargin)
    
%     arguments
%         geomType (1,1) string
%         varargin (1,:) cell
%     end
    
    switch geomType
        case 'parametric'
            hydro = getHydroParametric(varargin{:});
        otherwise
            error('WecOptTool:UnknownGeometryType',...
                'Invalid geometry type')
    end
    
end

function hydro = getHydroParametric(folder, width, height, depth, w)
               
    if w(1) == 0
        w = w(2:end);
    end
    
    % update the .geo file with parameters (width, hieght, depth
    geofn_0 = 'Flapper_base.geo';
    varinames = {'width','height','depth'};
    varivals = {width,height,depth};
    [geofn_1,ftxt] = WecOptTool.mesh.updateGeo(geofn_0, varinames, varivals, folder);
%     disp(ftxt)

    % call gmsh to create the mesh and save as STL
    geofn_2 = 'Flapper.stl';
    meshscalefator = 1;
    syscall_gmsh = sprintf('gmsh %s -clscale %f -1 -2 -o %s',...
        geofn_1,meshscalefator,geofn_2);
    [status,cmdout] = system(syscall_gmsh);
%     disp(cmdout)
    
    % read the file and translate to something that NEMOH can use
    [TR,fileformat,attributes,solidID] = stlread(geofn_2);
    
    figure('name','STL data')
    trimesh(TR,'EdgeColor','k')
    axis equal
    zlim([-Inf, 0])
    ylim([-10, 10])
    xlim([-10, 10])
    
%     hydro = WecOptTool.solver("NEMOH", folder, meshes, w);
    hydro = nan;
           
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

function [hydro, meshes] = designDevice(type, varargin) 
    % WaveBot   WEC based on the Sandia "WaveBot" device.
    %
    % The WaveBot is a model-scale wave energy converter (WEC) tested in
    % the Navy's Manuevering and Sea Keeping (MASK) basin. Reports and
    % papers about the WaveBot are available at advweccntrls.sandia.gov.
    
    switch type
        
        case 'existing'
            hydro = WecOptTool.geometry.existingNEMOH(varargin{:});
        case 'scalar'
            hydro = getHydroScalar(varargin{:});
        case 'parametric'
            [hydro, meshes] = getHydroParametric(varargin{:});
        otherwise
            error('WecOptTool:UnknownGeometryType',...
                'Invalid geometry type')
    end
    
end


function [hydro, meshes] = getHydroParametric(folder, r1, d1, w)
               
    if w(1) == 0
        w = w(2:end);
    end
    
    z0 = 0;
    r = [0,    r1,          r1,  r1,   0];
    z = [z0, z0, (-d1-z0)/2, -d1, -d1];

    % Mesh
    ntheta = 20;
    nfobj = 200;
    zG = 0;
    
    meshes = WecOptTool.mesh("AxiMesh",    ...
                                         folder,       ...
                                         r,            ...
                                         z,            ...
                                         ntheta,       ...
                                         nfobj,        ...
                                         zG,           ...
                                         1);
    
    hydro = WecOptTool.solver("NEMOH", folder, meshes, w);
           
end

% function hydro = getHydroScalar(folder, lambda, w)
%                    
%     if w(1) == 0
%     error('WecOptTool:UnknownGeometryType',...
%                 'Invalid frequency vector')     % TODO - more checks
%     end
%     
%     r = lambda * [0, 0.88, 0.88, 0.35, 0];
%     z = lambda * [0.2, 0.2, -0.16, -0.53, -0.53];
% 
%     % Mesh
%     ntheta = 20;
%     nfobj = 200;
%     zG = 0;
%     
%     meshes = WecOptTool.mesh("AxiMesh",    ...
%                              folder,       ...
%                              r,            ...
%                              z,            ...
%                              ntheta,       ...
%                              nfobj,        ...
%                              zG,           ...
%                              1);
%     
%     hydro = WecOptTool.solver("NEMOH", folder, meshes, w);
%            
% end


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

function hydro = designDevice(type, varargin) 
    
    switch type
        
        case 'existing'
            hydro = WecOptTool.callbacks.geometry.existingNEMOH(varargin{:});
        case 'scalar'
            hydro = getHydroScalar(varargin{:});
        case 'parametric'
            hydro = getHydroParametric(varargin{:});
        
    end
    
end

function hydro = getHydroScalar(lambda)
                    
    % Get data file path
    p = mfilename('fullpath');
    [filepath, ~, ~] = fileparts(p);
    dataPath = fullfile(filepath, 'RM3_BEM.mat');

    load(dataPath, 'hydro');

    % dimensionalize w/ WEC-Sim built-in function
    hydro.rho = 1025;
    hydro.g = 9.81;
%         hydro = Normalize(hydro); % TODO - this doesn't work for our data
%         that was produced w/ WAMIT...

    % scale by scaling factor lambda
    hydro.Vo = hydro.Vo .* lambda^3;
    hydro.C = hydro.C .* lambda^2;
    hydro.B = hydro.B .* lambda^2.5;
    hydro.A = hydro.A .* lambda^3;
    hydro.ex = complex(hydro.ex_re,hydro.ex_im) .* lambda^2;
    hydro.ex_ma = abs(hydro.ex);
    hydro.ex_ph = angle(hydro.ex);
    hydro.ex_re = real(hydro.ex);
    hydro.ex_im = imag(hydro.ex);
           
end


function hydro = getHydroParametric(r1, r2, d1, d2, w)
    
    % Float
    
    rf = [0 r1 r1 0];
    zf = [0 0 -d1 -d1];

    % Heave plate

    thk = 1;
    rs = [0 r2 r2 0];
    zs = [-d2 -d2 -d2-thk -d2-thk];

    % Mesh
    ntheta = 20;
    nfobj = 200;
    zG = 0;
    
    meshes = WecOptTool.mesh("AxiMesh",    ...
                             folder,       ...
                             rf,           ...
                             zf,           ...
                             ntheta,       ...
                             nfobj,        ...
                             zG,           ...
                             1);
    meshes(2) = WecOptTool.mesh("AxiMesh",  ...
                                folder,     ...
                                rs,         ...
                                zs,         ...
                                ntheta,     ...
                                nfobj,      ...
                                zG,         ...
                                2);
    
    hydro = WecOptTool.solver("NEMOH", folder, meshes, w);
           
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

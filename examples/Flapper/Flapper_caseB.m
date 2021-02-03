% Case B
%
% Giorgio B (~750kW)

clear performance

% Load a predefined elevation record
wave = load('wave_elev');
init_wave = 2000;
len_wave = 180;
eta = wave.wave(init_wave:(init_wave + len_wave - 1));
eta = eta-mean(eta);
dt = 1;
Nwave = length(eta);
T = Nwave * dt;
eta_f = fft(eta) / Nwave;

% Frequency vector
Nf = 20;
w0 = 2 * pi / T;
w = w0 * (1:Nf)';

% Expand and trim eta_f as required
if Nwave <= Nf
    eta_f = [eta_f; zeros(Nf - Nwave + 1, 1)];
end

eta_f = eta_f(2:Nf+1);

out = flapper_mwe([30, 15], eta_f, w);

function out = flapper_mwe(depth, eta_f, w)

    % Set flap dimensions (length is long axis)
    flap_width = 1;
    flap_length = 60;
    flap_height = 15;
    
    out = struct();
    
    for i = 1 : length(depth)
        
        name = sprintf('%3.1f m', depth(i));

        % Calculate hydrodynamic properties
        wkdir = WecOptTool.AutoFolder();
        [hydro, meshes] = designDevice('parametric',    ...
                                       wkdir.path,      ...
                                       flap_length,     ...
                                       flap_width,      ...
                                       flap_height,     ...
                                       depth(i),        ...
                                       w,               ...
                                       "panelSize", 2);

        % WecOptTool.plot.plotMesh(meshes);

        % Calculate moment of inertia
        mass = hydro.Vo * hydro.rho / 8;
        I = mass / 12 * (4 * flap_height ^ 2 + flap_length ^ 2);

        % Dummy sea state
        SS = WecOptTool.SeaState();

        % Simulate device subject to sea state and PS controller
        [performance(i), modelPS] = simulateDevice(I,               ...
                                                   hydro,           ...
                                                   SS,              ...
                                                   'PSEta',         ...
                                                   'forceEta', eta_f);
        performance(i).name = name;
        
        % Outputs
        out(i).name = name;
        out(i).A = squeeze(hydro.A);
        out(i).B = squeeze(hydro.B);
        out(i).ex = squeeze(hydro.ex);
        out(i).pow = performance(i).pow;
                                               
    end

    % Print and plot comparison
    performance.summary()
    performance.plotTime()
    
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

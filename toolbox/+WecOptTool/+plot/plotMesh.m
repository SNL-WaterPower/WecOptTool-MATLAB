function plotMesh(meshses, newFig)
    % Plot the given meshes on a single 3D axis.
    %
    % Arguments:
    %     meshses (struct):
    %         Struct array containing mesh description with fields as 
    %         described below
    %     newFig (bool):
    %         If true a new figure is created
    %
    % The meshes struct must contain the following fields:
    %
    % ============  ================  ======================================
    % **Variable**  **Format**        **Description**
    % bodyNum       int               body number
    % name          char array        name of the mesh
    % nodes         Nx4 table         table of N node positions with columns ID, x, y, z
    % panels        Mx4 int32 array   array of M panels where each row contains the 4 connected node IDs
    % xzSymmetric   bool              body is symmetric in xz plane (half mesh)
    % zG            float             z-coordinate of the bodies centre of gravity
    % ============  ================  ======================================
    %
    
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
    
    arguments
        meshses
        newFig = true
    end
    
    if isempty(meshses)
        return
    end

    if newFig
        figure
        ax1 = axes;
        view(ax1, 3)
    end
    
    hold on
    
    for mesh = meshses
        plotSingleMesh(ax1, mesh);
    end
    
    xlabel("x")
    ylabel("y")
    zlabel("z")
    
    axis image
    
    hold off
    
end

function plotSingleMesh(ax, mesh)

    n = size(mesh.panels, 1);
    
    X = zeros(4, n);
    Y = zeros(4, n);
    Z = zeros(4, n);
    
    for i = 1:n
        X(:, i) = mesh.nodes(mesh.panels(i, :), :).x;
        Y(:, i) = mesh.nodes(mesh.panels(i, :), :).y;
        Z(:, i) = mesh.nodes(mesh.panels(i, :), :).z;
    end
    
    fill3(ax, X, Y, Z, 'r')
    
    if ~mesh.xzSymmetric
        return
    end
    
    for i = 1:n
        Y(:, i) = -mesh.nodes(mesh.panels(i, :), :).y;
    end
    
    fill3(ax, X, Y, Z, 'r')
    
end


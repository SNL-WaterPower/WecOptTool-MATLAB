classdef AxiMesh < WecOptTool.base.Mesher & WecOptTool.base.NEMOH
    % Class for making meshes using the NEMOH aximesh routine
    %
    % Attributes:
    %     verb (bool): use verbose console outputs (default false)
    %     rho (float): water density (default = 1025 kg/m\ :sup:`3`)
    %     g (float):
    %         gravitational acceleration (default = 9.81 m/s\ :sup:`2`)
    %
    % --
    %
    % AxiMesh Properties:
    %     verb - use verbose console outputs (default false)
    %     rho - water density (default = 1025 kg/m^3)
    %     g - gravitational acceleration (default = 9.81 m/s^2)
    %
    % AxiMesh Methods:
    %     makeMesh - Mesh generation of for an axisymmetric body.
    %
    % See also WecOptTool.mesh
    %
    % --
    
    % Copyright Ecole Centrale de Nantes 2014
    % Modifications copyright 2017 Markel Penalba
    % Modifications copyright 2020 National Technology & Engineering  
    % Solutions of Sandia, LLC (NTESS). Under the terms of Contract  
    % DE-NA0003525 with NTESS, the U.S. Government retains certain rights 
    % in this software.
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
    
    properties
        verb = false
        rho = 1025
        g = 9.81
    end
    
    methods
        
        function meshData = makeMesh(obj, r, z, ntheta, nfobj, zG, bodyNum)
            % Mesh generation of an axisymmetric body.
            %
            % All coordinates are measured from the undisturbed sea
            % surface and only the body description below the sea surface
            % should be given, thus all z-coordinates should be negative.
            %
            % The produced mesh represents half of the body and is 
            % symmetric in the xz plane.
            %
            % Arguments:
            %   r (array of float): radial coordinates
            %   z (array of float): vertical coordinates
            %   ntheta (int):
            %       number of points for discretisation in angular 
            %       direction (over pi radians)
            %   nfobj (int):
            %       number of nodes within the resulting half body mesh
            %   zG (float):
            %       z-coordinate of the bodies centre of gravity
            %   bodyNum (int):
            %       the number of the body (starting from one)
            %       
            % Returns:
            %    struct:
            %        A mesh description with fields as described below
            %
            % ============  ================  ======================================
            % **Variable**  **Format**        **Description**
            % bodyNum       int               body number
            % name          char array        name of the mesh
            % nodes         Nx4 table         table of N node positions with columns ID, x, y, z
            % panels        Mx4 int32 array   array of M panels where each row contains the 4 connected node IDs
            % zG            float             z-coordinate of the bodies centre of gravity
            % ============  ================  ======================================
            %
            % Warning:
            %     z(i) must be greater than or equal to z(i+1)
            % 
            % Note:
            %     The original aximesh function was written by A. Babarit, 
            %     LHEEA Lab, and licensed under the Apache License, 
            %     Version 2.0.
            %
            % --
            % 
            % See also WecOptTool.mesh
            %
            % --
            
            % Throwing error message if Nemoh could not be found.
            nemohExistFlag = obj.isNemohInPath();

            if(~ nemohExistFlag)
                errMsg = ['Error: Unable to locate Nemoh binaries. ',   ...
                          'It is possible that the Nemoh path has not ',...
                          'been added to WecOptTool. Make sure that ',  ...
                          'the file path is  spelled correctly and ',   ...
                          'has been added to WecOptTool using the ',    ...
                          'InstallNemoh.m script'];
                error(errMsg);
            end
            
            startdir = pwd;
            cd(obj.path);
            rundir = '.';
            
            if exist(fullfile(rundir,'input.txt'), 'file') ~= 2
                [fip, errmsg] = fopen(fullfile(rundir,'input.txt'),'w');
                error(errmsg);
                fwrite(fip,'0\n');
                fclose(fip);
            end

            WOTDataPath = WecOptTool.system.getUserPath();
            configPath = fullfile(WOTDataPath, 'config.json');
            config = jsondecode(fileread(configPath));
            nemohPath = fullfile(config.nemohPath);

            if ispc
                nemoh_mesh_command = fullfile(nemohPath, 'mesh');
            else
                nemoh_mesh_command = fullfile(nemohPath, 'mesh');
            end

            n = length(r);
            mname = sprintf('axisym_%i',bodyNum);
    %         status=close('all');
            theta=[0.:pi/(ntheta-1):pi];
            nx=0;
            % Calcul des sommets du maillage
            for j=1:ntheta
                for i=1:n
                    nx=nx+1;
                    x(nx)=r(i)*cos(theta(j));
                    y(nx)=r(i)*sin(theta(j));
                    z(nx)=z(i);
                end
            end
            % Calcul des facettes
            nf=0;
            for i=1:n-1
                for j=1:ntheta-1
                    nf=nf+1;
                    NN(1,nf)=i+n*(j-1);
                    NN(2,nf)=i+1+n*(j-1);
                    NN(3,nf)=i+1+n*j;
                    NN(4,nf)=i+n*j;
                end
            end
            % Affichage de la description du maillage
            nftri=0;
            for i=1:nf
                nftri=nftri+1;
                tri(nftri,:)=[NN(1,i) NN(2,i) NN(3,i)];
                nftri=nftri+1;
                tri(nftri,:)=[NN(1,i) NN(3,i) NN(4,i)];
            end

            %         figure
            %         trimesh(tri,x,y,z,[zeros(nx,1)]);
            %         title('Characteristics of the discretisation');
            %         axis equal

            if obj.verb
                fprintf('\n --> Number of nodes             : %g',nx);
                fprintf('\n --> Number of panels (max 2000) : %g \n',nf);
            end

             % obj.path;

            % If this is a multi-body device the mesh and results 
            % directories will already exist
            if exist(fullfile(rundir,'mesh'),'dir') ~= 7
                mkdir(fullfile(rundir,'mesh'));
            end
            if exist(fullfile(rundir,'results'),'dir') ~= 7
                mkdir(fullfile(rundir,'results'));
            end

            % Creation des fichiers de calcul du maillage
            fid=fopen(fullfile('Mesh.cal'),'w');
            fprintf(fid,[mname,'\n'],1);
            fprintf(fid,'1 \n ');
            fprintf(fid,'0. 0. \n ');
            fprintf(fid,'%f %f %f \n',[0. 0. zG]);
            fprintf(fid,'%g \n ', nfobj);
            fprintf(fid,'2 \n ');
            fprintf(fid,'0. \n ');
            fprintf(fid,'1.\n');
            fprintf(fid,'%f \n ', obj.rho);
            fprintf(fid,'%f \n', obj.g);
            status=fclose(fid);

            fid=fopen(fullfile('ID.dat'),'w');
            fprintf(fid,['% g \n',rundir,' \n'],length(rundir));
            status=fclose(fid);
            fid=fopen(fullfile(rundir,'mesh',mname),'w');
            fprintf(fid,'%g \n',nx);
            fprintf(fid,'%g \n',nf);
            for i=1:nx
                fprintf(fid,'%E %E %E \n',[x(i) y(i) z(i)]);
            end
            for i=1:nf
                fprintf(fid,'%g %g %g %g \n',NN(:,i)');
            end

            status=fclose(fid);

            % Raffinement automatique du maillage et calculs hydrostatiques
            [status,msg] = system([nemoh_mesh_command,  ...
                                   ' >',                ...
                                   fullfile(rundir,'mesh','mesh.log')]);
            if status
                error(msg)
            else
                if obj.verb
                    fprintf(fileread(fullfile(rundir,'mesh','mesh.log')))
                end
            end
            
            meshFileName = join([mname, '.dat'], "");
            meshFilePath = fullfile(rundir, 'mesh', meshFileName);
            meshData = obj.readNEMOHMesh(meshFilePath);
            meshData.name = mname;
            meshData.zG = zG;
            meshData.bodyNum = bodyNum;
            
            cd(startdir);
        
        end
        
    end
        
    methods (Static, Access=private)
        
        function meshData = readNEMOHMesh(datFilePath)

            M = dlmread(datFilePath);
            zeroIdxs = find(M(:, 1) == 0);
            
            meshData.xzSymmetric = M(1, 2) == 1;
            nodes = M(2:zeroIdxs(1) - 1, :);
            meshData.nodes = table(int32(nodes(:,1)),   ...
                                   nodes(:,2),          ...
                                   nodes(:,3),          ...
                                   nodes(:,4),          ...
                                   'VariableNames', {'ID', 'x', 'y', 'z'});
            meshData.panels = int32(M(zeroIdxs(1) + 1:zeroIdxs(2) - 1, :));
            
        end
        
    end
end


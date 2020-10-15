classdef NEMOH < WecOptTool.base.Solver & WecOptTool.base.NEMOH
    % Class for solving meshes using the NEMOH suite.
    %
    % Arguments:
    %     base (string, optional):
    %        Parent for folder which stores NEMOH input and output files,
    %        default is tempdir
    %
    % Attributes:
    %     path (string): path to file storage folder
    %     verb (logical): use verbose console outputs (default false)
    %     rho (double): water density (default = 1025 kg/m\ :sup:`3`)
    %     g (double):
    %         gravitational acceleration (default = 9.81 m/s\ :sup:`2`)
    %
    % --
    %
    % NEMOH Properties:
    %     verb - use verbose console outputs (default false)
    %     rho - water density (default = 1025 kg/m^3)
    %     g - gravitational acceleration (default = 9.81 m/s^2)
    %
    % NEMOH Methods:
    %     getHydro - Calculate floating body hydrodynamic coefficients 
    %                using NEMOH
    %
    % See also WecOptTool.solver
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
    
    properties (Access=private)
        nemoh_mesh_command
        nemoh_preProc_command
        nemoh_run_command
        nemoh_postProc_command
    end
    
    methods
        
        function obj = NEMOH(basePath)
            
            obj = obj@WecOptTool.base.Solver(basePath);
            
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

            WOTDataPath = WecOptTool.system.getUserPath();
            configPath = fullfile(WOTDataPath, 'config.json');
            config = jsondecode(fileread(configPath));
            nemohPath = fullfile(config.nemohPath);

            if ispc
                obj.nemoh_mesh_command = fullfile(nemohPath, 'mesh');
                obj.nemoh_preProc_command = fullfile(nemohPath,     ...
                                                     'preProcessor');
                obj.nemoh_run_command = fullfile(nemohPath, 'solver');
                obj.nemoh_postProc_command = fullfile(nemohPath,    ...
                                                      'postProcessor');
            else
                obj.nemoh_mesh_command = fullfile(nemohPath, 'mesh');
                obj.nemoh_preProc_command = fullfile(nemohPath,     ...
                                                     'preProc');
                obj.nemoh_run_command = fullfile(nemohPath, 'solver');
                obj.nemoh_postProc_command = fullfile(nemohPath,    ...
                                                      'postProc');
            end
            
        end
        
        function hydro = getHydro(obj, meshes, w)
            % Calculate floating body hydrodynamic coefficients using 
            % NEMOH
            %
            % Arguments:
            %   meshes (struct):
            %       The meshes to be solved. Each object in the array
            %       represents a different body with body number given by 
            %       the ``bodyNum`` property. See table below for field
            %       definitions.
            %   w (array of double):
            %       The angular wave frequencies to be calculated.
            %       
            % Returns:
            %    :mat:class:`+WecOptTool.Hydrodynamics`:
            %        Hydrodynamics object
            %
            % **"meshes" Struct Fields**
            %
            % ============  ================  ======================================
            % **Variable**  **Format**        **Description**
            % bodyNum       int32             body number
            % name          char array        name of the mesh
            % nodes         Nx4 table         table of N node positions with columns ID, x, y, z
            % panels        Mx4 int32 array   array of M panels where each row contains the 4 connected node IDs
            % zG            double            z-coordinate of the bodies centre of gravity
            % ============  ================  ======================================
            % 
            % Note:
            %     The original aximesh function was written by A. Babarit, 
            %     LHEEA Lab, and licensed under the Apache License, 
            %     Version 2.0.
            %
            % --
            % 
            % See also WecOptTool.Hydrodynamics, WecOptTool.mesh, WecOptTool.solver
            %
            % --
            
            if length(meshes) == 1
                singleBody = true;
            else
                singleBody = false;
            end
            
            if w(1) < eps
                w = w(2:end);
            end
            
            for imesh = meshes
                obj.makeHydrostatics(imesh, singleBody);
                meshFileName = string(imesh.name) + ".dat";
                meshFilePath = fullfile(obj.path, "mesh", meshFileName);
                obj.writeMeshFile(imesh, meshFilePath)
            end
            
            obj.writeNemohCal(meshes, w)
            
            rundir = obj.path;
            startdir = pwd;
            cd(rundir);
            rundir = '.';
            
            if exist(fullfile(rundir,'input.txt'), 'file') ~= 2
                [fip, errmsg] = fopen(fullfile(rundir,'input.txt'),'w');
                error(errmsg);
                fwrite(fip,'0\n');
                fclose(fip);
            end

            obj.nemohCall(obj.nemoh_preProc_command);
            obj.nemohCall(obj.nemoh_run_command);
            obj.nemohCall(obj.nemoh_postProc_command);

            data = struct();
            data = WecOptTool.vendor.WEC_Sim.Read_NEMOH(data, rundir);
            
            hydro = WecOptTool.Hydrodynamics(data,                  ...
                                             "solverName", "NEMOH", ...
                                             "runDirectory", obj.path);
            
            cd(startdir)

        end
        
    end
    
    methods (Access=private)
       
        function makeHydrostatics(obj, mesh, singleBody)
            % Originally licensed under the Apache License, Version 2.0
            % Written by A. Babarit, LHEEA Lab.
            
            rundir = obj.path;
            startdir = pwd;
            cd(rundir);
            rundir = '.';
            
            mname = mesh.name;
            nx = height(mesh.nodes);
            nf = size(mesh.panels, 1);
            
            if obj.verb
                fprintf('\n --> Number of nodes             : %g',nx);
                fprintf('\n --> Number of panels (max 2000) : %g \n',nf);
            end

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
            fprintf(fid,'%f %f %f \n',[0. 0. mesh.zG]);
            fprintf(fid,'%g \n ', nf);
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
                fprintf(fid,'%E %E %E \n',mesh.nodes{i,{'x','y','z'}});
            end
            for i=1:nf
                fprintf(fid,'%g %g %g %g \n',mesh.panels(i, :));
            end
            status=fclose(fid);

            % Raffinement automatique du maillage et calculs hydrostatiques
            [status,msg] = system([obj.nemoh_mesh_command,  ...
                                   ' >',                    ...
                                   fullfile(rundir,'mesh','mesh.log')]);
            if status
                error(msg)
            else
                if obj.verb
                    fprintf(fileread(fullfile(rundir,'mesh','mesh.log')))
                end
            end
            
            meshpath = @(x) fullfile(rundir, 'mesh', x);

            if ~singleBody
                
                fnhs = meshpath('Hydrostatics.dat');
                fnKh = meshpath('KH.dat');
                fnIn = meshpath('Inertia_hull.dat');
                
                i = mesh.bodyNum - 1;
                hydro = sprintf('Hydrostatics_%i.dat', i);
                kh = sprintf('KH_%i.dat', i);
                ih = sprintf('Inertia_hull_%i.dat', i);
                
                movefile(fnhs, meshpath(hydro))
                movefile(fnKh, meshpath(kh));
                movefile(fnIn, meshpath(ih));
                
            end
            
            % Remove mesh file
            delete(meshpath(sprintf('%s.dat', mname)));
            
            cd(startdir);
            
        end
        
        function writeNemohCal(obj, meshes, w)
            
            nBody = length(meshes);
            filePath = fullfile(obj.path, 'Nemoh.cal');
            fileStrings = obj.getCalHeader(obj.rho, obj.g, nBody);
            
            for i = 1:nBody
                imesh = meshes(i);
                meshFileName = string(imesh.name) + ".dat";
                meshFilePath = fullfile('.','mesh',meshFileName);
                bodyStrings = obj.getCalBody(i,                         ...
                                             meshFilePath,              ...
                                             height(imesh.nodes),       ...
                                             size(imesh.panels, 1),     ...
                                             imesh.zG);
                fileStrings = [fileStrings bodyStrings];
            end
            
            footerString = obj.getCalFooter(w);
            fileStrings = [fileStrings footerString];
            
            fid = fopen(filePath, 'w');
            
            for line = fileStrings
                fprintf(fid, '%s', line);
            end
            
            status=fclose(fid);

        end
        
        function [status, msg] = nemohCall(obj, command)
            if obj.verb
                fprintf('Running Nemoh %s\n',command);
            end
            [status,msg] = system(command);
            if status
                error(msg)
            else
                if obj.verb
                    disp(msg)
                end
            end
        end
        
    end
    
    methods (Static, Access=private)
                
        function writeMeshFile(mesh, path)
            
            fid = fopen(path, 'w');
            fprintf(fid, ' %20i %10i\n', [2, mesh.xzSymmetric]);
            nodefmti = ' %13i';
            nodefmtf = ' %23.7f %23.7f %23.7f\n';
            
            for i = 1:height(mesh.nodes)
                fprintf(fid, nodefmti, mesh.nodes{i, 1});
                fprintf(fid, nodefmtf, mesh.nodes{i, 2:4});
            end
            
            fprintf(fid, ' %13i %13.2f %13.2f %13.2f\n', [0, 0, 0, 0]);
            
            panelfmt = ' %15i %15i %15i %15i\n';
            
            for i = 1:size(mesh.panels, 1)
                fprintf(fid, panelfmt, mesh.panels(i, :));
            end
            
            fprintf(fid, ' %10i %10i %10i %10i\n', [0, 0, 0, 0]);
            
            status = fclose(fid);
            
        end
        
        function headerStrings = getCalHeader(rho, g, nBodies)
            
            p = mfilename('fullpath');
            [filepath, ~, ~] = fileparts(p);
            
            headerStrings = strings(1, 7);
            lineOps = [2 rho; 3 g; 7 nBodies];
            
            fid = fopen(fullfile(filepath, "nemohcalheader.txt"));
            
            for i = 1:7
            
                rawLine = fgets(fid);
                opIdx = find(lineOps(:, 1) == i);
                
                if opIdx
                    fmtLine = sprintf(rawLine, lineOps(opIdx, 2));
                else
                    fmtLine = rawLine;
                end
                    
                headerStrings(i) = fmtLine;
                
            end
            
            status = fclose(fid);
            
        end
        
        function bodyStrings = getCalBody(bodyNum,         ...
                                          meshName,        ...
                                          nNodes,          ...
                                          nPanels,         ...
                                          zG)
                                   
            p = mfilename('fullpath');
            [filepath, ~, ~] = fileparts(p);
            
            bodyStrings = strings(1, 18);
            lineOps = {1 bodyNum;           ...
                       2 meshName;          ...
                       3 [nNodes nPanels];  ...
                       8 zG;                ...
                       9 zG;                ...                       
                       10 zG;               ...
                       15 zG;               ...
                       16 zG;               ...
                       17 zG};
            
            fid = fopen(fullfile(filepath, "nemohcalbody.txt"));
            
            for i = 1:18
            
                rawLine = fgets(fid);
                opIdx = find([lineOps{:, 1}] == i);
                
                if opIdx
                    fmtLine = sprintf(rawLine, lineOps{opIdx, 2});
                else
                    fmtLine = rawLine;
                end
                    
                bodyStrings(i) = fmtLine;
                
            end
            
            status = fclose(fid);
            
        end
        
        function footerStrings = getCalFooter(w)
            
            p = mfilename('fullpath');
            [filepath, ~, ~] = fileparts(p);
            
            footerStrings = strings(1, 8);
            lineOps = {2 [length(w) w(1) w(end)]};
            
            fid = fopen(fullfile(filepath, "nemohcalfooter.txt"));
            
            for i = 1:8
            
                rawLine = fgets(fid);
                opIdx = find([lineOps{:, 1}] == i);
                
                if opIdx
                    fmtLine = sprintf(rawLine, lineOps{opIdx, 2});
                else
                    fmtLine = rawLine;
                end
                    
                footerStrings(i) = fmtLine;
                
            end
            
            status = fclose(fid);
            
        end
            
    end
    
end


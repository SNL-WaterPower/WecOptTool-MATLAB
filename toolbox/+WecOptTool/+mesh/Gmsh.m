classdef Gmsh < WecOptTool.base.Mesher
    % Class for making meshes using the Gmsh finite element mesh generator
    %
    % Arguments:
    %     base (string, optional):
    %        Parent for folder which stores input and output files,
    %        default is tempdir
    %
    % Attributes:
    %     path (string): path to file storage folder
    %
    % --
    %
    % Gmsh Properties:
    %     path - path to file storage folder
    %
    % Gmsh Methods:
    %     makeMesh
    %
    % See also WecOptTool.mesh
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
    
    methods
        
        function meshData = makeMesh(obj, input, names, values)
            % Mesh generation
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
            % xzSymmetric   bool              body is symmetric in xz plane (half mesh)
            % zG            float             z-coordinate of the bodies centre of gravity
            % ============  ================  ======================================
            %
            % --
            % 
            % See also WecOptTool.mesh
            %
            % --
            
            arguments
                obj
                input string
            end
            
            arguments (Repeating)
                names string
                values string
            end
            
            % Throwing error message if Gmsh could not be found.
            gmshExistFlag = WecOptTool.mesh.Gmsh.isGmshInPath();

            if(~ gmshExistFlag)
                errMsg = ['Error: Unable to locate Gmsh executable. ',  ...
                          'It is possible that the Gmsh path has not ', ...
                          'been added to WecOptTool. Make sure that ',  ...
                          'the file path is spelled correctly and ',    ...
                          'has been added to WecOptTool using the ',    ...
                          'installGmsh.m script'];
                error(errMsg);
            end
            
            % Check that the input path is genuine (gmsh doesn't care)
            if ~isfile(input)
                error("WecOptTool:Gmsh:InputFileMissing",   ...
                      "The given input file path does not exist");
            end
            
            % gmsh command line call to set all arguments and generate 
            % matlab format output:
            %
            % $ gmsh flapper_base2.geo -setnumber lc 0.2 ^
            %   -setnumber width 5 -setnumber thick 1 -setnumber height 6 ^
            %   -0 --save_all -o test.m
            
            gmshPath = WecOptTool.system.readConfig('gmshPath');
            exeString = WecOptTool.mesh.Gmsh.getCommand();
            exePath = fullfile(gmshPath, exeString);
            commandString = sprintf('%s %s ', exePath, input);
            
            for i = 1:length(names)
                thisvar = sprintf('-setnumber %s %s ',  ...
                                  names{i},             ...
                                  values{i});
                commandString = [commandString thisvar];
            end
            
            outputPath = fullfile(obj.path, "mesh.m");
            outputString = sprintf('-0 -save_all -o %s', outputPath);
            commandString = [commandString outputString];
            
            disp(commandString)
            
            % Call the command
            [status, msg] = system(commandString);
            
            if status
                error(msg)
            end
        
        end
        
    end
    
    methods (Static)

        function inpath = isGmshInPath()
            % Determine if the Gmsh executable is installed
            %
            % Returns:
            %     bool: true if executable found, otherwise false.
            %
            
            inpath = 1;
            
            try
                 gmshPath = WecOptTool.system.readConfig('gmshPath');
            catch
                inpath = 0;
                return
            end
            
            command = WecOptTool.mesh.Gmsh.getCommand();
            command = command + " --version";
            exeString = fullfile(gmshPath, command);
            [status, ~] = system(exeString);
            
            if status ~= 0
                inpath = 0;
            end
            
        end
        
        function meshData = readMATLABMesh(mFilePath)

            M = dlmread(mFilePath);
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
        
    methods (Static, Access=private)
        
        function command = getCommand()
            
            if ispc
                command = "gmsh.exe";
            else
                command = "gmsh";
            end
            
        end
        
    end
end


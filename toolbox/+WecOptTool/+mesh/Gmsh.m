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
        
        function meshData = makeMesh(obj, geoFile,  ...
                                          bodyNum,  ...
                                          keys,     ...
                                          values,   ...
                                          options)
            % Mesh generation using a Gmsh .geo file
            %
            % Arguments:
            %   geoFile (string): path to input .geo file
            %   bodyNum (int32):
            %       the number of the body (starting from one)
            %   keys (string):
            %       variable name to assign value to in .geo file. This 
            %       argument must be used with the values argument. The
            %       keys and values arguments can be repeated.
            %   values (string):
            %       value to use for given variable name in keys argument. 
            %       This argument must be used with the keys argument. The
            %       keys and values arguments can be repeated.
            %   options: name-value pair options. See below.
            %
            % The following options are supported:
            %
            %    xzSymmetric (logical):
            %        Use to indicate if the mesh should be reflected in the
            %        xOz plane.
            %       
            % Returns:
            %    struct:
            %        A mesh description with fields as described below
            %
            % ============  ================  ======================================
            % **Variable**  **Format**        **Description**
            % bodyNum       int32             body number
            % name          char array        name of the mesh
            % nodes         Nx4 table         table of N node positions with columns ID, x, y, z
            % panels        Mx4 int32 array   array of M panels where each row contains the 4 connected node IDs
            % xzSymmetric   logical           body is symmetric in xz plane (half mesh)
            % ============  ================  ======================================
            %
            % Example:
            %     The following example uses the :mat:func:`+WecOptTool.mesh` 
            %     function as a shortcut to this method.
            %
            %     >>> meshes = WecOptTool.mesh("Gmsh",              ...
            %     ...                          folder,              ...
            %     ...                          "mygeo.geo",         ...
            %     ...                          1,                   ...
            %     ...                          "lc", 0.5,           ... % Passed to geo file
            %     ...                          "length", length,    ... % Passed to geo file
            %     ...                          "width", width,      ... % Passed to geo file
            %     ...                          "height", height,    ... % Passed to geo file
            %     ...                          "xzSymmetric", true);
            %
            % --
            % 
            % See also WecOptTool.mesh
            %
            % --
            
            arguments
                obj
                geoFile (1, 1) string
                bodyNum (1, 1) int32
            end
            
            arguments (Repeating)
                keys (1, 1) string
                values (1, 1) string
            end
            
            arguments
                options.xzSymmetric (1,1) logical = false
            end
            
            % Throwing error message if Gmsh could not be found.
            gmshExistFlag = obj.isGmshInPath();

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
            if ~isfile(geoFile)
                error("WecOptTool:Gmsh:InputFileMissing",   ...
                      "The given geo file path does not exist");
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
            commandString = sprintf('%s %s ', exePath, geoFile);
            
            for i = 1:length(keys)
                thisvar = sprintf('-setnumber %s %s ',  ...
                                  keys{i},             ...
                                  values{i});
                commandString = [commandString thisvar];
            end
            
            meshName = sprintf('gmsh_%i', bodyNum);
            meshFileName = sprintf('%s.m', meshName);
            
            outputPath = fullfile(obj.path, meshFileName);
            outputString = sprintf('-0 -save_all -o %s', outputPath);
            commandString = [commandString outputString];
            
            %disp(commandString)
            
            % Call the command
            [status, msg] = system(commandString);
            
            if status
                error(msg)
            end
            
            % load up the mesh
            mFilePath = fullfile(obj.path, meshFileName);
            meshData = obj.readMATLABMesh(mFilePath);
            
            % Add additional info
            meshData.bodyNum = bodyNum;
            meshData.name = meshName;
            meshData.xzSymmetric = options.xzSymmetric;
        
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
        
        function meshData = readMATLABMesh(mFilePath, options)
            % Load a matlab mesh file exported by Gmsh
            %
            % Arguments:
            %   mFilePath (string): path to input .m file
            %   options: name-value pair options. See below.
            %
            % The following options can be used to define the mesh
            % metadata:
            %
            %    bodyNum (int32):
            %        the bodynumber
            %    meshName (string):
            %        the name of the mesh
            %    xzSymmetric (logical):
            %        true if the body is symmetric in xz plane
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
            % xzSymmetric   logical           body is symmetric in xz plane (half mesh)
            % ============  ================  ======================================
            %
            
            arguments
                mFilePath (1, 1) string
                options.bodyNum (1, 1) int32 = 0
                options.meshName (1, 1) string = "gmsh_0";
                options.xzSymmetric (1, 1) logical = false;
            end
            
            % Adds msh to the function workspace
            run(mFilePath);
            
            meshData.xzSymmetric = false;
            indexes = 1:size(msh.POS, 1);
            meshData.nodes = table(indexes',        ...
                                   msh.POS(:,1),    ...
                                   msh.POS(:,2),    ...
                                   msh.POS(:,3),    ...
                                   'VariableNames', {'ID', 'x', 'y', 'z'});
            
            panels = [];
            
            % Triangle panels
            if isfield(msh, "TRIANGLES")
                tripanels = msh.TRIANGLES(:, 1:3);
                tripanels(:, 4) = tripanels(:, 1);
                panels = [panels; tripanels];
            end
            
            % Quad panels
            if isfield(msh, "QUADS")
                panels = [panels; msh.QUADS(:, 1:4)];
            end
            
            meshData.panels = panels;
            
            % Add metadata
            meshData.bodyNum = options.bodyNum;
            meshData.meshName = options.meshName;
            meshData.xzSymmetric = options.xzSymmetric;
            
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


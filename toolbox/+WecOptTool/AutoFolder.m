classdef AutoFolder < WecOptTool.base.TempFolder
    % Class that creates unique temporary folders, which are deleted 
    % upon object destruction.
    %
    % Attributes:
    %     path (string): path to unique folder for storage
    %
    % --
    % 
    % AutoFolder Methods:
    %     stashVar - store a variable for recovery later
    %     recoverVar - retrieve stashed variable
    %     archive - Save the folder and contents
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
    
    properties (Access = protected)
        varsPath
    end
    
    methods
        
        function obj = AutoFolder()
            
            obj = obj@WecOptTool.base.TempFolder();
            obj.varsPath = tempname;
            obj.mkdirSafe(obj.varsPath);
            
        end
        
        function stashVar(obj, variable)
            % Store a variable for recovery later.
            %
            % Arguments:
            %   variable: variable to store
            %
            % Note:
            %   A new stash is created every time a variable is stored,
            %   so multiple values may be returned by 
            %   :mat:meth:`.recoverVar`
            %
            
            arguments
                obj
                variable {mustBeNonempty}
            end
            
            resultsFolder = tempname(obj.varsPath);
            mkdir(resultsFolder);
            etcPath = fullfile(resultsFolder, inputname(2) + ".mat");
            save(etcPath, "variable");
            
        end
        
        function result = recoverVar(obj, variableName)
            % Recover stashed variable
            %
            % Arguments:
            %   variableName (string): variable to recover
            %
            % Returns:
            %   cell array:
            %       cell array containing all stored version of given
            %       variable name
            %
            
            arguments
                obj
                variableName string {mustBeNonempty}
            end
            
            pDirs = WecOptTool.system.getFolders(obj.varsPath,  ...
                                                 "absPath", true);
            nDirs = length(pDirs);
            result = {};

            for i = 1:nDirs
                dir = pDirs{i};
                fileName = fullfile(dir, variableName + ".mat");
                if isfile(fileName)
                    result = [result, {load(fileName).variable}];
                end
            end
            
        end
        
        function archive(obj, targetPath)
            % Save the folder and contents
            %
            % Args:
            %     targetPath (string): Path to destination folder
            %
            % Note:
            %   If there are no files to copy this function will not
            %   make the destination folder
            %
            
            arguments
                obj
                targetPath string
            end
            
            if length(dir(obj.path)) == 2
                return
            end
            
            copyfile(obj.path, targetPath);
            
        end
        
    end
    
    methods (Access = protected)
                
        function obj = rmFolders(obj)
            if isfolder(obj.path)
                WecOptTool.system.rmdirRetry(obj.path);
            end
            if isfolder(obj.varsPath)
                WecOptTool.system.rmdirRetry(obj.varsPath);
            end
        end
                
        function delete(obj)
            if ~WecOptTool.system.isParallel()
                obj.rmFolders();
            end
        end
        
    end
       
end


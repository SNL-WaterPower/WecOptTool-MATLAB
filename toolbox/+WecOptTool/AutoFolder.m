classdef AutoFolder < handle
    % Class that creates a unique temporary folder.
    %
    % The folder may either be orphaned and will be deleted upon deletion 
    % of the container object or it may be a child of a given base folder, 
    % in which case deletion of the folder is the responsibility of the
    % parent.
    %
    % Arguments:
    %     base (optional string): path of the parent folder.
    %
    % Attributes:
    %     path (string): path to unique folder
    %
    % --
    % 
    % AutoFolder Methods:
    %     saveFolder - Save the folder and contents
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
    
    properties
        path
    end
    
    properties (Access = private)
        autoRemoveFolder = true
    end
    
    methods
        
        function obj = AutoFolder(base)
            
            if nargin > 0 && isempty(base)
                obj.autoRemoveFolder = false;
                return
            end
            
            args = {};
            
            if nargin > 0
                args{1} = base;
                obj.autoRemoveFolder = false;
            end
                
            obj.makeFolder(args{:});
            
        end
        
        function saveFolder(obj, targetPath)
            % Save the folder and contents
            %
            % Args:
            %     targetPath (string): Path to destination folder
            %
            % Note:
            %   If there are no files to copy this function will not
            %   make the destination folder
            %
            
            if length(dir(obj.path)) == 2
                return
            end
            
            copyfile(obj.path, targetPath);
            
        end
        
    end
    
    methods (Access=protected)
        
        function obj = makeFolder(obj, base)
            
            if obj.path
                errStr = "folder is already defined";
                error('WecOptTool:AutoFolder:FolderDefined', errStr)
            end
            
            % Try to ensure folder is unique and reserved
            if nargin > 1
                obj.path = tempname(base);
            else
                obj.path = tempname;
            end
            
            [status, ~, message] = mkdir(obj.path);
            
            if ~status || strcmp(message, 'MATLAB:MKDIR:DirectoryExists')
                errStr = "Failed to create unique folder";
                error('WecOptTool:AutoFolder:NoUniqueFolder', errStr)
            end
            
        end
        
        function obj = rmFolder(obj)
            if isfolder(obj.path)
                WecOptTool.system.rmdirRetry(obj.path);
            end
        end
                
        function delete(obj)
            if obj.autoRemoveFolder && ~WecOptTool.system.isParallel()
                obj.rmFolder();
            end
        end
        
    end
    
end


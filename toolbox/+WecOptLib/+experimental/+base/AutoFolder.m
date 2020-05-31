classdef AutoFolder < handle
    
    properties
        folder
    end
    
    properties (Access = private)
        autoRemoveFolder = true
    end
    
    methods
        
        function obj = AutoFolder(base)
            
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
            
            if length(dir(obj.folder)) == 2
                return
            end
            
            copyfile(obj.folder, targetPath);
            
        end
        
    end
    
    methods (Access=protected)
        
        function obj = makeFolder(obj, base)
            
            if obj.folder
                errStr = "folder is already defined";
                error('WecOptTool:AutoFolder:FolderDefined', errStr)
            end
            
            % Try to ensure folder is unique and reserved
            if nargin > 1
                obj.folder = tempname(base);
            else
                obj.folder = tempname;
            end
            
            [status, ~, message] = mkdir(obj.folder);
            
            if ~status || strcmp(message, 'MATLAB:MKDIR:DirectoryExists')
                errStr = "Failed to create unique folder";
                error('WecOptTool:AutoFolder:NoUniqueFolder', errStr)
            end
            
        end
        
        function obj = rmFolder(obj)
            if isfolder(obj.folder)
                WecOptLib.utils.rmdirRetry(obj.folder);
            end
        end
                
        function delete(obj)
            if obj.autoRemoveFolder && ~WecOptLib.utils.isParallel()
                obj.rmFolder();
            end
        end
        
    end
    
end


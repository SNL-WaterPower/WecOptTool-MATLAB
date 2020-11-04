function folderNames = getFolders(baseFolder, varargin)
    % Returns folder names found at a given folder path (excludes '.' 
    % and '..')
    %
    % Args:
    %   baseFolder (character vector | string scalar):
    %     folder path used for search
    %   varargin: name-value pair options. See below.
    %
    % The following options are supported:
    %
    %   absPath (logical):
    %     If true, the absolute path to the folders is returned. Defaults
    %     to false.
    %
    % Returns:
    %   cell array: Discovered folder names
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
    
    p = inputParser;
    
    defaultAbsPath = false;
    validCharString = @(x) ischar(x) | isstring(x);
    
    addRequired(p, 'baseFolder', validCharString);
    addParameter(p, 'absPath', defaultAbsPath, @islogical);
    
    parse(p, baseFolder, varargin{:});
   
    validBaseFolder = p.Results.baseFolder; 
    
    if ~isfolder(validBaseFolder)
        folderNames = {};
        return
    end
    
    d = dir(validBaseFolder);
    dfolders = d([d(:).isdir] == 1);
    dfolders = dfolders(~ismember({dfolders(:).name}, {'.', '..'}));
    
    relativeFolderNames = {dfolders(:).name};
    
    if ~p.Results.absPath
        folderNames = relativeFolderNames;
        return
    end
    
    folderNames = cell(1, length(relativeFolderNames));
    
    for i = 1:length(relativeFolderNames)
        folderNames{i} = fullfile(validBaseFolder, relativeFolderNames{i});
    end
    
end

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

function value = readConfig(key, varargin)
%READCONFIG Read the value for the given key in the config file

    % Default directory for config
    WOTDataPath = WecOptTool.system.getUserPath();

    p = inputParser;
    validText = @(x) isstring(x) || ischar(x);
    addRequired(p, 'key', validText);
    addParameter(p, 'configDir', WOTDataPath, validText);
    parse(p, key, varargin{:});
    
    if ~exist(p.Results.configDir, 'dir')
        errStr = "Config directory '" + p.Results.configDir +   ...
                 "' does not exist";
        errStr = strrep(errStr, '\', '\\');
        error('WecOptTool:readConfig:missingDirectory', errStr)
    end
    
    configPath = fullfile(p.Results.configDir, 'config.json');
    
    if ~exist(configPath, 'file')
        errStr = "Config file 'config.json' does not exist";
        error('WecOptTool:readConfig:missingFile', errStr)
    end
    
    config = jsondecode(fileread(configPath));
    
    if ~isfield(config, p.Results.key)
        errStr = "Config file does contain key: " +  p.Results.key;
        error('WecOptTool:readConfig:missingKey', errStr)
    end
    
    value = config.(p.Results.key);
    
end


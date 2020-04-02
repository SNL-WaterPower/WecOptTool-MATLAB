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

function writeConfig(key, value, varargin)
%WRITECONFIG Add given key with given value to config file
    
    % Default directory for config
    WOTDataPath = WecOptLib.utils.getUserPath();

    p = inputParser;
    validText = @(x) isstring(x) || ischar(x);
    addRequired(p, 'key', validText);
    addRequired(p, 'value');
    addParameter(p, 'configDir', WOTDataPath, validText);
    parse(p, key, value, varargin{:});

    % Check if the user data directory exists and make if necessary
    if ~exist(p.Results.configDir, 'dir')
       mkdir(p.Results.configDir)
    end
    
    % Check if the config file exists and read
    configPath = fullfile(p.Results.configDir, 'config.json');
    
    if exist(configPath, 'file')
        config = jsondecode(fileread(configPath));
    else
        config = struct(char(p.Results.key), p.Results.value);
    end
    
    if strcmp(p.Results.value, "")
        config = rmfield(config, p.Results.key);
    else
        config.(p.Results.key) = p.Results.value;
    end
    
    % Convert to JSON text and save
    jsonConfig = jsonencode(config);
    fid = fopen(configPath, 'w');
    fprintf(fid, '%s', jsonConfig);
    fclose(fid);
    
end


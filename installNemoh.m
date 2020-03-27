
% Copyright 2020 Sandia National Labs
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
%     along with Foobar.  If not, see <https://www.gnu.org/licenses/>.

function installNemoh(nemohPath)
%INSTALLNEMOH Add Nemoh executables path to WecOptTool
    
    % Check if the user data directory exists and make if necessary
    WOTDataPath = WecOptLib.utils.getUserPath();
    
    if ~exist(WOTDataPath, 'dir')
       mkdir(WOTDataPath)
    end
    
    % Check if the config file exists and read
    configPath = [WOTDataPath filesep 'config.json'];
    
    if exist(configPath, 'file')
        config = jsondecode(fileread(configPath));
        config.nemohPath = nemohPath;
    else
        config = struct('nemohPath', nemohPath);
    end
    
    % Convert to JSON text and save
    jsonConfig = jsonencode(config);
    fid = fopen(configPath, 'w');
    fprintf(fid, '%s', jsonConfig);
    fclose(fid);

end


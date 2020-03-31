
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

function installNemoh(nemohPath)
%INSTALLNEMOH Add Nemoh executables path to WecOptTool
    
    % Check if the a current path is set
    try
        oldNemohPath = WecOptLib.utils.readConfig('nemohPath');
    catch
        oldNemohPath = "";
    end
    
    % Update the config file
    WecOptLib.utils.writeConfig('nemohPath', nemohPath)
    
    % Check installation
    nemohTestPath = fullfile(tempdir, "nemoh_installCheck");

    if ~exist(nemohTestPath, 'dir')
        mkdir(nemohTestPath)
    end

    nemohExistFlag = WecOptLib.nemoh.isNemohInPath(nemohTestPath);

    if nemohExistFlag
        
        fprintf('Successfully Installed Nemoh\n');
        
    else
        
        msg = ['Nemoh not found. Please check the specified path ' ...
               'and try again. \n'];
        fprintf(msg);
        
        % Revert back to the old config
        WecOptLib.utils.writeConfig('nemohPath', oldNemohPath)
        
    end

end


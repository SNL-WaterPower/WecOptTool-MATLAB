function installExternal(name, key, path, validation)
    % Add an external program path to WecOptTool
    %
    % Args:
    %     name (string):
    %         name of the program to be installed
    %     key (string):
    %         key to store the executable path in the 
    %     path (string):
    %         path to external program
    %     validation (function handle):
    %         callback to validate installation. Should return true if
    %         installed.
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
    
    arguments
        name
        key
        path
        validation = []
    end
    
    % Check if the a current path is set
    try
        oldPath = WecOptTool.system.readConfig(key);
    catch
        oldPath = "";
    end
    
    % Update the config file
    WecOptTool.system.writeConfig(key, path)
        
    if isempty(validation)
        return
    end
    
    % Check installation
    progExistFlag = validation();

    if progExistFlag
        
        fprintf('Successfully installed %s\n', name);
        
    else
        
        msg = ['%s not found. Please check the specified path ' ...
               'and try again.\n'];
        fprintf(msg, name);
        
        % Revert back to the old config
        WecOptTool.system.writeConfig(key, oldPath)
        
    end

end


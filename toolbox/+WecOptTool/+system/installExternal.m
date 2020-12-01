function installExternal(name, key, path, validation, options)
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
    %     options: name-value pair options. See below.
    %
    % The following options are supported:
    %
    %   configDir (string): Alternative path for config directory
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
        name (1, 1) string
        key (1, 1) string
        path (1, 1) string
        validation {WecOptTool.validation.mustBeFunctionHandle} = []
        options.configDir (1, 1) string
    end
    
    % Get the config path
    if isfield(options, "configDir")
        configDir = options.configDir;
    else
        configDir = WecOptTool.system.getUserPath();
    end
    
    if isempty(validation)
        WecOptTool.system.writeConfig(key, path, 'configDir', configDir);
        return
    end
    
    % Check installation
    progExistFlag = validation();
    
    if progExistFlag
        
        WecOptTool.system.writeConfig(key, path, 'configDir', configDir);
        fprintf('Successfully installed %s\n', name);
        
    else
        
        msg = ['%s not found. Please check the specified path ' ...
               'and try again.\n'];
        fprintf(msg, name);
        
    end

end


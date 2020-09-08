function [combined, licensed, installed] = hasToolbox(licenseName,  ...
                                                      installedName)
    % Check if an extension toolbox is installed
    %
    % Arguments:
    %     licenseName (string):
    %         the licence name (normally with underscores)
    %     installedName (string):
    %         the toolbox name (as given by the ver command)
    %
    % Returns:
    %     (): outputs are:
    %     
    %         combined (bool): true if toolbox is licensed and installed
    %         licensed (bool): true is toolbox is licensed
    %         installed (bool): true is toolbox is installed
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

    licensed = logical(license('test', licenseName));
    
    installedProducts = ver;
    installedNames = {installedProducts(:).Name};
    installed = false;

    for name = installedNames
        if contains(name, installedName)
            installed = true;
            break
        end
    end

    combined = licensed && installed;
    
end


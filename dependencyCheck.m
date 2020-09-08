function dependencyCheck()
    % Check that all dependencies are licensed and installed
    
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
    
    import WecOptTool.system.hasToolbox
    
    allfoundflag = true;
    
    fprintf('\nWecOptTool Dependency Checker\n');
    fprintf('-------------------------------\n');
    
    %% Required Products
    
    fprintf('\n');
    fprintf('Required\n');
    fprintf('--------\n');
    
    %% Optimisation Toolbox
    
    [optimBoxFound,     ...
     optimBoxLicensed,  ...
     optimBoxInstalled] = hasToolbox("Optimization_Toolbox",    ...
                                     "Optimization Toolbox");
    
    print_dependency("Optimization Toolbox",    ...
                     optimBoxInstalled,         ...
                     optimBoxLicensed);
    
    allfoundflag = allfoundflag && optimBoxFound;
    
    %% Nemoh
    
    nemohExistFlag = WecOptTool.base.NEMOH.isNemohInPath();
    print_dependency("NEMOH", nemohExistFlag);
    
    %% Optional Products
    
    fprintf('\n');
    fprintf('Optional\n');
    fprintf('--------\n');
    
    %% Parallel Computing Toolbox
    
    [~,                     ...
     parallelBoxLicensed,   ...
     parallelBoxInstalled] = hasToolbox("Distrib_Computing_Toolbox",    ...
                                        "Parallel Computing Toolbox");
    
    print_dependency("Parallel Toolbox",    ...
                     parallelBoxInstalled,  ...
                     parallelBoxLicensed);
    
    %% Global Optimization Toolbox
    
    [~,                     ...
     globOptBoxLicensed,    ...
     globOptBoxInstalled] = hasToolbox("GADS_Toolbox",  ...
                                       "Global Optimization Toolbox");
    
    print_dependency("Global Optimization Toolbox",    ...
                     globOptBoxInstalled,  ...
                     globOptBoxLicensed);
    
    %% WAFO
    
    wafoFunction = 'bretschneider';
    wafoPath = fullfile('wafo', 'spec','bretschneider.m');
    
    wafoCheck = lower(which(wafoFunction));
    wafoInstalled = contains(wafoCheck, wafoPath) &&    ...
                        (exist(wafoCheck, 'file') == 2);
    
    print_dependency("WAFO", wafoInstalled);
    
    %% End matter
    
    fprintf('\n')
    
    % Warn if execution not possible
    if ~allfoundflag
        warning("Mandatory dependencies are missing!")
    end
    
end

function print_dependency(name, installed, licensed, options)

    arguments
        name
        installed
        licensed = true
        options.columns = 45
    end
    
    name = name + ":";

    if licensed && installed
        nChars = options.columns - 6;
        fprintf('%-*s Found\n', nChars, name);
    elseif ~licensed && installed
        nChars = options.columns - 11;
        fprintf('%-*s Unlicensed\n', nChars, name);
    else
        nChars = options.columns - 14;
        fprintf('%-*s Not Installed\n', nChars, name);
    end
    
end

classdef NEMOH < handle
    % Base class containing NEMOH helpers
    %
    % Attributes:
    %    verb (bool): use verbose console outputs (default false)
    %    rho (float): water density (default = 1025 kg/m\ :sup:`3`)
    %    g (float):
    %        gravitational acceleration (default = 9.81 m/s\ :sup:`2`)
    %
    % --
    %
    % NEMOH Properties:
    %     verb - use verbose console outputs (default false)
    %     rho - water density (default = 1025 kg/m^3)
    %     g - gravitational acceleration (default = 9.81 m/s^2)
    %
    % NEMOH Methods:
    %     isNemohInPath - Determine if the NEMOH executables can be found.
    %
    % See also WecOptTool.mesh.AxiMesh, WecOptTool.solver.NEMOH
    %
    % --
    
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
    
    properties
        verb = false
        rho = 1025
        g = 9.81
    end
    
    methods (Static)

        function inpath = isNemohInPath()
            % Determine if the NEMOH executables can be found.
            %
            % Returns:
            %     logical: true if executables found, otherwise false.
            %
            
            startdir = pwd;
            inpath = 1;
            
            try
                 nemohPath = WecOptTool.system.readConfig('nemohPath');
            catch
                inpath = 0;
                cd(startdir);
                return
            end

            rundir = tempname;
            [status, ~, message] = mkdir(rundir);

            if ~status || strcmp(message, 'MATLAB:MKDIR:DirectoryExists')
                errStr = "Failed to create unique folder";
                error('WecOptTool:AutoFolder:NoUniqueFolder', errStr)
            end

            cd(rundir);

            windows_exes = ["Mesh", "postProcessor", "preProcessor", "Solver"];
            unix_exes = ["mesh", "postProc", "preProc", "solver"];

            if ispc

                for exe = windows_exes

                    exePath = fullfile(nemohPath, exe);
                    [status, result] = system(exePath);

                    if ~(status == 0 || contains(result, 'ID.dat'))
                        inpath = 0;
                        cd(startdir);
                        return
                    end

                end

            else

                for exe = unix_exes

                    exePath = fullfile(nemohPath, exe);
                    [status, result] = system(exePath);

                    if ~(status == 0 || contains(result, 'ID.dat'))
                        inpath = 0;
                        cd(startdir);
                        return
                    end

                end

            end

            cd(startdir);
            WecOptTool.system.rmdirRetry(rundir);
            
        end
        
    end

end

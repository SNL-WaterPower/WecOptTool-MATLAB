
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

function inpath = isNemohInPath(rundir)
    
    startdir = pwd;
    inpath = 1;

    if ~exist(rundir, 'dir')
        inpath = 0;
        return
    end

    WOTDataPath = WecOptLib.utils.getUserPath();
    
    if ~exist(WOTDataPath, 'dir')
        inpath = 0;
        return
    end
    
    configPath = fullfile(WOTDataPath, 'config.json');
    
    if ~exist(configPath, 'file')
        inpath = 0;
        return
    end
    
    config = jsondecode(fileread(configPath));
    
    if ~isfield(config,'nemohPath')
        inpath = 0;
        return
    end
    
    nemohPath = fullfile(config.nemohPath);
    cd(rundir);
    
    windows_exes = ["Mesh", "postProcessor", "preProcessor", "Solver"];
    unix_exes = ["mesh", "postProc", "preProc", "solver"];
    
    if ispc
        
        for exe = windows_exes
            
            exePath = fullfile(nemohPath, exe);
            [status, result] = system(exePath);
            
            if ~(status == 0 || contains(result, 'ID.dat'))
                inpath = 0;
                return
            end
            
        end
        
    else
        
        for exe = unix_exes
            
            exePath = fullfile(nemohPath, exe);
            [status, result] = system(exePath);
            
            if ~(status == 0 || contains(result, 'ID.dat'))
                inpath = 0;
                return
            end
        
        end
        
    end
    
    cd(startdir);

end

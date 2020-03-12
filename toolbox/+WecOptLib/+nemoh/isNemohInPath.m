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
    
    configPath = [WOTDataPath filesep 'config.json'];
    
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
            
            exePath = strcat(nemohPath, filesep, exe);
            [status, result] = system(exePath);
            
            if ~(status == 0 || contains(result, 'ID.dat'))
                inpath = 0;
                return
            end
            
        end
        
    else
        
        for exe = unix_exes
            
            exePath = strcat(nemohPath, filesep, exe);
            [status, result] = system(exePath);
            
            if ~(status == 0 || contains(result, 'ID.dat'))
                inpath = 0;
                return
            end
        
        end
        
    end
    
    cd(startdir);

end

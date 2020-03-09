function inpath = isNemohInPath(rundir)
    
    startdir = pwd;
    cd(rundir);
    
    inpath = 1;
    
    windows_exes = ["Mesh", "postProcessor", "preProcessor", "Solver"];
    unix_exes = ["mesh", "postProc", "preProc", "solver"];
    
    if ispc
        
        for exe = windows_exes
            
            [status, result] = system(exe);
            
            if ~(status == 0 || contains(result, 'ID.dat'))
                inpath = 0;
                return
            end
            
        end
        
    else
        
        for exe = unix_exes
            
            [status, result] = system(exe);
            
            if ~(status == 0 || contains(result, 'ID.dat'))
                inpath = 0;
                return
            end
        
        end
        
    end
    
    cd(startdir);

end

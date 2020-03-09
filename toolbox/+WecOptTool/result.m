function result(study)
    
    % In the future, this code could be embedded in the geometry
    % classes themselves
    
    disp('Optimal solution is:')
    
    if strcmp(study.geomMode, 'parametric')
        
        %  r1 - Floar radius [m]
        %  r2 - Reaction plate radius [m]
        %  d1 - Float Draft [m]
        %  d2 - Reaction Plate depth [m]
        
        sol = study.out{1};
        
        disp("    r1: " + sol(1) + " [m]");
        disp("    r2: " + sol(2) + " [m]");
        disp("    d1: " + sol(3) + " [m]");
        disp("    d2: " + sol(4) + " [m]");
        
    elseif strcmp(study.geomMode, 'scalar')
        
        sol = study.out{1};
        disp("    lambda " + sol(1));
    
    end
    
    disp('')
    
    
    if strcmp(study.geomMode, 'parametric') || ...
       strcmp(study.geomMode, 'scalar')
   
        fval = study.out{2};
        
    elseif strcmp(study.geomMode, 'existing')
        
        fval = study.out{1};
        
    end
    
    disp("Optimal function value is: " + (-fval) + " [W]")
    
end

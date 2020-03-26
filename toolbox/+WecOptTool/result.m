function result(study)
    
    % In the future, this code could be embedded in the geometry
    % classes themselves
    
    disp('Optimal solution is:')
    
    if strcmp(study.geomMode, 'parametric')
        
        %  r1 - Floar radius [m]
        %  r2 - Reaction plate radius [m]
        %  d1 - Float Draft [m]
        %  d2 - Reaction Plate depth [m]
        
        disp("    r1: " + study.out.sol(1) + " [m]");
        disp("    r2: " + study.out.sol(2) + " [m]");
        disp("    d1: " + study.out.sol(3) + " [m]");
        disp("    d2: " + study.out.sol(4) + " [m]");
        
    elseif strcmp(study.geomMode, 'scalar')
        
        disp("    lambda " + study.out.sol(1));
    
    end
    
    disp('')
    disp("Optimal function value is: "...
        + (-study.out.fval) + " [W]")
    
end

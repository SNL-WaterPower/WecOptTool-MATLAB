function c = bisection(f, a, b, options)
    % Bisection method
    %
    % Args:
    %   f real valued function
    %   a,b interval boundaries (float) with the property f(a) * f(b) <= 0
    %   tol tolerance (float)
    %   nmax maximum number of operations
    
    arguments
        f {WecOptLib.validation.mustBeFunctionHandle};
        a {mustBeNumeric, mustBeFinite};
        b {mustBeNumeric, mustBeFinite, mustBeGreaterThan(b, a)};
        options.tol {mustBeNumeric,     ...
                     mustBePositive,    ...
                     mustBeFinite,      ...
                     mustBeNonzero} = 1e-10;
        options.nmax  {mustBeInteger,   ...
                       mustBePositive,  ...
                       mustBeFinite,    ...
                       mustBeNonzero} = 1000;
    end
    
    if f(a) * f(b) > 0
        eID = "WecOptLib:bisection:badInterval";
        error(eID, "Incorrect initial interval [a, b]")
    end

    n = 1;
    
    while n < options.nmax
        
        c = (a + b) / 2;
        
        if abs(f(c)) < options.tol
            return
        elseif (b - a) / 2 < eps
            eID = "WecOptLib:bisection:searchSpaceClosed";
            error(eID, 'Search space closed before finding a solution')
        end
        
        n = n + 1;
        
        if sign(f(c)) == sign(f(a))
            a = c;
        else
            b = c;
        end
        
    end
    
    eID = "WecOptLib:bisection:tooManyIterations";
    error(eID, 'Number of iterations exceeded')
    
end

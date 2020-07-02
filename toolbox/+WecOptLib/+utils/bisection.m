function c = bisection(f, a, b, tol, nmax)
    %BISECTION Summary of this function goes here
    %   Detailed explanation goes here
    
    arguments
        f {WecOptLib.validation.mustBeFunctionHandle};
        a {mustBeNumeric, mustBeFinite};
        b {mustBeNumeric, mustBeFinite, mustBeGreaterThan(b, a)};
        tol {mustBeNumeric,     ...
             mustBePositive,    ...
             mustBeFinite,      ...
             mustBeNonzero} = eps;
         nmax  {mustBeInteger,     ...
                mustBePositive,    ...
                mustBeFinite,      ...
                mustBeNonzero} = 1000;
    end

    n = 1;
    
    while n < nmax
        
        c = (a + b) / 2;
        
        if abs(f(c)) < eps
            return
        elseif (b - a) / 2 < tol
            error('Search space closed before finding a solution')
        end
        
        n = n + 1;
        
        if sign(f(c)) == sign(f(a))
            a = c;
        else
            b = c;
        end
        
    end
    
    error('Number of iterations exceeded')
    
end

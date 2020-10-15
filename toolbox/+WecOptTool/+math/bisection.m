function c = bisection(f, a, b, options)
    % Bisection method
    %
    % Args:
    %   f (double): real valued function
    %   a (double): search space lower boundary
    %   b (double): search space upper boundary
    %   tol (optional, double): solution tolerance, default = 1e-10
    %   nmax (optional, int): maximum number of operations, default = 1e4
    %
    % Returns:
    %   double: root of f
    %
    % Note:
    %     The given interval boundaries must satisfy f(a) * f(b) <= 0
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
    
    arguments
        f {WecOptTool.validation.mustBeFunctionHandle};
        a {mustBeNumeric, mustBeFinite};
        b {mustBeNumeric, mustBeFinite, mustBeGreaterThan(b, a)};
        options.tol {mustBeNumeric,     ...
                     mustBePositive,    ...
                     mustBeFinite,      ...
                     mustBeNonzero} = 1e-10;
        options.nmax  {mustBeInteger,   ...
                       mustBePositive,  ...
                       mustBeFinite,    ...
                       mustBeNonzero} = 1e4;
    end
    
    if f(a) * f(b) > 0
        eID = "WecOptTool:bisection:badInterval";
        error(eID, "Incorrect initial interval [a, b]")
    end

    n = 1;
    
    while n < options.nmax
        
        c = (a + b) / 2;
        
        if abs(f(c)) < options.tol
            return
        elseif (b - a) / 2 < eps
            eID = "WecOptTool:bisection:searchSpaceClosed";
            error(eID, 'Search space closed before finding a solution')
        end
        
        n = n + 1;
        
        if sign(f(c)) == sign(f(a))
            a = c;
        else
            b = c;
        end
        
    end
    
    eID = "WecOptTool:bisection:tooManyIterations";
    error(eID, 'Number of iterations exceeded')
    
end

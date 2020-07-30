function tests = bisectionTest()
   tests = functiontests(localfunctions);
end

function testIdentity(testCase)

    import matlab.unittest.constraints.IsEqualTo
    import matlab.unittest.constraints.AbsoluteTolerance

    f = @(x) x;
    result = WecOptLib.utils.bisection(f, -1, 1);
    
    testCase.assertThat(result,     ...
                        IsEqualTo(0, 'Within', AbsoluteTolerance(1e-10)))
    
end

function testParabola(testCase)

    import matlab.unittest.constraints.IsEqualTo
    import matlab.unittest.constraints.AbsoluteTolerance

    f = @(x) x^2 - 1;
    result = WecOptLib.utils.bisection(f, 0, 10);
    
    testCase.assertThat(result,     ...
                        IsEqualTo(1, 'Within', AbsoluteTolerance(1e-10)))
    
end

function testBadInterval(testCase)

    f = @(x) x;
    eID = "WecOptLib:bisection:badInterval";
    verifyError(testCase,                                   ...
                @() WecOptLib.utils.bisection(f, 0.5, 1),   ...
                eID)
            
end

function testSearchSpaceClosed(testCase)

    function f = step(x)
        if x > 0
            f = 1;
        else
            f = -1;
        end
    end
        
    eID = "WecOptLib:bisection:searchSpaceClosed";
    verifyError(testCase,                                       ...
                @() WecOptLib.utils.bisection(@step, -1, 1),    ...
                eID)
            
end

function testTooManyIterations(testCase)

    function f = step(x)
        if x > 0
            f = 1;
        else
            f = -1;
        end
    end
        
    eID = "WecOptLib:bisection:tooManyIterations";
    verifyError(testCase,                                       ...
                @() WecOptLib.utils.bisection(@step, -1, 1,     ...
                                              "nmax", 2),       ...
                eID)
            
end

% Copyright 2020 National Technology & Engineering Solutions of Sandia, 
% LLC (NTESS). Under the terms of Contract DE-NA0003525 with NTESS, the 
% U.S. Government retains certain rights in this software.
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
%     along with WecOptTool.  If not, see <https://www.gnu.org/licenses/>.

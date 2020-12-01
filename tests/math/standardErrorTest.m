function tests = standardErrorTest()
   tests = functiontests(localfunctions);
end

function testMeasureSum(testCase)
    
    f = @() randn(5, 1) + 1;
    n_tests = 1000;
    test = boolean(zeros(n_tests, 1));
    
    for i = 1:n_tests
        
        [results, stdError] = WecOptTool.math.standardError(    ...
                                                    'measure', f, 5, 5);
        
        % Check that the expected value is within 99% interval
        actual = sum(mean(results));
        expected = 5;
        test(i) = (actual - 2.58 * stdError < expected) &&    ...
                  (expected < actual + 2.58 * stdError);
        
    end
    
    assertTrue(testCase, all(test))
    
end

function testMeasureMax(testCase)
    
    f = @() randn(5, 1) + 1;
    n_tests = 1000;
    testi = boolean(zeros(n_tests, 1));
    
    for i = 1:n_tests
        
        [results, stdError] = WecOptTool.math.standardError(        ...
                                                        'measure',  ...
                                                        f,          ...
                                                        5,          ...
                                                        5,          ...
                                                        'metric', 'max');
        
        % Check that the expected value is within 99% interval
        actual = mean(results);
        expected = 1;
        
        test = and(actual - 2.58 * stdError < expected, ...
                   expected < actual + 2.58 * stdError);
        testi = all(test);
        
    end
    
    assertTrue(testCase, all(testi))
    
end

function testReduceSumMean(testCase)
    
    f = @() randn(5, 1) + 1;
    expected = 5;
    tolerance = 0.01;
    n_tests = 10;
    test = boolean(zeros(n_tests, 1));
    
    for i = 1:n_tests
        
        [results, ~] = WecOptTool.math.standardError('reduce',   ...
                                                     f,          ...
                                                     5,          ...
                                                     tolerance,  ...
                                                     'metric', 'summean');
        
        actual = sum(mean(results));
        test(i) = WecOptTool.math.isClose(actual,   ...
                                          expected, ...
                                          'rtol', tolerance);
        
    end
    
    assertTrue(testCase, all(test))
    
end

function testMeasureSumStruct(testCase)
    
    function s = f()
        s.f = randn(5, 1) + 1;
    end
    
    [S, stdError] = WecOptTool.math.standardError('measure',  ...
                                                  @f,         ...
                                                  5,          ...
                                                  5,          ...
                                                  'targetField', 'f');
    
    % Check that the expected value is within 95% interval
    actual = sum(mean([S.f]));
    expected = 5;
    test = (actual - 1.96 * stdError < expected) &&    ...
           (expected < actual + 1.96 * stdError);
    
    assertTrue(testCase, test)
    
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

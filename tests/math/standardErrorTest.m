function tests = standardErrorTest()
   tests = functiontests(localfunctions);
end

function testBadResultType(testCase)
    
    f = @() randn(5, 1) + 1;
    helper = @() WecOptTool.math.standardError('bad', f, 5, 1);
    errCode = 'WecOptTool:standardError:badResultType';
    verifyError(testCase, helper, errCode);
    
end

function testBadMetric(testCase)
    
    f = @() randn(5, 1) + 1;
    helper = @() WecOptTool.math.standardError('measure',   ...
                                               f,           ...
                                               5,           ...
                                               1,           ...
                                               'metric', 'bad');
    errCode = 'WecOptTool:standardError:badMetric';
    verifyError(testCase, helper, errCode);
    
end

function testBadErrorMode(testCase)
    
    f = @() randn(5, 1) + 1;
    helper = @() WecOptTool.math.standardError('measure',   ...
                                               f,           ...
                                               5,           ...
                                               1,           ...
                                               'onError', 'bad');
    errCode = 'WecOptTool:standardError:badErrorMode';
    verifyError(testCase, helper, errCode);
    
end

function testMeasureNorm(testCase)

    f = @() randn(5, 1) + 1;
    expected = 5;
    confidence = 2.576; % 99% interval
    
    n_tests = 1000;
    test = boolean(zeros(n_tests, 1));
    
    for i = 1:n_tests
        
        [results, stdError, ~] = WecOptTool.math.standardError(    ...
                                                    'measure', f, 5, 5);
        
        % Check that the expected value is within interval
        actual = sum(mean(results));
        test(i) = (actual - confidence * stdError < expected) &&    ...
                  (expected < actual + confidence * stdError);
        
    end
    
    tpct = sum(test) / n_tests * 100;
    
    % Add some slack!
    assertGreaterThan(testCase, tpct, 96)
    
end

function testMeasureMax(testCase)
    
    f = @() randn(5, 1) + 1;
    expected = 1;
    confidence = 2.576; % 99% interval
    
    n_tests = 1000;
    testi = boolean(zeros(n_tests, 1));
    
    for i = 1:n_tests
        
        [results, stdError, ~] = WecOptTool.math.standardError(     ...
                                                        'measure',  ...
                                                        f,          ...
                                                        5,          ...
                                                        10,         ...
                                                        'metric', 'max');
        
        % Check that the expected value is within interval
        actual = mean(results);        
        test = and(expected - confidence * stdError < actual, ...
                   actual < expected + confidence * stdError);
        testi(i) = all(test);
        
    end
    
    tpct = sum(testi) / n_tests * 100;
    
    % Add some slack!
    assertGreaterThan(testCase, tpct, 96)
    
end

function testMeasureNormStruct(testCase)
    
    function s = f()
        s.f = randn(5, 1) + 1;
    end

    confidence = 2.576; % 99% interval
    
    n_tests = 1000;
    test = boolean(zeros(n_tests, 1));
    
    for i = 1:n_tests
    
        [S, stdError, ~] = WecOptTool.math.standardError(       ...
                                                    'measure',  ...
                                                    @f,         ...
                                                    5,          ...
                                                    5,          ...
                                                    'targetField', 'f');

        % Check that the expected value is within interval
        actual = sum(mean([S.f]));
        expected = 5;
        test(i) = (actual - confidence * stdError < expected) &&    ...
                  (expected < actual + confidence * stdError);
              
    end
    
    tpct = sum(test) / n_tests * 100;
    
    % Add some slack!
    assertGreaterThan(testCase, tpct, 96)
    
end

function testReduceNormMean(testCase)
    
    f = @() randn(5, 1) + 1;
    expected = 5;
    tolerance = 0.01;
    confidence = 2.576; % 99% interval
    
    n_tests = 100;
    test = boolean(zeros(n_tests, 1));
    
    for i = 1:n_tests
        
        [results, ~, ~] = WecOptTool.math.standardError(        ...
                                                    'reduce',   ...
                                                    f,          ...
                                                    5,          ...
                                                    tolerance,  ...
                                                    'metric', 'normmean');
        
        actual = sum(mean(results));
        checktol = expected * tolerance * confidence;
        test(i) = WecOptTool.math.isClose(actual,   ...
                                          expected, ...
                                          'atol', checktol);
        
    end
    
    tpct = sum(test) / n_tests * 100;
    
    % Add some slack!
    assertGreaterThan(testCase, tpct, 96)
    
end

function testReduceNormMeanMaxWarn(testCase)
    
    f = @() randn(5, 1) + 1;
    tolerance = 1e-9;
    maxN = 5;
    errCode = 'WecOptTool:standardError:maxNReached';
    
    function varargout = helper()
        [~, stdError, N] = WecOptTool.math.standardError(               ...
                                                'reduce',               ...
                                                f,                      ...
                                                5,                      ...
                                                tolerance,              ...
                                                'metric', 'normmean',   ...
                                                'maxN', maxN);
        varargout = {stdError, N};
    end
    
    [stdError, N] = verifyWarning(testCase, @helper, errCode);
    verifyEqual(testCase, maxN, N)
    verifyGreaterThan(testCase, stdError, tolerance)
    
end

function testReduceNormMeanMaxError(testCase)
    
    f = @() randn(5, 1) + 1;
    tolerance = 1e-9;
    maxN = 5;
    errCode = 'WecOptTool:standardError:maxNReached';
    
    helper = @() WecOptTool.math.standardError('reduce',                ...
                                               f,                       ...
                                               5,                       ...
                                               tolerance,               ...
                                               'metric', 'normmean',    ...
                                               'maxN', maxN,            ...
                                               'onError', 'raise');
    
    verifyError(testCase, helper, errCode);

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

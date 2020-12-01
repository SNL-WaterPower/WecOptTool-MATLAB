function tests = standardErrorTest()
   tests = functiontests(localfunctions);
end

function testMeasureSum(testCase)

    f = @() randn(5, 1) + 1;
    [results, stdError] = WecOptTool.math.standardError('measure', f, 5, 5);
    
    % Check that the expected value is within 95% interval
    actual = sum(mean(results));
    expected = 5;
    test = (actual - 1.96 * stdError < expected) &&    ...
           (expected < actual + 1.96 * stdError);
    
    assertTrue(testCase, test)
    
end

function testMeasureMax(testCase)

    f = @() randn(5, 1) + 1;
    [results, stdError] = WecOptTool.math.standardError('measure',  ...
                                                        f,          ...
                                                        5,          ...
                                                        5,          ...
                                                        'metric', 'max');
    
    % Check that the expected value is within 95% interval
    actual = mean(results);
    expected = 1;
    
    test = and(actual - 1.96 * stdError < expected, ...
               expected < actual + 1.96 * stdError);
    
    assertTrue(testCase, all(test))
    
end

function testReduceSumMean(testCase)

    f = @() randn(5, 1) + 1;
    tolerance = 0.01;

    [results, ~] = WecOptTool.math.standardError('reduce',   ...
                                                 f,          ...
                                                 5,          ...
                                                 tolerance,  ...
                                                 'metric', 'summean');
    
    actual = sum(mean(results));
    expected = 5;
    
    assertEqual(testCase, actual, expected, 'RelTol', tolerance)
    
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

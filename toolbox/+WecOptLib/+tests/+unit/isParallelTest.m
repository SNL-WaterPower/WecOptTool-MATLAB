function tests = isParallelTest()
   tests = functiontests(localfunctions);
end

function testIsParallelTrue(testCase)

    testCase.assumeTrue(WecOptLib.utils.hasParallelToolbox(),   ...
                        'Parallel toolbox not available')
    
    tests = zeros(1, 2);
    
    parfor i = 1:2
        tests(i) = WecOptLib.utils.isParallel();
    end
    
    verifyEqual(testCase, all(tests), true)

end

function testIsParallelFalse(testCase)

    tests = zeros(1, 2);
    
    for i = 1:2
        tests(i) = WecOptLib.utils.isParallel();
    end
    
    verifyEqual(testCase, any(tests), false)

end

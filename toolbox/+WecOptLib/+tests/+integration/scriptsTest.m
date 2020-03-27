function tests = scriptsTest()
   tests = functiontests(localfunctions);
end

function testDependencyCheck(testCase)
    
    srcRootPath = WecOptLib.utils.getSrcRootPath();
    cd(srcRootPath);
    verifyWarningFree(testCase, @dependencyCheck);
    
end

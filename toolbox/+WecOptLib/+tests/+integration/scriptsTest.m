function tests = scriptsTest()
   tests = functiontests(localfunctions);
end

function testDependencyCheck(testCase)
    
    % Get this directories path
    srcRootPath = WecOptLib.utils.getSrcRootPath();
    cd(srcRootPath);
    verifyWarningFree(testCase, @dependencyCheck);
    
end

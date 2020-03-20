function tests = scriptsTest()
   tests = functiontests(localfunctions);
end

function testDependencyCheck(testCase)
    
    % Get this directories path
    s = what('WecOptLib');
    parts = strsplit(s.path, filesep);
    dirCell = join(parts(1:end-2), filesep);
    cd(dirCell{1});
    verifyWarningFree(testCase, @dependencyCheck);
    
end

function testDataToolPath(testCase)
    
    % Get this directories path
    s = what('WecOptLib');
    parts = strsplit(s.path, filesep);
    dirCell = join(parts(1:end-2), filesep);
    cd(dirCell{1});
    verifyWarningFree(testCase, @() dataTool('path'));
    
end

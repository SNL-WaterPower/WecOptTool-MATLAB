function tests = StudyTest()
% StudyTest

    tests = functiontests(localfunctions);

end

function testStudyUniqueDir(testCase)
    
    testStudy1 = WecOptTool.RM3Study();
    testStudy2 = WecOptTool.RM3Study();
    
    verifyNotEqual(testCase, testStudy1.nemohDir, testStudy2.nemohDir)
    
end

function testStudyDestructor(testCase)
    
    testStudy = WecOptTool.RM3Study();
    
    % Fake directory build
    testDir = testStudy.nemohDir;
    mkdir(testStudy.nemohDir)
    
    % Trigger destructor
    clear testStudy
    
    verifyEqual(testCase, exist(testDir, 'dir'), 0)
    
end

function testStudyCopyNEMOH(testCase)
    
    testStudy = WecOptTool.RM3Study();
    
    % Fake directory build
    mkdir(testStudy.nemohDir)
    
    filePath = fullfile(testStudy.nemohDir, 'changing.txt');
    fileID = fopen(filePath,'w');
    fmt = '%5d %5d %5d %5d\n';
    fprintf(fileID,fmt, magic(4));
    fclose(fileID);
    
    % Copy data
    testDir = fullfile(tempdir, 'testStudyCopyNEMOH');
    testStudy.copyNEMOH(testDir);
    
    verifyEqual(testCase, exist(testDir, 'dir'), 7)
    rmdir(testDir, 's')
    
end

function testStudyNoCopyNEMOH(testCase)
    
    testStudy = WecOptTool.RM3Study();
    
    % Attempt Copy data
    testDir = fullfile(tempdir, 'testStudyNoCopyNEMOH');
    testStudy.copyNEMOH(testDir);
    
    verifyTrue(testCase, ~exist(testDir, 'dir'))
    
end

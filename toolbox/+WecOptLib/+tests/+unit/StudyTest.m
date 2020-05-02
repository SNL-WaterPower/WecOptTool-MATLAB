
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

function tests = StudyTest()
% StudyTest

    tests = functiontests(localfunctions);

end

function testStudyUniqueDir(testCase)
    
    testStudy1 = WecOptTool.RM3Study();
    testStudy2 = WecOptTool.RM3Study();
    
    verifyNotEqual(testCase, testStudy1.studyDir, testStudy2.studyDir)
    
end

function testStudyDestructor(testCase)
    
    % Directory build
    testStudy = WecOptTool.RM3Study();    
    assertTrue(testCase, isfolder(testStudy.studyDir))
    testDir = testStudy.studyDir;
    
    % Trigger destructor
    clear testStudy
    
    verifyEqual(testCase, isfolder(testDir), false)
    
end

function testSaveStudyData(testCase)

    import matlab.unittest.fixtures.TemporaryFolderFixture
    
    tempFixture = testCase.applyFixture(                            ...
             TemporaryFolderFixture('PreservingOnFailure',  true,   ...
                                    'WithSuffix', 'testStudySaveNEMOH'));
    
    testStudy = WecOptTool.RM3Study();
    
    filePath = fullfile(testStudy.studyDir, 'changing.txt');
    fileID = fopen(filePath,'w');
    fmt = '%5d %5d %5d %5d\n';
    fprintf(fileID,fmt, magic(4));
    fclose(fileID);
    
    % Copy data
    testDir = fullfile(tempFixture.Folder, "test");
    testStudy.saveData(testDir);
    
    verifyTrue(testCase, isfolder(testDir))
    rmdir(testDir, 's')
    
end

function testSaveStudyDataNoCopy(testCase)

    import matlab.unittest.fixtures.TemporaryFolderFixture
    
    tempFixture = testCase.applyFixture(                            ...
             TemporaryFolderFixture('PreservingOnFailure',  true,   ...
                                    'WithSuffix', 'testStudyNoSopyNEMOH'));
    
    testStudy = WecOptTool.RM3Study();
    
    % Attempt to copy data
    testDir = fullfile(tempFixture.Folder, "test");
    testStudy.saveData(testDir);
    
    verifyFalse(testCase, isfolder(testDir))
    
end

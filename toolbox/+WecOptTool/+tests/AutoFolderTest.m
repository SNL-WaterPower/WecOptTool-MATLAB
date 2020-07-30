function tests = AutoFolderTest()
    tests = functiontests(localfunctions);
end

function testUniqueDir(testCase)
    
    autoFolder1 = WecOptTool.base.AutoFolder();
    autoFolder2 = WecOptTool.base.AutoFolder();
    
    verifyNotEqual(testCase, autoFolder1.folder, autoFolder2.folder)
    
end

function testDestructor(testCase)
    
    % Directory build
    autoFolder = WecOptTool.base.AutoFolder();
    assertTrue(testCase, isfolder(autoFolder.folder))
    testDir = autoFolder.folder;
    
    % Trigger destructor
    clear autoFolder
    
    verifyEqual(testCase, isfolder(testDir), false)
    
end

function testParentFolderDestructor(testCase)

    import matlab.unittest.fixtures.TemporaryFolderFixture
    
    tempFixture = testCase.applyFixture(                            ...
             TemporaryFolderFixture('PreservingOnFailure',  true,   ...
                                    'WithSuffix', 'testStudySaveNEMOH'));
    
    autoFolder = WecOptTool.base.AutoFolder(tempFixture.Folder);
    testDir = autoFolder.folder;
    verifyTrue(testCase, isfolder(testDir))
    
    % Trigger destructor
    clear autoFolder
    
    % Folder should not be deleted
    verifyTrue(testCase, isfolder(testDir))
    
end

function testSaveFolder(testCase)

    import matlab.unittest.fixtures.TemporaryFolderFixture
    
    tempFixture = testCase.applyFixture(                            ...
             TemporaryFolderFixture('PreservingOnFailure',  true,   ...
                                    'WithSuffix', 'testStudySaveNEMOH'));
    
    autoFolder = WecOptTool.base.AutoFolder();
    
    filePath = fullfile(autoFolder.folder, 'changing.txt');
    fileID = fopen(filePath,'w');
    fmt = '%5d %5d %5d %5d\n';
    fprintf(fileID,fmt, magic(4));
    fclose(fileID);
    
    % Copy data
    testDir = fullfile(tempFixture.Folder, "test");
    autoFolder.saveFolder(testDir);
    
    verifyTrue(testCase, isfolder(testDir))
    rmdir(testDir, 's')
    
end

function testSaveFolderNoCopy(testCase)

    import matlab.unittest.fixtures.TemporaryFolderFixture
    
    tempFixture = testCase.applyFixture(                            ...
             TemporaryFolderFixture('PreservingOnFailure',  true,   ...
                                    'WithSuffix', 'testStudyNoSopyNEMOH'));
    
    autoFolder = WecOptTool.base.AutoFolder();
    
    % Attempt to copy data
    testDir = fullfile(tempFixture.Folder, "test");
    autoFolder.saveFolder(testDir);
    
    verifyFalse(testCase, isfolder(testDir))
    
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

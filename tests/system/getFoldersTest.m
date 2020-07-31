
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

function tests = getFoldersTest()
   tests = functiontests(localfunctions);
end

function testNotFolder(testCase)

    import matlab.unittest.fixtures.TemporaryFolderFixture
    tempFixture = testCase.applyFixture(                            ...
             TemporaryFolderFixture('PreservingOnFailure',  true,   ...
                                    'WithSuffix', 'testNotFolder'));
    
    dummyFile = fullfile(tempFixture.Folder, "dummy.txt");
    fclose(fopen(dummyFile, 'w'));
    assertTrue(testCase, isfile(dummyFile))
    
    folderNames = WecOptTool.system.getFolders(dummyFile);
    verifyEmpty(testCase, folderNames)

end

function testEmptyFolder(testCase)

    import matlab.unittest.fixtures.TemporaryFolderFixture
    tempFixture = testCase.applyFixture(                            ...
             TemporaryFolderFixture('PreservingOnFailure',  true,   ...
                                    'WithSuffix', 'testNotFolder'));
    
    dummyFile = fullfile(tempFixture.Folder, "dummy.txt");
    fclose(fopen(dummyFile, 'w'));
    assertTrue(testCase, isfile(dummyFile))
    
    folderNames = WecOptTool.system.getFolders(tempFixture.Folder);
    verifyEmpty(testCase, folderNames)

end

function testRelativePaths(testCase)

    import matlab.unittest.fixtures.TemporaryFolderFixture
    tempFixture = testCase.applyFixture(                            ...
             TemporaryFolderFixture('PreservingOnFailure',  true,   ...
                                    'WithSuffix', 'testNotFolder'));
    
    % Make some folders to test
    nFolders = 5;
    expected = cell(1, nFolders);
    
    for i = 1:nFolders
        
        folderName = sprintf('dummy%d', i);
        absFolderPath = fullfile(tempFixture.Folder, folderName);
        mkdir(absFolderPath);
        
        assertTrue(testCase, isfolder(absFolderPath))
        expected{i} = folderName;
        
    end
        
    folderNames = WecOptTool.system.getFolders(tempFixture.Folder);
    verifyEqual(testCase, folderNames, expected)

end


function testAbsolutePaths(testCase)

    import matlab.unittest.fixtures.TemporaryFolderFixture
    tempFixture = testCase.applyFixture(                            ...
             TemporaryFolderFixture('PreservingOnFailure',  true,   ...
                                    'WithSuffix', 'testNotFolder'));
    
    % Make some folders to test
    nFolders = 5;
    expected = cell(1, nFolders);
    
    for i = 1:nFolders
        
        folderName = sprintf('dummy%d', i);
        absFolderPath = fullfile(tempFixture.Folder, folderName);
        mkdir(absFolderPath);
        
        assertTrue(testCase, isfolder(absFolderPath))
        expected{i} = absFolderPath;
        
    end
        
    folderNames = WecOptTool.system.getFolders(tempFixture.Folder,    ...
                                             "absPath", true);
    verifyEqual(testCase, folderNames, expected)

end



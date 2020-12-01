function tests = installExternalTest
   tests = functiontests(localfunctions);
end

function testInstallDummy(testCase)
    
    import matlab.unittest.fixtures.TemporaryFolderFixture
    import matlab.unittest.constraints.IsFile
    import matlab.unittest.constraints.IsEqualTo
    
    tempFixture = testCase.applyFixture(                            ...
             TemporaryFolderFixture('PreservingOnFailure',  true,   ...
                                    'WithSuffix', 'testInstallDummy'));
    
    f = @() true;
    
    WecOptTool.system.installExternal("Test",       ...
                                      "Basil",      ...
                                      "Brush",      ...
                                      f,            ...
                                      'configDir', tempFixture.Folder);
    
    filePath = fullfile(tempFixture.Folder, 'config.json');
    testCase.verifyThat(filePath, IsFile)
    
    fileID = fopen(filePath);
    tline = fgetl(fileID);
    fclose(fileID);
    
    expVal = '{"Basil":"Brush"}';
    testCase.verifyThat(tline, IsEqualTo(expVal))
    
end

function testInstallDummyFail(testCase)
    
    import matlab.unittest.fixtures.TemporaryFolderFixture
    import matlab.unittest.constraints.IsFile
    import matlab.unittest.constraints.IsEqualTo
    
    tempFixture = testCase.applyFixture(                            ...
             TemporaryFolderFixture('PreservingOnFailure',  true,   ...
                                    'WithSuffix', 'testInstallDummyFail'));
    
    f = @() false;
    catchFile = fullfile(tempFixture.Folder, "output.txt");
    
    diary(catchFile)
    WecOptTool.system.installExternal("Test",       ...
                                      "Basil",      ...
                                      "Brush",      ...
                                      f,            ...
                                      'configDir', tempFixture.Folder);
    diary off
    
    filePath = fullfile(tempFixture.Folder, 'config.json');
    testCase.verifyThat(filePath, ~IsFile)
    
    s = dir(catchFile);         
    filesize = s.bytes;
    
    verifyEqual(testCase, filesize, 63)
    
end

function testInstallDummyReWrite(testCase)
    
    import matlab.unittest.fixtures.TemporaryFolderFixture
    import matlab.unittest.constraints.IsFile
    import matlab.unittest.constraints.IsEqualTo
    
    tempFixture = testCase.applyFixture(                            ...
             TemporaryFolderFixture('PreservingOnFailure',  true,   ...
                                    'WithSuffix', 'testInstallDummyFail'));
    
    f = @() true;
    
    WecOptTool.system.installExternal("Test",       ...
                                      "Basil",      ...
                                      "Brush",      ...
                                      f,            ...
                                      'configDir', tempFixture.Folder);
    
    filePath = fullfile(tempFixture.Folder, 'config.json');
    testCase.verifyThat(filePath, IsFile)
    
    fileID = fopen(filePath);
    tline = fgetl(fileID);
    fclose(fileID);
    
    expVal = '{"Basil":"Brush"}';
    testCase.verifyThat(tline, IsEqualTo(expVal))
    
    WecOptTool.system.installExternal("Test",       ...
                                      "Basil",      ...
                                      "Faulty",      ...
                                      f,            ...
                                      'configDir', tempFixture.Folder);
    
    fileID = fopen(filePath);
    tline = fgetl(fileID);
    fclose(fileID);
    
    expVal = '{"Basil":"Faulty"}';
    testCase.verifyThat(tline, IsEqualTo(expVal))
    
end

function testInstallDummyFailReWrite(testCase)
    
    import matlab.unittest.fixtures.TemporaryFolderFixture
    import matlab.unittest.constraints.IsFile
    import matlab.unittest.constraints.IsEqualTo
    
    tempFixture = testCase.applyFixture(                            ...
             TemporaryFolderFixture('PreservingOnFailure',  true,   ...
                                    'WithSuffix', 'testInstallDummyFail'));
    
    f = @() true;
    
    WecOptTool.system.installExternal("Test",       ...
                                      "Basil",      ...
                                      "Brush",      ...
                                      f,            ...
                                      'configDir', tempFixture.Folder);
    
    filePath = fullfile(tempFixture.Folder, 'config.json');
    testCase.verifyThat(filePath, IsFile)
    
    fileID = fopen(filePath);
    tline = fgetl(fileID);
    fclose(fileID);
    
    expVal = '{"Basil":"Brush"}';
    testCase.verifyThat(tline, IsEqualTo(expVal))
    
    f = @() false;
    
    WecOptTool.system.installExternal("Test",       ...
                                      "Basil",      ...
                                      "Faulty",      ...
                                      f,            ...
                                      'configDir', tempFixture.Folder);
    
    fileID = fopen(filePath);
    tline = fgetl(fileID);
    fclose(fileID);
    
    expVal = '{"Basil":"Brush"}';
    testCase.verifyThat(tline, IsEqualTo(expVal))
    
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

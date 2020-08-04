function tests = writeConfigTest
   tests = functiontests(localfunctions);
end

function testWriteConfigNew(testCase)

    import matlab.unittest.fixtures.TemporaryFolderFixture
    import matlab.unittest.constraints.IsFile
    import matlab.unittest.constraints.IsEqualTo
    
    tempFixture = testCase.applyFixture(                            ...
             TemporaryFolderFixture('PreservingOnFailure',  true,   ...
                                    'WithSuffix', 'testWriteConfigNew'));

    WecOptTool.system.writeConfig("test", 1,    ...
                                  'configDir', tempFixture.Folder)
    
    filePath = fullfile(tempFixture.Folder, 'config.json');
    testCase.verifyThat(filePath, IsFile)
    
    fileID = fopen(filePath);
    tline = fgetl(fileID);
    fclose(fileID);
    
    expVal = '{"test":1}';
    testCase.verifyThat(tline, IsEqualTo(expVal))
    
end

function testWriteConfigExists(testCase)

    import matlab.unittest.fixtures.TemporaryFolderFixture
    import matlab.unittest.constraints.IsFile
    import matlab.unittest.constraints.IsEqualTo
    
    tempFixture = testCase.applyFixture(                            ...
         TemporaryFolderFixture('PreservingOnFailure',  true,       ...
                                'WithSuffix', 'testWriteConfigExists'));

    WecOptTool.system.writeConfig("test", 1,    ...
                                  'configDir', tempFixture.Folder)
    
    filePath = fullfile(tempFixture.Folder, 'config.json');
    testCase.verifyThat(filePath, IsFile)
    
    fileID = fopen(filePath);
    tline = fgetl(fileID);
    fclose(fileID);
    
    expVal = '{"test":1}';
    testCase.verifyThat(tline, IsEqualTo(expVal))
    
    WecOptTool.system.writeConfig("new", 2,     ...
                                  'configDir', tempFixture.Folder)
    
    filePath = fullfile(tempFixture.Folder, 'config.json');
    testCase.verifyThat(filePath, IsFile)
    
    fileID = fopen(filePath);
    tline = fgetl(fileID);
    fclose(fileID);
    
    expVal = '{"test":1,"new":2}';
    testCase.verifyThat(tline, IsEqualTo(expVal))
    
end

function testWriteConfigRemove(testCase)

    import matlab.unittest.fixtures.TemporaryFolderFixture
    import matlab.unittest.constraints.IsFile
    import matlab.unittest.constraints.IsEqualTo
    
    tempFixture = testCase.applyFixture(                            ...
         TemporaryFolderFixture('PreservingOnFailure',  true,       ...
                                'WithSuffix', 'testWriteConfigRemove'));

    WecOptTool.system.writeConfig("test", 1,    ...
                                  'configDir', tempFixture.Folder)
    
    filePath = fullfile(tempFixture.Folder, 'config.json');
    testCase.verifyThat(filePath, IsFile)
    
    fileID = fopen(filePath);
    tline = fgetl(fileID);
    fclose(fileID);
    
    expVal = '{"test":1}';
    testCase.verifyThat(tline, IsEqualTo(expVal))
    
    WecOptTool.system.writeConfig("test",  "",     ...
                                  'configDir', tempFixture.Folder)
    
    filePath = fullfile(tempFixture.Folder, 'config.json');
    testCase.verifyThat(filePath, IsFile)
    
    fileID = fopen(filePath);
    tline = fgetl(fileID);
    fclose(fileID);
    
    expVal = '{}';
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

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

function tests = readConfigTest
   tests = functiontests(localfunctions);
end

function testReadConfigNoDir(testCase)

    func = @() WecOptLib.utils.readConfig("test", 'configDir', "");
    eID = 'WecOptTool:readConfig:missingDirectory';
    verifyError(testCase, func, eID)
    
end

function testReadConfigNoFile(testCase)

    import matlab.unittest.fixtures.TemporaryFolderFixture
    
    tempFixture = testCase.applyFixture(                            ...
         TemporaryFolderFixture('PreservingOnFailure',  true,       ...
                                'WithSuffix', 'testReadConfigNoFile'));

    func = @() WecOptLib.utils.readConfig("test",   ...
                                          'configDir', tempFixture.Folder);
    eID = 'WecOptTool:readConfig:missingFile';
    verifyError(testCase, func, eID)
    
end

function testReadConfigNoKey(testCase)

    import matlab.unittest.fixtures.TemporaryFolderFixture
    import matlab.unittest.constraints.IsFile
    
    tempFixture = testCase.applyFixture(                            ...
         TemporaryFolderFixture('PreservingOnFailure',  true,       ...
                                'WithSuffix', 'testReadConfigNoKey'));

    WecOptLib.utils.writeConfig("test", 1, 'configDir', tempFixture.Folder)
    
    filePath = fullfile(tempFixture.Folder, 'config.json');
    testCase.verifyThat(filePath, IsFile)
                            
    func = @() WecOptLib.utils.readConfig("wrongkey",   ...
                                          'configDir', tempFixture.Folder);
    eID = 'WecOptTool:readConfig:missingKey';
    verifyError(testCase, func, eID)
    
end

function testReadConfig(testCase)

    import matlab.unittest.fixtures.TemporaryFolderFixture
    import matlab.unittest.constraints.IsFile
    import matlab.unittest.constraints.IsEqualTo
    
    tempFixture = testCase.applyFixture(                            ...
         TemporaryFolderFixture('PreservingOnFailure',  true,       ...
                                'WithSuffix', 'testReadConfig'));

    expected = 1;
    WecOptLib.utils.writeConfig("test",     ...
                                expected,   ...
                                'configDir', tempFixture.Folder)
    
    filePath = fullfile(tempFixture.Folder, 'config.json');
    testCase.verifyThat(filePath, IsFile)
    
    actual = WecOptLib.utils.readConfig("test",   ...
                                        'configDir', tempFixture.Folder);
    
    testCase.verifyThat(actual, IsEqualTo(expected))
    
end


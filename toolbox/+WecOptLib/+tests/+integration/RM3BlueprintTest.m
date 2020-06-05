function tests = RM3BlueprintTest()
    tests = functiontests(localfunctions);
end

function testVerify_CC(testCase)

    import matlab.unittest.fixtures.PathFixture
            
    addFolder = fullfile(WecOptLib.utils.getSrcRootPath(),  ...
                         "examples",                        ...
                         "RM3");
    testCase.applyFixture(PathFixture(addFolder));

    S = WecOptLib.tests.data.exampleSpectrum();
    S.ph = rand(length(S.w),1)* 2 * pi;
    SS = WecOptTool.types("SeaState", S);
    
    blueprint = RM3();
            
    geomMode.type = 'scalar';
    geomMode.params = {1};
    cntrlMode.type = 'CC';
    
    RM3Device = makeDevices(blueprint, geomMode, cntrlMode);
    simulate(RM3Device, SS);
    
    expSol = 3.772016088262561e+06;
    verifyEqual(testCase,                   ...
                RM3Device.aggregation.pow,  ... 
                expSol,                     ...
                'RelTol', 0.001)
    
end

function testVerify_damping(testCase)

    import matlab.unittest.fixtures.TemporaryFolderFixture
    tempFixture = testCase.applyFixture(                            ...
             TemporaryFolderFixture('PreservingOnFailure',  true,   ...
                                    'WithSuffix', 'testVerify_damping'));


    S = WecOptLib.tests.data.exampleSpectrum();
    S.ph = rand(length(S.w),1)* 2 * pi;
    [S.w, S.S] = WecOptLib.utils.subSampleFreqs(S);
    RM3Device = WecOptLib.models.RM3.DeviceModel();
    WECpow = RM3Device.getPower(tempFixture.Folder, S,'P','scalar',1);
    
    expSol = 1.349990052717686e+06;
    verifyEqual(testCase, WECpow, expSol, 'RelTol', 0.001)
    
end

% function testVerify_SeaStates(testCase)
% % Load Sea States
% SS = load('Y:\WecOptTool\toolbox\+WecOptLib\+tests\+data\sea-states.mat');
% 
% %S.ph = rand(length(S.w),1)* 2 * pi;
% %[S.w, S.S] = WecOptLib.utils.subSampleFreqs(S);
% RM3Device = WecOptLib.models.RM3DeviceModel();
% WECpow = RM3Device.getPower(S,'P','scalar',1);
% expSol = -1.349990052717686e+06;
% verifyEqual(testCase, WECpow, expSol, 'RelTol', 0.001)
% end

function testVerify_PS(testCase)

    import matlab.unittest.fixtures.TemporaryFolderFixture
    tempFixture = testCase.applyFixture(                            ...
             TemporaryFolderFixture('PreservingOnFailure',  true,   ...
                                    'WithSuffix', 'testVerify_PS'));


    S = WecOptLib.tests.data.exampleSpectrum();
    S.ph = rand(length(S.w),1)* 2 * pi;
    [S.w, S.S] = WecOptLib.utils.subSampleFreqs(S);
    delta_Zmax = 10;
    delta_Fmax = 1e9;
    RM3Device = WecOptLib.models.RM3.DeviceModel();
    WECpow = RM3Device.getPower(tempFixture.Folder,     ...
                                S,                      ...
                                'PS',                   ...
                                'scalar',               ...
                                1,                      ...
                                {},                     ...
                                [delta_Zmax,delta_Fmax]);
    
    expSol = 3.772016088252104e+06;
    verifyEqual(testCase, WECpow, expSol, 'RelTol', 0.001)
    
end

function test_RM3_mass(testCase)

    RM3Device = WecOptLib.models.RM3.DeviceModel();
    hydro = RM3Device.getHydrodynamics('scalar',1);
    mass = sum(hydro.Vo * hydro.rho);
    
    expSol = 1.652838125000000e6;
    verifyEqual(testCase, mass, expSol, 'RelTol', 0.001)

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

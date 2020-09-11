function tests = optionsTest()
    tests = functiontests(localfunctions);
end

function testVerify_CC(testCase)

    import matlab.unittest.fixtures.PathFixture
            
    addFolder = fullfile(WecOptTool.system.getSrcRootPath(),    ...
                         "examples",                            ...
                         "RM3");
    testCase.applyFixture(PathFixture(addFolder));

    SS = WecOptTool.SeaState.exampleSpectrum();
            
    deviceHydro = designDevice('scalar', 1);
    performance = simulateDevice(deviceHydro, SS, 'CC');
    pow = sum(performance.powPerFreq);
    
    expSol = 4.072835515358689e+06;
    verifyEqual(testCase, pow, expSol, 'RelTol', 0.001)
    
end

function testVerify_damping(testCase)

    import matlab.unittest.fixtures.PathFixture
            
    addFolder = fullfile(WecOptTool.system.getSrcRootPath(),    ...
                         "examples",                            ...
                         "RM3");
    testCase.applyFixture(PathFixture(addFolder));

    SS = WecOptTool.SeaState.exampleSpectrum();
    
    deviceHydro = designDevice('scalar', 1);
    performance = simulateDevice(deviceHydro, SS, 'P');
    pow = sum(performance.powPerFreq);
    
    expSol = 2.144693683724375e+06;
    verifyEqual(testCase, pow, expSol, 'RelTol', 0.001)
    
end

% function testVerify_SeaStates(testCase)
% % Load Sea States
% SS = load('Y:\WecOptTool\toolbox\+WecOptLib\+tests\+data\sea-states.mat');
% 
% %S.ph = rand(length(S.w),1)* 2 * pi;
% RM3Device = WecOptLib.models.RM3DeviceModel();
% WECpow = RM3Device.getPower(S,'P','scalar',1);
% expSol = -1.349990052717686e+06;
% verifyEqual(testCase, WECpow, expSol, 'RelTol', 0.001)
% end

function testVerify_PS(testCase)

    import matlab.unittest.fixtures.PathFixture
            
    addFolder = fullfile(WecOptTool.system.getSrcRootPath(),    ...
                         "examples",                            ...
                         "RM3");
    testCase.applyFixture(PathFixture(addFolder));

    SS = WecOptTool.SeaState.exampleSpectrum("resampleByError", 0.08);
    
    deviceHydro = designDevice('scalar', 1);
    performance = simulateDevice(deviceHydro, SS, 'PS', 10, 1e9);
    pow = sum(performance.powPerFreq);
    
    expSol = 4.072812570315526e+06;
    verifyEqual(testCase, pow, expSol, 'RelTol', 0.001)
    
end

function test_RM3_mass(testCase)

    import matlab.unittest.fixtures.PathFixture
            
    addFolder = fullfile(WecOptTool.system.getSrcRootPath(),    ...
                         "examples",                            ...
                         "RM3");
    testCase.applyFixture(PathFixture(addFolder));
    
    deviceHydro = designDevice('scalar', 1);
    mass = sum(deviceHydro.Vo * deviceHydro.rho);
    
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

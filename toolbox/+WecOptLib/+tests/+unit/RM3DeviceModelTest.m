
% Copyright 2020 Sandia National Labs
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
%     along with Foobar.  If not, see <https://www.gnu.org/licenses/>.

function tests = RM3DeviceModelTest()
% RM3DeviceModelTest
%
% Performs a series of unit tests to verify that the code is (still)
% working correctly.
%
% Call as
%           results = runtests('RM3DeviceModelTest')
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


tests = functiontests(localfunctions);

end

function testVerify_CC(testCase)
S = WecOptLib.tests.data.exampleSpectrum();
S.ph = rand(length(S.w),1)* 2 * pi;
RM3Device = WecOptLib.models.RM3.DeviceModel();
WECpow = RM3Device.getPower(S,'CC','scalar',1);
expSol = 3.772016088262561e+06;
verifyEqual(testCase, WECpow, expSol, 'RelTol', 0.001)
end

function testVerify_damping(testCase)
S = WecOptLib.tests.data.exampleSpectrum();
S.ph = rand(length(S.w),1)* 2 * pi;
[S.w, S.S] = WecOptLib.utils.subSampleFreqs(S);
RM3Device = WecOptLib.models.RM3.DeviceModel();
WECpow = RM3Device.getPower(S,'P','scalar',1);
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
S = WecOptLib.tests.data.exampleSpectrum();
S.ph = rand(length(S.w),1)* 2 * pi;
[S.w, S.S] = WecOptLib.utils.subSampleFreqs(S);
delta_Zmax = 10;
delta_Fmax = 1e9;
RM3Device = WecOptLib.models.RM3.DeviceModel();
WECpow = RM3Device.getPower(S,'PS','scalar',1,[delta_Zmax,delta_Fmax]);
expSol = 3.772016088252104e+06;
verifyEqual(testCase, WECpow, expSol, 'RelTol', 0.001)
end

function test_RM3_mass(testCase)
RM3Device = WecOptLib.models.RM3.DeviceModel();
hydro = RM3Device.getHydrodynamics('scalar',{1});
mass = sum(hydro.Vo * hydro.rho);
expSol = 1.652838125000000e6;
verifyEqual(testCase, mass, expSol, 'RelTol', 0.001)
end

function test_existingRunFiles(testCase)
tol = 5 * eps;
S = WecOptLib.tests.data.exampleSpectrum();
S.ph = rand(length(S.w),1)* 2 * pi;
[S.w, S.S] = WecOptLib.utils.subSampleFreqs(S);
RM3Device = WecOptLib.models.RM3.DeviceModel();
[madepow,etc] = RM3Device.getPower(S,'CC','parametric',[10,15,3,42]);
madeFile = etc.rundir;
[existpow,~] = RM3Device.getPower(S,'CC','existing', madeFile);
verifyEqual(testCase, madepow, existpow, 'RelTol', tol);
end

function test_runParametric(testCase)
S = WecOptLib.tests.data.exampleSpectrum();
S.ph = rand(length(S.w),1)* 2 * pi;
[S.w, S.S] = WecOptLib.utils.subSampleFreqs(S);
RM3Device = WecOptLib.models.RM3.DeviceModel();
WECpow = RM3Device.getPower(S,'CC','parametric',[10,15,3,42]);
expSol = 4.415667556078834e+06;
verifyEqual(testCase, WECpow, expSol, 'RelTol', 0.001)
end

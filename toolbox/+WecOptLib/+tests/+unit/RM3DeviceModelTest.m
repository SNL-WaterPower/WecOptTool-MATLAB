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
rundir = join([tempdir filesep "NEMOHtest"], "");
RM3Device = WecOptLib.models.RM3.DeviceModel(rundir);
WECpow = RM3Device.getPower(S,'CC','scalar',1);
expSol = 3.772016088262561e+06;
verifyEqual(testCase, WECpow, expSol, 'RelTol', 0.001)
end

function testVerify_damping(testCase)
S = WecOptLib.tests.data.exampleSpectrum();
S.ph = rand(length(S.w),1)* 2 * pi;
[S.w, S.S] = WecOptLib.utils.subSampleFreqs(S);
rundir = join([tempdir filesep "NEMOHtest"], "");
RM3Device = WecOptLib.models.RM3.DeviceModel(rundir);
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
rundir = join([tempdir filesep "NEMOHtest"], "");
RM3Device = WecOptLib.models.RM3.DeviceModel(rundir);
WECpow = RM3Device.getPower(S,'PS','scalar',1,[delta_Zmax,delta_Fmax]);
expSol = 3.772016088252104e+06;
verifyEqual(testCase, WECpow, expSol, 'RelTol', 0.001)
end

function test_RM3_mass(testCase)
rundir = join([tempdir filesep "NEMOHtest"], "");
RM3Device = WecOptLib.models.RM3.DeviceModel(rundir);
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
rundir = join([tempdir filesep "NEMOHtest"], "");
RM3Device = WecOptLib.models.RM3.DeviceModel(rundir);
[madepow,etc] = RM3Device.getPower(S,'CC','parametric',[10,15,3,42]);
madeFile = etc.rundir;
[existpow,~] = RM3Device.getPower(S,'CC','existing', madeFile);
verifyEqual(testCase, madepow, existpow, 'RelTol', tol);
rmdir(rundir, 's')
end

function test_runParametric(testCase)
S = WecOptLib.tests.data.exampleSpectrum();
S.ph = rand(length(S.w),1)* 2 * pi;
[S.w, S.S] = WecOptLib.utils.subSampleFreqs(S);
rundir = join([tempdir filesep "NEMOHtest"], "");
RM3Device = WecOptLib.models.RM3.DeviceModel(rundir);
WECpow = RM3Device.getPower(S,'CC','parametric',[10,15,3,42]);
expSol = 4.415667556078834e+06;
verifyEqual(testCase, WECpow, expSol, 'RelTol', 0.001)
rmdir(rundir, 's')
end

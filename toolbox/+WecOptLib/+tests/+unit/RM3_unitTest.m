function tests = RM3_unitTest()
% tests = RM3_unitTest()
%
% Performs a series of unit tests to verify that the code is (still)
% working correctly.
%
% Call as
%           results = runtests('RM3_unitTest')
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


tests = functiontests(localfunctions);

end

function testVerify_CC(testCase)
S = WecOptLib.tests.data.exampleSpectrum();
S.ph = rand(length(S.w),1)* 2 * pi;
[S.w, S.S] = subSampleFreqs(S);
WECpow = WecOptLib.volatile.RM3_getPow(S,'CC','scalar',1);
expSol = -3.772016088262561e+06;
verifyEqual(testCase, WECpow, expSol, 'RelTol', 0.001)
end

function testVerify_damping(testCase)
S = WecOptLib.tests.data.exampleSpectrum();
S.ph = rand(length(S.w),1)* 2 * pi;
[S.w, S.S] = subSampleFreqs(S);
WECpow = WecOptLib.volatile.RM3_getPow(S,'P','scalar',1);
expSol = -1.349990052717686e+06;
verifyEqual(testCase, WECpow, expSol, 'RelTol', 0.001)
end

function testVerify_PS(testCase)
S = WecOptLib.tests.data.exampleSpectrum();
S.ph = rand(length(S.w),1)* 2 * pi;
[S.w, S.S] = subSampleFreqs(S);
delta_Zmax = 10;
delta_Fmax = 1e9;
WECpow = WecOptLib.volatile.RM3_getPow(S,'PS','scalar',1,[delta_Zmax,delta_Fmax]);
expSol = -3.772016088252104e+06;
verifyEqual(testCase, WECpow, expSol, 'RelTol', 0.001)
end

function test_RM3_mass(testCase)
hydro = WecOptLib.volatile.RM3_getNemoh('scalar',{1});
mass = sum(hydro.Vo * hydro.rho);
expSol = 1.652838125000000e6;
verifyEqual(testCase, mass, expSol, 'RelTol', 0.001)
end

function test_existingRunFiles(testCase)
tol = 5 * eps;
S = WecOptLib.tests.data.exampleSpectrum();
S.ph = rand(length(S.w),1)* 2 * pi;
[S.w, S.S] = subSampleFreqs(S);
[madepow,etc] = WecOptLib.volatile.RM3_getPow(S,'CC','parametric',[10,15,3,42]);
madeFile = etc.rundir;
[existpow,~] = WecOptLib.volatile.RM3_getPow(S,'CC','existing', madeFile);
verifyEqual(testCase, madepow, existpow, 'RelTol', tol);
end

function test_runParametric(testCase)
S = WecOptLib.tests.data.exampleSpectrum();
S.ph = rand(length(S.w),1)* 2 * pi;
[S.w, S.S] = subSampleFreqs(S);
WECpow = WecOptLib.volatile.RM3_getPow(S,'CC','parametric',[10,15,3,42]);
expSol = -4.415667556078834e+06;
verifyEqual(testCase, WECpow, expSol, 'RelTol', 0.001)
end

function [new_w, new_S] = subSampleFreqs(S, npoints)
%subSampleFreq - subsamples sea state and interpolates to three harmonics
%    gets a subsampling of a given seastate by linear interpolation
%    Inputs:
%        S = seastate.  must have S.S and S.w
%        npoints = number of points to subsample
%    Outputs:
%        newS = new density values
%        neww = new frequency values

if(nargin < 2)
    npoints = 120;
end
ind_sp = find(S.S > 0.01 * max(S.S),1,'last');

new_w = linspace(S.w(1), S.w(ind_sp) * 3, npoints);
new_S = interp1(S.w, S.S, new_w);

new_S(isnan(new_S)) = 0;
end


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

% Notes: 
%
% Currently testing cylinder and sphere shaped geometries, cube to come.
%
% All test functions use a relative tolerance.  to adjust the tolerance,
% modify the `tol` variable at the top of each test case.
%
% All evaluations use verification, rather than something more strict, such
% as assertions.  This is to ensure that all tests run.
%
% Currently all verifications are based off of run data from a working
% version.  A more analytic approach may be taken at a later date.
%
% -Zachary Morrell 5/17/2019

function tests = getNemohTest
   tests = functiontests(localfunctions);
end

function testCylinderM(testCase)
    tol = .001;

    w = linspace(0.1,1,10);
    r=[0 1 1 0]; 
    z=[.5 .5 -.5 -.5];
    rundir = fullfile(tempdir, 'WecOptTool_testCylinderM');
    [hydro] = WecOptLib.nemoh.getNemoh(r,z,w,rundir);
    
    mAct = hydro.Vo * hydro.rho;
    mExp = 1602.74022500000;
    verifyEqual(testCase, mAct, mExp, 'RelTol', tol)
    
    WecOptLib.nemoh.cleanNemoh(rundir);
    
end

function testCylinderA(testCase)
    tol = .001;

    w = linspace(0.1,1,10);
    r=[0 1 1 0]; 
    z=[.5 .5 -.5 -.5];
    rundir = fullfile(tempdir, 'WecOptTool_testCylinderA');
    [hydro] = WecOptLib.nemoh.getNemoh(r,z,w,rundir);
    
    AAct = squeeze(hydro.A(3,3,:))*hydro.rho;
    
    %expected value off of previous runs
    AExp = [2.449950000000000e+03;...
            2.466340000000000e+03;...
            2.479139000000000e+03;...
            2.502448000000000e+03;...
            2.518107000000000e+03;...
            2.526768000000000e+03;...
            2.530628000000000e+03;...
            2.526432000000000e+03;...
            2.514688000000000e+03;...
            2.496468000000000e+03];
  
    verifyEqual(testCase, AAct, AExp, 'RelTol', tol)
    
    WecOptLib.nemoh.cleanNemoh(rundir);
    
end

function testCylinderAinf(testCase)
    tol = .001;
    w = linspace(0.1,1,10);
    r=[0 1 1 0]; 
    z=[.5 .5 -.5 -.5];
    rundir = fullfile(tempdir, 'WecOptTool_testCylinderAinf');
    [hydro] = WecOptLib.nemoh.getNemoh(r,z,w,rundir);

    AinfAct = hydro.Ainf(3,3)*hydro.rho;
    AinfExp = 2.496468000000000e+03;
    
    verifyEqual(testCase, AinfAct, AinfExp, 'RelTol', tol)
    
    WecOptLib.nemoh.cleanNemoh(rundir);
    
end

function testCylinderB(testCase)
    tol = .001;

    w = linspace(0.1,1,10);
    r=[0 1 1 0]; 
    z=[.5 .5 -.5 -.5];
    rundir = fullfile(tempdir, 'WecOptTool_testCylinderB');
    [hydro] = WecOptLib.nemoh.getNemoh(r,z,w,rundir);
    
    BAct = squeeze(hydro.B(3,3,:)).*w'*hydro.rho;
    BExp = [0.509248900000000;...
            4.04226400000000;...
            13.4646100000000;...
            31.3241400000000;...
            59.7084300000000;...
            100.121500000000;...
            153.377200000000;...
            219.584900000000;...
            298.097900000000;...
            387.615300000000];
    verifyEqual(testCase, BAct, BExp, 'RelTol', tol);
    
    WecOptLib.nemoh.cleanNemoh(rundir);
    
end

function testCylinderEx(testCase)
    tol = .001;

    w = linspace(0.1,1,10);
    r=[0 1 1 0]; 
    z=[.5 .5 -.5 -.5];
    rundir = fullfile(tempdir, 'WecOptTool_testCylinderEx');
    [hydro] = WecOptLib.nemoh.getNemoh(r,z,w,rundir);
    
    ExAct = (squeeze(hydro.ex_re(3,1,:)) + ...
                1i * squeeze(hydro.ex_im(3,1,:))) * hydro.rho * hydro.g;
    ExExp = [31405.2399999587 + 0.0509254181638977i;...
             31283.0899895515 + 0.808531169306684i;...
             31078.8897373919 + 4.04019042295150i;...
             30790.5674486798 + 12.5344804511268i;...
             30419.5153310345 + 29.8738322913427i;...
             29967.3696654497 + 60.1343427919986i;...
             29435.7036000245 + 107.528514833500i;...
             28829.1224344311 + 176.055037363224i;...
             28152.4237611598 + 269.115469988388i;...
             27410.4363488219 + 389.247231437354i];
         
     verifyEqual(testCase, ExAct, ExExp, 'RelTol', tol);
     
     WecOptLib.nemoh.cleanNemoh(rundir);
     
end

function testCylinderC(testCase)
    tol = .001;
    
    w = linspace(0.1,1,10);
    r=[0 1 1 0]; 
    z=[.5 .5 -.5 -.5];
    rundir = fullfile(tempdir, 'WecOptTool_testCylinderC');
    [hydro] = WecOptLib.nemoh.getNemoh(r,z,w,rundir);

    CAct = hydro.C(3,3)*hydro.rho*hydro.g;
    CExp = 3.144575000000000e+04;
    verifyEqual(testCase, CAct, CExp, 'RelTol', tol);
    
    WecOptLib.nemoh.cleanNemoh(rundir);
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% End of Cylinder Tests;
% Next is Sphere

% Sphere is generated using Chebyshev nodes for the values in the z point
% vector.  This is done because Chebyshev nodes provide points on a line
% that correspond to the projection of evenly spaced (by arclength) points
% on a semisphere, onto the line. Radius values are determined simply from
% the z points to be sqrt(1 - zk^2)

% Again the tolerance for each function can be adjusted using the `tol`
% variable at the top of each function.
%
% To modify the number of Chebyshev nodes, modify the variable `n` at the
% top of each function.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function testSphererM(testCase)
    tol = .001;
    n = 40;
    
    w = linspace(0.1,1,10);
    rundir = fullfile(tempdir, 'WecOptTool_testSphererM');
    
    % using n points, preallocating space for speed.
    z = 1:n;
    r = 1:n;
    
    % want the top and bottom of sphere to be accounted for
    z(1) = 1;
    z(n) = -1;
    r(1) = 0;
    r(n) = 0;
    
    %chebyshev node formula: 
    %for k in 1..n
    %zk = cos((2k-1)/2n*pi)
    
    %using n-2 chebyshev nodes, to round out the array of size n
    
    for k = 1:(n-2)
        zk = cos((2*k-1)/(2*(n-2)) * pi);
        z(k+1) = zk;
        r(k+1) = sqrt(1 - zk^2); 
    end
    
    [hydro] = WecOptLib.nemoh.getNemoh(r,z,w,rundir);
    
    mAct = hydro.Vo * hydro.rho;
    mExp = 2.133340700000000e+03;
   
    verifyEqual(testCase, mAct, mExp, 'RelTol', tol)
    
    WecOptLib.nemoh.cleanNemoh(rundir);
    
end

function testSphereA(testCase)
    tol = .001;
    n = 40;
    
    w = linspace(0.1,1,10);
    rundir = fullfile(tempdir, 'WecOptTool_testSphereA');
    
    % using n points, preallocating space for speed.
    z = 1:n;
    r = 1:n;
    
    % want the top and bottom of sphere to be accounted for
    z(1) = 1;
    z(n) = -1;
    r(1) = 0;
    r(n) = 0;
    
    %chebyshev node formula: 
    %for k in 1..n
    %zk = cos((2k-1)/2n*pi)
    
    %using n-2 chebyshev nodes, to round out the array of size n
    
    for k = 1:(n-2)
        zk = cos((2*k-1)/(2*(n-2)) * pi);
        z(k+1) = zk;
        r(k+1) = sqrt(1 - zk^2); 
    end
    
    [hydro] = WecOptLib.nemoh.getNemoh(r,z,w,rundir);
    
    AAct = squeeze(hydro.A(3,3,:))*hydro.rho;
    AExp = [1.805080000000000e+03;...
            1.822259000000000e+03;...
            1.846489000000000e+03;...
            1.866336000000000e+03;...
            1.882618000000000e+03;...
            1.893489000000000e+03;...
            1.897963000000000e+03;...
            1.895358000000000e+03;...
            1.884580000000000e+03;...
            1.866094000000000e+03];
  
    verifyEqual(testCase, AAct, AExp, 'RelTol', tol)
    
    WecOptLib.nemoh.cleanNemoh(rundir);
    
end

function testSphereAinf(testCase)
    tol = .001;
    n = 40;
    
    w = linspace(0.1,1,10);
    rundir = fullfile(tempdir, 'WecOptTool_testSphereAinf');
    
    % using n points, preallocating space for speed.
    z = 1:n;
    r = 1:n;
    
    % want the top and bottom of sphere to be accounted for
    z(1) = 1;
    z(n) = -1;
    r(1) = 0;
    r(n) = 0;
    
    %chebyshev node formula: 
    %for k in 1..n
    %zk = cos((2k-1)/2n*pi)
    
    %using n-2 chebyshev nodes, to round out the array of size n
    
    for k = 1:(n-2)
        zk = cos((2*k-1)/(2*(n-2)) * pi);
        z(k+1) = zk;
        r(k+1) = sqrt(1 - zk^2); 
    end
    
    [hydro] = WecOptLib.nemoh.getNemoh(r,z,w,rundir);

    AinfAct = hydro.Ainf(3,3)*hydro.rho;
    AinfExp = 1.866094000000000e+03;
    
    verifyEqual(testCase, AinfAct, AinfExp, 'RelTol', tol)
    
    WecOptLib.nemoh.cleanNemoh(rundir);
    
end

function testSphereB(testCase)
    tol = .001;
    n = 40;
    
    w = linspace(0.1,1,10);
    rundir = fullfile(tempdir, 'WecOptTool_testSphereB');
    
    % using n points, preallocating space for speed.
    z = 1:n;
    r = 1:n;
    
    % want the top and bottom of sphere to be accounted for
    z(1) = 1;
    z(n) = -1;
    r(1) = 0;
    r(n) = 0;
    
    %chebyshev node formula: 
    %for k in 1..n
    %zk = cos((2k-1)/2n*pi)
    
    %using n-2 chebyshev nodes, to round out the array of size n
    
    for k = 1:(n-2)
        zk = cos((2*k-1)/(2*(n-2)) * pi);
        z(k+1) = zk;
        r(k+1) = sqrt(1 - zk^2); 
    end
    
    [hydro] = WecOptLib.nemoh.getNemoh(r,z,w,rundir);
    
    BAct = squeeze(hydro.B(3,3,:)).*w'*hydro.rho;
    BExp = [0.517412700000000;...
            4.108027000000001;...
            13.687960000000000;...
            31.861250000000002;...
            60.774350000000000;...
            1.019905000000000e+02;...
            1.564007000000000e+02;...
            2.241753000000000e+02;...
            3.047622000000000e+02;...
            3.969600000000000e+02];
        
    verifyEqual(testCase, BAct, BExp, 'RelTol', tol);
    
    WecOptLib.nemoh.cleanNemoh(rundir);
    
end

function testSphereEx(testCase)
    tol = .001;
    n = 40;
    
    w = linspace(0.1,1,10);
    rundir = fullfile(tempdir, 'WecOptTool_testSphereEx');
    
    % using n points, preallocating space for speed.
    z = 1:n;
    r = 1:n;
    
    % want the top and bottom of sphere to be accounted for
    z(1) = 1;
    z(n) = -1;
    r(1) = 0;
    r(n) = 0;
    
    %chebyshev node formula: 
    %for k in 1..n
    %zk = cos((2k-1)/2n*pi)
    
    %using n-2 chebyshev nodes, to round out the array of size n
    
    for k = 1:(n-2)
        zk = cos((2*k-1)/(2*(n-2)) * pi);
        z(k+1) = zk;
        r(k+1) = sqrt(1 - zk^2); 
    end
    [hydro] = WecOptLib.nemoh.getNemoh(r,z,w,rundir);
    
    ExAct = (squeeze(hydro.ex_re(3,1,:)) + ...
                1i * squeeze(hydro.ex_im(3,1,:))) * hydro.rho * hydro.g;
    ExExp = [3.135264999995731e+04 + 5.174237563772652e-02i;...
             3.123397998919338e+04 + 8.216251484554422e-01i;...
             3.103439972829488e+04 + 4.106630071455531e+00i;...
             3.075387735867814e+04 + 1.274604976429039e+01i;...
             3.039233480194188e+04 + 3.039422925936637e+01i;...
             2.995119743334907e+04 + 6.122006325009694e+01i;...
             2.943299609927892e+04 + 1.095575640094596e+02i;...
             2.884138117499728e+04 + 1.795407533474796e+02i;...
             2.818175074881988e+04 + 2.747483930624004e+02i;...
             2.745981680392228e+04 + 3.979351517871062e+02i];
         
     verifyEqual(testCase, ExAct, ExExp, 'RelTol', tol)
     
     WecOptLib.nemoh.cleanNemoh(rundir);
     
end

function testSphereC(testCase)
    tol = .001;
    n = 40;
    
    w = linspace(0.1,1,10);
    rundir = fullfile(tempdir, 'WecOptTool_testSphereC');
    
    % using n points, preallocating space for speed.
    z = 1:n;
    r = 1:n;
    
    % want the top and bottom of sphere to be accounted for
    z(1) = 1;
    z(n) = -1;
    r(1) = 0;
    r(n) = 0;
    
    %chebyshev node formula: 
    %for k in 1..n
    %zk = cos((2k-1)/2n*pi)
    
    %using n-2 chebyshev nodes, to round out the array of size n
    
    for k = 1:(n-2)
        zk = cos((2*k-1)/(2*(n-2)) * pi);
        z(k+1) = zk;
        r(k+1) = sqrt(1 - zk^2); 
    end
    [hydro] = WecOptLib.nemoh.getNemoh(r,z,w,rundir);

    CAct = hydro.C(3,3)*hydro.rho*hydro.g;
    CExp = 3.139205000000000e+04;
    
    verifyEqual(testCase, CAct, CExp, 'RelTol', tol)
    
    WecOptLib.nemoh.cleanNemoh(rundir);
end

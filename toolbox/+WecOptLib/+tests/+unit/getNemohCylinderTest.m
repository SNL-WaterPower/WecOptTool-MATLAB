
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

% Notes: 
%
% Tests cylinder shaped geometries
%
% All test functions use a relative tolerance.  to adjust the tolerance,
% modify the `tol` property of the class.
%
% Currently all verifications are based off of run data from a working
% version.  A more analytic approach may be taken at a later date.
%

classdef getNemohCylinderTest < matlab.unittest.TestCase
 
    properties
        tol = .001
        w = linspace(0.1,1,10)
        hydro
    end
 
    methods(TestClassSetup)
        
        function runNEMOH(testCase)
            
            import matlab.unittest.fixtures.TemporaryFolderFixture
            tempFixture = testCase.applyFixture(                        ...
                 TemporaryFolderFixture('PreservingOnFailure',  true,   ...
                                        'WithSuffix', 'testCylinderM'));

            r=[0 1 1 0]; 
            z=[.5 .5 -.5 -.5];

            [testCase.hydro] = ...
                WecOptLib.nemoh.getNemoh(r,             ...
                                         z,             ...
                                         testCase.w,    ...
                                         tempFixture.Folder);
            
        end
        
    end
    
    methods(Test)
    
        function testCylinderM(testCase)
            
            mAct = testCase.hydro.Vo * testCase.hydro.rho;
            mExp = 1602.74022500000;

            verifyEqual(testCase, mAct, mExp, 'RelTol', testCase.tol)

        end


        function testCylinderA(testCase)
            
            AAct = squeeze(testCase.hydro.A(3,3,:)) * testCase.hydro.rho;

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

            verifyEqual(testCase, AAct, AExp, 'RelTol', testCase.tol)

        end

        function testCylinderAinf(testCase)

            AinfAct = testCase.hydro.Ainf(3,3) * testCase.hydro.rho;
            AinfExp = 2.496468000000000e+03;

            verifyEqual(testCase, AinfAct, AinfExp, 'RelTol', testCase.tol)

        end

        function testCylinderB(testCase)

            BAct = squeeze(testCase.hydro.B(3,3,:)).*testCase.w' * ...
                                                    testCase.hydro.rho;
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
            
            verifyEqual(testCase, BAct, BExp, 'RelTol', testCase.tol)

        end

        function testCylinderEx(testCase)

            ExAct = (squeeze(testCase.hydro.ex_re(3,1,:)) + ...
                        1i * squeeze(testCase.hydro.ex_im(3,1,:))) *    ...
                                     testCase.hydro.rho *               ...
                                     testCase.hydro.g;
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

             verifyEqual(testCase, ExAct, ExExp, 'RelTol', testCase.tol);

        end

        function testCylinderC(testCase)

            CAct = testCase.hydro.C(3,3) * testCase.hydro.rho *     ...
                                                        testCase.hydro.g;
            CExp = 3.144575000000000e+04;
            verifyEqual(testCase, CAct, CExp, 'RelTol', testCase.tol);

        end
        
    end
    
end



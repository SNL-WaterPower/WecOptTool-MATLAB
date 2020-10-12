classdef getNemohSphereTest < matlab.unittest.TestCase
    % Notes: 
    %
    % Tests sphere shaped geometries.
    %
    % All test functions use a relative tolerance.  to adjust the tolerance,
    % modify the `tol` property of the class.
    %
    % Currently all verifications are based off of run data from a working
    % version.  A more analytic approach may be taken at a later date.

    % Copyright 2020 National Technology & Engineering Solutions of Sandia, 
    % LLC (NTESS). Under the terms of Contract DE-NA0003525 with NTESS, the 
    % U.S. Government retains certain rights in this software.
    %
    % This file is part of WecOptTool.
    % 
    %     WecOptTool is free software: you can redistribute it and/or 
    %     modify it under the terms of the GNU General Public License as 
    %     published by the Free Software Foundation, either version 3 of 
    %     the License, or (at your option) any later version.
    % 
    %     WecOptTool is distributed in the hope that it will be useful,
    %     but WITHOUT ANY WARRANTY; without even the implied warranty of
    %     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    %     GNU General Public License for more details.
    % 
    %     You should have received a copy of the GNU General Public 
    %     License along with WecOptTool.  If not, see 
    %     <https://www.gnu.org/licenses/>.
    
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

            n = 40;

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

            ntheta = 20;
            nfobj = 200;
            
            meshes = WecOptTool.mesh("AxiMesh",             ...
                                     tempFixture.Folder,    ...
                                     r,                     ...
                                     z,                     ...
                                     ntheta,                ...
                                     nfobj,                 ...
                                     1);
    
            testCase.hydro = WecOptTool.solver("NEMOH",             ...
                                               tempFixture.Folder,  ...
                                               meshes,              ...
                                               testCase.w);
            
        end
        
    end
    
    methods(Test)
    
        function testSphereA(testCase)

            AAct = squeeze(testCase.hydro.A(3,3,:)) * testCase.hydro.rho;
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

            verifyEqual(testCase, AAct, AExp, 'RelTol', testCase.tol)

        end

        function testSphereAinf(testCase)

            AinfAct = testCase.hydro.Ainf(3,3) * testCase.hydro.rho;
            AinfExp = 1.866094000000000e+03;

            verifyEqual(testCase, AinfAct, AinfExp, 'RelTol', testCase.tol)

        end

        function testSphereB(testCase)

            BAct = squeeze(testCase.hydro.B(3,3,:)).*testCase.w' *  ...
                                                    testCase.hydro.rho;
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

            verifyEqual(testCase, BAct, BExp, 'RelTol', testCase.tol);

        end

        function testSphereEx(testCase)

            ExAct = squeeze(testCase.hydro.ex(3,1,:)) * ...
                            testCase.hydro.rho * testCase.hydro.g;
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

             verifyEqual(testCase, ExAct, ExExp, 'RelTol', testCase.tol)

        end

        function testSphereC(testCase)

            CAct = testCase.hydro.C(3,3) * testCase.hydro.rho * ...
                                                        testCase.hydro.g;
            CExp = 3.139205000000000e+04;

            verifyEqual(testCase, CAct, CExp, 'RelTol', testCase.tol)

        end
        
    end
    
end



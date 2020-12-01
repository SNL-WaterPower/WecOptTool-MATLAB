classdef GmshNemohCylinderTest < matlab.unittest.TestCase
    % Notes: 
    %
    % Tests cylinder shaped geometries with Gmsh and Nemoh
    %
    % All test functions use a relative tolerance. To adjust the tolerance,
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
            
            installed = WecOptTool.mesh.Gmsh.isGmshInPath();
            testCase.assumeTrue(boolean(installed),     ...
                                'Gmsh not installed')
                                    
            meshes = WecOptTool.mesh("Gmsh",                    ...
                                     tempFixture.Folder,        ...
                                     "cylinder.geo",            ...
                                     1,                         ...
                                     "bottom", -0.5,            ...
                                     "xzSymmetric", true);
            
            testCase.hydro = WecOptTool.solver("NEMOH",             ...
                                               tempFixture.Folder,  ...
                                               meshes,              ...
                                               testCase.w);
            
        end
        
    end
    
    methods(Test)
        
        function testCylinderM(testCase)
            
            mAct = testCase.hydro.Vo * testCase.hydro.rho;
            mExp = 1.606163725000000e+03;
            
            verifyEqual(testCase, mAct, mExp, 'RelTol', testCase.tol)
            
        end
        
        function testCylinderA(testCase)
            
            AAct = squeeze(testCase.hydro.A(3,3,:)) * testCase.hydro.rho;
            
            %expected value off of previous runs
            AExp = [2.452013000000000;  ...
                    2.468481000000000;  ...
                    2.481607000000000;  ...
                    2.504833000000000;  ...
                    2.520626000000000;  ...
                    2.529518000000000;  ...
                    2.533362000000000;  ...
                    2.529162000000000;  ...
                    2.517457000000000;  ...
                    2.499193000000000] * 1.0e+03;
            
            verifyEqual(testCase, AAct, AExp, 'RelTol', testCase.tol)
            
        end
        
        function testCylinderAinf(testCase)
            
            AinfAct = testCase.hydro.Ainf(3,3) * testCase.hydro.rho;
            AinfExp = 2.499193000000000e+03;
            
            verifyEqual(testCase, AinfAct, AinfExp, 'RelTol', testCase.tol)
            
        end
        
        function testCylinderB(testCase)
            
            BAct = squeeze(testCase.hydro.B(3,3,:)).*testCase.w' * ...
                                                    testCase.hydro.rho;
            BExp = [0.005114439000000;  ...
                    0.040597320000000;  ...
                    0.135229900000000;  ...
                    0.314608700000000;  ...
                    0.599709900000000;  ...
                    1.005656000000000;  ...
                    1.540655000000000;  ...
                    2.205822000000000;  ...
                    2.994739000000000;  ...
                    3.894383000000000] * 1.0e+02;
            
            verifyEqual(testCase, BAct, BExp, 'RelTol', testCase.tol)
            
        end
        
        function testCylinderEx(testCase)
            
            ExAct = squeeze(testCase.hydro.ex(3,1,:))   * ...
                                     testCase.hydro.rho * ...
                                     testCase.hydro.g;
            ExExp = [3.147211999995811 + 0.000005134915566i;    ...
                     3.134980998946163 + 0.000081286640192i;    ...
                     3.114529973546449 + 0.000405931954948i;    ...
                     3.085655743083528 + 0.001259171014548i;    ...
                     3.048499523213468 + 0.003000661303820i;    ...
                     3.003213927080010 + 0.006039585471402i;    ...
                     2.949970233739679 + 0.010799080973108i;    ...
                     2.889230905971996 + 0.017680022659339i;    ...
                     2.821462587131328 + 0.027023765137250i;    ...
                     2.747164970313414 + 0.039085344208512i] * 1.0e+04;
             
             verifyEqual(testCase, ExAct, ExExp, 'RelTol', testCase.tol);
             
        end
        
        function testCylinderC(testCase)
            
            CAct = testCase.hydro.C(3,3) * testCase.hydro.rho *     ...
                                                        testCase.hydro.g;
            CExp = 3.151269e+04;
            verifyEqual(testCase, CAct, CExp, 'RelTol', testCase.tol);
            
        end
        
    end
    
end

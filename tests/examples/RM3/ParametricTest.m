classdef ParametricTest < matlab.unittest.TestCase
 
    properties
        SS
        performanceCC
        performanceP
        performancePS
        folder
        rundir
    end
 
    methods(TestClassSetup)
        
        function getPower(testCase)

            import matlab.unittest.fixtures.PathFixture
            
            addFolder = fullfile(WecOptTool.system.getSrcRootPath(),    ...
                                 "examples",                            ...
                                 "RM3");
            testCase.applyFixture(PathFixture(addFolder));
            
            testCase.SS = WecOptTool.SeaState.exampleSpectrum(          ...
                                              "extendFrequencies", 2,   ...
                                              "resampleByStep", 0.05);
            w = testCase.SS.getRegularFrequencies(0.5);
            testCase.folder = WecOptTool.AutoFolder();

            deviceHydro = designDevice('parametric',            ...
                                       testCase.folder.path,    ...
                                       10, 15, 3, 42,           ...
                                       w);
            
            testCase.rundir = deviceHydro.runDirectory;
            
            testCase.performanceP = simulateDevice(deviceHydro,     ...
                                                   testCase.SS,     ...
                                                   'P');
                                        
            testCase.performanceCC = simulateDevice(deviceHydro,    ...
                                                    testCase.SS,    ...
                                                    'CC');
            
            delta_Zmax = 10;
            delta_Fmax = 1e9;
            
            testCase.performancePS = simulateDevice(deviceHydro,    ...
                                                    testCase.SS,    ...
                                                    'PS',           ...
                                                    delta_Zmax,     ...
                                                    delta_Fmax,     ...
                                                    'iter',         ...
                                                    1e-4);
            
        end
        
    end
    
    methods(Test)
    
        function test_existingRunFiles(testCase)
                        
            tol = 1e-12;
            madeFile = testCase.rundir;
            
            deviceHydro = designDevice('existing', madeFile);
            newPerformance = simulateDevice(deviceHydro,   ...
                                            testCase.SS,   ...
                                            'CC');
            
            verifyEqual(testCase,                ...
                        testCase.performanceCC,  ...
                        newPerformance,          ...
                        'RelTol', tol);
            
        end

        function test_runParametric(testCase)
            
            expSol = 4.759798816032207e+06;
            pow = sum(testCase.performanceCC.powPerFreq);
            verifyEqual(testCase, pow, expSol, 'RelTol', 0.001)
                        
        end
        
        function test_bounds(testCase)
            
            % Test that P <= CC
            lower = sum(testCase.performanceP.powPerFreq); 
            upper = sum(testCase.performanceCC.powPerFreq);
            verifyGreaterThanOrEqual(testCase, upper, lower)
            
        end
        
        
        function test_lower_bound(testCase)
            
            % The P controller should be the lower bound for PS
            expSol = sum(testCase.performanceP.powPerFreq); 
            pow = sum(testCase.performancePS.powPerFreq);
            verifyGreaterThanOrEqual(testCase, pow, expSol)
            
        end

        function test_upper_bound(testCase)
            
            % The CC controller should be the upper bound for PS
            expSol = sum(testCase.performanceCC.powPerFreq); 
            pow = sum(testCase.performancePS.powPerFreq);
            verifyLessThanOrEqual(testCase, pow, expSol)
            
        end
        
    end
    
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

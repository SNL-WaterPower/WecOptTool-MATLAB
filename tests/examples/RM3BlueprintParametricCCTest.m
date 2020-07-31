classdef RM3BlueprintParametricCCTest < matlab.unittest.TestCase
 
    properties
        SS
        performance
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
            
            testCase.rundir = deviceHydro.rundir;
            testCase.performance = simulateDevice(deviceHydro,   ...
                                                  testCase.SS,   ...
                                                  'CC');
            
        end
        
    end
    
    methods(Test)
    
        function test_existingRunFiles(testCase)
                        
            tol = 5 * eps;
            madeFile = testCase.rundir;
            
            deviceHydro = designDevice('existing', madeFile);
            newPerformance = simulateDevice(deviceHydro,   ...
                                            testCase.SS,   ...
                                            'CC');
            
            verifyEqual(testCase,                ...
                        testCase.performance,    ...
                        newPerformance,          ...
                        'RelTol', tol);
            
        end

        function test_runParametric(testCase)
            
            expSol = 4.759798816032207e+06;
            pow = sum(testCase.performance.powPerFreq);
            verifyEqual(testCase, pow, expSol, 'RelTol', 0.001)
                        
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

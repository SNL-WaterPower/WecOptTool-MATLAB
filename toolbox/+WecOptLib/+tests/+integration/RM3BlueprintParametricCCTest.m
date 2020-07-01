classdef RM3BlueprintParametricCCTest < matlab.unittest.TestCase
 
    properties
        SS
        blueprint
        device
    end
 
    methods(TestClassSetup)
        
        function getPower(testCase)

            import matlab.unittest.fixtures.PathFixture
            
            addFolder = fullfile(WecOptLib.utils.getSrcRootPath(),  ...
                                 "examples",                        ...
                                 "RM3");
            testCase.applyFixture(PathFixture(addFolder));
            
            S = WecOptLib.tests.data.exampleSpectrum();
            S.ph = rand(length(S.w),1)* 2 * pi;
            [S.w, S.S] = WecOptLib.utils.subSampleFreqs(S);
            testCase.SS = WecOptTool.types("SeaState", S);
            w = testCase.SS.getRegularFrequencies(0.5);

            testCase.blueprint = RM3();
            
            geomMode.type = 'parametric';
            geomMode.params = {10, 15, 3, 42, w};
            cntrlMode.type = 'CC';

            testCase.device = makeDevices(testCase.blueprint,   ...
                                          geomMode,             ...
                                          cntrlMode);
            simulate(testCase.device, testCase.SS);
            
        end
        
    end
    
    methods(Test)
    
        function test_existingRunFiles(testCase)
                        
            tol = 5 * eps;
            madeFile = testCase.device.hydro.rundir;
            geomMode.type = 'existing';
            geomMode.params = {madeFile};
            cntrlMode.type = 'CC';
            
            newDevice = makeDevices(testCase.blueprint,     ...
                                    geomMode,               ...
                                    cntrlMode);
            simulate(newDevice, testCase.SS);
            
            verifyEqual(testCase,                           ...
                        testCase.device.aggregation.pow,    ...
                        newDevice.aggregation.pow,          ...
                        'RelTol', tol);
            
        end

        function test_runParametric(testCase)
            
            expSol = 4.714404025520907e+06;
            verifyEqual(testCase,                           ...
                        testCase.device.aggregation.pow,    ...
                        expSol,                             ...
                        'RelTol', 0.001)
                        
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

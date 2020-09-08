classdef RM3ParametricPSBug < matlab.unittest.TestCase
    % Test class for bug in RM3 example where the PS controller does not
    % generate a sensible answer for the geometry 14.76, 15.71, 2.58, 37.27
    %
    % >>> runtests('bugs\RM3ParametricPSBug.m')
    %
    
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
        SS
        deviceHydro
        performanceCC
        performanceCC2
        performanceP
        performancePS
    end
 
    methods(TestClassSetup)
        
        function getCCPower(testCase)
            
            import matlab.unittest.fixtures.PathFixture
            
            addFolder = fullfile(WecOptTool.system.getSrcRootPath(),    ...
                                 "examples",                            ...
                                 "RM3");
            testCase.applyFixture(PathFixture(addFolder));
            
            testCase.SS = WecOptTool.SeaState.exampleSpectrum(          ...
                                              "extendFrequencies", 2,   ...
                                              "resampleByStep", 0.05);
            
            w = testCase.SS.getRegularFrequencies(0.5);
            folder = WecOptTool.AutoFolder();
            
            testCase.deviceHydro =                                      ...
                               designDevice('parametric',               ...
                                            folder.path,                ...
                                            14.76, 15.71, 2.58, 37.27,  ...
                                            w);
            
            testCase.performanceP =                                    ...
                                simulateDevice(testCase.deviceHydro,   ...
                                               testCase.SS,            ...
                                               'P');
                                        
            testCase.performanceCC =                                    ...
                                simulateDevice(testCase.deviceHydro,    ...
                                               testCase.SS,             ...
                                               'CC');
                                           
            testCase.performanceCC2 =                                    ...
                                simulateDevice(testCase.deviceHydro,    ...
                                               testCase.SS,             ...
                                               'CC2');
            
            delta_Zmax = 10;
            delta_Fmax = 1e9;
            
            testCase.performancePS =                                    ...
                                simulateDevice(testCase.deviceHydro,    ...
                                               testCase.SS,             ...
                                               'PS',                    ...
                                               delta_Zmax,              ...
                                               delta_Fmax,              ...
                                               'iter');
            
        end
        
    end
    
    methods(Test)
        
        function test_bounds(testCase)
            
            % Test that P <= CC
            lower = sum(testCase.performanceP.powPerFreq); 
            upper = sum(testCase.performanceCC.powPerFreq);
            verifyGreaterThanOrEqual(testCase, upper, lower)
            
        end
        
        function test_CC_equal(testCase)
            
            % Test that CC == CC2
            UB = sum(testCase.performanceCC.powPerFreq); 
            CC = sum(testCase.performanceCC2.powPerFreq);
            verifyGreaterThanOrEqual(testCase, UB, CC)
            
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

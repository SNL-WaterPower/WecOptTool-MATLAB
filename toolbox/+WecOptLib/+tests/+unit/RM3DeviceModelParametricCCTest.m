
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

classdef RM3DeviceModelParametricCCTest < matlab.unittest.TestCase
 
    properties
        SS
        WECpow
        etc
    end
 
    methods(TestClassSetup)
        
        function getPower(testCase)
            
            S = WecOptLib.tests.data.exampleSpectrum();
            S.ph = rand(length(S.w),1)* 2 * pi;
            [S.w, S.S] = WecOptLib.utils.subSampleFreqs(S);
            testCase.SS = S;

            RM3Device = WecOptLib.models.RM3.DeviceModel();
            geomOptions = {'spectra', S};
            
            [testCase.WECpow,                                   ...
             testCase.etc] = RM3Device.getPower(S,              ...
                                                'CC',           ...
                                                'parametric',   ...
                                                [10,15,3,42],   ...
                                                geomOptions);
            
        end
        
    end
    
    methods(Test)
    
        function test_existingRunFiles(testCase)
            
            tol = 5 * eps;
            madeFile = testCase.etc.rundir;
            RM3Device = WecOptLib.models.RM3.DeviceModel();
            [existpow,~] = RM3Device.getPower(testCase.SS,  ...
                                              'CC',         ...
                                              'existing',   ...
                                              madeFile);
            
            verifyEqual(testCase,           ...
                        testCase.WECpow,    ...
                        existpow,           ...
                        'RelTol', tol);
            
        end

        function test_runParametric(testCase)
            
            expSol = 4.415667556078834e+06;
            verifyEqual(testCase,           ...
                        testCase.WECpow,    ...
                        expSol,             ...
                        'RelTol', 0.001)
                        
        end
        
    end
    
end



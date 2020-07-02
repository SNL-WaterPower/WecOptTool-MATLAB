classdef SeaStateTest < matlab.unittest.TestCase
 
    properties
        S
        SS
        OriginalDefault
    end
 
    methods(TestClassSetup)
        
        function captureVisibility(testCase)
            testCase.OriginalDefault = get(0,'DefaultFigureVisible');
        end
        
        function setup(testCase)
            
            testCase.S = WecOptLib.tests.data.example8Spectra();
            testCase.SS = WecOptTool.types("SeaState", testCase.S,      ...
                                           "trimFrequencies", 0.01,     ...
                                           "resampleByError", 0.01);
            
        end
        
    end
    
    methods (TestMethodSetup)
        function killPlots (~)
            set(0,'DefaultFigureVisible','off');
        end
    end
    
    methods (TestMethodTeardown)
        function loadPlots (~)
            set(0,'DefaultFigureVisible','on');
        end
    end
    
    methods(TestClassTeardown)
        function checkVisibilityRestored(testCase)
            testCase.assertEqual(get(0,'DefaultFigureVisible'),     ...
                                 testCase.OriginalDefault);
        end
    end
    
    methods(Test)
        
        function testCheck_multiSeaStates(testCase)
            testCase.SS.checkSpectrum(testCase.S)
        end
        
        function test_checkSpectrum_missingFields(testCase)
            S1 = WecOptLib.tests.data.exampleSpectrum();
            S1 = rmfield(S1,'w');
            eID = "WecOptTool:SeaState:checkSpectrum";
            wID = 'SeaState:checkSpectrum:missingFields';
            
            fError = @() verifyError(testCase,                          ...
                                     @() testCase.SS.checkSpectrum(S1), ...
                                     eID);
            verifyWarning(testCase, fError, wID);
        end

        function testCheck_mismatchedLengths(testCase)
            S1 = WecOptLib.tests.data.exampleSpectrum();
            S1.w = [];
            eID = "WecOptTool:SeaState:checkSpectrum";
            wID = 'SeaState:checkSpectrum:mismatchedLengths';
            
            fError = @() verifyError(testCase,                          ...
                                     @() testCase.SS.checkSpectrum(S1), ...
                                     eID);
            verifyWarning(testCase, fError, wID);
        end

        function testCheck_notColumnVectors(testCase)
            S1 = WecOptLib.tests.data.exampleSpectrum();
            S1.w = S1.w';
            eID = "WecOptTool:SeaState:checkSpectrum";
            wID = 'SeaState:checkSpectrum:notColumnVectors';
            
            fError = @() verifyError(testCase,                          ...
                                     @() testCase.SS.checkSpectrum(S1), ...
                                     eID);
            verifyWarning(testCase, fError, wID);
        end

        function testCheck_Positive(testCase)
            S1 = WecOptLib.tests.data.exampleSpectrum();
            S1.w(1) = -1.0;
            eID = "WecOptTool:SeaState:checkSpectrum";
            wID = 'SeaState:checkSpectrum:negativeFrequencies';
            
            fError = @() verifyError(testCase,                          ...
                                     @() testCase.SS.checkSpectrum(S1), ...
                                     eID);
            verifyWarning(testCase, fError, wID);
        end
        
        function testCheck_Monotonic(testCase)
            S1 = WecOptLib.tests.data.exampleSpectrum();
            S1.w(1) = max(S1.w) + 1;
            eID = "WecOptTool:SeaState:checkSpectrum";
            wID = 'SeaState:checkSpectrum:notMonotonic';
            
            fError = @() verifyError(testCase,                          ...
                                     @() testCase.SS.checkSpectrum(S1), ...
                                     eID);
            verifyWarning(testCase, fError, wID);
        end
        
        function testcheckRegular(testCase)
            S1 = WecOptLib.tests.data.exampleSpectrum();
            S1.w(2) = 0.9 * S1.w(2);
            eID = "WecOptTool:SeaState:checkSpectrum";
            wID = 'SeaState:checkSpectrum:notRegular';
            
            fError = @() verifyError(testCase,                          ...
                                     @() testCase.SS.checkSpectrum(S1), ...
                                     eID);
            verifyWarning(testCase, fError, wID);
        end
        
        function testTrimFrequencies(testCase)
            
            wMin=1;
            wMax=100;
            w=linspace(wMin,wMax)';
            S1.w = w;
            
            spectra = zeros(length(w),1);
            oneThird = floor(length(spectra)/3);
            spectra(oneThird:2*oneThird, 1) = 1;
            expectedLength= length(spectra(oneThird:2*oneThird,1));        
            S1.S = spectra;

            % Remove the tails
            noTailsS = testCase.SS.trimFrequencies(S1, 0.01);
            testCase.SS.checkSpectrum(noTailsS);
            lengthS = length(noTailsS.S);
            verifyTrue(testCase, expectedLength==lengthS);
            
        end
        
        function testResampleByStep(testCase)
            
            wMin=0.001;
            wMax=2*pi;
            w=linspace(wMin,wMax)';
            S1.w = w;       
            S1.S = sin(w);

            dw = 0.3;

            resampledS = testCase.SS.resampleByStep(S1, dw);
            testCase.SS.checkSpectrum(resampledS);
            verifyTrue(testCase, all(round(diff(resampledS.w),2)==dw));

        end
        
        function testPlot(testCase)
            verifyWarningFree(testCase, @() testCase.SS.plot())
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
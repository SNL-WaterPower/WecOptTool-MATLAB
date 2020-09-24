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
            
            p = mfilename('fullpath');
            [filepath, ~, ~] = fileparts(p);
            dataPath = fullfile(filepath,       ...
                                '..',           ...
                                'toolbox',      ...
                                '+WecOptTool',  ...
                                'data',         ...
                                'spectrum.mat');
            testCase.S = load(dataPath).S;
            testCase.SS = WecOptTool.SeaState(testCase.S,               ...
                                              "resampleByError", 0.01,  ...
                                              "trimFrequencies", 0.01,  ...
                                              "extendFrequencies", 2);
            
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

        function testSampleError(testCase)
            verifyTrue(testCase, all([testCase.SS.sampleError] == 0.01))
        end
        
        function testTrimLoss(testCase)
            verifyTrue(testCase, all([testCase.SS.trimLoss] == 0.01))
        end
        
        function testFrequencies(testCase)
            l = max(testCase.SS(1).w);
            lbase = max(testCase.SS(1).basew);
            verifyTrue(testCase, 2 * lbase > l && l > lbase)
        end
        
        function testGetAllFrequencies(testCase)
            
            freqs = testCase.SS.getAllFrequencies();
            verifyTrue(testCase, all(freqs >=0))
            verifyTrue(testCase, all(diff(freqs) >= 0))
            verifyTrue(testCase, length(freqs) == length(unique(freqs)))
            
            maxFreqs = 0;
            
            for i = 1:length(testCase.SS)
                maxFreqs = maxFreqs + length(testCase.SS(i).w);
            end
            
            verifyTrue(testCase, length(freqs) <= maxFreqs) 
            
        end
        
        function testGetRegularFrequencies(testCase)
            
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance
            
            dw = 0.1;
            freqs = testCase.SS.getRegularFrequencies(dw);
            verifyTrue(testCase, all(freqs >=0))
            verifyTrue(testCase, all(diff(freqs) >= 0))
            verifyTrue(testCase, length(freqs) == length(unique(freqs)))
            verifyTrue(testCase, length(uniquetol(diff(freqs), 1e-9)) == 1)
            
            dwTest = uniquetol(diff(freqs), 1e-9);
            testCase.assertThat(dwTest,     ...
                    IsEqualTo(dw, 'Within', RelativeTolerance(1e-9)))
            
            allFreqs = testCase.SS.getAllFrequencies();
            verifyTrue(testCase, min(freqs) <= min(allFreqs));
            verifyTrue(testCase, max(freqs) >= max(allFreqs));
            
        end
        
        function testGetAmplitudeSpectrum(testCase)
            % Looking for (Hs/4)^2 where Hs=8 for the test BS spectrum
            spectrum = WecOptTool.SeaState.exampleSpectrum();
            ampSpec = spectrum.getAmplitudeSpectrum();
            verifyEqual(testCase, sum(ampSpec.^2) / 2, 4,       ...
                        'RelTol', 5e-3);
        end
        
        function testPlot(testCase)
            testCase.SS.plot();
        end
        
        function testcheckSpectruMultiSeaStates(testCase)
            testCase.SS.checkSpectrum(testCase.S)
        end
        
        function testCheckSpectrumMissingFields(testCase)
            S1 = testCase.S;
            S1 = rmfield(S1,'w');
            eID = "WecOptTool:SeaState:checkSpectrum";
            wID = 'SeaState:checkSpectrum:missingFields';
            
            fError = @() verifyError(testCase,                          ...
                                     @() testCase.SS.checkSpectrum(S1), ...
                                     eID);
            verifyWarning(testCase, fError, wID);
        end

        function testCheckSpectrumMismatchedLengths(testCase)
            S1 = testCase.S;
            S1.w = [];
            eID = "WecOptTool:SeaState:checkSpectrum";
            wID = 'SeaState:checkSpectrum:mismatchedLengths';
            
            fError = @() verifyError(testCase,                          ...
                                     @() testCase.SS.checkSpectrum(S1), ...
                                     eID);
            verifyWarning(testCase, fError, wID);
        end

        function testCheckSpectrumNotColumnVectors(testCase)
            S1 = testCase.S;
            S1.w = S1.w';
            eID = "WecOptTool:SeaState:checkSpectrum";
            wID = 'SeaState:checkSpectrum:notColumnVectors';
            
            fError = @() verifyError(testCase,                          ...
                                     @() testCase.SS.checkSpectrum(S1), ...
                                     eID);
            verifyWarning(testCase, fError, wID);
        end

        function testCheckSpectrumNegativeFrequencies(testCase)
            S1 = testCase.S;
            S1.w(1) = -1.0;
            eID = "WecOptTool:SeaState:checkSpectrum";
            wID = 'SeaState:checkSpectrum:negativeFrequencies';
            
            fError = @() verifyError(testCase,                          ...
                                     @() testCase.SS.checkSpectrum(S1), ...
                                     eID);
            verifyWarning(testCase, fError, wID);
        end
        
        function testCheckSpectrumNotMonotonic(testCase)
            S1 = testCase.S;
            S1.w(1) = max(S1.w) + 1;
            eID = "WecOptTool:SeaState:checkSpectrum";
            wID = 'SeaState:checkSpectrum:notMonotonic';
            
            fError = @() verifyError(testCase,                          ...
                                     @() testCase.SS.checkSpectrum(S1), ...
                                     eID);
            verifyWarning(testCase, fError, wID);
        end
        
        function testCheckSpectrumNotRegular(testCase)
            S1 = testCase.S;
            S1.w(2) = 0.9 * S1.w(2);
            eID = "WecOptTool:SeaState:checkSpectrum";
            wID = 'SeaState:checkSpectrum:notRegular';
            
            fError = @() verifyError(testCase,                          ...
                                     @() testCase.SS.checkSpectrum(S1), ...
                                     eID);
            verifyWarning(testCase, fError, wID);
        end
        
        function testGetSpecificEnergy(testCase)
            
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance
           
            f = @(x) -1 * (x - 2) .^ 2 + 1;
            S1.w = (1:0.01:3)';
            S1.S = f(S1.w);
            
            result = testCase.SS.getSpecificEnergy(S1, "g", 1, "rho", 1);
            expected = 4 / 3;
            
            testCase.assertThat(result,     ...
                IsEqualTo(expected, 'Within', RelativeTolerance(0.001)))
            
        end
        
        function testGetMaxAbsoluteDensityError(testCase)
            
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance
            
            f = @(x) -1 * (x - 2) .^ 2 + 1;
            S1.w = (1:0.01:3)';
            S1.S = f(S1.w);
            
            S2.w = S1.w;
            S2.S = S1.S - 0.1;
            
            result = testCase.SS.getMaxAbsoluteDensityError(S1, S2);
            
            testCase.assertThat(result,     ...
                    IsEqualTo(0.1, 'Within', RelativeTolerance(1e-9)))
            
        end
        
        function testGetRelativeEnergyError(testCase)
            
            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.RelativeTolerance
            
            f = @(x) -1 * (x - 2) .^ 2 + 1;
            S1.w = (1:0.01:3)';
            S1.S = f(S1.w);
            
            S2.w = S1.w;
            S2.S = S1.S .* 0. + 0.5;
            
            result = testCase.SS.getRelativeEnergyError(S1, S2);
            expected = 1 / 4;
            
            testCase.assertThat(result,     ...
                IsEqualTo(expected, 'Within', RelativeTolerance(0.02)))
            
        end
            
        function testTrimFrequencies(testCase)
            
            wMin = 1;
            wMax = 100;
            w = (wMin:1:wMax)';
            S1.w = w;
            
            spectra = zeros(length(w),1);
            oneThird = floor(length(spectra)/3);
            spectra(oneThird:2*oneThird, 1) = 1;
            expectedLength = length(spectra(1:2*oneThird,1)); 
            S1.S = spectra;

            % Remove the tails
            noTailsS = testCase.SS.trimFrequencies(S1, 0.01);
            testCase.SS.checkSpectrum(noTailsS);
            lengthS = length(noTailsS.S);
            verifyTrue(testCase, expectedLength == lengthS);
            
        end
        
        function testExtendFrequencies(testCase)
            
            wMin = 1;
            wMax = 100;
            w = (wMin:1:wMax)';
            S1.w = w;
            S1.S = w .* 0;
            
            S2 = testCase.SS.extendFrequencies(S1, 2);
            verifyEqual(testCase, length(S2.w), 200);
            
        end
        
        function testResampleByStep(testCase)
            
            wMin = 0;
            wMax = 2*pi;
            w = (wMin:pi/32:wMax)';
            S1.w = w;       
            S1.S = sin(w);

            dw = 0.3;

            resampledS = testCase.SS.resampleByStep(S1, dw);
            testCase.SS.checkSpectrum(resampledS);
            verifyTrue(testCase,    ...
                       all(round(diff(resampledS.w), 2) == dw));

        end
        
        function testResampleByError(testCase)
            
            f = @(x) -1 * (x - 2) .^ 2 + 1;
            S1.w = (1:0.1:3)';
            S1.S = f(S1.w);
            
            S2 = testCase.SS.resampleByError(S1, 0.01);
            
            E1 = testCase.SS.getSpecificEnergy(S1, "g", 1, "rho", 1);
            E2 = testCase.SS.getSpecificEnergy(S2, "g", 1, "rho", 1);
            
            verifyTrue(testCase, E2 < E1)
            
            interpS = interp1(S2.w,             ...
                              S2.S,             ...
                              S1.w,             ...
                              'linear',         ...
                              'extrap');
            
            checkError = abs(S1.S - interpS) / max(S1.S);
            verifyTrue(testCase, all(checkError <= 0.01 + 1e-9))
                          
        end
        
        function testExampleSpectrum(testCase)
        
            test = WecOptTool.SeaState.exampleSpectrum(                 ...
                                            "resampleByError", 0.05,    ...
                                            "trimFrequencies", 0.01,    ...
                                            "extendFrequencies", 4);
                                       
            verifyTrue(testCase, isa(test, "WecOptTool.SeaState"))
            
        end
        
        function testExample8Spectrum(testCase)
        
            test = WecOptTool.SeaState.example8Spectra(                 ...
                                            "resampleByError", 0.05,    ...
                                            "trimFrequencies", 0.01,    ...
                                            "extendFrequencies", 4);
                                       
            verifyTrue(testCase, isa(test, "WecOptTool.SeaState"))
            
        end
        
        function testRegularWave(testCase)
            
            dw = 0.25;
            nf = 50;
            w = dw * (1:nf)';
            test = WecOptTool.SeaState.regularWave(                     ...
                                            w,                          ...
                                            [1, 1],                     ...
                                            "trimFrequencies", 0.01);
            
            verifyTrue(testCase, isa(test, "WecOptTool.SeaState"))
            verifyTrue(testCase, test.S(end) > 0)
            
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

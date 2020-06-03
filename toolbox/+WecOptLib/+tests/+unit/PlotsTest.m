
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

classdef PlotsTest < matlab.unittest.TestCase
    
    properties
        OriginalDefault
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
    
    methods(TestClassSetup)
        function captureVisibility(testCase)
            testCase.OriginalDefault = get(0,'DefaultFigureVisible');
        end
    end
    
    methods(TestClassTeardown)
        function checkVisibilityRestored(testCase)
            testCase.assertEqual(get(0,'DefaultFigureVisible'),     ...
                                 testCase.OriginalDefault);
        end
    end
    
    methods(Test)

        function testPowerPerFreqSingleSpectrum(testCase)
            
            % Fake some inputs
            spectrum = WecOptLib.tests.data.exampleSpectrum();
            etc.freq = {};
            etc.powPerFreq = {};
            etc.freq{1} = spectrum.w;
            etc.powPerFreq{1} = spectrum.S;

            testHandle = @() WecOptLib.plots.powerPerFreq(spectrum, etc);
            verifyWarningFree(testCase, testHandle)
                              
        end
        
        function testPowerPerFreqMultiSpectra(testCase)
            
            % Fake some inputs
            spectra = WecOptLib.tests.data.example8Spectra();
            NSS=length(spectra);
            etc.freq = {};
            etc.powPerFreq = {};
            
            for i = 1:NSS
                spectrum = spectra(i);
                etc.freq{i} = spectrum.w;
                etc.powPerFreq{i} = spectrum.S;
            end
            
            testHandle = @() WecOptLib.plots.powerPerFreq(spectra, etc);
            verifyWarningFree(testCase, testHandle)
                              
        end
    
        function testRemoveTails(testCase)
            % Fake some inputs
            S=struct();
            wMin=1;
            wMax=100;
            w=linspace(wMin,wMax)';
            S.w = w;
            spectra = zeros(length(w),1);
            oneThird = floor(length(spectra)/3);
            spectra(oneThird:2*oneThird, 1) = 1;   
            S.S = spectra;

            % Remove the tails
            noTailsS = WecOptLib.utils.removeSpectraTails(S);
            testHandle = @() WecOptLib.plots.compareNoTailsSS(S, noTailsS);
            
            verifyWarningFree(testCase, testHandle)
                              
        end
        
        function testCompareSpectra(testCase)
            % Fake some inputs
            S=struct();
            wMin=0.001;
            wMax=2*pi;
            w=linspace(wMin,wMax)';
            S.w = w;       
            S.S = sin(w);

            minBins=22;
            maxError=0.01;

            downSampledS = WecOptLib.utils.downSampleSpectra(S,maxError, minBins); 
            testHandle = @() WecOptLib.plots.compareSpectra(S, downSampledS);
            
            verifyWarningFree(testCase, testHandle)
                              
        end
        
    end
    
end

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
            spectrum = WecOptTool.SeaState.exampleSpectrum();
            input.w = spectrum.w;
            input.powPerFreq = spectrum.S;

            WecOptTool.plot.powerPerFreq(input);
                              
        end
        
        function testPowerPerFreqMultiSpectra(testCase)
            
            % Fake some inputs
            spectra = WecOptTool.SeaState.example8Spectra();
            NSS = length(spectra);
            
            for i = 1:NSS
                spectrum = spectra(i);
                input(i).w = spectrum.w;
                input(i).powPerFreq = spectrum.S(2:end);
            end
            
            WecOptTool.plot.powerPerFreq(input);
                              
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

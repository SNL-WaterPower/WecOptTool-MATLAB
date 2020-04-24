
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

classdef ExampleTest < matlab.unittest.TestCase
    
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
        
        function testExample(testCase)
            
            srcRootPath = WecOptLib.utils.getSrcRootPath();
            cd(srcRootPath);
            
            if WecOptLib.utils.hasParallelToolbox()
                verifyWarningFree(testCase, @example);
            else
                verifyWarning(testCase, ...
                              @example, ...
                              'optimlib:commonMsgs:NoPCTLicense');
            end
            
        end
        
        function testScalarExample(testCase)
            
            warning('off', 'WaveSpectra:NoWeighting')
            study = WecOptTool.RM3Study();
            
            S = WecOptLib.tests.data.example8Spectra();
            study.addSpectra(S);
            
            cc = WecOptTool.control.ComplexConjugate();
            study.addControl(cc);

            % Add geometry design variables (scalar)
            x0 = 1.;
            lb = 0.5;
            ub = 2;

            scalar = WecOptTool.geom.Scalar(x0, lb, ub);
            study.addGeometry(scalar);

            options = optimoptions('fmincon');
            options.MaxFunctionEvaluations = 5;
            options.UseParallel = true;

            runStudy = @() WecOptTool.run(study, options);
            
            if WecOptLib.utils.hasParallelToolbox()
                verifyWarningFree(testCase, runStudy);
            else
                verifyWarning(testCase, ...
                              runStudy, ...
                              'optimlib:commonMsgs:NoPCTLicense');
            end
            
            WecOptTool.result(study);
            WecOptTool.plot(study);
            
        end
        
    end
    
end


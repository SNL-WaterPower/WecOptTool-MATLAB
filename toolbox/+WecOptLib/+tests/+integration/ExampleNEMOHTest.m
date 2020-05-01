
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

classdef ExampleNEMOHTest < matlab.unittest.TestCase
    
    properties
        Study
        OriginalDefault
    end
    
    methods (TestMethodSetup)
        function killPlots (~)
            set(0,'DefaultFigureVisible','off');
        end
    end
    
    methods(TestClassSetup)
        
        function captureVisibility(testCase)
            testCase.OriginalDefault = get(0,'DefaultFigureVisible');
        end
        
        function runExample(testCase)
            
            set(0,'DefaultFigureVisible','off');
            
            examplePath = fullfile(WecOptLib.utils.getSrcRootPath(),    ...
                                   "example.m");
            
            % This fills the function namespace with the variables defined
            % in the example
            run(examplePath);
            testCase.Study = study;
            
        end
        
    end
    
    methods(TestClassTeardown)
        function checkVisibilityRestored(testCase)
            set(0,'DefaultFigureVisible',testCase.OriginalDefault);
            testCase.assertEqual(get(0,'DefaultFigureVisible'),     ...
                                 testCase.OriginalDefault);
        end
    end
    
    methods(Test)
        
        function testExample(testCase)
            
            verifyInstanceOf(testCase,          ...
                             testCase.Study,    ...
                             ?WecOptTool.RM3Study)
            
        end

        function testExistingExample(testCase)
            
            warning('off', 'WaveSpectra:NoWeighting')
            
            import WecOptLib.utils.getFolders
            
            study = WecOptTool.RM3Study();
            S = WecOptLib.tests.data.example8Spectra();
            study.addSpectra(S);
            
            cc = WecOptTool.control.ComplexConjugate();
            study.addControl(cc);

            % Add geometry design variables (existing)
            nemohDirs = getFolders(testCase.Study.studyDir,     ...
                                   "absPath", true);
            assertTrue(testCase, isfolder(nemohDirs{1}))
            
            existing = WecOptTool.geom.Existing(nemohDirs{1});
            study.addGeometry(existing);

            WecOptTool.run(study);
            WecOptTool.result(study);
            WecOptTool.plot(study);
            
            warning('on', 'WaveSpectra:NoWeighting')
            
        end
        
    end
    
end


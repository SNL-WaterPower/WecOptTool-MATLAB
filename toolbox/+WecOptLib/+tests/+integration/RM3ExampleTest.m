classdef RM3ExampleTest < matlab.unittest.TestCase
    
    properties
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
            
            examplePath = fullfile(WecOptLib.utils.getSrcRootPath(),    ...
                                   "examples",                          ...
                                   "RM3",                               ...
                                   "example.m");
            
            % This fills the function namespace with the variables defined
            % in the example
            run(examplePath);
            
            verifyInstanceOf(testCase,          ...
                             devices(1),        ...
                             ?WecOptTool.Device)
            
        end
        
        function testExampleOptim(testCase)
            
            examplePath = fullfile(WecOptLib.utils.getSrcRootPath(),    ...
                                   "examples",                          ...
                                   "RM3",                               ...
                                   "example_optim.m");
            
            % This fills the function namespace with the variables defined
            % in the example
            run(examplePath);
            
            verifyInstanceOf(testCase,          ...
                             bestDevice,        ...
                             ?WecOptTool.Device)
            
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

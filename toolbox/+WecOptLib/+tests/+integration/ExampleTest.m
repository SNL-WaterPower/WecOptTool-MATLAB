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
            verifyWarningFree(testCase, @example);
            
        end
        
    end
    
end


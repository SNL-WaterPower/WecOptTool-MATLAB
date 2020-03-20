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
            
            % Get this directories path
            s = what('WecOptLib');
            parts = strsplit(s.path, filesep);
            dirCell = join(parts(1:end-2), filesep);
            cd(dirCell{1});
            verifyWarningFree(testCase, @example);
            
        end
        
    end
    
end


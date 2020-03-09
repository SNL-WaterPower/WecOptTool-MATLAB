function runTests()
%RUNTESTS

    import matlab.unittest.TestRunner;
    import matlab.unittest.TestSuite;
    import matlab.unittest.plugins.TestReportPlugin;

    % Define test suite
    suite = TestSuite.fromPackage('WecOptLib.tests',    ...
                                  'IncludingSubpackages', true);
    
    % Build the runner
    runner = TestRunner.withTextOutput;
    htmlFolder = 'test_results';
    plugin = TestReportPlugin.producingHTML(htmlFolder);

    % Add plugin and run
    runner.addPlugin(plugin);
    runner.run(suite);

end


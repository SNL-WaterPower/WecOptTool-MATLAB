function results = runTests()
%RUNTESTS

    import matlab.unittest.TestRunner;
    import matlab.unittest.TestSuite;
    import matlab.unittest.plugins.TestReportPlugin;

    % Define test suite
    suite = TestSuite.fromPackage('WecOptLib.tests',    ...
                                  'IncludingSubpackages', true);
    
    % Build the runner
    runner = TestRunner.withTextOutput;
    
    % Add HTML plugin
    htmlFolder = 'test_results';
    plugin = TestReportPlugin.producingHTML(htmlFolder);
    runner.addPlugin(plugin);

    % Add PDF
    pdfFile = 'test_results.pdf';
    plugin = TestReportPlugin.producingPDF(pdfFile);
    runner.addPlugin(plugin);

    % Run the tests
    results = runner.run(suite);

end


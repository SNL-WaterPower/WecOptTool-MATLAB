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
    
    p = mfilename('fullpath');
    [filepath, ~, ~] = fileparts(p);
    
    % Add HTML plugin
    htmlFolder = [filepath filesep 'test_results'];
    plugin = TestReportPlugin.producingHTML(htmlFolder);
    runner.addPlugin(plugin);

    % Add PDF
    pdfFile = [filepath filesep 'test_results.pdf'];
    plugin = TestReportPlugin.producingPDF(pdfFile);
    runner.addPlugin(plugin);

    % Run the tests
    results = runner.run(suite);

end


function results = runTests(options)

    arguments
        options.reportHTML = true
        options.reportPDF = true
    end

    import matlab.unittest.TestRunner;
    import matlab.unittest.TestSuite;
    import matlab.unittest.plugins.TestReportPlugin;

    % Define test suite
    suite = TestSuite.fromFolder('tests',    ...
                                 'IncludingSubfolders', true);
    
    % Build the runner
    runner = TestRunner.withTextOutput;
    
    p = mfilename('fullpath');
    [filepath, ~, ~] = fileparts(p);
    
    % Add HTML plugin
    if options.reportHTML    
        htmlFolder = fullfile(filepath,'test_results');
        plugin = TestReportPlugin.producingHTML(htmlFolder);
        runner.addPlugin(plugin);
    end

    % Add PDF plugin
    if options.reportPDF
        pdfFile = fullfile(filepath,'test_results.pdf');
        plugin = TestReportPlugin.producingPDF(pdfFile);
        runner.addPlugin(plugin);
    end

    % Run the tests
    results = runner.run(suite);

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


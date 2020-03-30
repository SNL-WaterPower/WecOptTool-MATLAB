
% Copyright 2020 Sandia National Labs
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
    htmlFolder = fullfile(filepath,'test_results');
    plugin = TestReportPlugin.producingHTML(htmlFolder);
    runner.addPlugin(plugin);

    % Add PDF
    pdfFile = fullfile(filepath,'test_results.pdf');
    plugin = TestReportPlugin.producingPDF(pdfFile);
    runner.addPlugin(plugin);

    % Run the tests
    results = runner.run(suite);

end



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
%     along with Foobar.  If not, see <https://www.gnu.org/licenses/>.

%%%% Purpose: Check that all dependencies are accounted for

%% Init

allfoundflag = true;

fprintf('\nWecOptTool Dependency Checker\n');
fprintf('-------------------------------\n');

%% Required Products

fprintf('\n');
fprintf('Required\n');
fprintf('--------\n');

%% Optimisation Toolbox

% First Check for ToolBox license
optimizationToolboxLicensed = license('test', "Optimization_Toolbox");

% Second check if installed
addons = matlab.addons.installedAddons();

if isempty(addons)
    
    optimizationToolboxInstalled = false;
    
else
    
    iOptimizationToolbox = addons.Name == "Optimization Toolbox";

    if ~iOptimizationToolbox
        optimizationToolboxInstalled = false;
    else
        optimizationToolboxInstalled = ...
                                    addons.Enabled(iOptimizationToolbox);
    end
    
end

if optimizationToolboxLicensed && optimizationToolboxInstalled
    fprintf('Optimization Toolbox:          Found\n');
elseif ~optimizationToolboxLicensed && opmizationToolboxInstalled
    allfoundflag = false;
    fprintf('Optimization Toolbox:          Unlicensed\n');
else
    allfoundflag = false;
    fprintf('Optimization Toolbox:          Not Installed\n');
end

%% Nemoh

nemohTestPath = fullfile(tempdir, "WecOptTool_dependencyCheck");

if ~exist(nemohTestPath, 'dir')
    mkdir(nemohTestPath)
end

nemohExistFlag = WecOptLib.nemoh.isNemohInPath(nemohTestPath);

if nemohExistFlag
    fprintf('NEMOH:                         Found\n');
else
    allfoundflag = false;
    fprintf('NEMOH:                         Not found\n');
end

%% Optional Products

fprintf('\n');
fprintf('Optional\n');
fprintf('--------\n');

%% Parallel Computing Toolbox

[parallelToolboxFound,      ...
 parallelToolboxLicensed,   ...
 parallelToolboxInstalled] = WecOptLib.utils.hasParallelToolbox();

if parallelToolboxFound
    fprintf('Parallel Toolbox:              Found\n');
elseif ~parallelToolboxLicensed && parallelToolboxInstalled
    fprintf('Parallel Toolbox:              Unlicensed\n');
else
    fprintf('Paralell Toolbox:              Not Installed\n');
end

%% WAFO

wafoFunction = 'bretschneider';
wafoPath = fullfile('wafo', 'spec','bretschneider.m');

wafoCheck = lower(which(wafoFunction));

% Don't set allfoundflag for missing optional deps
if contains(wafoCheck, wafoPath) && (exist(wafoCheck, 'file') == 2)
    fprintf('WAFO:                          Found\n');
else
    fprintf('WAFO:                          Not found\n');
end

fprintf('\n')

%% Warn if execution not possible

if ~allfoundflag
    warning("Mandatory dependencies are missing!")
end

%% Cleanup
WecOptLib.utils.rmdirRetry(nemohTestPath);

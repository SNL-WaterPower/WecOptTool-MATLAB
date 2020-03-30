
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
optimizationToolboxLicense = license('test', "Optimization_Toolbox");

% Second check if installed
installedProducts = ver;
installedNames = {installedProducts(:).Name};
optimizationToolboxInstalled = false;

for name = installedNames
    if contains(name, "Optimization Toolbox")
        optimizationToolboxInstalled = true;
        break
    end
end

if optimizationToolboxLicense && optimizationToolboxInstalled
    fprintf('Optimization Toolbox:          Found\n');
elseif ~optimizationToolboxLicense && opmizationToolboxInstalled
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

% First check for license
parallelToolboxLicense = license('test', "Distrib_Computing_Toolbox");

% Second check if installed
for name = installedNames
    if contains(name, "Parallel Computing Toolbox")
        parallelToolboxInstalled = true;
        break
    end
end

if parallelToolboxLicense && parallelToolboxInstalled
    fprintf('Parallel Toolbox:              Found\n');
elseif ~parallelToolboxLicense && parallelToolboxInstalled
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

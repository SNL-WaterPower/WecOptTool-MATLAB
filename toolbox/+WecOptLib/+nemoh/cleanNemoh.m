
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

function [] = cleanNemoh(rundir)
% [] = cleanNemoh(dir)
%
% Removes the files created by NEMOH
%
% Input
%       rundir     (optional) specificy target directory
%
% RG Coe 2018
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 1
    rundir = '.';
end

delete(fullfile(rundir,'Nemoh.cal'), ...
    fullfile(rundir,'ID.dat'), ...
    fullfile(rundir,'Mesh.cal'), ...
    fullfile(rundir,'Normalvelocities.dat'),...
    fullfile(rundir,'input.txt'));
delete(fullfile(rundir,'results','*'),fullfile(rundir,'mesh','*'));

status = rmdir(fullfile(rundir,'results'));
status = rmdir(fullfile(rundir,'mesh'));
status = rmdir(rundir);

end

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


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

function [srcRootPath] = getSrcRootPath()
%getSrcRootPath Return path to WecOptTool src code root directory
    p = mfilename('fullpath');
    [pDir, ~, ~] = fileparts(p);
    parts = strsplit(pDir, filesep);
    srcRootPath = fullfile(parts{1:end-3});
    
    % Linux requires a leading slash
    if ~ispc
        srcRootPath = append(filesep, srcRootPath);
    end
    
end


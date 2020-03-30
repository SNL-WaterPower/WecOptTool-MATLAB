
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

function [WOTDataPath] = getUserPath()
%GETUSERPATH Return path to WecOptTool user data directory
    if ispc
        appDataPath = getenv('APPDATA');
        WOTDataPath = fullfile(appDataPath, 'WecOptTool');
    else
        appDataPath = getenv('HOME');
        WOTDataPath = fullfile(appDataPath, '.wecopttool');
    end
end


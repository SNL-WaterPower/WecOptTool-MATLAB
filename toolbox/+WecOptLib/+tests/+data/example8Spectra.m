
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

function SS = example8Spectra
%EXAMPLE8SPECTRA Example Bretschneider spectrum with varying HHm0s, Tps, 
%                Nbins, and range
    p = mfilename('fullpath');
    [filepath, ~, ~] = fileparts(p);
    dataPath = fullfile(filepath, '8spectra.mat');
    example_data = load(dataPath);
    SS = example_data.SS;
end

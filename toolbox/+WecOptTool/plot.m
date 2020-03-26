
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

function plot(study)
    % PLOT Plots frequency vs. power for optimized study geometry
    
    disp("Generating plot...")
    
    RM3Device = WecOptLib.models.RM3.DeviceModel();
    [~, etc] = RM3Device.getPower(study.spectra,                    ...
                                  study.controlType,                ...
                                  study.geomMode,                   ...
                                  study.out{1},                     ...
                                  study.controlParams);

    % Power vs Frequency Plot
    WecOptLib.plots.powerPerFreq(study.spectra, etc);
    
end

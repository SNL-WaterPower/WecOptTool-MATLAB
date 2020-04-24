
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

function plot(study)
    % Plots frequency vs. power for optimized study
    % 
    % Args:
    %     study (:mat:class:`+WecOptTool.RM3Study`):
    %         executed RM3Study object
    
    disp("Generating plot...")
    
    % Add SS to geomOptions for parametric mode
    if strcmp(study.geomMode, 'parametric')
        geomOptions = [study.geomOptions, {'spectra', study.spectra}];
    else
        geomOptions = study.geomOptions;
    end
    
    RM3Device = WecOptLib.models.RM3.DeviceModel();
    [~, etc] = RM3Device.getPower(study.studyDir,                   ...
                                  study.spectra,                    ...
                                  study.controlType,                ...
                                  'existing',                       ...
                                  study.out.rundir,                 ...
                                  geomOptions,                      ...
                                  study.controlParams);

    % Power vs Frequency Plot
    WecOptLib.plots.powerPerFreq(study.spectra, etc);
    
end

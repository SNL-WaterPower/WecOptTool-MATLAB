function plotFreq(device)
            
    % Look at first sea state only

    figure('Name','SimRes.plotFreq')
    ax(1) = subplot(2,1,1);
    hold on
    grid on
    ax(2) = subplot(2,1,2);
    hold on
    grid on

    fns = ["eta", "F0", "u", "Fpto"];
    vrs = {device.motions(1).eta_fd    ...
           device.motions(1).F0        ...
           device.performances(1).u    ...
           device.performances(1).Fpto};
    mrks = {'o','.','+','s'};

    for ii = 1:length(fns)

        stem(ax(1),device.motions(1).w, abs(vrs{ii}), mrks{ii},...
            'DisplayName', fns{ii})
        stem(ax(2),device.motions(1).w, angle(vrs{ii}), mrks{ii},...
            'DisplayName', fns{ii})
    end

    ylabel(ax(1),'Magnitude')
    ylabel(ax(2),'Angle [rad]')
    xlabel('Frequency [rad/s]')

    legend(ax(1))
    linkaxes(ax,'x')

end

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

function plotTime(device ,t)
    
    if nargin < 2
        trep = 2*pi/(device.motions(1).w(2) - device.motions(1).w(1));
        t = 0:0.05:trep;
    end

    figure('Name','SimRes.plotTime')

    for ii = 1:5
        ax(ii) = subplot(5, 1, ii);
        hold on
        grid on
    end


    for jj = 1:length(device.motions)
        fns = {"eta", "F0", "u", "Fpto"};
        vrs = {device.motions(jj).eta_fd    ...
               device.motions(jj).F0        ...
               device.performances(jj).u    ...
               device.performances(jj).Fpto};
        for ii = 1:length(fns)
            timeRes.(fns{ii}) = getTimeRes(device.motions(jj).w,    ...
                                           vrs{ii},                 ...
                                           t);
        end
        timeRes.pow = timeRes.u .* timeRes.Fpto;

        fns = [fns(:)', {'pow'}];

        for ii = 1:length(fns)
            plot(ax(ii),t,timeRes.(fns{ii}))
            ylabel(ax(ii),fns{ii})
        end
        for ii = 1:length(ax) - 1
            set(ax(ii),'XTickLabel',[])
        end
        linkaxes(ax,'x')
        xlabel(ax(end),'Time [s]')
    end
    
    xlim([t(1), t(end)])

end

function [timeRes] = getTimeRes(w, fn, t_vec)
    timeRes = zeros(size(t_vec));
    for ii = 1:length(w) % for each freq. TODO - use IFFT
        timeRes = timeRes ...
            + real(fn(ii) * exp(1i * w(ii) * t_vec));
    end
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


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

function powerPerFreq(spectra, etc)
    %POWERPERFREQ
    
    % Number of Sea-States
    NSS = length(spectra);
    
    multiSeaState = false;
    if NSS>1
        multiSeaState = true;
    end    
    
    figure
    
    if multiSeaState
    
        hold on

        for i = 1 : length(etc.powPerFreq)
            
            powPerFreq = etc.powPerFreq{i};
            freq = etc.freq{i};
            plot(freq, powPerFreq,'DisplayName',int2str(i))

        end

        legend()
        
    else
        
        powPerFreq = etc.powPerFreq{1};
        freq = etc.freq{1};
        plot(freq, powPerFreq)
        
    end
        
    xlabel('Frequency [$\omega$]','Interpreter','latex')
    ylabel('Power [$W]$','Interpreter','latex')
    grid
    
end


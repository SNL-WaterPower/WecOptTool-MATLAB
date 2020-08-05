function powerPerFreq(input)
    % Plots power per frequency for a simulated device.
    %
    % Arguments:
    %   input (struct):
    %       A struct array with fields defined in the table below
    %
    % ============  ================  =====================================
    % **Variable**  **Format**        **Description**
    % w             Nx1 float array   N sea-state frequencie
    % powPerFreq    Nx1 float array   Power production per frequency
    % ============  ================  =====================================
    %
    
    % Copyright 2020 National Technology & Engineering Solutions of Sandia, 
    % LLC (NTESS). Under the terms of Contract DE-NA0003525 with NTESS, the 
    % U.S. Government retains certain rights in this software.
    %
    % This file is part of WecOptTool.
    % 
    %     WecOptTool is free software: you can redistribute it and/or 
    %     modify it under the terms of the GNU General Public License as 
    %     published by the Free Software Foundation, either version 3 of 
    %     the License, or (at your option) any later version.
    % 
    %     WecOptTool is distributed in the hope that it will be useful,
    %     but WITHOUT ANY WARRANTY; without even the implied warranty of
    %     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    %     GNU General Public License for more details.
    % 
    %     You should have received a copy of the GNU General Public 
    %     License along with WecOptTool.  If not, see 
    %     <https://www.gnu.org/licenses/>.
    
    % Number of Sea-States
    NSS = length(input);
    
    multiSeaState = false;
    if NSS>1
        multiSeaState = true;
    end    
    
    figure
    
    if multiSeaState
    
        hold on

        for i = 1 : NSS
            
            freq = input(i).w;
            powPerFreq = input(i).powPerFreq;
            plot(freq, powPerFreq,'DisplayName',int2str(i))

        end

        legend()
        
    else
        
        freq = input(1).w;
        powPerFreq = input(1).powPerFreq;
        plot(freq, powPerFreq)
        
    end
        
    xlabel('Frequency [$\omega$]','Interpreter','latex')
    ylabel('Power [$W]$','Interpreter','latex')
    grid
    
end

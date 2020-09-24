function hydro = existingNEMOH(nemohFolder)
    % A predefined geometry callback for reading an existing NEMOH
    % solution.
    %
    % Arguments:
    %     nemohFolder (string):
    %         Path to the folder containing existing NEMOH output files
    %
    % Returns:
    %    :mat:class:`+WecOptTool.Hydrodynamics`: Hydrodynamics object
    %
    % --
    % See also WecOptTool.Hydrodynamics
    % --
    
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
    
    data = struct();
    data = WecOptTool.vendor.WEC_Sim.Read_NEMOH(data,  ...
                                                nemohFolder);
    hydro = WecOptTool.Hydrodynamics(data,                  ...
                                     "solverName", "NEMOH", ...
                                     "runDirectory", nemohFolder);
    
end

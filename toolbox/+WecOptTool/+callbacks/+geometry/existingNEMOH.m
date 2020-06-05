function hydro = existingNEMOH(folder, nemohFolder)
    % A predefined geometry callback for reading an existing NEMOH
    % solution.
    %
    % Arguments:
    %     nemohFolder (string):
    %         Path to the folder containing NEMOH output files
    %
    % Returns:
    %    Hydro: A populated Hydro object
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
    
    hydro = struct();
    hydro = WecOptLib.vendor.WEC_Sim.Read_NEMOH(hydro,          ...
                                                nemohFolder);
    hydro = WecOptTool.types.Hydro(hydro);
    
end

function hydro = solver(solverName, folder, varargin)
    % Solve a mesh using shortcuts to the ``getHydro`` method of the 
    % defined Solver concrete classes in the :mat:mod:`+WecOptTool.+solver` 
    % package.
    %
    % Arguments:
    %     solverName (string):
    %         Solver routine to use. Current options are:
    %              
    %              * NEMOH (:mat:class:`+WecOptTool.+solver.NEMOH`)
    %
    %     folder (string):
    %         Path to the folder to store output files
    %     varargin:
    %         Arguments to pass to the solver routine. See the ``getHydro``
    %         method of the chosen solver class for details.
    %
    % Returns:
    %    struct: Output struct from chosen solver
    %
    % --
    %
    % See also WecOptTool.solver.NEMOH
    %
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
    
    fullQName = "WecOptTool.solver." + solverName;
    solverHandle = str2func(fullQName);
    solver = solverHandle(folder);
    hydro = solver.getHydro(varargin{:});

end

classdef Hydro < WecOptTool.base.Data
    % Data type for storage of hydrodynamic coefficients
    %
    % This data type defines a set of parameters that are common to the
    % results of boundary element method solvers for floating body
    % hydrodynamics. It is based upon a subset of the variables in the
    % BEMIO hydro data structure, provided by `WEC-Sim 
    % <https://wec-sim.github.io/WEC-Sim/>`_.
    %
    % The following parameters must be provided within the input struct 
    % (any additional parameters given will also be stored within the 
    % created object:
    %
    %     * Nb
    %     * Nf
    %     * Nh
    %     * Vo
    %     * C
    %     * B
    %     * A
    %     * ex_ma
    %     * ex_ph
    %     * ex_re
    %     * ex_im
    %
    % Once created, the parameters in the object are read only, but the
    % object can be converted to a struct, and then modified.
    %
    % Arguments:
    %    input (struct):
    %        A struct (not array) whose fields represent the parameters
    %        to be stored.
    %
    % Attributes:
    %     Nb (int): Number of bodies
    %     Nf (int): Number of wave frequencies
    %     Nh (int): Number of wave headings
    %     Vo (array of float):
    %         displaced volume of bodies (shape [1,Nb])
    %     C (array of float):
    %         linear restoring stiffness (shape [6,6,Nb])
    %     B (array of float):
    %         radiation wave damping (shape [6*Nb,6*Nb,Nf])
    %     A (array of float):
    %         radiation added mass (shape [6*Nb,6*Nb,Nf])
    %     ex_ma (array of float):
    %         magnitude of excitation force (shape [6*Nb,Nh,Nf])
    %     ex_ph (array of float):
    %         phase of excitation force or torque (shape [6*Nb,Nh,Nf])
    %     ex_re (array of float):
    %         real component of excitation force or torque (shape 
    %         [6*Nb,Nh,Nf])
    %     ex_im (array of float):
    %         imaginary component of excitation force or torque (shape 
    %         [6*Nb,Nh,Nf])
    %
    % Methods:
    %    struct(): convert to struct
    %
    % Note:
    %    To create an array of Hydro objects see the
    %    :mat:func:`+WecOptTool.types` function.
    %
    % --
    %
    %  Hydro Properties:
    %     Nb - Number of bodies
    %     Nf - Number of wave frequencies
    %     Nh - Number of wave headings
    %     Vo - displaced volume of bodies (shape [1,Nb])
    %     C - linear restoring stiffness (shape [6,6,Nb])
    %     B - radiation wave damping (shape [6*Nb,6*Nb,Nf])
    %     A - radiation added mass (shape [6*Nb,6*Nb,Nf])
    %     ex_ma - magnitude of excitation force (shape [6*Nb,Nh,Nf])
    %     ex_ph - phase of excitation force or torque (shape [6*Nb,Nh,Nf])
    %     ex_re - real component of excitation force or torque (shape 
    %             [6*Nb,Nh,Nf])
    %     ex_im- imaginary component of excitation force or torque (shape 
    %            [6*Nb,Nh,Nf])
    %
    %  Hydro Methods:
    %    struct - convert to struct
    %
    % See also WecOptTool.types
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
    
    properties (GetAccess=protected)
        meta = struct("name", {"Nb",    ...
                               "Nf",    ...
                               "Nh",    ...
                               "Vo",    ...
                               "C",     ...
                               "B",     ...
                               "A",     ...
                               "ex_ma", ...
                               "ex_ph", ...
                               "ex_re", ...
                               "ex_im"},    ...
                      "validation", {@isnumeric,    ...
                                     @isnumeric,    ...
                                     @isnumeric,    ...
                                     @isnumeric,    ...
                                     @isnumeric,    ...
                                     @isnumeric,    ...
                                     @isnumeric,    ...
                                     @isnumeric,    ...
                                     @isnumeric,    ...
                                     @isnumeric,    ...
                                     @isnumeric});
    end
    
end


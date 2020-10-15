classdef Hydrodynamics
    % Data type for storage of solver hydrodynamics output.
    %
    % This data type defines a set of parameters that are common to the
    % description of wave device hydrodynamics parameters, such as in
    % `WEC-Sim's BEMIO <http://wec-sim.github.io/WEC-Sim/advanced_features.html?highlight=bemio#bemio-hydro-data-structure>`_.
    %
    % The following parameters must be provided within the input struct,
    % which map directly to class attributes (see below):
    %
    %     * ex
    %     * g
    %     * rho
    %     * w
    %     * A
    %     * Ainf
    %     * B
    %     * C
    %     * Nb
    %     * Nh
    %     * Nf
    %     * Vo
    %
    % Note:
    %     Any negative radiation damping coefficients detected for 
    %     individual bodies will be set to zero, automatically.
    %
    % Arguments:
    %    hydroData (struct):
    %        A struct containing the required fields
    %    options: name-value pair options. See below.
    %
    % The following options are supported:
    %
    %    solverName (string):
    %        The name of the solver used to generate the data
    %    runDirectory (string):
    %        Path to the directory containing the solver's output files
    %
    % Attributes:
    %    base (struct):
    %        copy of the input struct
    %    ex (array of double):
    %        complex excitation force or torque ([6*Nb,Nh,Nf])
    %    g (double):
    %        gravitational acceleration
    %    rho (double):
    %        water density
    %    w (array of double):
    %        simulated wave frequencies ([1,Nf])
    %    A (array of double):
    %        radiation added mass ([6*Nb,6*Nb,Nf])
    %    Ainf (array of double):
    %        infinite frequency added mass ([6*Nb,6*Nb])
    %    B (array of double):
    %        radiation wave damping ([6*Nb,6*Nb,Nf])
    %    C (array of double):
    %        hydrostatic restoring stiffness ([6,6,Nb])
    %    Nb (int32):
    %        number of bodies
    %    Nh (int32):
    %        number of wave headings
    %    Nf (int32):
    %        number of wave frequencies
    %    Vo (array of double):
    %        displaced volume ([1,Nb])
    %    solverName (string):
    %        name of solver used to generate hydrodyamic parameters.
    %        Default is "Unknown".
    %    runDirectory (string):
    %        path to folder containing output files of the hydrodynamic
    %        solver. Defaults to "".
    %
    % --
    %
    % Hydrodynamics Properties:
    %     S - spectral density
    %     base - copy of the input struct
    %     ex - complex component of excitation force or torque ([6*Nb,Nh,Nf])
    %     g - gravitational acceleration
    %     rho - water density
    %     w - simulated wave frequencies ([1,Nf])
    %     A - radiation added mass ([6*Nb,6*Nb,Nf])
    %     Ainf - infinite frequency added mass ([6*Nb,6*Nb])
    %     B - radiation wave damping ([6*Nb,6*Nb,Nf])
    %     C - hydrostatic restoring stiffness ([6,6,Nb])
    %     Nb - number of bodies
    %     Nh - number of wave headings
    %     Nf - number of wave frequencies
    %     Vo - displaced volume ([1,Nb])
    %     solverName - name of solver used to generate hydrodyamic parameters. Default is "Unknown".
    %     runDirectory - Path to folder containing output files of the hydrodynamic solver. Defaults to "".
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
    
    properties
        base
        ex
        g
        rho
        w
        A
        Ainf
        B
        C
        Nb
        Nh
        Nf
        Vo
        solverName
        runDirectory
    end
    
    methods
        
        function obj = Hydrodynamics(hydroData, options)
            
            arguments
                hydroData
                options.solverName = "Unknown"
                options.runDirectory = ""
            end
            
            obj.base = hydroData;
            obj.ex = complex(hydroData.ex_re, hydroData.ex_im);
            obj.g = hydroData.g;
            obj.rho = hydroData.rho;
            obj.w = hydroData.w;
            obj.A = hydroData.A;
            obj.Ainf = hydroData.Ainf;
            obj.B = obj.checkDamping(hydroData.B);
            obj.C = hydroData.C;
            obj.Nb = hydroData.Nb;
            obj.Nh = hydroData.Nh;
            obj.Nf = hydroData.Nf;
            obj.Vo = hydroData.Vo;
            obj.solverName = options.solverName;
            obj.runDirectory = options.runDirectory;
            
        end
        
    end
    
    methods (Static, Access=private)
        
        function newB = checkDamping(B)
            % Checks that diagonal radiation damping always positive

            newB = B;

            for ii = 1:size(B, 1)
                Bdiag = squeeze(B(ii,ii,:));
                Bdiag(Bdiag < 0) = 0;
                newB(ii,ii,:) = Bdiag;
            end

        end
    
    end
    
end


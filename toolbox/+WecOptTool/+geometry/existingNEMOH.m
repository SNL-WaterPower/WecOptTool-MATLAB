function hydro = existingNEMOH(nemohFolder)
    % A predefined geometry callback for reading an existing NEMOH
    % solution.
    %
    % Arguments:
    %     nemohFolder (string):
    %         Path to the folder containing existing NEMOH output files
    %
    % Returns:
    %    struct: Hydrodynamic data with fields defined in the table below
    %
    % ============  ========================  ======================================
    % **Variable**  **Format**                **Description**
    % A             [6*Nb,6*Nb,Nf]            radiation added mass
    % Ainf          [6*Nb,6*Nb]               infinite frequency added mass
    % B             [6*Nb,6*Nb,Nf]            radiation wave damping
    % theta         [1,Nh]                    wave headings (deg)
    % body          {1,Nb}                    body names
    % cb            [3,Nb]                    center of buoyancy
    % cg            [3,Nb]                    center of gravity
    % code          string                    BEM code (WAMIT, AQWA, or NEMOH)
    % dof 	        [6 + GBM, Nb] 		      Degrees of freedom (DOF) for each body. Default DOF for each body is 6 plus number of possible generalized body modes (GBM).
    % exc_im        [6*Nb,Nh,Nf]              imaginary component of excitation force or torque
    % exc_K         [6*Nb,Nh,length(ex_t)]    excitation IRF
    % exc_ma        [6*Nb,Nh,Nf]              magnitude of excitation force or torque
    % exc_ph        [6*Nb,Nh,Nf]              phase of excitation force or torque
    % exc_re        [6*Nb,Nh,Nf]              real component of excitation force or torque
    % exc_t         [1,length(ex_t)]          time steps in the excitation IRF
    % exc_w         [1,length(ex_w)]          frequency step in the excitation IRF
    % file          string                    BEM output filename
    % fk_im         [6*Nb,Nh,Nf]              imaginary component of Froude-Krylov contribution to the excitation force or torque
    % fk_ma         [6*Nb,Nh,Nf]              magnitude of Froude-Krylov excitation component
    % fk_ph         [6*Nb,Nh,Nf]              phase of Froude-Krylov excitation component
    % fk_re         [6*Nb,Nh,Nf]              real component of Froude-Krylov contribution to the excitation force or torque
    % g             [1,1]                     gravity
    % h             [1,1]                     water depth
    % Khs             [6,6,Nb]                hydrostatic restoring stiffness
    % Nb            [1,1]                     number of bodies
    % Nf            [1,1]                     number of wave frequencies
    % Nh            [1,1]                     number of wave headings
    % ra_K          [6*Nb,6*Nb,length(ra_t)]  radiation IRF
    % ra_t          [1,length(ra_t)]          time steps in the radiation IRF
    % ra_w          [1,length(ra_w)]          frequency steps in the radiation IRF  
    % rho           [1,1]                     density
    % sc_im         [6*Nb,Nh,Nf]              imaginary component of scattering contribution to the excitation force or torque
    % sc_ma         [6*Nb,Nh,Nf]              magnitude of scattering excitation component
    % sc_ph         [6*Nb,Nh,Nf]              phase of scattering excitation component
    % sc_re         [6*Nb,Nh,Nf]              real component of scattering contribution to the excitation force or torque
    % ss_A          [6*Nb,6*Nb,ss_O,ss_O]     state space A matrix
    % ss_B          [6*Nb,6*Nb,ss_O,1]        state space B matrix
    % ss_C          [6*Nb,6*Nb,1,ss_O]        state space C matrix
    % ss_conv       [6*Nb,6*Nb]               state space convergence flag
    % ss_D          [6*Nb,6*Nb,1]             state space D matrix
    % ss_K          [6*Nb,6*Nb,length(ra_t)]  state space radiation IRF
    % ss_O          [6*Nb,6*Nb]               state space order
    % ss_R2         [6*Nb,6*Nb]               state space R2 fit
    % T             [1,Nf]                    wave periods
    % Vo            [1,Nb]                    displaced volume
    % omega         [1,Nf]                    wave frequencies
    % ============  ========================  ======================================
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
    hydro = WecOptTool.vendor.WEC_Sim.Read_NEMOH(hydro,     ...
                                                 nemohFolder);
    
end

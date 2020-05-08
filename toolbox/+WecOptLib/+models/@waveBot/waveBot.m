classdef waveBot < handle
    % waveBot   WECs based on the Sandia "WaveBot" device
    % The WaveBot is a model-scale wave energy converter (WEC) tested in
    % the Navy's Manuevering and Sea Keeping (MASK) basin. Reports and
    % papers about the WaveBot are available at advweccntrls.sandia.gov.
    %
    % waveBot Properties:
    %   controlType - determines type of controller ('P', 'CC', or 'PS')
    %   geomType - determines way device geometry is set by user
    %   w - determines frequencies for evaluation [rad/s]
    %   studyDir - location to run BEM
    %   hydro - structure created by Read_NEMOH
    %
    % waveBot Methods:
    %   runHydro - defines geometry and runs BEM
    %   plot - plots geometry cross section
    %   simPerformance - simulates the performance of the design
    %
    % See also WECOPTLIB.NEMOH.GETNEMOH, READ_NEMOH
    %
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
    
    properties
        controlType     % 'P', 'CC', or 'PS'
        geomType        % 'scalar' or 'parametric'
        w               % column vector of frequencies [rad/s]
        studyDir        % TODO
        hydro           % TODO
        geom            % TODO
    end
    methods
        function obj = waveBot(controlType,geomType,w)
            % waveBot   creates object of type waveBot
            %
            % Args.
            %   controlType     determines the type of controller that will
            %                   be used to simulate performance, either
            %                   'P'     proportional resistive damping
            %                   'CC'    complex conjugate control (optimal)
            %                   'PS'    pseudo-spectral (numerical optimal)
            %   geomType        determines the way in which device geometry
            %                   is set by the user, either
            %                   'scalar'        all dimensions scaled by a
            %                                   single factor
            %                   'parametric'    geometry defined by major
            %                                   radius (r1), radius at keel
            %                                   (r2), draft of chine (d1),
            %                                   and overall draft (d2)
            %   w               frequency vector [rad/s]
            
            if nargin < 3
                w = 2*pi*linspace(0.05, 2, 50)';
            end

            obj.controlType = controlType;
            obj.geomType = geomType;
            obj.w = w;
            obj.makeStudyDir()
        end
        
        function runHydro(obj, geomDef)
            % runHydro  defines geometry and runs BEM
            %   Defines the cross sectional geometry based and calls the
            %   boundary element model solver to populate the hydro
            %   structure
            %
            % Args.
            %   geomDef     vector with variables to define geometry;
            %               if using geomType = `parametric`
            %                   geomDef = [r1, r2, r3, r4];
            %                   r1 is radius at the deck
            %                   r2 is radius at the keel
            %                   d1 is draft of chine
            %                   d2 is total draft
            %
            %               if using geomType = 'scalar'
            %                   geomDef = [lambda]
            %                   where lambda is a linear scalar for all
            %                   dimensions and the base values are
            %                   r1 = 0.88 m
            %                   r2 = 0.35 m
            %                   d1 = 0.16 m
            %                   d2 = 0.53 m
            
            switch obj.geomType
                case 'parametric'
                    % r1 is radius at the deck
                    % r2 is radius at the keel
                    % d1 is draft of chine
                    % d2 is total draft
                    
                    r1 = geomDef(1);
                    r2 = geomDef(2);
                    d1 = geomDef(3);
                    d2 = geomDef(4);
                    
                    obj.geom.r = [0, r1, r1, r2, 0];
                    obj.geom.z = [0.2, 0.2, -d1, -d2, -d2];
                case 'scalar'
                    lambda = geomDef; % single scalar
                    obj.geom.r = lambda * [0, 0.88, 0.88, 0.35, 0];
                    obj.geom.z = lambda * [0.2, 0.2, -0.16, -0.53, -0.53];
                    
                otherwise
                    error('invalid geometryType')
            end
            obj.hydro = WecOptLib.nemoh.getNemoh(obj.geom.r,obj.geom.z,...
                obj.w,obj.studyDir);
            obj.hydro.w = obj.hydro.w(:);
            obj.hydro.T = obj.hydro.T(:);
        end
        
        function plot(obj, ax)
            % plot  plots geometry cross section
            %
            % Args.
            %   ax  (optional) axes handle (e.g., ax = gca)
            
            
            if nargin < 2
                figure('name','WaveBot Geometry')
                ax = gca;
                plot(ax,[0, 0.88, 0.88, 0.35, 0],...
                    [0.2, 0.2, -0.16, -0.53, -0.53],'.--',...
                    'DisplayName','original')
            end
            
            hold on
            grid on
            plot(ax,obj.geom.r, obj.geom.z,'o-')
            
            legend('location','southeast')
            xlabel('r [m]')
            ylabel('z [m]')
            ylim([-Inf, 0])
        end
        
        
        function simRes = simPerformance(obj, Spect)
            % simPerformance    simulates the performance of the design
            %   finds the maximum power possible for the given design in
            %   the specified conditions
            %
            % Args.
            %   Spect       wave spectrum (or spectra) defined in the style
            %               of WAFO
            % Returns
            %   simRes      structure (TODO - make this a class?)
            %               containing simulation results with fileds
            %               w       frequency vector
            %               eta     complex wave elevation spectrum
            %               Fe      complex excitation spectrum
            %               pow     real power spectrum
            %                       (tot_avg_pow = sum(simRes.pow)
            %               u       complex velocity spectrum
            %               Zpto    PTO impedance
            %               Fpto    complex PTO force spectrum
            %
            % See also JONSWAP
            
            % check spectrum for validity
            WecOptLib.utils.checkSpectrum(Spect)
            
            if isempty(obj.hydro)
                error('cannot simulate performance before calling runHydro(...)')
            end
            
            if length(Spect) > 1                        % TODO
                error('have not added looping for multiple sea states yet')
            end
            
            % interpolate wave spectrum onto BEM        % TODO subsample
            S = interp1(Spect.w,Spect.S,obj.hydro.w,'linear',0);
            S = S(:);
            
            % get wave elevation spectrum
            dw = mean(diff(obj.hydro.w));
            waveAmp = sqrt(2 * dw * S);
            ph = rand(length(S), 1);
            eta_fd = waveAmp .* exp(1i*ph);
            eta_fd = eta_fd(:);
            
            % excitation FRF
            Hex = complex(squeeze(obj.hydro.ex_re(3, 1, :)),...
                squeeze(obj.hydro.ex_im(3, 1, :)))...
                * obj.hydro.g * obj.hydro.rho;
            
            % excitation spectrum
            Fe = Hex .* eta_fd;
            
            % mass
            m = obj.hydro.Vo * obj.hydro.rho;
            
            % hydrostatic stiffness
            K = obj.hydro.C(3,3) * obj.hydro.g * obj.hydro.rho;
            
            % radiation damping FRF
            B = squeeze(obj.hydro.B(3,3,:)) * obj.hydro.rho .* obj.hydro.w;
            
            % added mass FRF
            A = squeeze(obj.hydro.A(3,3,:)) * obj.hydro.rho;
            
            % friction
            Bf = max(B) * 0.1;
            
            % intrinsic impedance
            Zi = B + Bf + 1i * (obj.hydro.w .* (m + A) - K ./ obj.hydro.w);
            
            
            % -------------------------------------------------------------
            switch obj.controlType
                
                case 'CC' % -----------------------------------------------
                    
                    % power (see, e.g., Falnes 2002, eq 3.44)
                    pow = abs(Fe).^2 ./ (8 * real(Zi));
                    
                    % velocity (see, e.g., Falnes 2002, eq 3.46)
                    u = Fe ./ (2 * real(Zi));
                    
                    % PTO impedance (see, e.g., Falnes 2002, eq 6.24)
                    Zpto = conj(Zi);
                    
                    % PTO force
                    Fpto = -Zpto .* u;
                    
                case 'P' % ------------------------------------------------
                    
                    % define objective function for power from a damping
                    % controller (see, e.g., Falnes 2002, pg. 51-52)
                    P_max = @(b) -0.5*b*sum(abs(Fe ./ (Zi + b)).^2);
                    
                    % solve for damping to produce most power (can do
                    % analytically for a single frequency, but must use
                    % numerical solution for spectrum). Note that fval is
                    % the sum of power absorbed (negative being "good") -
                    % the following should be true: -1 * fval = sum(pow),
                    % where pow is the frequency dependent array calculated
                    % below.
                    [B_opt, ~] = fminsearch(P_max, max(real(Zi)));
                    
                    % velocity
                    u = Fe ./ (B_opt + Zi);
                    
                    % power
                    pow = 0.5 * B_opt .* abs(u).^2;
                    
                    % PTO force
                    Fpto = -B_opt .* u;
                    
                    % PTO impedance
                    Zpto = B_opt * ones(size(Zi));
                    
                case 'PS' % -----------------------------------------------
                    error('not yet implemented') % TODO
                    
                otherwise % -----------------------------------------------
                    error('invalid controlType')
            end
            
            % assembly output
            simRes.w = obj.hydro.w;
            simRes.eta = eta_fd;
            simRes.Fe = Fe;
            simRes.pow = pow;
            simRes.u = u;
            simRes.Zpto = Zpto;
            simRes.Fpto = Fpto;
            
        end
    end
    
    methods (Access=protected)
        
        function obj = makeStudyDir(obj)
            
            if obj.studyDir
                errStr = "studyDir is already defined";
                error('WecOptTool:StudyDirDefined', errStr)
            end
            
            % Try to ensure folder is unique and reserved
            obj.studyDir = tempname;
            [status, ~, message] = mkdir(obj.studyDir);
            
            if ~status || strcmp(message, 'MATLAB:MKDIR:DirectoryExists')
                errStr = "Failed to create unique folder";
                error('WecOptTool:NoUniqueFolder', errStr)
            end
            
        end
        
        function obj = rmStudyDir(obj)
            if isfolder(obj.studyDir)
                WecOptLib.utils.rmdirRetry(obj.studyDir);
            end
        end
        
        function delete(obj)
            if ~WecOptLib.utils.isParallel()
                obj.rmStudyDir();
            end
        end
    end
end
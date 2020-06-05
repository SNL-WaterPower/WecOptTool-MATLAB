classdef WaveBot < matlab.mixin.Copyable
    % WaveBot   WECs based on the Sandia "WaveBot" device
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
    %     WecOptTool is distributed in the hope that it will be useful, but
    %     WITHOUT ANY WARRANTY; without even the implied warranty of
    %     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
    %     General Public License for more details.
    %
    %     You should have received a copy of the GNU General Public License
    %     along with WecOptTool.  If not, see
    %     <https://www.gnu.org/licenses/>.
    
    properties
        controlType     % 'P', 'CC', or 'PS'
        geomType        % 'scalar' or 'parametric'
        w               % column vector of frequencies at which to perform
        % analyses [rad/s]
        dw
        studyDir        % TODO
        hydro           % TODO
        geom            % TODO
        delta_Zmax (1,1)  double {mustBePositive} = 0.7 % max PTO travel
        delta_Fmax (1,1)  double {mustBePositive} = 5e3 % max PTO force
        N (1,1) double {mustBePositive} = 12.47 % gear ratio
        Kt (1,1) double {mustBePositive} = 6.17 % torque constant [Nm/A]
        Ke (1,1) double {mustBePositive} = 4.12 % elec. constant [Vs/rad]
        Rw (1,1) double {mustBePositive} = 0.5 % motor winding resistnace [Ohms]
    end
    methods
        function obj = WaveBot(controlType,geomType,w)
            % WaveBot   creates object of type WaveBot
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
            %                   'existing'      TODO
            %   w               column vector of frequencies at which to perform
            %                   analyses [rad/s]
            
            if nargin < 3
                w = 2*pi*linspace(0.05, 2, 50)';
            end
            
            obj.controlType = controlType;
            obj.geomType = geomType;
            obj.w = w;
            obj.dw = w(2) - w(1);
            obj.makeStudyDir();
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
            
            % create a substructure for the raw output from Read_Nemoh
            obj.hydro.raw = WecOptLib.nemoh.getNemoh(obj.geom.r, ...
                obj.geom.z, obj.w,obj.studyDir);
            
            obj.hydro.w = obj.hydro.raw.w(:);
            obj.hydro.T = obj.hydro.raw.T(:);
            obj.hydro.rho = obj.hydro.raw.rho;
            obj.hydro.g = obj.hydro.raw.g;
            obj.hydro.Vo = obj.hydro.raw.Vo;
            
            % mass
            obj.hydro.m = obj.hydro.Vo * obj.hydro.rho;
            
            % hydrostatic stiffness
            obj.hydro.K = obj.hydro.raw.C(3,3) * obj.hydro.raw.g ...
                * obj.hydro.rho;
            
            % radiation damping FRF
            obj.hydro.B = squeeze(obj.hydro.raw.B(3,3,:)) ...
                * obj.hydro.rho .* obj.hydro.w;
            
            % added mass FRF
            obj.hydro.A = squeeze(obj.hydro.raw.A(3,3,:)) * obj.hydro.rho;
            
            % friction
            obj.hydro.Bf = max(obj.hydro.B) * 0.1;
            
            % intrinsic impedance
            obj.hydro.Zi = obj.hydro.B + obj.hydro.Bf + ...
                1i * (obj.hydro.w .* (obj.hydro.m + obj.hydro.A) - ...
                obj.hydro.K ./ obj.hydro.w);
            
            % excitation FRF
            obj.hydro.Hex = complex(squeeze(obj.hydro.raw.ex_re(3, 1, :)),...
                squeeze(obj.hydro.raw.ex_im(3, 1, :)))...
                * obj.hydro.g * obj.hydro.rho;
            
            % reorder the fields for better comprehension
            fl = {'w','T','A','B','Zi','Hex',...
                'K','Bf','Vo','m','rho','g','raw'};
            obj.hydro = orderfields(obj.hydro, fl);
            
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
        
        
        function simResults = simPerformance(obj, Spect)
            % simPerformance    simulates the performance of the design
            %   finds the maximum power possible for the given design in
            %   the specified conditions
            %
            % Args.
            %   Spect       wave spectrum (or spectra) defined in the style
            %               of WAFO by functions such as jonswap,
            %               bretschneider
            % Returns
            %   SimResults  object containing simulation results
            %
            % See also jonswap, bretschneider, WecOptLib.simResults
            
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
            ph = rand(length(S), 1) * 2 * pi;
            eta_fd = waveAmp .* exp(1i*ph);
            eta_fd = eta_fd(:);
            
            % excitation spectrum
            Fe = obj.hydro.Hex .* eta_fd;
            
            % -------------------------------------------------------------
            switch obj.controlType
                
                % since both CC and P can be described in terms of a
                % complex PTO impedance, it is convenient to handle them
                % together
                case {'CC', 'P'} % ----------------------------------------
                    
                    switch obj.controlType
                        
                        case 'CC' % ---------------------------------------
                            
                            % PTO impedance (see, e.g., Falnes 2002, eq 6.24)
                            Zpto = conj(obj.hydro.Zi);
                            
                        case 'P' % ----------------------------------------
                            
                            % define objective function for power from a
                            % damping controller (see, e.g., Falnes 2002,
                            % pg. 51-52)
                            P_max = @(b) -0.5*b*sum(abs(Fe ./ ...
                                (obj.hydro.Zi + b)).^2);
                            
                            % solve for damping to produce most power (can
                            % do analytically for a single frequency, but
                            % must use numerical solution for spectrum).
                            % Note that fval is the sum of power absorbed
                            % (negative being "good") - the following
                            % should be true: -1 * fval = sum(pow), where
                            % pow is the frequency dependent array
                            % calculated below.
                            [B_opt, ~] = fminsearch(P_max, ...
                                max(real(obj.hydro.Zi)));
                            
                            % PTO impedance
                            Zpto = complex(B_opt * ones(size(obj.hydro.Zi)),0);
                            
                    end
                    
                    % velocity
                    u = Fe ./ (Zpto + obj.hydro.Zi);
                    
                    % position
                    pos = u ./ (1i * obj.hydro.w);
                    
                    % PTO force
                    Fpto = -Zpto .* u;
                    
                    % power
                    pow = 0.5 * Fpto .* conj(u);
                    
                case 'PS' % -----------------------------------------------
                    %                     error('not yet implemented') % TODO
                    
                    ps = obj.getPSCoefficients;
                    ps.wave_amp = waveAmp; % TODO
                    
                    % Use mutliple phase realizations for PS at the model
                    % is nonlinear (note that we use the original phasing
                    % from the other cases)
                    n_ph = 5;
                    ph_mat = [ph, rand(length(ps.w), n_ph-1)];
                    
                    
                    freq = ps.W;
                    n_freqs = length(freq);
                    phasePowMat = zeros(n_ph, 1);
                    powPerFreqMat = zeros(n_freqs, n_ph);
                    
                    for ind_ph = 1 : n_ph
                        
                        ph = ph_mat(:, ind_ph);
                        [powTot, fRes(ind_ph), tRes(ind_ph)] = obj.getPSPhasePower(ps, ph);
                        phasePowMat(ind_ph) = powTot;
                        powPerFreqMat(:, ind_ph) = fRes.pow;
                        
                    end
                    
                    ph = ph_mat(:,1);
                    u = fRes(1).vel;
                    pos = fRes(1).pos;
                    Zpto = nan(size(obj.hydro.Zi)); % TODO
                    Fpto = fRes(1).u;
                    pow = powPerFreqMat(:,1);
                    
                otherwise % -----------------------------------------------
                    error('invalid controlType')
            end
            
            % assembly output
            nm = sprintf('WaveBot_%s',obj.controlType); % TODO add datetime?
            simResults = WecOptLib.SimResults(nm);
            simResults.ph = ph;
            simResults.w = obj.hydro.w;
            simResults.eta = eta_fd;
            simResults.Fe = Fe;
            simResults.u = u;
            simResults.pos = pos;
            simResults.Zpto = Zpto;
            simResults.Fpto = Fpto;
            simResults.pow = pow;
            
        end
    end
    
    methods (Access=protected)
        
        function motion = getPSCoefficients(obj)
            % getPSCoefficients   constructs the necessary coefficients and
            % matrices used in the pseudospectral control optimization
            % problem
            %
            % Note that these coefficients are not sea state dependent,
            % thus it is beneficial to find them once only when doing a
            % study involving multiple sea states.
            %
            % Bacelli 2014: Background Chapter 4.1, 4.2; RM3 in section 6.1
            
            % Number of frequency - half the number of Fourier coefficients
            Nf = length(obj.w);
            
            % Collocation points uniformly distributed between 0 and T
            % note that we have 2*Nf collocation points since we will have
            % two Fourier coefficients for each frequency
            Nc = (2*Nf) + 2;
            
            % Rebuild frequency vector to ensure monotonically increasing
            % with w(1) = w0
            w0 = obj.dw;                    % fundamental frequency
            T = 2 * pi/w0;                  % '' period
            W = obj.w(1) + w0 * (0:Nf-1)';
            
            % Building cost function component
            % we will form the cost function as transpose(x) * H x, where x
            % is a vector of [vel, u]; we want the product above to result
            % in power (u*vel)
            H = [0,1;1,0];
            H_mat = 0.5 * kron(H, eye(2*Nf));
            
            % Building matrices B33 and A33
            Adiag33 = zeros(2*Nf-1,1);
            Bdiag33 = zeros(2*Nf,1);
            
            Adiag33(1:2:end) = W.* obj.hydro.A;
            Bdiag33(1:2:end) = obj.hydro.B;
            Bdiag33(2:2:end) = Bdiag33(1:2:end);
            
            Bmat = diag(Bdiag33);
            Amat = diag(Adiag33,1);
            Amat = Amat - Amat';

            G = Amat + Bmat;
            
            B = obj.hydro.Bf * eye(2*Nf);
            C = blkdiag(obj.hydro.K * eye(2*Nf));
            M = blkdiag(obj.hydro.m * eye(2*Nf));
            
            % Building derivative matrix
            d = [W(:)'; zeros(1, length(W))];
            Dphi1 = diag(d(1:end-1), 1);
            Dphi1 = (Dphi1 - Dphi1');
            Dphi = blkdiag(Dphi1);
            
            % scaling factor to improve optimization performance
            m_scale = obj.hydro.m; 
            
            % equality constraints for EOM
            P =  (M*Dphi + B + G + (C / Dphi)) / m_scale;
            Aeq = [P, -eye(2*Nf) ];
            
            % Calculating collocation points for constraints
            tkp = linspace(0, T, 4*(Nc));
            tkp = tkp(1:end);
            Wtkp = W*tkp;
            Phip1 = zeros(2*size(Wtkp,1),size(Wtkp,2));
            Phip1(1:2:end,:) = cos(Wtkp);
            Phip1(2:2:end,:) = sin(Wtkp);
            
            Phip = blkdiag(Phip1);
            
            A_ineq = kron([1 0], Phip1' / Dphi1);
            B_ineq = ones(size(A_ineq, 1),1) * obj.delta_Zmax;
            
            %force constraint section
            siz = size(A_ineq);
            forc =  Phip1';
            
            B_ineq = [B_ineq; ones(siz(1),1) * obj.delta_Fmax/m_scale];
            A_ineq = [A_ineq; kron([0 1], forc)];
            
             
            motion.Nf = Nf;
            motion.T = T;
            motion.W = W;                   % TODO: not sure should be carrying around another omega
            motion.w = obj.hydro.w;
            motion.H_mat = H_mat;
            motion.tkp = tkp;
            motion.Aeq = Aeq;
            motion.A_ineq = A_ineq;
            motion.B_ineq = B_ineq;
            motion.Phip = Phip;
            motion.Phip1 = Phip1;
            motion.Dphi = Dphi;
            motion.m_scale = m_scale;
            
        end
        
        function [powTot, fRes, tRes] = getPSPhasePower(obj, ps, ph)
            %Calculates power using the pseudospectral method given a phase and
            % a descrption of the body movement. Returns total phase power and
            % power per frequency
            
            eta_fd = ps.wave_amp .* exp(1i*ph);
            
            fef3 = zeros(2*ps.Nf,1);
            
            E3 = obj.hydro.Hex .* eta_fd;
            
            fef3(1:2:end) =  real(E3);
            fef3(2:2:end) = -imag(E3);
            
            Beq = [fef3] / ps.m_scale;
            
            % constrained optimiztion
            qp_options = optimoptions('fmincon',  ...
                'Algorithm', 'sqp',               ...
                'Display', 'off',                 ...
                'MaxIterations', 1e3,             ...
                'MaxFunctionEvaluations', 1e5,    ...
                'OptimalityTolerance', 1e-8,      ...
                'StepTolerance', 1e-6);
            
            siz = size(ps.A_ineq);
            X0 = zeros(siz(2),1);
            [y, fval, exitflag, output] = fmincon(@pow_calc,...
                X0,...
                ps.A_ineq,...
                ps.B_ineq,...
                ps.Aeq,...
                Beq,...
                [], [], [],...
                qp_options);
            
            % y is a column vector containing [vel; u] of the
            % pseudospectral coefficients
            tmp = reshape(y,[],2);
            x1hat = tmp(:,1);
            uhat = tmp(:,2);
            Phat = 1/2 * x1hat .* uhat;
            
%             % find the spectra
            ps2spec = @(x) (x(1:2:end) - 1i * x(2:2:end));  % TODO - probably make this a global function
            velFreq = ps2spec(x1hat);                   % TODO - make these complex
            posFreq = velFreq ./ obj.w;
            uFreq = ps.m_scale * ps2spec(uhat);
            powFreq = ps.m_scale * ps2spec(Phat);
            zFreq = uFreq ./ velFreq;

%             % find time histories
            spec2time = @(x) ps.Phip' * x;              % TODO - probably make this a global function
            velT = spec2time(x1hat);
            posT = (ps.Phip' / ps.Dphi) * x1hat;
            uT = ps.m_scale * spec2time(uhat);
            powT = 1 * velT .* uT;
            
            powTot = trapz(ps.tkp, powT) / (ps.tkp(end) - ps.tkp(1));
%             assert(WecOptLib.utils.isClose(powTot, sum(powFreq), 'rtol', 0.10)) TODO
            
            % assemble outputs
            fRes.pos = posFreq;
            fRes.vel = velFreq;
            fRes.u = uFreq;
            fRes.pow = powFreq;
            
            tRes.pos = posT;
            tRes.vel = velT;
            tRes.u = uT;
            tRes.pow = powT;
            
            function P = pow_calc(X)
                P = X' * ps.H_mat * X;
            end
            
        end
        
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
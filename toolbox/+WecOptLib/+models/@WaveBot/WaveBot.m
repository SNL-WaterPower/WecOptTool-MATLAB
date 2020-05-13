classdef WaveBot < handle
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
            %               of WAFO
            % Returns
            %   simResults  object containing simulation results
            %
            % See also JONSWAP, WecOptLib.simResults
            
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
                    
                    ps = getPSCoefficients(obj);
                    ps.wave_amp = waveAmp; % TODO
                    
                    % Add phase realizations
                    n_ph_avg = 5;
                    ph_mat = 2 * pi * rand(length(ps.w), n_ph_avg);
                    n_ph = size(ph_mat, 2);
                    
                    freq = ps.W;
                    n_freqs = length(freq);
                    powPerFreqMat = zeros(n_ph, n_freqs);
                    
                    for ind_ph = 1 : n_ph
                        
                        ph = ph_mat(:, ind_ph);
                        [~, phasePowPerFreq] = obj.getPSPhasePower(ps, ph);
                        
                        for ind_freq = 1 : n_freqs
                            powPerFreqMat(ind_ph, ind_freq) = obj.phasePowPerFreq(ind_freq);
                        end
                        
                    end
                    
                    pow = mean(powPerFreqMat);
                    
                otherwise % -----------------------------------------------
                    error('invalid controlType')
            end
            
            % assembly output
            nm = sprintf('WaveBot_%s',obj.controlType); % TODO add datetime?
            simResults = WecOptLib.simResults(nm);
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
        
        function ps = getPSCoefficients(obj)
            
            
            delta_Zmax = 10;
            delta_Fmax = 1e5;
            
            
            %PSCOEFFICIENTS
            % Bacelli 2014: Background Chapter 4.1, 4.2; RM3 in section 6.1
            % Number of frequency - half the number of fourier coefficients
            Nf = length(obj.w);
            % Collocation points uniformly distributed btween 0 and T
            Nc = (2*Nf) + 2;
            
            % Frequency vector (re-build)
            w0 = obj.dw;
            T = 2 * pi/w0;
            W = obj.w(1) + w0 * (0:Nf-1)';
            
            % Building cost function
            H = [0, 0, 1; 1, -1, 0];
            H_mat = 0.5 * kron(H, eye(1*Nf));
            
            % Building matrices B33 and A33
            Adiag33 = zeros(2*Nf-1,1);
            Adiag33(1:2:end) = W.* obj.hydro.A;
            
            Bdiag33 = zeros(2*Nf,1);
            Bdiag33(1:2:end) = obj.hydro.B;
            Bdiag33(2:2:end) = Bdiag33(1:2:end);
            
            Bmat = diag(Bdiag33);
            Amat = diag(Adiag33,1);
            Amat = Amat - Amat';
            
            G33 = (Amat + Bmat);
            
            %             % Building matrices B39 and A39
            %             Adiag39 = zeros(2*Nf-1,1);
            %             Bdiag39 = zeros(2*Nf,1);
            %
            %             Adiag39(1:2:end) = W.* obj.A39;
            %             Bdiag39(1:2:end) = obj.B39;
            %             Bdiag39(2:2:end) = Bdiag39(1:2:end);
            %
            %             Bmat = diag(Bdiag39);
            %             Amat = diag(Adiag39,1);
            %             Amat = Amat - Amat';
            %
            %             G39 = (Amat + Bmat);
            
            %             % Building matrices B99 and A99
            %             Adiag99 = zeros(2*Nf-1,1);
            %             Bdiag99 = zeros(2*Nf,1);
            %
            %             Adiag99(1:2:end) = W.* obj.A99;
            %             Bdiag99(1:2:end) = obj.B99;
            %             Bdiag99(2:2:end) = Bdiag99(1:2:end);
            %
            %             Bmat = diag(Bdiag99);
            %             Amat = diag(Adiag99,1);
            %             Amat = Amat - Amat';
            %
            %             G99 = (Amat + Bmat);
            
            G = [G33];
            
            B = obj.hydro.Bf * eye(2*Nf);
            C = blkdiag(obj.hydro.K * eye(2*Nf));
            M = blkdiag(obj.hydro.m * eye(2*Nf));
            
            % Building derivative matrix
            d = [W(:)'; zeros(1, length(W))];
            Dphi1 = diag(d(1:end-1), 1);
            Dphi1 = (Dphi1 - Dphi1');
            %             Dphi = blkdiag(Dphi1, Dphi1);
            Dphi = blkdiag(Dphi1);
            
            m_scale = obj.hydro.m; % scaling factor for optimization
            
            % equality constraints for EOM
            P =  (M*Dphi + B + G + (C / Dphi)) / m_scale;
%             Aeq = [P, -[eye(2*Nf)] ];
            Aeq = [P, -[eye(1*Nf); -eye(1*Nf)] ];
            
            % Calculating collocation points for constraints
            tkp = linspace(0, T, 4*(Nc));
            tkp = tkp(1:end);
            Wtkp = W*tkp;
            Phip1 = zeros(2*size(Wtkp,1),size(Wtkp,2));
            Phip1(1:2:end,:) = cos(Wtkp);
            Phip1(2:2:end,:) = sin(Wtkp);
            
            Phip = blkdiag(Phip1, Phip1);
            
            A_ineq = kron([1 -1 0; -1 1 0], Phip1' / Dphi1);
            B_ineq = ones(size(A_ineq, 1),1) * delta_Zmax;
            
            %force constraint section
            siz = size(A_ineq);
            forc =  Phip1';
            
            B_ineq = [B_ineq; ones(siz(1),1) * delta_Fmax/m_scale];
            A_ineq = [A_ineq; kron([0 0 1; 0 0 -1], forc)];
            
            ps.w = obj.w; % TODO
            ps.Nf = Nf;
            ps.T = T;
            ps.W = W;
            ps.H_mat = H_mat;
            ps.tkp = tkp;
            ps.Aeq = Aeq;
            ps.A_ineq = A_ineq;
            ps.B_ineq = B_ineq;
            ps.Phip = Phip;
            ps.Phip1 = Phip1;
            ps.Dphi = Dphi;
            ps.m_scale = m_scale;
            
        end
        
        function [pow, powPerFreq] = getPSPhasePower(obj, ps, ph)
            %Calculates power using the pseudospectral method given a phase and
            % a descrption of the body movement. Returns total phase power and
            % power per frequency
            
            eta_fd = ps.wave_amp .* exp(1i*ph);
            %             eta_fd = eta_fd(start:end);
            
            fef3 = zeros(2*ps.Nf,1);
            %             fef9 = zeros(2*obj.Nf,1);
            
            E3 = obj.hydro.Hex .* eta_fd;
            %             E9 = obj.H9 .* eta_fd;
            
            fef3(1:2:end) =  real(E3);
            fef3(2:2:end) = -imag(E3);
%             fef9(1:2:end) =  real(E9);
%             fef9(2:2:end) = -imag(E9);
            
            Beq = [fef3] / ps.m_scale;
            
            % constrained optimiztion
            qp_options = optimoptions('fmincon',                        ...
                'Algorithm', 'sqp',               ...
                'Display', 'off',                 ...
                'MaxIterations', 1e3,             ...
                'MaxFunctionEvaluations', 1e5,    ...
                'OptimalityTolerance', 1e-8,      ...
                'StepTolerance', 1e-6);
            
            siz = size(ps.A_ineq);
            X0 = zeros(siz(2),1);
            pow_calc(X0)
            [y, ~, ~, ~] = fmincon(@pow_calc,       ...
                X0,              ...
                ps.A_ineq,   ...
                ps.B_ineq,   ...
                ps.Aeq,      ...
                Beq,             ...
                [], [], [],      ...
                qp_options);
            
            % y is a vector of x1hat, x2hat, & uhat. Calculate energy using
            % Equation 6.11 of Bacelli 2014
            uEnd = numel(y);
            x1End = uEnd / 3;
            x2Start = x1End + 1;
            x2End = 2 * uEnd / 3;
            uStart = x2End + 1;
            
            x1hat = y(1:x1End);
            x2hat = y(x2Start:x2End);
            uhat = y(uStart:end);
            
            Pvec = -1 / 2 * (x1hat - x2hat) .* uhat;
            % Add the sin and cos components to get power as function of W
            powPerFreq = Pvec(1:2:end) + Pvec(2:2:end);
            powPerFreq = powPerFreq * ps.m_scale;
            
            velT = ps.Phip' * [x1hat;x2hat];
            body1End = numel(velT) / 2;
            Body2Start = body1End + 1;
            velTBody1 = velT(1:body1End);
            velTBody2 = velT(Body2Start:end);
            
            % posT = (motion.Phip' / motion.Dphi) * [x1hat;x2hat];
            % relative position (check constraint satisfaction)
            
            % relPosT = posT(1:end/2)- posT(end/2+1:end);
            % relative velocity (check constraint satisfaction)
            % relVelT = velT(1:end/2)- velT(end/2+1:end);
            
            % Alternative power calculation
            uT = ps.m_scale * ps.Phip1' * uhat;
            Pt = (velTBody2 - velTBody1) .* uT;
            pow = trapz(ps.tkp, Pt) / (ps.tkp(end) - ps.tkp(1));
            assert(WecOptLib.utils.isClose(pow, sum(powPerFreq)))
            
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
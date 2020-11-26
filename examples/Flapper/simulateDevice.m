function [performance, dynModel] = simulateDevice(I,            ...
                                                  hydro,        ...
                                                  seastate,     ...
                                                  controlType,  ...
                                                  options)
                                              
    % simulateDevice   Oscillating Wave Surge Converter
    %
    % See: https://en.wikipedia.org/wiki/Oyster_wave_energy_converter
    %
    % Arguments:
    %  I            moment of inertia
    %  hydro        structure containing BEM results
    %  seastate     sea state object
    %  controlType  controller type:
    %                   complex conjugate:      'CC'
    %                   proportional damping:   'P'
    %                   pseudo-spectral:        'PS'
    %  name-value pairs
    %  interpMethod (optional) method to use for linear interpolation
    %  thetaMax     (only valid for controlType == 'controlType') maximum
    %               angular displacement
    %  tauMax       (only valid for controlType == 'controlType') maximum
    %               PTO torque
    %
    % See also WecOptTool.SeaState, interp1
    
    arguments
        I (1, 1) double
        hydro (1,1) WecOptTool.Hydrodynamics
        seastate (1,:) WecOptTool.SeaState
        controlType (1,1) string
        options.thetaMax (1,:) double  = 1e9 % TODO - can be assymetric, need to check throughout
        options.tauMax (1,:) double = 1e9
        options.interpMethod (1,1) string = 'linear'
    end
    
    dynModel = getDynamicsModel(I,              ...
                                hydro,          ...
                                seastate,       ...
                                options.interpMethod);
    
    switch controlType
        case 'CC'
            performance = complexCongugateControl(dynModel);
         case 'P'
             performance = dampingControl(dynModel);
         case 'PS'
             performance = psControl(dynModel,          ...
                                     options.thetaMax,  ...
                                     options.tauMax);
    end

end
        
function dynModel = getDynamicsModel(I,         ...
                                     hydro,     ...
                                     SS,        ...
                                     interpMethod)
    
    function result = toVector(matrix)
        result = squeeze(matrix(1, 1, :));
    end

    % Restoring (in roll)
    K = hydro.C(4,4) * hydro.g * hydro.rho;

    w = hydro.w(:);
    dw = w(2) - w(1);
    
    % Calculate wave amplitude
    waveAmpSS = SS.getAmplitudeSpectrum();
    waveAmp = interp1(SS.w, waveAmpSS, w, interpMethod, 'extrap');

    % Row vector of phases
    ph = ones(size(waveAmp)) * pi / 2;

    % Wave height in frequency domain
    eta_fd = waveAmp .* exp(1i * ph);
    eta_fd = eta_fd(:);
    
    % radiation damping FRF
    B = toVector(hydro.B) * hydro.rho .* w;

    % added mass FRF
    A = toVector(hydro.A) * hydro.rho;

    % friction
    Bf = max(B) * 0.1;      % TODO - make this adjustable

    % intrinsic impedance
    Zi = B + Bf + 1i * (w .* (I + A) - K ./ w);

    % Excitation Forces
    Hex = toVector(hydro.ex) * hydro.g * hydro.rho;
    F0 = Hex .* eta_fd;

    dynModel.I = I;
    dynModel.K = K;
    dynModel.w = w;
    dynModel.eta_fd = eta_fd;
    dynModel.dw = dw;
    dynModel.wave_amp = waveAmp;
    dynModel.ph = ph;
    dynModel.B = B;
    dynModel.A = A;
    dynModel.Bf = Bf;
    dynModel.Zi = Zi;
    dynModel.Hex = Hex;
    dynModel.F0 = F0;
    
end

function myPerf = complexCongugateControl(dynModel,~)
    
    myPerf = Performance();
    myPerf.name = "CC";
            
    myPerf.thetaPTO = conj(dynModel.Zi);
    
    % velocity
    myPerf.omega = dynModel.F0 ./ (myPerf.thetaPTO + dynModel.Zi);
    
    % position
    myPerf.theta = myPerf.omega ./ (1i * dynModel.w);
    
    % PTO force
    myPerf.tauPTO = -1 * myPerf.thetaPTO .* myPerf.omega;
    
    % power
    myPerf.pow = 0.5 * myPerf.tauPTO .* conj(myPerf.omega);
    
    myPerf.ph = dynModel.ph;
    myPerf.w = dynModel.w;
    myPerf.eta = dynModel.eta_fd;
    myPerf.F0 = dynModel.F0;

end

function myPerf = dampingControl(dynModel,~)
    
    myPerf = Performance();
    myPerf.name = "P";
    
    P_max = @(b) -0.5*b*sum(abs(dynModel.F0 ./ ...
                                (dynModel.Zi + b)).^2);
                            
    % Solve for damping to produce most power (can do analytically for a
    % single frequency, but must use numerical solution for spectrum). Note
    % that fval is the sum of power absorbed (negative being "good") - the
    % following should be true: -1 * fval = sum(pow), where pow is the
    % frequency dependent array calculated below.
    [B_opt, ~] = fminsearch(P_max, max(real(dynModel.Zi)));

    % PTO impedance
    myPerf.thetaPTO = complex(B_opt * ones(size(dynModel.Zi)),0);
    
    % velocity
    myPerf.omega = dynModel.F0 ./ (myPerf.thetaPTO + dynModel.Zi);
    
    % position
    myPerf.theta = myPerf.omega ./ (1i * dynModel.w);
    
    % PTO force
    myPerf.tauPTO = -1 * myPerf.thetaPTO .* myPerf.omega;
    
    % power
    myPerf.pow = 0.5 * myPerf.tauPTO .* conj(myPerf.omega);
    
    myPerf.ph = dynModel.ph;
    myPerf.w = dynModel.w;
    myPerf.eta = dynModel.eta_fd;
    myPerf.F0 = dynModel.F0;

end

function myPerf = psControl(dynModel, delta_thetaMax, delta_tauMax)

    arguments
        dynModel (1, 1) struct
        delta_thetaMax (1,:) double {mustBeReal,mustBePositive}
        delta_tauMax (1,:) double {mustBeReal,mustBePositive}
    end
        
    % Fix random seed <- Do we want this???
    rng(1);
    
    % Reformulate equations of motion
    dynModel = getPSCoefficients(dynModel, delta_thetaMax, delta_tauMax);
    
    % Add phase realizations
    n_ph = 5;
    ph_mat = [dynModel.ph, rand(length(dynModel.w), n_ph-1)];

    for ind_ph = 1 : n_ph
        
        ph = ph_mat(:, ind_ph);
        [phasePowMat(ind_ph), fRes(ind_ph), tRes(ind_ph)] = ...
            getPSPhasePower(dynModel, ph);
        
        
        theta(:, ind_ph) = fRes(ind_ph).pos;
        omega(:, ind_ph) = fRes(ind_ph).vel;
        thetaPTO(:, ind_ph) = fRes(ind_ph).thetaPTO;
        tauPTO(:, ind_ph) = fRes(ind_ph).u;
        pow(:, ind_ph) = fRes(ind_ph).pow;
        eta(:, ind_ph) = fRes(ind_ph).eta;
        F0(:, ind_ph) = fRes(ind_ph).F0;
        
    end
    
    % assemble results
    myPerf = Performance();
    myPerf.name = "PS";
    myPerf.w = dynModel.w;
    myPerf.eta = eta;
    myPerf.F0 = F0;
    myPerf.ph = ph_mat;
    myPerf.omega = omega;
    myPerf.theta = theta;
    myPerf.thetaPTO = thetaPTO;
    myPerf.tauPTO = tauPTO;
    myPerf.pow = pow;
    
end

function dynModel = getPSCoefficients(dynModel,         ...
                                      delta_thetaMax,   ...
                                      delta_tauMax)
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
    Nf = length(dynModel.w);
    
    % Collocation points uniformly distributed between 0 and T
    % note that we have 2*Nf collocation points since we will have
    % two Fourier coefficients for each frequency
    Nc = (2*Nf) + 2;
    
    % Rebuild frequency vector to ensure monotonically increasing
    % with w(1) = w0
    w0 = dynModel.dw;                    % fundamental frequency
    T = 2 * pi/w0;                  % '' period
    
    % Building cost function component
    % we will form the cost function as transpose(x) * H x, where x
    % is a vector of [vel, u]; we want the product above to result
    % in power (u*vel)
    H = [0,1;1,0];
    H_mat = 0.5 * kron(H, eye(2*Nf));
    
    % Building matrices B33 and A33
    Adiag33 = zeros(2*Nf-1,1);
    Bdiag33 = zeros(2*Nf,1);
    
    Adiag33(1:2:end) = dynModel.w.* dynModel.A;
    Bdiag33(1:2:end) = dynModel.B;
    Bdiag33(2:2:end) = Bdiag33(1:2:end);
    
    Bmat = diag(Bdiag33);
    Amat = diag(Adiag33,1);
    Amat = Amat - Amat';
    
    G = Amat + Bmat;
    
    B = dynModel.Bf * eye(2*Nf);
    C = blkdiag(dynModel.K * eye(2*Nf));
    M = blkdiag(dynModel.I * eye(2*Nf));
    
    % Building derivative matrix
    d = [dynModel.w(:)'; zeros(1, length(dynModel.w))];
    Dphi1 = diag(d(1:end-1), 1);
    Dphi1 = (Dphi1 - Dphi1');
    Dphi = blkdiag(Dphi1);
    
    % scaling factor to improve optimization performance
    m_scale = dynModel.I;
    
    % equality constraints for EOM
    P =  (M*Dphi + B + G + (C / Dphi)) / m_scale;
    Aeq = [P, -eye(2*Nf) ];
    Aeq = [Aeq,            zeros(2*Nf,2);
        zeros(1,4*Nf), dynModel.K / m_scale, -1];
    
    % Calculating collocation points for constraints
    tkp = linspace(0, T, 4*(Nc));
    tkp = tkp(1:end);
    Wtkp = dynModel.w*tkp;
    Phip1 = zeros(2*size(Wtkp,1),size(Wtkp,2));
    Phip1(1:2:end,:) = cos(Wtkp);
    Phip1(2:2:end,:) = sin(Wtkp);
    
    Phip = blkdiag(Phip1);
    
    A_ineq =  [kron([1 0], Phip1' / Dphi1), ones(4*Nc,1), zeros(4*Nc,1)];
    A_ineq = [A_ineq; -A_ineq];
    
    % position constraints
    if length(delta_thetaMax)==1
        B_ineq = [ones(size(A_ineq, 1),1) * delta_thetaMax];
    else
        B_ineq = [ones(size(A_ineq, 1)/2,1) * max(delta_thetaMax);
            -ones(size(A_ineq, 1)/2,1) * min(delta_thetaMax)];
    end
    
    % force constraints
    siz = size(A_ineq);
    forc =  [kron([0 1], Phip'), zeros(4*Nc,1), ones(4*Nc,1)];
    
    if length(delta_tauMax)==1
        B_ineq = [B_ineq; ones(siz(1),1) * delta_tauMax/m_scale];
    else
        B_ineq = [B_ineq; ones(siz(1)/2,1) * max(delta_tauMax)/m_scale;
            -ones(siz(1)/2,1) * min(delta_tauMax)/m_scale];
    end
    
    A_ineq = [A_ineq; forc; -forc];
    
    dynModel.Nf = Nf;
    dynModel.T = T;
    dynModel.H_mat = H_mat;
    dynModel.tkp = tkp;
    dynModel.Aeq = Aeq;
    dynModel.A_ineq = A_ineq;
    dynModel.B_ineq = B_ineq;
    dynModel.Phip = Phip;
    dynModel.Phip1 = Phip1;
    dynModel.Dphi = Dphi;
    dynModel.mass_scale = m_scale;
    
end

function [powTot, fRes, tRes] = getPSPhasePower(dynModel, ph)
    % getPSPhasePower   calculates power using the pseudospectral
    % method given a phase and a descrption of the body movement.
    % Returns total phase power and power per frequency

    eta_fd = dynModel.wave_amp .* exp(1i*ph);
    E3 = dynModel.Hex .* eta_fd;
    
    fef3 = zeros(2 * dynModel.Nf, 1);
    
    fef3(1:2:end) =  real(E3);
    fef3(2:2:end) = -imag(E3);
    
    Beq = [fef3; 0] / dynModel.mass_scale;
    
    % constrained optimization settings
    qp_options = optimoptions('fmincon',  ...
        'Algorithm', 'sqp',               ...
        'Display', 'off',                 ...
        'MaxIterations', 1e3,             ...
        'MaxFunctionEvaluations', 1e5,    ...
        'OptimalityTolerance', 1e-8,      ...
        'StepTolerance', 1e-8);
    
    siz = size(dynModel.A_ineq);
    X0 = zeros(siz(2),1);
    [y, fval, exitflag, output] = fmincon(@pow_calc,...
        X0,...
        dynModel.A_ineq,...
        dynModel.B_ineq,...
        dynModel.Aeq,...         % Aeq and Beq are the hydrodynamic model
        Beq,...
        [], [], [],...
        qp_options);
    
    %     if exitflag ~= 1      % for debugging
    %         disp(exitflag)
    %         disp(output)
    %     end
    
    % y is a column vector containing [vel; u] of the
    % pseudospectral coefficients
    tmp = reshape(y(1:end-2),[],2);
    x1hat = tmp(:,1);
    uhat = tmp(:,2);
    
    % find the spectra
    ps2spec = @(x) (x(1:2:end) - 1i * x(2:2:end));  % TODO - probably make this a global function
    velFreq = ps2spec(x1hat);
    posFreq = velFreq ./ (1i * dynModel.w);
    uFreq = dynModel.mass_scale * ps2spec(uhat);
    powFreq = 1/2 * uFreq .* conj(velFreq);
    zFreq = uFreq ./ velFreq;
    
    % find time histories
    spec2time = @(x) dynModel.Phip' * x;              % TODO - probably make this a global function
    velT = spec2time(x1hat);
    posT = y(end-1) + (dynModel.Phip' / dynModel.Dphi) * x1hat;
    uT = dynModel.mass_scale * (y(end) + spec2time(uhat));
    powT = 1 * velT .* uT;
    
    powTot = trapz(dynModel.tkp, powT) / (dynModel.tkp(end) - dynModel.tkp(1));
    assert(WecOptTool.math.isClose(powTot, sum(real(powFreq)),...
        'rtol', eps*1e2),...
        sprintf('Mismatch in PS results\n\tpowTot: %.3e\n\tpowFreq: %.3e',...
        powTot,sum(real(powFreq))))
    
    % assemble outputs
    fRes.pos = posFreq;
    fRes.vel = velFreq;
    fRes.u = uFreq;
    fRes.pow = powFreq;
    fRes.thetaPTO = zFreq;
    fRes.eta = eta_fd;
    fRes.F0 = E3;
    
    tRes.pos = posT;
    tRes.vel = velT;
    tRes.u = uT;
    tRes.pow = powT;
    
    function P = pow_calc(X)
        P = X(1:end-2)' * dynModel.H_mat * X(1:end-2); % 1/2 factor dropped for simplicity
    end
end

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

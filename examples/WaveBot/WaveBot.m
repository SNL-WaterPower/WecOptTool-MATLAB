classdef WaveBot < WecOptTool.Blueprint
    % WaveBot   WEC based on the Sandia "WaveBot" device.
    %
    % The WaveBot is a model-scale wave energy converter (WEC) tested in
    % the Navy's Manuevering and Sea Keeping (MASK) basin. Reports and
    % papers about the WaveBot are available at advweccntrls.sandia.gov.
    
    properties
        
        geometryCallbacks = struct(                                     ...
            'existing', @WecOptTool.callbacks.geometry.existingNEMOH,   ...
            'scalar', @getHydroScalar,                                  ...
            'parametric', @getHydroParametric)
        
        staticModelCallback = @getStaticModel
        dynamicModelCallback = @getDynamicModel
        
        controllerCallbacks = struct('CC', @complexCongugateControl,...
                                     'P',  @dampingControl,...
                                     'PS', @psControl)
                                 
        aggregationHook = @aggregate
        
    end
    
end

%% Device-specific functions
% The following functions are defined here and referenced by the
% handles/callbacks within the Blueprint class

function hydro = getHydroScalar(folder, lambda, w)
                   
    if w(1) == 0
        w = w(2:end);
    end
    
    r = lambda * [0, 0.88, 0.88, 0.35, 0];
    z = lambda * [0.2, 0.2, -0.16, -0.53, -0.53];

    % Mesh
    ntheta = 20;
    nfobj = 200;
    zG = 0;
    
    meshes = WecOptTool.mesh("AxiMesh",    ...
                             folder,       ...
                             r,            ...
                             z,            ...
                             ntheta,       ...
                             nfobj,        ...
                             zG,           ...
                             1);
    
    hydro = WecOptTool.solver("NEMOH", folder, meshes, w);
           
end

function hydro = getHydroParametric(folder, r1, r2, d1, d2, S, freqStep)
    
    S = struct(S);
    w = WecOptLib.utils.seaStatesGlobalW(S, freqStep);
               
    if w(1) == 0
        w = w(2:end);
    end
    
    r = [0, r1, r1, r2, 0];
    z = [0.2, 0.2, -d1, -d2, -d2];

    % Mesh
    ntheta = 20;
    nfobj = 200;
    zG = 0;
    
    meshes = WecOptTool.mesh("AxiMesh",    ...
                                         folder,       ...
                                         r,            ...
                                         z,            ...
                                         ntheta,       ...
                                         nfobj,        ...
                                         zG,           ...
                                         1);
    
    hydro = WecOptTool.solver("NEMOH", folder, meshes, w);
           
end


function staticModel = getStaticModel(hydro)
            
    % Mass
    staticModel.mass = hydro.Vo * hydro.rho;

    % Restoring
    staticModel.K = hydro.C(3,3) * hydro.g * hydro.rho;

end
        
function motion = getDynamicModel(staticModel, hydro, SS)

    function result = interp_mass(hydro, dof1, dof2, w)
        result = interp1(hydro.w,                           ...
                         squeeze(hydro.A(dof1, dof2, :)),   ...
                         w,                                 ...
                         'linear',                          ...
                         0);
    end

    function result = interp_rad(hydro, dof1, dof2, w)
        result = interp1(hydro.w,                           ...
                         squeeze(hydro.B(dof1, dof2, :)),   ...
                         w,                                 ...
                         'linear',                          ...
                         0);
    end

    function result = interp_ex(hydro, dof, w)

        h = complex(squeeze(hydro.ex_re(dof, 1, :)),   ...
                    squeeze(hydro.ex_im(dof, 1, :)));

        result = interp1(hydro.w, h ,w, 'linear', 0);

    end

    w = hydro.w(:);
    dw = w(2) - w(1); % TODO - make dw a property
    
    SS_struct = SS.struct;
    SS_struct.S = interp1(SS_struct.w,SS_struct.S,hydro.w,...
        'nearest',0); % TODO - allow user to set interp method
    SS = WecOptTool.types('SeaState',SS_struct);
    
    
    % Calculate wave amplitude
    waveAmp = sqrt(2 * dw * SS.S(:));

    % Row vector of random phases?
    ph = rand(length(SS.S), 1);

    % Wave height in frequency domain
    eta_fd = waveAmp .* exp(1i * ph);
    eta_fd = eta_fd(:);
    % radiation damping FRF
    B = interp_rad(hydro, 3, 3, w) * hydro.rho .* w;

    % added mass FRF
    A = interp_mass(hydro, 3, 3, w) * hydro.rho;

    % friction
    Bf = max(B) * 0.1;      % TODO - make this adjustable

    % intrinsic impedance
    Zi = B + Bf + 1i * (w .* (staticModel.mass + A) - staticModel.K ./ w);

    % Excitation Forces
    Hex = interp_ex(hydro, 3, w) * hydro.g * hydro.rho;
    F0 = Hex .* eta_fd;

    dynamic.w = w;
    dynamic.eta_fd = eta_fd;
    dynamic.dw = dw;
    dynamic.wave_amp = waveAmp;
    dynamic.ph = ph;
    dynamic.B = B;
    dynamic.A = A;
    dynamic.Bf = Bf;
    dynamic.Zi = Zi;
    dynamic.F0 = F0;
    
    % Merge in staticModel
    fn = fieldnames(staticModel);
    for i = 1:length(fn)
       dynamic.(fn{i}) = staticModel.(fn{i});
    end
    
    motion = WecOptTool.types("Motion", dynamic);

end

function myPerf = complexCongugateControl(motion)
    
    myPerf = WecOptTool.types.Performance();
            
    myPerf.Zpto = conj(motion.Zi);
    
    % velocity
    myPerf.u = motion.F0 ./ (myPerf.Zpto + motion.Zi);
    
    % position
    myPerf.pos = myPerf.u ./ (1i * motion.w);
    
    % PTO force
    myPerf.Fpto = -1 * myPerf.Zpto .* myPerf.u;
    
    % power
    myPerf.pow = 0.5 * myPerf.Fpto .* conj(myPerf.u);
    
    myPerf.ph = motion.ph;
    myPerf.w = motion.w;
    myPerf.eta = motion.eta_fd;
    myPerf.F0 = motion.F0;

end

function myPerf = dampingControl(motion)
    
    myPerf = WecOptTool.types.Performance(); % TODO - move this up to Device?
            
    P_max = @(b) -0.5*b*sum(abs(motion.F0 ./ ...
                                (motion.Zi + b)).^2);
                            
    % Solve for damping to produce most power (can do analytically for a
    % single frequency, but must use numerical solution for spectrum). Note
    % that fval is the sum of power absorbed (negative being "good") - the
    % following should be true: -1 * fval = sum(pow), where pow is the
    % frequency dependent array calculated below.
    [B_opt, ~] = fminsearch(P_max, max(real(motion.Zi)));

    % PTO impedance
    myPerf.Zpto = complex(B_opt * ones(size(motion.Zi)),0);
    
    % velocity
    myPerf.u = motion.F0 ./ (myPerf.Zpto + motion.Zi);
    
    % position
    myPerf.pos = myPerf.u ./ (1i * motion.w);
    
    % PTO force
    myPerf.Fpto = -1 * myPerf.Zpto .* myPerf.u;
    
    % power
    myPerf.pow = 0.5 * myPerf.Fpto .* conj(myPerf.u);
    
    myPerf.ph = motion.ph;
    myPerf.w = motion.w;
    myPerf.eta = motion.eta_fd;
    myPerf.F0 = motion.F0;

end

function myPerf = psControl(motion,delta_Zmax,delta_Fmax)
%     motion = getPSCoefficients(motion, delta_Zmax, delta_Fmax);
%     ps.wave_amp = waveAmp; % TODO
%     
%     % Use mutliple phase realizations for PS at the model
%     % is nonlinear (note that we use the original phasing
%     % from the other cases)
%     n_ph = 5;
%     ph_mat = [ph, rand(length(ps.w), n_ph-1)];
%     
%     n_freqs = length(motion.w);
%     phasePowMat = zeros(n_ph, 1);
%     powPerFreqMat = zeros(n_freqs, n_ph);
%     
%     for ind_ph = 1 : n_ph
%         
%         ph = ph_mat(:, ind_ph);
% %         [powTot, fRes(ind_ph), tRes(ind_ph)] = getPSPhasePower(ps, ph);
%         [pow, powPerFreq] = getPSPhasePower(motion, ph)
%         phasePowMat(ind_ph) = powTot;
%         powPerFreqMat(:, ind_ph) = fRes(ind_ph).pow;
%         
%     end
%     
%     ph = ph_mat(:,1);
%     u = fRes(1).vel;
%     pos = fRes(1).pos;
%     Zpto = nan(size(motion.hydro.Zi)); % TODO
%     Fpto = fRes(1).u;
%     pow = powPerFreqMat(:,1);

    motion = struct(motion);
        
    % Fix random seed <- Do we want this???
    rng(1);
    
    % Reformulate equations of motion
    motion = getPSCoefficients(motion, delta_Zmax, delta_Fmax);
    
    % Add phase realizations
    n_ph = 5;
    ph_mat = [motion.ph, rand(length(motion.w), n_ph-1)];

    for ind_ph = 1 : n_ph
        
        ph = ph_mat(:, ind_ph);
        [phasePowMat(ind_ph), fRes(ind_ph), tRes(ind_ph)] = getPSPhasePower(motion, ph);
        
        
        pos(:, ind_ph) = fRes(ind_ph).pos;
        u(:, ind_ph) = fRes(ind_ph).vel;
        Zpto(:, ind_ph) = fRes(ind_ph).Zpto;
        Fpto(:, ind_ph) = fRes(ind_ph).u;
        pow(:, ind_ph) = fRes(ind_ph).pow;
    end
    
    % assemble results
    myPerf = WecOptTool.types.Performance();
    myPerf.w = motion.w;
    myPerf.eta = motion.eta_fd;
    myPerf.F0 = motion.F0;
    myPerf.ph = ph_mat;
    myPerf.u = u;
    myPerf.pos = pos;
    myPerf.Zpto = Zpto;
    myPerf.Fpto = Fpto;
    myPerf.pow = pow;
    
end

function motion = getPSCoefficients(motion, delta_Zmax, delta_Fmax)
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
    Nf = length(motion.w);
    
    % Collocation points uniformly distributed between 0 and T
    % note that we have 2*Nf collocation points since we will have
    % two Fourier coefficients for each frequency
    Nc = (2*Nf) + 2;
    
    % Rebuild frequency vector to ensure monotonically increasing
    % with w(1) = w0
    w0 = motion.dw;                    % fundamental frequency
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
    
    Adiag33(1:2:end) = motion.w.* motion.A;
    Bdiag33(1:2:end) = motion.B;
    Bdiag33(2:2:end) = Bdiag33(1:2:end);
    
    Bmat = diag(Bdiag33);
    Amat = diag(Adiag33,1);
    Amat = Amat - Amat';
    
    G = Amat + Bmat;
    
    B = motion.Bf * eye(2*Nf);
    C = blkdiag(motion.K * eye(2*Nf));
    M = blkdiag(motion.mass * eye(2*Nf));
    
    % Building derivative matrix
    d = [motion.w(:)'; zeros(1, length(motion.w))];
    Dphi1 = diag(d(1:end-1), 1);
    Dphi1 = (Dphi1 - Dphi1');
    Dphi = blkdiag(Dphi1);
    
    % scaling factor to improve optimization performance
    m_scale = motion.mass;
    
    % equality constraints for EOM
    P =  (M*Dphi + B + G + (C / Dphi)) / m_scale;
    Aeq = [P, -eye(2*Nf) ];
    Aeq = [Aeq,            zeros(2*Nf,2);
        zeros(1,4*Nf), motion.K / m_scale, -1];
    
    % Calculating collocation points for constraints
    tkp = linspace(0, T, 4*(Nc));
    tkp = tkp(1:end);
    Wtkp = motion.w*tkp;
    Phip1 = zeros(2*size(Wtkp,1),size(Wtkp,2));
    Phip1(1:2:end,:) = cos(Wtkp);
    Phip1(2:2:end,:) = sin(Wtkp);
    
    Phip = blkdiag(Phip1);
    
    A_ineq =  [kron([1 0], Phip1' / Dphi1), ones(4*Nc,1), zeros(4*Nc,1)];
    A_ineq = [A_ineq; -A_ineq];
    
    % position constraints
    if length(delta_Zmax)==1
        B_ineq = [ones(size(A_ineq, 1),1) * delta_Zmax];
    else
        B_ineq = [ones(size(A_ineq, 1)/2,1) * max(delta_Zmax);
            -ones(size(A_ineq, 1)/2,1) * min(delta_Zmax)];
    end
    
    % force constraints
    siz = size(A_ineq);
    forc =  [kron([0 1], Phip'), zeros(4*Nc,1), ones(4*Nc,1)];
    if length(delta_Fmax)==1
        B_ineq = [B_ineq; ones(siz(1),1) * delta_Fmax/m_scale];
    else
        B_ineq = [B_ineq; ones(siz(1)/2,1) * max(delta_Fmax)/m_scale;
            -ones(siz(1)/2,1) * min(delta_Fmax)/m_scale];
    end
    A_ineq = [A_ineq; forc; -forc];
    
    motion.Nf = Nf;
    motion.T = T;
    motion.H_mat = H_mat;
    motion.tkp = tkp;
    motion.Aeq = Aeq;
    motion.A_ineq = A_ineq;
    motion.B_ineq = B_ineq;
    motion.Phip = Phip;
    motion.Phip1 = Phip1;
    motion.Dphi = Dphi;
    motion.mass_scale = m_scale;
end

function [powTot, fRes, tRes] = getPSPhasePower(motion, ph)
    % getPSPhasePower   calculates power using the pseudospectral
    % method given a phase and a descrption of the body movement.
    % Returns total phase power and power per frequency

    eta_fd = motion.wave_amp .* exp(1i*ph);
    
    fef3 = zeros(2*motion.Nf,1);
    
    E3 = motion.F0;
    
    fef3(1:2:end) =  real(E3);
    fef3(2:2:end) = -imag(E3);
    
    Beq = [fef3; 0] / motion.mass_scale;
    
    % constrained optimization settings
    qp_options = optimoptions('fmincon',  ...
        'Algorithm', 'sqp',               ...
        'Display', 'off',                 ...
        'MaxIterations', 1e3,             ...
        'MaxFunctionEvaluations', 1e5,    ...
        'OptimalityTolerance', 1e-8,      ...
        'StepTolerance', 1e-8);
    
    siz = size(motion.A_ineq);
    X0 = zeros(siz(2),1);
    [y, fval, exitflag, output] = fmincon(@pow_calc,...
        X0,...
        motion.A_ineq,...
        motion.B_ineq,...
        motion.Aeq,...         % Aeq and Beq are the hydrodynamic model
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
    posFreq = velFreq ./ (1i * motion.w);
    uFreq = motion.mass_scale * ps2spec(uhat);
    powFreq = 1/2 * uFreq .* conj(velFreq);
    zFreq = uFreq ./ velFreq;
    
    % find time histories
    spec2time = @(x) motion.Phip' * x;              % TODO - probably make this a global function
    velT = spec2time(x1hat);
    posT = y(end-1) + (motion.Phip' / motion.Dphi) * x1hat;
    uT = motion.mass_scale * (y(end) + spec2time(uhat));
    powT = 1 * velT .* uT;
    
    powTot = trapz(motion.tkp, powT) / (motion.tkp(end) - motion.tkp(1));
    assert(WecOptLib.utils.isClose(powTot, sum(real(powFreq)),...
        'rtol', eps*1e2),...
        sprintf('Mismatch in PS results\n\tpowTot: %.3e\n\tpowFreq: %.3e',...
        powTot,sum(real(powFreq))))
    
    % assemble outputs
    fRes.pos = posFreq;
    fRes.vel = velFreq;
    fRes.u = uFreq;
    fRes.pow = powFreq;
    fRes.Zpto = zFreq;
    
    tRes.pos = posT;
    tRes.vel = velT;
    tRes.u = uT;
    tRes.pow = powT;
    
    function P = pow_calc(X)
        P = X(1:end-2)' * motion.H_mat * X(1:end-2); % note that 1/2 factor is dropped for simplicity
    end
end

function out = aggregate(seastate, hydro, motions, performances)
    s = struct(seastate);
    p = struct(performances);
    out.pow = dot([p.pow], [s.mu]) / sum([s.mu]);
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

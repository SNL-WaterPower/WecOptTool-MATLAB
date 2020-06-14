classdef RM3 < WecOptTool.Blueprint
    
    properties
        
        geometryCallbacks = struct(                                     ...
            'existing', @WecOptTool.callbacks.geometry.existingNEMOH,   ...
            'scalar', @getHydroScalar,                                  ...
            'parametric', @getHydroParametric)
        
        staticModelCallback = @getStaticModel
        dynamicModelCallback = @getDynamicModel
        
        controllerCallbacks = struct('CC', @complexCongugateControl,    ...
                                     'P',  @dampingControl,             ...
                                     'PS', @pseudoSpectralControl)
                                 
        aggregationHook = @aggregate
        
    end
    
end

function hydro = getHydroScalar(folder, lambda)
                    
    % Get data file path
    p = mfilename('fullpath');
    [filepath, ~, ~] = fileparts(p);
    dataPath = fullfile(filepath, 'RM3_BEM.mat');

    load(dataPath, 'hydro');

    % dimensionalize w/ WEC-Sim built-in function
    hydro.rho = 1025;
    hydro.g = 9.81;
%         hydro = Normalize(hydro); % TODO - this doesn't work for our data
%         that was produced w/ WAMIT...

    % scale by scaling factor lambda
    hydro.Vo = hydro.Vo .* lambda^3;
    hydro.C = hydro.C .* lambda^2;
    hydro.B = hydro.B .* lambda^2.5;
    hydro.A = hydro.A .* lambda^3;
    hydro.ex = complex(hydro.ex_re,hydro.ex_im) .* lambda^2;
    hydro.ex_ma = abs(hydro.ex);
    hydro.ex_ph = angle(hydro.ex);
    hydro.ex_re = real(hydro.ex);
    hydro.ex_im = imag(hydro.ex);
    
    hydro = WecOptTool.types("Hydro", hydro);
           
end


function hydro = getHydroParametric(folder, r1, r2, d1, d2, S, freqStep)
    
    w = WecOptLib.utils.seaStatesGlobalW(struct(S), freqStep);
               
    if w(1) == 0
        w = w(2:end);
    end
    
    % Float
    
    rf = [0 r1 r1 0];
    zf = [0 0 -d1 -d1];

    % Heave plate

    thk = 1;
    rs = [0 r2 r2 0];
    zs = [-d2 -d2 -d2-thk -d2-thk];

    % Mesh
    ntheta = 20;
    nfobj = 200;
    zG = 0;
    
    meshes = WecOptTool.mesh("AxiMesh",    ...
                             folder,       ...
                             rf,           ...
                             zf,           ...
                             ntheta,       ...
                             nfobj,        ...
                             zG,           ...
                             1);
    meshes(2) = WecOptTool.mesh("AxiMesh",  ...
                                folder,     ...
                                rs,         ...
                                zs,         ...
                                ntheta,     ...
                                nfobj,      ...
                                zG,         ...
                                2);
    
    hydro = WecOptTool.solver("NEMOH", folder, meshes, w);
           
end


function static = getStaticModel(hydro)
            
    % Mass
    static.mass1 = hydro.Vo(1) * hydro.rho;
    static.mass2 = hydro.Vo(2) * hydro.rho;

    % Restoring
    static.K3 = hydro.C(3,3,1) * hydro.g * hydro.rho;
    static.K9 = hydro.C(3,3,2) * hydro.g * hydro.rho;

end
        
function motion = getDynamicModel(static, hydro, S)

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

    % Ignore tails of the spectra; return indicies of the 
    % vals>1% of max
    iSpec = find(S.S > 0.01*max(S.S));

    % Return column vector of all w between first/last indicies
    iStart = min(iSpec);
    iEnd   = max(iSpec);
    iSkip  = 1;
    w = S.w(iStart:iSkip:iEnd);

    % Calculate w step-size
    if length(iSpec) == 1
        dw = wStep;    
    else    
        dw = mean(diff(S.w))*iSkip;   
    end

    % Get column vector S at same indicies as w (Removed 
    % interpolation). 
    s = S.S(iStart:iSkip:iEnd);

    % TODO: is interp needed?
    % s = interp1(S.w(:), S.S, w,'linear',0);
    % Calculate wave amplitude
    waveAmp = sqrt(2 * dw * s);

    % Row vector of random phases?
    ph = rand(length(s), 1);

    % Wave height in frequency domain
    eta_fd = waveAmp .* exp(1i*ph);
    eta_fd = eta_fd(:);

    % Radiation impedance matrix: B + iwA
    % A: Added Mass
    % B: Damping 
    B99 = interp_rad(hydro, 9, 9, w) * hydro.rho .* w;
    A99 = interp_mass(hydro, 9, 9, w) * hydro.rho;

    B39 = (interp_rad(hydro, 3, 9, w) + ...
                interp_rad(hydro, 9, 3, w)) / 2 * hydro.rho .* w;
    A39 = (interp_mass(hydro, 3, 9, w) + ...
                interp_mass(hydro, 9, 3, w)) / 2 * hydro.rho;

    B33 = interp_rad(hydro, 3, 3, w) * hydro.rho .* w;
    A33 = interp_mass(hydro, 3, 3, w) * hydro.rho;

    % Excitation
    H3 = interp_ex(hydro, 3, w) * hydro.g * hydro.rho;
    H9 = interp_ex(hydro, 9, w) * hydro.g * hydro.rho;

    % Excitation Forces
    E3 = H3 .* eta_fd;
    E9 = H9 .* eta_fd;

    % friction
    % Add some friction proportional to the max radiation damping 
    % term
    Bf = max(B33) * 0.1;

    % Calculate Impedance
    Z3 = B33 + Bf + 1i * ( ...
                w .* (static.mass1 + A33) - static.K3 ./ w);
    Z9 = B99 + Bf + 1i * ( ...
                w .* (static.mass2 + A99) - static.K9 ./ w);

    % Hydrodynamic radiation coupling between the two bodies 
    % [Falnes 1999].       
    Zc = B39 + 1i * w .* A39;

    % External Impedance
    Z0 = Z3 + Z9 + 2*Zc;

    % Intrinsic Impedance
    Zi = (Z3.*Z9 - Zc.^2) ./ Z0;

    % Excitation Force
    F0 = (E3.*(Z9+Zc) - E9 .* (Z3 + Zc)) ./ Z0;

    dynamic.w = w;
    dynamic.dw = dw;
    dynamic.wave_amp = waveAmp;
    dynamic.ph = ph;
    dynamic.B99 = B99;
    dynamic.A99 = A99;
    dynamic.B39 = B39;
    dynamic.A39 = A39;
    dynamic.B33 = B33;
    dynamic.A33 = A33;
    dynamic.H3 = H3;
    dynamic.H9 = H9;
    dynamic.E3 = E3;
    dynamic.E9 = E9;
    dynamic.Bf = Bf;
    dynamic.Z3 = Z3;
    dynamic.Z9 = Z9;
    dynamic.Zc = Zc;
    dynamic.Z0 = Z0;
    dynamic.Zi = Zi;
    dynamic.F0 = F0;
    
    % Merge in static
    fn = fieldnames(static);
    for i = 1:length(fn)
       dynamic.(fn{i}) = static.(fn{i});
    end
    
    motion = WecOptTool.types("Motion", dynamic);

end


function performance = complexCongugateControl(motion)
            
    % Maximum absorbed power
    % Note: Re{Zi} = Radiation Damping Coeffcient
    out.powPerFreq = abs(motion.F0) .^ 2 ./ (8 * real(motion.Zi));
    
    performance = WecOptTool.types("Performance", out);

end

function performance = dampingControl(motion)
            
    % Max Power for a given Damping Coeffcient [Falnes 2002 
    % (p.51-52)]
    P_max = @(b) -0.5 * b *     ...
                    sum(abs(motion.F0 ./ (motion.Zi + b)) .^ 2);

    % Optimize the linear damping coeffcient(B)
    B_opt = fminsearch(P_max, max(real(motion.Zi)));

    % Power per frequency at optimial damping?
    out.powPerFreq = 0.5 * B_opt * ...
                    (abs(motion.F0 ./ (motion.Zi + B_opt)) .^ 2);
                
    performance = WecOptTool.types("Performance", out);

end

function performance = pseudoSpectralControl(motion,        ...
                                             delta_Zmax,    ...
                                             delta_Fmax)

    % PSEUDOSPECTRAL Pseudo spectral control
    %   Returns power per frequency and frequency bins
    
    motion = struct(motion);
        
    % Fix random seed <- Do we want this???
    rng(1);
    
    % Reformulate equations of motion
    motion = getPSCoefficients(motion, delta_Zmax, delta_Fmax);
    
    % Add phase realizations
    n_ph_avg = 5;
    ph_mat = 2 * pi * rand(length(motion.w), n_ph_avg); 
    n_ph = size(ph_mat, 2);
    
    freq = motion.W;
    n_freqs = length(freq);
    powPerFreqMat = zeros(n_ph, n_freqs);
    
    for ind_ph = 1 : n_ph
        
        ph = ph_mat(:, ind_ph);
        [~, phasePowPerFreq] = getPSPhasePower(motion, ph);
        
        for ind_freq = 1 : n_freqs
            powPerFreqMat(ind_ph, ind_freq) = phasePowPerFreq(ind_freq);
        end
        
    end
    
    out.powPerFreq = mean(powPerFreqMat);
    performance = WecOptTool.types("Performance", out);
    
end

function motion = getPSCoefficients(motion, delta_Zmax, delta_Fmax)
    %PSCOEFFICIENTS
    % Bacelli 2014: Background Chapter 4.1, 4.2; RM3 in section 6.1
    % Number of frequency - half the number of fourier coefficients

    Nf = length(motion.w);
    % Collocation points uniformly distributed btween 0 and T
    Nc = (2*Nf) + 2;

    % Frequency vector (re-build)
    w0 = motion.dw;
    T = 2*pi/w0;
    W = motion.w(1)+w0*(0:Nf-1)';

    % Building cost function
    H = [0, 0, 1; 0, 0, -1; 1, -1, 0];
    H_mat = 0.5 * kron(H, eye(2*Nf));

    % Building matrices B33 and A33
    Adiag33 = zeros(2*Nf-1,1);
    Bdiag33 = zeros(2*Nf,1);

    Adiag33(1:2:end) = W.* motion.A33;
    Bdiag33(1:2:end) = motion.B33;
    Bdiag33(2:2:end) = Bdiag33(1:2:end);

    Bmat = diag(Bdiag33);
    Amat = diag(Adiag33,1);
    Amat = Amat - Amat';

    G33 = (Amat + Bmat);

    % Building matrices B39 and A39
    Adiag39 = zeros(2*Nf-1,1);
    Bdiag39 = zeros(2*Nf,1);

    Adiag39(1:2:end) = W.* motion.A39;
    Bdiag39(1:2:end) = motion.B39;
    Bdiag39(2:2:end) = Bdiag39(1:2:end);

    Bmat = diag(Bdiag39);
    Amat = diag(Adiag39,1);
    Amat = Amat - Amat';

    G39 = (Amat + Bmat);

    % Building matrices B99 and A99
    Adiag99 = zeros(2*Nf-1,1);
    Bdiag99 = zeros(2*Nf,1);

    Adiag99(1:2:end) = W.* motion.A99;
    Bdiag99(1:2:end) = motion.B99;
    Bdiag99(2:2:end) = Bdiag99(1:2:end);

    Bmat = diag(Bdiag99);
    Amat = diag(Adiag99,1);
    Amat = Amat - Amat';

    G99 = (Amat + Bmat);

    G = [G33, G39;
         G39, G99];

    B = motion.Bf * eye(4*Nf);
    C = blkdiag(motion.K3 * eye(2*Nf), motion.K9 * eye(2*Nf));
    M = blkdiag(motion.mass1 * eye(2*Nf), motion.mass2 * eye(2*Nf));

    % Building derivative matrix
    d = [W(:)'; zeros(1, length(W))];
    Dphi1 = diag(d(1:end-1), 1);
    Dphi1 = (Dphi1 - Dphi1');
    Dphi = blkdiag(Dphi1, Dphi1);

    m_scale = (motion.mass1+motion.mass2)/2; % scaling factor for optimization

    % equality constraints for EOM
    P =  (M*Dphi + B + G + (C / Dphi)) / m_scale;
    Aeq = [P, -[eye(2*Nf); -eye(2*Nf)] ];

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

    B_ineq=[B_ineq; ones(siz(1),1) * delta_Fmax / m_scale];
    A_ineq=[A_ineq; kron([0 0 1; 0 0 -1], forc)];
    
    motion.Nf = Nf;
    motion.T = T;
    motion.W = W;
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

function [pow, powPerFreq] = getPSPhasePower(motion, ph)
    %Calculates power using the pseudospectral method given a phase and
    % a descrption of the body movement. Returns total phase power and 
    % power per frequency 
    
    function P = pow_calc(X)
        P = X' * motion.H_mat * X;
    end
    
    eta_fd = motion.wave_amp .* exp(1i*ph);
    %             eta_fd = eta_fd(start:end);
    
    fef3 = zeros(2*motion.Nf,1);
    fef9 = zeros(2*motion.Nf,1);
    
    E3 = motion.H3 .* eta_fd;
    E9 = motion.H9 .* eta_fd;
    
    fef3(1:2:end) =  real(E3);
    fef3(2:2:end) = -imag(E3);
    fef9(1:2:end) =  real(E9);
    fef9(2:2:end) = -imag(E9);
    
    Beq = [fef3; fef9] / motion.m_scale;
    
    % constrained optimiztion
    qp_options = optimoptions('fmincon',                        ...
                              'Algorithm', 'sqp',               ...
                              'Display', 'off',                 ...
                              'MaxIterations', 1e3,             ...
                              'MaxFunctionEvaluations', 1e5,    ...
                              'OptimalityTolerance', 1e-8,      ...
                              'StepTolerance', 1e-6);
    
    siz = size(motion.A_ineq);
    X0 = zeros(siz(2),1);
    [y, ~, ~, ~] = fmincon(@pow_calc,       ...
                           X0,              ...
                           motion.A_ineq,   ...
                           motion.B_ineq,   ...
                           motion.Aeq,      ...
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
    powPerFreq = powPerFreq * motion.m_scale;
    
    velT = motion.Phip' * [x1hat;x2hat];
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
    uT = motion.m_scale * motion.Phip1' * uhat;
    Pt = (velTBody2 - velTBody1) .* uT;
    pow = trapz(motion.tkp, Pt) / (motion.tkp(end) - motion.tkp(1));
    assert(WecOptLib.utils.isClose(pow, sum(powPerFreq)))
    
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

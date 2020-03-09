function [pow, etc] = RM3_getPow(S,                 ...
                                 controlType,       ...
                                 geomMode,          ...
                                 geomParams,        ...
                                 controlParams)
% pow = RM3_getPow(S, controlType, geomMode, ...)
%
% Top-level evaluation function for RM3 device.
%
% Inputs
%       S               wave spectra structure, with fields:
%           S.S         spectral energy distribution [m^2 s/rad]
%           S.w         frequency [rad/s]
%           S.ph        phasing
%           S.mu        weighting factor
%       controlType     choose control type for PTO:
%                           CC: complex conjugate (no constraints)
%                           PS: pseudo-spectral (with constraints)
%                           P: proportional damping
%       geomMode        choose mode for geometry definition; geometry
%                       inputs are passed in as string-value pairs, see
%                       RM3_getNemoh documentation for more info.
%                           scalar: single scaling factor lambda
%                           parametric: [r1, r2, d1, d2] parameters
%                           existing: pass existing NEMOH rundir
%       geomParams      contains parameters for the geometric mode
%       controlParams   if using the 'PS' control type, optional arguments for
%                       deltaZmax and deltaFmax
%                           Note: to use the optional arguments, both must
%                           be provided, otherwise the program will use
%                           default values of
%                               deltaZmax = 10
%                               deltaFmax = 1e9
% Outputs
%       pow             power weighted by weighting factors
%       etc             structure with two items, containing pow and the
%                       hydro struct from Nemoh
%
% Examples:
% 1) Using scalar input with CC control and scaling factor 1:
%
% S = bretschneider([],[8,10],0);
% [pow, etc] = RM3_getPow(S, 'CC', 'scalar', 1);
%
%
% 2) Using 'PS' control with optional deltaZmax and deltaFmax specified
%
% S = bretschneider([],[8,10],0);
%
% r1 = 10;       % radius of float
% r2 = 15;       % radius of sink
% d1 = 2;        % float depth
% d2 = 42;       % sink depth
%
% deltaZmax = 15;
% deltaFmax = 1e7;
%
% [pow, etc] = RM3_getPow(S, 'PS', 'parametric', [r1,r2,d1,d2], deltaZmax, deltaFmax);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% check inputs
if ~isfield(S,'mu')
    for ind_ss = 1:length(S)
        S(ind_ss).mu = 1;
    end
    if length(S) > 1
        warning('No weighting field mu in wave spectra structure S, setting to 1')
    end
end

% get the hydrodynamic FRFs
[hydro,rundir] = WecOptLib.volatile.RM3_getNemoh(geomMode, geomParams);

% find WEC performance
maxVals = [];

if strcmp(controlType, 'PS')
    if nargin == 5
        maxVals = controlParams;
    end
end

for ind_ss = 1:length(S) % TODO - consider parfor?
    pow_ss(ind_ss) = RM3_eval(S(ind_ss), hydro, controlType, maxVals);
end

% assemble output
mus = [S(:).mu];
pow = dot(pow_ss(:), mus(:)) / sum([S(:).mu]);

etc.pow = pow_ss;
etc.hydro = hydro;
etc.rundir = rundir;

end

function pow_ss = RM3_eval(S, hydro, controlType, maxVals)

if strcmp(controlType, 'PS') && length(maxVals) == 2
    delta_Zmax = maxVals(1);
    delta_Fmax = maxVals(2);
elseif strcmp(controlType, 'PS')
    warning('Using arbitrary position and PTO constraints (Zmax=10, Fmax=1e9)')
    delta_Zmax = 10;
    delta_Fmax = 1e9;
end

% if length(S.

ind_sp = find(S.S > 0.01*max(S.S));

if length(ind_sp) == 1
    start_ind = ind_sp;
    end_ind = ind_sp;
    w_skip = 1;
    w = S.w(start_ind:w_skip:end_ind);
    w = w(:);
    dw = w;
else
    start_ind = min(ind_sp);
    end_ind = max(ind_sp);
    w_skip = 1;
    w = S.w(start_ind:w_skip:end_ind);
    w = w(:);
    dw = mean(diff(S.w))*w_skip;
end

% [~, start_ind] = min(abs(hydro.w - S.w(find(S.S > 0.01*max(S.S), 1, 'first'))));
% [~, end_ind] = min(abs(hydro.w - S.w(find(S.S > 0.01*max(S.S), 1, 'last'))));


% w = hydro.w(start_ind:w_skip:end_ind);


S_interp = interp1(S.w(:), S.S, w,'linear',0);
wave_amp = sqrt(2 * dw * S_interp);
ph = rand(length(S_interp), 1);
eta_fd = wave_amp .* exp(1i*ph);
eta_fd = eta_fd(:);

% w = hydro.w(1:w_skip:w_max);
% w = w(:);
% dw = mean(diff(w));
%
% S_interp = interp1(S.w(:), S.S, w,'linear',0);
% wave_amp = sqrt(2 * dw * S_interp);
% start_ind = find(S_interp > 0.01, 1);
% ph = rand(length(S_interp), 1);
% eta_fd = wave_amp .* exp(1i*ph);
% eta_fd = eta_fd(start_ind:end);



% mass
mass1 = hydro.Vo(1) * hydro.rho;
mass2 = hydro.Vo(2) * hydro.rho;

% restoring
K3 = hydro.C(3,3,1) * hydro.g * hydro.rho;
K9 = hydro.C(3,3,2) * hydro.g * hydro.rho;

% radiation
B99 = interp1(hydro.w,squeeze(hydro.B(9, 9, :)),w,'linear',0) * hydro.rho .* w;
A99 = interp1(hydro.w,squeeze(hydro.A(9, 9, :)),w,'linear',0) * hydro.rho;

B39 = ((interp1(hydro.w,squeeze(hydro.B(3, 9, :)),w,'linear',0) + ...
    interp1(hydro.w,squeeze(hydro.B(9, 3, :)),w,'linear',0)) ./ 2) * hydro.rho .* w;
A39 = ((interp1(hydro.w,squeeze(hydro.A(3, 9, :)),w,'linear',0) + ...
    interp1(hydro.w,squeeze(hydro.A(9, 3, :)),w,'linear',0)) ./ 2) * hydro.rho;

B33 = squeeze(interp1(hydro.w,squeeze(hydro.B(3, 3, :)),w,'linear',0)) * hydro.rho .* w;
A33 = squeeze(interp1(hydro.w,squeeze(hydro.B(3, 3, :)),w,'linear',0)) * hydro.rho;

% excitation
H3 = interp1(hydro.w,complex(squeeze(hydro.ex_re(3, 1, :)), ...
    squeeze(hydro.ex_im(3, 1, :))),w,'linear',0)...
    * hydro.g * hydro.rho;
H9 = interp1(hydro.w,complex(squeeze(hydro.ex_re(9, 1, :)), ...
    squeeze(hydro.ex_im(9, 1, :))),w,'linear',0)...
    * hydro.g * hydro.rho;

% friction
Bf = max(B33) * 0.1;

D3 = 0;
D9 = 0;

E3 = H3 .* eta_fd;
E9 = H9 .* eta_fd;

switch controlType
    case 'CC'
        [pow_ss] = cc();
        
    case 'P'
        [pow_ss] = damping();
        
    case 'PS'
        [pow_ss] = ps();
end

    function [pow_ss] = cc()
        Z3 = B33 + D3 + Bf + 1i*(w.*(mass1 + A33) - K3./w);
        Z9 = B99 + D9 + Bf + 1i*(w.*(mass2 + A99) - K9./w);
        Zc = B39 + 1i * w .* A39;
        
        
        Z0 = Z3 + Z9 + 2*Zc;
        Zi = (Z3.*Z9 - Zc.^2) ./ Z0;
        
        F0 = (E3.*(Z9+Zc) - E9.*(Z3+Zc))./Z0;
        Pabs = abs(F0).^2 ./ (8* real(Zi));
        Ur = F0 ./ (2 * real(Zi));
        Sr = -1i * Ur ./ w;
        Fl = conj(Zi) .* Ur;
        
        tkp = linspace(0, 2*pi/(mean(diff(w))), 4*(length(w)));
        
        exp_mat = exp(1i * w * tkp);
        srt = real(Sr .' * exp_mat);
        urt = real(Ur .' * exp_mat);
        Flt = real(Fl .' * exp_mat);
        
        pow_ss = -1 * sum(Pabs);
    end

    function [pow_ss] = damping()
        Z3 = B33 + D3 + Bf + 1i*(w.*(mass1 + A33) - K3./w);
        Z9 = B99 + D9 + Bf + 1i*(w.*(mass2 + A99) - K9./w);
        Zc = B39 + 1i * w .* A39;
        
        Z0 = Z3 + Z9 + 2*Zc;
        Zi = (Z3.*Z9 - Zc.^2) ./ Z0;
        
        F0 = (E3.*(Z9+Zc) - E9.*(Z3+Zc))./Z0;
        
        Ur = F0 ./ (2 * real(Zi));
        Sr = -1i * Ur ./ w;
        Fl = conj(Zi) .* Ur;
        
        tkp = linspace(0, 2*pi/(mean(diff(w))), 4*(length(w)));
        
        P_max = @(b) -0.5*b*sum(abs(F0./(Zi+b)).^2);
        
        B_opt = fminsearch(P_max, max(real(Zi)));
        
        Pabs = 0.5*B_opt *(abs(F0 ./ (Zi + B_opt)).^2);
        
        exp_mat = exp(1i * w * tkp);
        srt = real(Sr .' * exp_mat);
        urt = real(Ur .' * exp_mat);
        Flt = real(Fl .' * exp_mat);
        
        pow_ss=-1 * sum(Pabs);
    end

    function [pow_ss] = ps()
        % Number of frequency - half the number of fourier coefficients
        Nf = length(w);
        % Collocation points uniformly distributed btween 0 and T
        Nc = (2*Nf) + 2;
        
        % Frequency vector (re-build)
        w0 = dw;
        T = 2*pi/w0;
        W = w(1)+w0*(0:Nf-1)';
        
        % Building cost function
        H = [0, 0, 1; 0, 0, -1; 1, -1, 0];
        H_mat = 0.5 * kron(H, eye(2*Nf));
        
        
        % Building matrices B33 and A33 ******************
        Adiag33 = zeros(2*Nf-1,1);
        Bdiag33 = zeros(2*Nf,1);
        
        Adiag33(1:2:end) = W.* A33;
        Bdiag33(1:2:end) = B33;
        Bdiag33(2:2:end) = Bdiag33(1:2:end);
        
        Bmat = diag(Bdiag33);
        Amat = diag(Adiag33,1);
        Amat = Amat - Amat';
        
        G33 = (Amat + Bmat);
        
        % Building matrices B39 and A39 ******************
        Adiag39 = zeros(2*Nf-1,1);
        Bdiag39 = zeros(2*Nf,1);
        
        Adiag39(1:2:end) = W.* A39;
        Bdiag39(1:2:end) = B39;
        Bdiag39(2:2:end) = Bdiag39(1:2:end);
        
        Bmat = diag(Bdiag39);
        Amat = diag(Adiag39,1);
        Amat = Amat - Amat';
        
        G39 = (Amat + Bmat);
        
        % Building matrices B99 and A99 ******************
        Adiag99 = zeros(2*Nf-1,1);
        Bdiag99 = zeros(2*Nf,1);
        
        Adiag99(1:2:end) = W.* A99;
        Bdiag99(1:2:end) = B99;
        Bdiag99(2:2:end) = Bdiag99(1:2:end);
        
        Bmat = diag(Bdiag99);
        Amat = diag(Adiag99,1);
        Amat = Amat - Amat';
        
        G99 = (Amat + Bmat);
        
        G = [G33, G39;
             G39, G99];
        
        B = Bf * eye(4*Nf);
        C = blkdiag(K3 * eye(2*Nf), K9 * eye(2*Nf));
        M = blkdiag(mass1 * eye(2*Nf), mass2 * eye(2*Nf));
        
        % Building derivative matrix
        d = [W(:)'; zeros(1, length(W))];
        Dphi1 = diag(d(1:end-1), 1);
        Dphi1 = (Dphi1 - Dphi1');
        Dphi = blkdiag(Dphi1, Dphi1);
        
        m_scale = (mass1+mass2)/2; % scaling factor for optimization
        
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
        
        B_ineq=[B_ineq; ones(siz(1),1) * delta_Fmax/m_scale];
        A_ineq=[A_ineq; kron([0 0 1; 0 0 -1], forc)];
        
        %         spy(G99,'r')
        
        %% optimization
        n_ph_avg = 5; % number of phase realizations to average
        rng(1); % for consistency and allow to debug
        ph_mat = 2*pi*rand(length(w), n_ph_avg); % add phase realization
        n_ph = size(ph_mat, 2);
        %n_ph =1;
        Pt_mat = zeros(n_ph, 1);
        
        for ind_ph = 1: n_ph
            
            ph = ph_mat(:, ind_ph);
            eta_fd = wave_amp .* exp(1i*ph);
            %             eta_fd = eta_fd(start:end);
            
            fef3 = zeros(2*Nf,1);
            fef9 = zeros(2*Nf,1);
            
            E3 = H3 .* eta_fd;
            E9 = H9 .* eta_fd;
            
            fef3(1:2:end) =  real(E3);
            fef3(2:2:end) = -imag(E3);
            fef9(1:2:end) =  real(E9);
            fef9(2:2:end) = -imag(E9);
            
            Beq = [fef3; fef9] / m_scale;
            
            qp_options = optimoptions(@fmincon,...
                'Algorithm', 'sqp',...
                'Display', 'off',...
                'MaxIterations', 1e3,...
                'MaxFunctionEvaluations', 1e5,...
                'OptimalityTolerance', 1e-8,...
                'StepTolerance', 1e-6);
            
            X0 = zeros(siz(2),1);
            [y, fval, exitflag, output] = fmincon(@pow_calc, X0 , A_ineq, B_ineq, Aeq, Beq,...
                [], [], [], qp_options); % constrained optimiztion
            
            velT = Phip'*y(1:2*end/3);
            posT = (Phip' / Dphi)*y(1:2*end/3);
            relPosT = posT(1:end/2)- posT(end/2+1:end); % relative position (check constraint satisfaction)
            relVelT = velT(1:end/2)- velT(end/2+1:end); % relative velocity (check constraint satisfaction)
            
            uT = m_scale *Phip1'*y(1+2*end/3 : end);
            Pt = (velT(1:end/2)- velT(end/2+1:(end/2)*2)) .*  uT ;
            
            Pt_mat(ind_ph) = trapz(tkp, Pt) / (tkp(end) - tkp(1));
            
        end
    
        pow_ss = mean(Pt_mat);
        
        function P = pow_calc(X)
            
            P = X' * H_mat * X;
            
        end
    end

end

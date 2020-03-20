function motion = getPSCoefficients(motion)
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
    B_ineq = ones(size(A_ineq, 1),1) * motion.delta_Zmax;

    %force constraint section
    siz = size(A_ineq);
    forc =  Phip1';

    B_ineq=[B_ineq; ones(siz(1),1) * motion.delta_Fmax/m_scale];
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


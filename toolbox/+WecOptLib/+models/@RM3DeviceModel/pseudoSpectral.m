function [pow_ss] = pseudoSpectral(obj, RM3)
    % Number of frequency - half the number of fourier coefficients
    Nf = length(RM3.w);
    % Collocation points uniformly distributed btween 0 and T
    Nc = (2*Nf) + 2;

    % Frequency vector (re-build)
    w0 = RM3.dw;
    T = 2*pi/w0;
    W = RM3.w(1)+w0*(0:Nf-1)';

    % Building cost function
    H = [0, 0, 1; 0, 0, -1; 1, -1, 0];
    H_mat = 0.5 * kron(H, eye(2*Nf));


    % Building matrices B33 and A33 ******************
    Adiag33 = zeros(2*Nf-1,1);
    Bdiag33 = zeros(2*Nf,1);

    Adiag33(1:2:end) = W.* RM3.A33;
    Bdiag33(1:2:end) = RM3.B33;
    Bdiag33(2:2:end) = Bdiag33(1:2:end);

    Bmat = diag(Bdiag33);
    Amat = diag(Adiag33,1);
    Amat = Amat - Amat';

    G33 = (Amat + Bmat);

    % Building matrices B39 and A39 ******************
    Adiag39 = zeros(2*Nf-1,1);
    Bdiag39 = zeros(2*Nf,1);

    Adiag39(1:2:end) = W.* RM3.A39;
    Bdiag39(1:2:end) = RM3.B39;
    Bdiag39(2:2:end) = Bdiag39(1:2:end);

    Bmat = diag(Bdiag39);
    Amat = diag(Adiag39,1);
    Amat = Amat - Amat';

    G39 = (Amat + Bmat);

    % Building matrices B99 and A99 ******************
    Adiag99 = zeros(2*Nf-1,1);
    Bdiag99 = zeros(2*Nf,1);

    Adiag99(1:2:end) = W.* RM3.A99;
    Bdiag99(1:2:end) = RM3.B99;
    Bdiag99(2:2:end) = Bdiag99(1:2:end);

    Bmat = diag(Bdiag99);
    Amat = diag(Adiag99,1);
    Amat = Amat - Amat';

    G99 = (Amat + Bmat);

    G = [G33, G39;
         G39, G99];

    B = RM3.Bf * eye(4*Nf);
    C = blkdiag(RM3.K3 * eye(2*Nf), RM3.K9 * eye(2*Nf));
    M = blkdiag(RM3.mass1 * eye(2*Nf), RM3.mass2 * eye(2*Nf));

    % Building derivative matrix
    d = [W(:)'; zeros(1, length(W))];
    Dphi1 = diag(d(1:end-1), 1);
    Dphi1 = (Dphi1 - Dphi1');
    Dphi = blkdiag(Dphi1, Dphi1);

    m_scale = (RM3.mass1+RM3.mass2)/2; % scaling factor for optimization

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
    B_ineq = ones(size(A_ineq, 1),1) * RM3.delta_Zmax;

    %force constraint section
    siz = size(A_ineq);
    forc =  Phip1';

    B_ineq=[B_ineq; ones(siz(1),1) * RM3.delta_Fmax/m_scale];
    A_ineq=[A_ineq; kron([0 0 1; 0 0 -1], forc)];

    %         spy(G99,'r')

    %% optimization
    n_ph_avg = 5; % number of phase realizations to average
    rng(1); % for consistency and allow to debug
    ph_mat = 2*pi*rand(length(RM3.w), n_ph_avg); % add phase realization
    n_ph = size(ph_mat, 2);
    %n_ph =1;
    Pt_mat = zeros(n_ph, 1);

    for ind_ph = 1: n_ph

        ph = ph_mat(:, ind_ph);
        eta_fd = RM3.wave_amp .* exp(1i*ph);
        %             eta_fd = eta_fd(start:end);

        fef3 = zeros(2*Nf,1);
        fef9 = zeros(2*Nf,1);

        E3 = RM3.H3 .* eta_fd;
        E9 = RM3.H9 .* eta_fd;

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

        % y is a vector of x1hat, x2hat, & uhat. Calculate energy using 
        %    Equation 6.11 of Bacelli 2014
        x1hat = y(1:end/3);
        x2hat = y(end/3+1:2*end/3);
        uhat = y(2*end/3+1:end);
        J = -T/2*(x1hat - x2hat).*uhat;
        % Add the sin and cos components to get power as function of W      
        P = J(1:2:end) + J(2:2:end);  %    See Parseval's Theorem
        plot(W,P)
        
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
classdef RM3 < WecOptLib.experimental.Blueprint
    
    properties
        
        geometryCallbacks = struct(                                     ...
            'existing',                                                 ...
              @WecOptLib.experimental.callbacks.geometry.existingNEMOH, ...
            'scalar', @getHydroScalar,                                  ...
            'parametric', @getHydroParametric)
        
        staticModelCallback = @getStaticModel
        dynamicModelCallback = @getDynamicModel
        
        controllerCallbacks = struct('CC', @complexCongugateControl,    ...
                                     'P',  @dampingControl)
                                 
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
    
    hydro = WecOptLib.experimental.types("Hydro", hydro);
           
end


function hydro = getHydroParametric(folder, r1, r2, d1, d2, S, freqStep)
                    
    w = WecOptLib.utils.seaStatesGlobalW(S, freqStep);
               
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
    
    meshes = WecOptLib.experimental.mesh("AxiMesh",    ...
                                         folder,       ...
                                         rf,           ...
                                         zf,           ...
                                         ntheta,       ...
                                         nfobj,        ...
                                         zG,           ...
                                         1);
    meshes(2) = WecOptLib.experimental.mesh("AxiMesh",  ...
                                            folder,     ...
                                            rf,         ...
                                            zf,         ...
                                            ntheta,     ...
                                            nfobj,      ...
                                            zG,         ...
                                            2);
    
    hydro = WecOptLib.experimental.solver("NEMOH", folder, meshes, w);
           
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
    
    motion = WecOptLib.experimental.types("Motion", dynamic);

end


function performance = complexCongugateControl(motion, S)
            
    % Maximum absorbed power
    % Note: Re{Zi} = Radiation Damping Coeffcient
    out.powPerFreq = abs(motion.F0) .^ 2 ./ (8 * real(motion.Zi));
    
    performance = WecOptLib.experimental.types("Performance", out);

end

function performance = dampingControl(motion, S)
            
    % Max Power for a given Damping Coeffcient [Falnes 2002 
    % (p.51-52)]
    P_max = @(b) -0.5 * b *     ...
                    sum(abs(motion.F0 ./ (motion.Zi + b)) .^ 2);

    % Optimize the linear damping coeffcient(B)
    B_opt = fminsearch(P_max, max(real(motion.Zi)));

    % Power per frequency at optimial damping?
    out.powPerFreq = 0.5 * B_opt * ...
                    (abs(motion.F0 ./ (motion.Zi + B_opt)) .^ 2);
                
    performance = WecOptLib.experimental.types("Performance", out);

end

function out = aggregate(seastate, hydro, motions, performances)
    s = struct(seastate);
    p = struct(performances);
    out.pow = dot([p.pow], [s.mu]) / sum([s.mu]);
end

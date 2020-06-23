classdef WaveBot < WecOptTool.Blueprint
    
    properties
        
        geometryCallbacks = struct(                                     ...
            'existing', @WecOptTool.callbacks.geometry.existingNEMOH,   ...
            'scalar', @getHydroScalar,                                  ...
            'parametric', @getHydroParametric)
        
        staticModelCallback = @getStaticModel
        dynamicModelCallback = @getDynamicModel
        
        controllerCallbacks = struct('CC', @complexCongugateControl,    ...
                                     'P',  @dampingControl)
                                 
        aggregationHook = @aggregate
        
    end
    
end

function hydro = getHydroScalar(folder, lambda, S, freqStep)
    
    S = struct(S);
    w = WecOptLib.utils.seaStatesGlobalW(S, freqStep);
               
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


function static = getStaticModel(hydro)
            
    % Mass
    static.mass = hydro.Vo * hydro.rho;

    % Restoring
    static.K = hydro.C(3,3) * hydro.g * hydro.rho;

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
    
    % radiation damping FRF
    B = interp_rad(hydro, 3, 3, w) * hydro.rho .* w;

    % added mass FRF
    A = interp_mass(hydro, 3, 3, w) * hydro.rho;

    % friction
    Bf = max(B) * 0.1;

    % intrinsic impedance
    Zi = B + Bf + 1i * (w .* (static.mass + A) - static.K ./ w);

    % Excitation Forces
    H = interp_ex(hydro, 3, w) * hydro.g * hydro.rho;
    F0 = H .* eta_fd;

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
    
    % Merge in static
    fn = fieldnames(static);
    for i = 1:length(fn)
       dynamic.(fn{i}) = static.(fn{i});
    end
    
    motion = WecOptTool.types("Motion", dynamic);

end


function performance = complexCongugateControl(motion)
            
    Zpto = conj(motion.Zi);
    
    out.u = motion.F0 ./ (Zpto + motion.Zi);
    out.Fpto = -Zpto .* out.u;
    out.powPerFreq = -real(0.5 * out.Fpto .* conj(out.u));
    
    performance = WecOptTool.types("Performance", out);

end

function performance = dampingControl(motion)
            
   P_max = @(b) -0.5*b*sum(abs(motion.F0 ./ ...
                                (motion.Zi + b)).^2);
                            
    % solve for damping to produce most power (can do analytically for a 
    % single frequency, but must use numerical solution for spectrum).
    % Note that fval is the sum of power absorbed (negative being "good") 
    % - the following should be true: -1 * fval = sum(pow), where pow is 
    %the frequency dependent array calculated below.
    [B_opt, ~] = fminsearch(P_max, max(real(motion.Zi)));

    % PTO impedance
    Zpto = complex(B_opt * ones(size(motion.Zi)),0);
    
    out.u = motion.F0 ./ (Zpto + motion.Zi);
    out.Fpto = -Zpto .* out.u;
    out.powPerFreq = -real(0.5 * out.Fpto .* conj(out.u));
                
    performance = WecOptTool.types("Performance", out);

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

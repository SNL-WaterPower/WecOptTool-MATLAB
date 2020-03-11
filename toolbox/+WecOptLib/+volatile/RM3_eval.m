function pow_ss = RM3_eval(S, hydro, controlType, maxVals)
% pow_ss = RM3_eval(S, hydro, controlType, geomMode, maxVals)
%
% Returns one Sea-state power given spectra, BEM response, geomMode,
%    and the max vals
%
% Inputs
%       S               wave spectra structure, with fields:
%           S.S         spectral energy distribution [m^2 s/rad]
%           S.w         frequency [rad/s]
%           S.ph        phasing
%           S.mu        weighting factor
%       hydro           hydro struct from Nemoh
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
%       controlParams   if using the 'PS' control type, optional arguments 
%                       for deltaZmax and deltaFmax
%                           Note: to use the optional arguments, both must
%                           be provided, otherwise the program will use
%                           default values of
%                               deltaZmax = 10
%                               deltaFmax = 1e9
% Outputs
%       pow_ss           power weighted by weighting factors
%
% Examples:
% 1) Using scalar input with CC control and scaling factor 1:
%  WecOptLib.volatile.RM3_eval(S, hydro, controlType, maxVals);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(controlType, 'PS') && length(maxVals) == 2
    delta_Zmax = maxVals(1);
    delta_Fmax = maxVals(2);
    RM3.delta_Zmax = delta_Zmax;
    RM3.delta_Fmax = delta_Fmax;
elseif strcmp(controlType, 'PS')
    warning('Using arbitrary position and PTO constraints (Zmax=10, Fmax=1e9)')
    delta_Zmax = 10;
    delta_Fmax = 1e9;
    RM3.delta_Zmax = delta_Zmax;
    RM3.delta_Fmax = delta_Fmax;
end



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


RM3.w = w;
RM3.dw = dw;
% Only for PS
RM3.wave_amp = wave_amp;
RM3.ph = ph;

% mass
RM3.mass1 = hydro.Vo(1) * hydro.rho;
RM3.mass2 = hydro.Vo(2) * hydro.rho;

% restoring
RM3.K3 = hydro.C(3,3,1) * hydro.g * hydro.rho;
RM3.K9 = hydro.C(3,3,2) * hydro.g * hydro.rho;

% radiation
RM3.B99 = interp1(hydro.w,squeeze(hydro.B(9, 9, :)),w,'linear',0) * hydro.rho .* w;
RM3.A99 = interp1(hydro.w,squeeze(hydro.A(9, 9, :)),w,'linear',0) * hydro.rho;

RM3.B39 = ((interp1(hydro.w,squeeze(hydro.B(3, 9, :)),w,'linear',0) + ...
    interp1(hydro.w,squeeze(hydro.B(9, 3, :)),w,'linear',0)) ./ 2) * hydro.rho .* w;
RM3.A39 = ((interp1(hydro.w,squeeze(hydro.A(3, 9, :)),w,'linear',0) + ...
    interp1(hydro.w,squeeze(hydro.A(9, 3, :)),w,'linear',0)) ./ 2) * hydro.rho;

RM3.B33 = squeeze(interp1(hydro.w,squeeze(hydro.B(3, 3, :)),w,'linear',0)) * hydro.rho .* w;
RM3.A33 = squeeze(interp1(hydro.w,squeeze(hydro.B(3, 3, :)),w,'linear',0)) * hydro.rho;

% excitation
RM3.H3 = interp1(hydro.w,complex(squeeze(hydro.ex_re(3, 1, :)), ...
    squeeze(hydro.ex_im(3, 1, :))),w,'linear',0)...
    * hydro.g * hydro.rho;
RM3.H9 = interp1(hydro.w,complex(squeeze(hydro.ex_re(9, 1, :)), ...
    squeeze(hydro.ex_im(9, 1, :))),w,'linear',0)...
    * hydro.g * hydro.rho;

% friction
RM3.Bf = max(RM3.B33) * 0.1;

RM3.D3 = 0;
RM3.D9 = 0;

RM3.E3 = RM3.H3 .* eta_fd;
RM3.E9 = RM3.H9 .* eta_fd;

switch controlType
    case 'CC'
        [pow_ss] = WecOptLib.volatile.complexConjugate(RM3);
        
    case 'P'
        [pow_ss] = WecOptLib.volatile.damping(RM3);
        
    case 'PS'
        [pow_ss] = WecOptLib.volatile.ps(RM3);
end

end

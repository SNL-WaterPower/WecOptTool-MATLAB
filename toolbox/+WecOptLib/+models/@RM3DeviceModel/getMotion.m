function RM3 = getMotion(obj, S, hydro, controlType, maxVals)
% pow_ss = getMotion(S, hydro, controlType, geomMode, maxVals)
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
%                           be provided
% Outputs
%       pow_ss           power weighted by weighting factors
%
% Examples:
% 1) Using scalar input with CC control and scaling factor 1:
%  WecOptLib.volatile.buildRM3(S, hydro, controlType, maxVals);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set max values for PS control
if strcmp(controlType, 'PS') && length(maxVals) == 2
    delta_Zmax = maxVals(1);
    delta_Fmax = maxVals(2);
    RM3.delta_Zmax = delta_Zmax;
    RM3.delta_Fmax = delta_Fmax;
end

% Ignore tails of the spectra; return indicies of the vals>1% of max
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

% Get column vector S at same indicies as w (Removed interpolation). 
s = S.S(iStart:iSkip:iEnd);
% TODO: is interp needed? %s = interp1(S.w(:), S.S, w,'linear',0);
% Calculate wave amplitude
waveAmp = sqrt(2 * dw * s);
% Row vector of random phases?
ph = rand(length(s), 1);
eta_fd = waveAmp .* exp(1i*ph);
eta_fd = eta_fd(:);

% Save the frequency
RM3.w = w;
RM3.dw = dw;
% Only for PS
RM3.wave_amp = waveAmp;
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

end
